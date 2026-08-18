-- =============================================================================
-- Business Question 11: What is the pay transparency rate (percentage disclosing salary)
-- by country and by role family?
-- Tables Joined: job_postings_fact, location_dim, role_family_dim
-- Underlying Row Count: 787,686 job postings (4.2% global transparency rate)
-- =============================================================================

SELECT 
    l.country,
    rf.role_family_name,
    COUNT(j.job_id) AS total_postings,
    COUNT(j.salary_year_avg) + COUNT(j.salary_hour_avg) - COUNT(CASE WHEN j.salary_year_avg IS NOT NULL AND j.salary_hour_avg IS NOT NULL THEN 1 END) AS postings_with_salary_disclosed,
    ROUND(
        (COUNT(j.salary_year_avg) + COUNT(j.salary_hour_avg) - COUNT(CASE WHEN j.salary_year_avg IS NOT NULL AND j.salary_hour_avg IS NOT NULL THEN 1 END))::NUMERIC 
        / COUNT(j.job_id) * 100, 2
    ) AS pay_transparency_pct
FROM job_postings_fact j
JOIN location_dim l ON j.location_id = l.location_id
JOIN role_family_dim rf ON j.role_family_id = rf.role_family_id
GROUP BY l.country, rf.role_family_name
HAVING COUNT(j.job_id) >= 20
ORDER BY pay_transparency_pct DESC;
