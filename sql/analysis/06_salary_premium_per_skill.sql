-- =============================================================================
-- Business Question 06: What is the salary premium for individual skills?
-- (Compares avg salary for jobs requiring skill X vs jobs not requiring skill X)
-- Tables Joined: job_postings_fact, skills_job_dim, skills_dim
-- Underlying Row Count: 22,034 salaried postings. Restricted to skills in >= 100 salaried postings.
-- =============================================================================

WITH overall_salaried AS (
    SELECT AVG(salary_year_avg) AS global_avg_salary
    FROM job_postings_fact
    WHERE salary_year_avg IS NOT NULL
),
skill_salary_stats AS (
    SELECT 
        s.skill_id,
        s.skills AS skill_name,
        s.type AS skill_type,
        COUNT(j.job_id) AS salaried_postings_count,
        ROUND(AVG(j.salary_year_avg), 2) AS avg_salary_with_skill
    FROM skills_dim s
    JOIN skills_job_dim sj ON s.skill_id = sj.skill_id
    JOIN job_postings_fact j ON sj.job_id = j.job_id
    WHERE j.salary_year_avg IS NOT NULL
      AND s.is_canonical = TRUE
    GROUP BY s.skill_id, s.skills, s.type
    HAVING COUNT(j.job_id) >= 100
)
SELECT 
    sss.skill_name,
    sss.skill_type,
    sss.salaried_postings_count AS postings_with_salary,
    sss.avg_salary_with_skill,
    ROUND(g.global_avg_salary, 2) AS overall_salaried_avg,
    ROUND(sss.avg_salary_with_skill - g.global_avg_salary, 2) AS salary_premium_usd,
    ROUND(((sss.avg_salary_with_skill - g.global_avg_salary) / g.global_avg_salary) * 100, 2) AS pct_salary_premium
FROM skill_salary_stats sss
CROSS JOIN overall_salaried g
ORDER BY salary_premium_usd DESC;
