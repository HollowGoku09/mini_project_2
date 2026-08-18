-- =============================================================================
-- Business Question 12: How do job platforms (via LinkedIn, Indeed, etc.) compare in terms of
-- role family coverage and salary transparency rates?
-- Tables Joined: platform_dim, job_postings_fact, role_family_dim
-- Underlying Row Count: 787,686 job postings across multiple platforms
-- =============================================================================

SELECT 
    p.platform_name,
    rf.role_family_name,
    COUNT(j.job_id) AS posting_volume,
    COUNT(j.salary_year_avg) AS salaried_postings_count,
    ROUND(COUNT(j.salary_year_avg)::NUMERIC / COUNT(j.job_id) * 100, 2) AS salary_disclosure_rate_pct,
    ROUND(AVG(j.salary_year_avg), 2) AS avg_disclosed_salary_usd
FROM job_postings_fact j
JOIN platform_dim p ON j.platform_id = p.platform_id
JOIN role_family_dim rf ON j.role_family_id = rf.role_family_id
GROUP BY p.platform_name, rf.role_family_name
HAVING COUNT(j.job_id) >= 100
ORDER BY posting_volume DESC;
