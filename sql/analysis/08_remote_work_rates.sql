-- =============================================================================
-- Business Question 08: How do remote work rates vary by country, role family, and seniority level?
-- Tables Joined: job_postings_fact, location_dim, role_family_dim
-- Underlying Row Count: 787,686 job postings across 160 countries
-- =============================================================================

SELECT 
    l.country,
    rf.role_family_name,
    j.seniority,
    COUNT(j.job_id) AS total_postings,
    SUM(CASE WHEN j.job_work_from_home THEN 1 ELSE 0 END) AS remote_postings_count,
    ROUND(SUM(CASE WHEN j.job_work_from_home THEN 1 ELSE 0 END)::NUMERIC / COUNT(j.job_id) * 100, 2) AS remote_work_pct
FROM job_postings_fact j
JOIN location_dim l ON j.location_id = l.location_id
JOIN role_family_dim rf ON j.role_family_id = rf.role_family_id
GROUP BY l.country, rf.role_family_name, j.seniority
HAVING COUNT(j.job_id) >= 20
ORDER BY total_postings DESC;
