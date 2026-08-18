-- =============================================================================
-- Business Question 09: What percentage of job postings explicitly state no degree requirement,
-- broken down by role family and seniority?
-- Tables Joined: job_postings_fact, role_family_dim
-- Underlying Row Count: 787,686 job postings (30.6% overall no-degree mention)
-- =============================================================================

SELECT 
    rf.role_family_name,
    j.seniority,
    COUNT(j.job_id) AS total_postings,
    SUM(CASE WHEN j.job_no_degree_mention THEN 1 ELSE 0 END) AS no_degree_mention_count,
    ROUND(SUM(CASE WHEN j.job_no_degree_mention THEN 1 ELSE 0 END)::NUMERIC / COUNT(j.job_id) * 100, 2) AS no_degree_mention_pct,
    ROUND(100 - (SUM(CASE WHEN j.job_no_degree_mention THEN 1 ELSE 0 END)::NUMERIC / COUNT(j.job_id) * 100), 2) AS degree_required_or_preferred_pct
FROM job_postings_fact j
JOIN role_family_dim rf ON j.role_family_id = rf.role_family_id
GROUP BY rf.role_family_name, j.seniority
ORDER BY rf.role_family_name, j.seniority;
