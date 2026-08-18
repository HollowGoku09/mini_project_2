-- =============================================================================
-- Business Question 04: How did demand for top skills evolve month-by-month across 2023?
-- Tables Joined: job_postings_fact, skills_job_dim, skills_dim
-- Underlying Row Count: 787,686 job postings collected during 2023
-- =============================================================================

SELECT 
    TO_CHAR(j.job_posted_date, 'YYYY-MM') AS year_month,
    s.skills AS skill_name,
    s.type AS skill_type,
    COUNT(j.job_id) AS monthly_postings
FROM job_postings_fact j
JOIN skills_job_dim sj ON j.job_id = sj.job_id
JOIN skills_dim s ON sj.skill_id = s.skill_id
WHERE s.is_canonical = TRUE
GROUP BY TO_CHAR(j.job_posted_date, 'YYYY-MM'), s.skills, s.type
ORDER BY year_month ASC, monthly_postings DESC;
