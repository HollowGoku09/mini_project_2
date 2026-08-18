-- =============================================================================
-- Business Question 07: Who are the top 25 hiring companies by posting volume,
-- what is their most-demanded skill, and what is their average salary?
-- Tables Joined: company_dim, job_postings_fact, skills_job_dim, skills_dim
-- Underlying Row Count: 140,033 companies, 787,686 job postings
-- =============================================================================

WITH top_companies AS (
    SELECT 
        c.company_id,
        c.name AS company_name,
        COUNT(j.job_id) AS total_postings,
        COUNT(j.salary_year_avg) AS salaried_postings_count,
        ROUND(AVG(j.salary_year_avg), 2) AS avg_salary_usd
    FROM company_dim c
    JOIN job_postings_fact j ON c.company_id = j.company_id
    GROUP BY c.company_id, c.name
    ORDER BY total_postings DESC
    LIMIT 25
),
company_top_skills AS (
    SELECT 
        tc.company_id,
        s.skills AS top_skill_name,
        COUNT(sj.job_id) AS skill_count,
        ROW_NUMBER() OVER (PARTITION BY tc.company_id ORDER BY COUNT(sj.job_id) DESC) AS rn
    FROM top_companies tc
    JOIN job_postings_fact j ON tc.company_id = j.company_id
    JOIN skills_job_dim sj ON j.job_id = sj.job_id
    JOIN skills_dim s ON sj.skill_id = s.skill_id
    WHERE s.is_canonical = TRUE
    GROUP BY tc.company_id, s.skills
)
SELECT 
    tc.company_name,
    tc.total_postings,
    tc.salaried_postings_count AS postings_with_salary,
    tc.avg_salary_usd,
    cts.top_skill_name AS most_demanded_skill
FROM top_companies tc
LEFT JOIN company_top_skills cts ON tc.company_id = cts.company_id AND cts.rn = 1
ORDER BY tc.total_postings DESC;
