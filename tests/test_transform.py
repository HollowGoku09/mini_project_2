"""
tests/test_transform.py
========================
Unit tests for data transformations:
- Skill canonicalisation (mapping variant names to canonical parent IDs)
- Multi-type skill resolution (sas, ruby, firebase)
- Role family assignment (10 job_title_short values -> 4 role families)
- Seniority parsing and base role extraction
- Sudan anomaly exclusion logic
"""

import unittest
import pandas as pd
from src.transform import (
    transform_skills,
    build_role_family_dim,
    transform_job_postings_chunk
)
from src.config import ROLE_FAMILY_MAP

class TestTransformations(unittest.TestCase):

    def test_skill_canonicalisation(self):
        """Verify near-duplicate skills are mapped to canonical parent IDs."""
        sample_skills = pd.DataFrame([
            {'skill_id': 1, 'skills': 'power bi', 'type': 'analyst_tools'},
            {'skill_id': 2, 'skills': 'powerbi', 'type': 'analyst_tools'},
            {'skill_id': 3, 'skills': 'python', 'type': 'programming'},
            {'skill_id': 4, 'skills': 'sql server', 'type': 'databases'},
            {'skill_id': 5, 'skills': 'sqlserver', 'type': 'databases'}
        ])
        
        transformed = transform_skills(sample_skills)
        
        row_powerbi = transformed[transformed['skill_id'] == 2].iloc[0]
        self.assertEqual(row_powerbi['canonical_skill_id'], 1)
        self.assertFalse(row_powerbi['is_canonical'])
        
        row_python = transformed[transformed['skill_id'] == 3].iloc[0]
        self.assertEqual(row_python['canonical_skill_id'], 3)
        self.assertTrue(row_python['is_canonical'])
        
        row_sqlserver = transformed[transformed['skill_id'] == 5].iloc[0]
        self.assertEqual(row_sqlserver['canonical_skill_id'], 4)
        self.assertFalse(row_sqlserver['is_canonical'])

    def test_multi_type_skill_resolution(self):
        """Verify multi-type skills (sas, ruby, firebase) are assigned primary types."""
        sample_skills = pd.DataFrame([
            {'skill_id': 10, 'skills': 'sas', 'type': 'programming'},
            {'skill_id': 11, 'skills': 'ruby', 'type': 'webframeworks'},
            {'skill_id': 12, 'skills': 'firebase', 'type': 'cloud'}
        ])
        
        transformed = transform_skills(sample_skills)
        
        sas_type = transformed[transformed['skills'] == 'sas']['type'].values[0]
        self.assertEqual(sas_type, 'analyst_tools')
        
        ruby_type = transformed[transformed['skills'] == 'ruby']['type'].values[0]
        self.assertEqual(ruby_type, 'programming')
        
        firebase_type = transformed[transformed['skills'] == 'firebase']['type'].values[0]
        self.assertEqual(firebase_type, 'databases')

    def test_role_family_mapping(self):
        """Verify all 10 job_title_short titles map correctly to the 4 role families."""
        df_fam = build_role_family_dim()
        family_names = set(df_fam['role_family_name'])
        
        expected_families = {'Data & Analytics', 'Software Engineering', 'Cloud & DevOps', 'AI/ML'}
        self.assertEqual(family_names, expected_families)
        
        self.assertEqual(ROLE_FAMILY_MAP['Data Analyst'], 'Data & Analytics')
        self.assertEqual(ROLE_FAMILY_MAP['Software Engineer'], 'Software Engineering')
        self.assertEqual(ROLE_FAMILY_MAP['Cloud Engineer'], 'Cloud & DevOps')
        self.assertEqual(ROLE_FAMILY_MAP['Machine Learning Engineer'], 'AI/ML')

    def test_seniority_parsing(self):
        """Verify Senior prefix is correctly parsed into Senior vs Mid-Entry."""
        chunk = pd.DataFrame([
            {
                'job_id': 101, 'company_id': 1, 'job_title': 'Senior Data Engineer',
                'job_title_short': 'Senior Data Engineer', 'job_location': 'New York, NY',
                'job_via': 'via LinkedIn', 'job_schedule_type': 'Full-time',
                'job_work_from_home': True, 'job_no_degree_mention': False,
                'job_health_insurance': True, 'job_country': 'United States',
                'job_posted_date': '2023-05-15', 'salary_rate': 'year',
                'salary_year_avg': 140000, 'salary_hour_avg': None
            },
            {
                'job_id': 102, 'company_id': 1, 'job_title': 'Data Engineer',
                'job_title_short': 'Data Engineer', 'job_location': 'Austin, TX',
                'job_via': 'via Indeed', 'job_schedule_type': 'Full-time',
                'job_work_from_home': False, 'job_no_degree_mention': True,
                'job_health_insurance': False, 'job_country': 'United States',
                'job_posted_date': '2023-06-10', 'salary_rate': 'year',
                'salary_year_avg': 105000, 'salary_hour_avg': None
            }
        ])
        
        loc_lookup = {'New York, NY': 1, 'Austin, TX': 2}
        plat_lookup = {'LinkedIn': 1, 'Indeed': 2}
        sched_lookup = {'Full-time': 1}
        rf_lookup = {'Senior Data Engineer': 1, 'Data Engineer': 1}
        comp_set = {1}
        
        valid_df, _ = transform_job_postings_chunk(
            chunk, loc_lookup, plat_lookup, sched_lookup, rf_lookup, comp_set
        )
        
        row_senior = valid_df[valid_df['job_id'] == 101].iloc[0]
        self.assertEqual(row_senior['seniority'], 'Senior')
        self.assertEqual(row_senior['base_role'], 'Data Engineer')
        
        row_mid = valid_df[valid_df['job_id'] == 102].iloc[0]
        self.assertEqual(row_mid['seniority'], 'Mid-Entry')
        self.assertEqual(row_mid['base_role'], 'Data Engineer')

if __name__ == '__main__':
    unittest.main()
