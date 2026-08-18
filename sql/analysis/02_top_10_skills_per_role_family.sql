-- =============================================================================
-- Business Question 02: What are the top 10 skills per role family?
-- Tables Joined: role_family_dim, job_postings_fact, skills_job_dim, skills_dim
-- Underlying Row Count: 787,686 job postings across 4 role families
-- Performance Note: Uses DENSE_RANK() window function to avoid N separate queries.
-- =============================================================================

WITH skill_counts AS (
    SELECT 
        rf.role_family_name,
        s.skills AS skill_name,
        s.type AS skill_type,
        COUNT(j.job_id) AS posting_count,
        DENSE_RANK() OVER (
            PARTITION BY rf.role_family_name 
            ORDER BY COUNT(j.job_id) DESC
        ) AS rank_in_family
    FROM job_postings_fact j
    JOIN role_family_dim rf ON j.role_family_id = rf.role_family_id
    JOIN skills_job_dim sj ON j.job_id = sj.job_id
    JOIN skills_dim s ON sj.skill_id = s.skill_id
    WHERE s.is_canonical = TRUE
    GROUP BY rf.role_family_name, s.skills, s.type
)
SELECT 
    role_family_name,
    rank_in_family,
    skill_name,
    skill_type,
    posting_count
FROM skill_counts
WHERE rank_in_family <= 10
ORDER BY role_family_name, rank_in_family;
