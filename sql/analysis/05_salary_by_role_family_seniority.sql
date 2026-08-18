-- =============================================================================
-- Business Question 05: What is the average yearly salary by role family and seniority level?
-- Tables Joined: job_postings_fact, role_family_dim
-- Underlying Row Count: 22,034 postings with non-null salary_year_avg (2.8% of total)
-- Academic Caveat: ALWAYS pair salary averages with postings_with_salary count!
-- =============================================================================

SELECT 
    rf.role_family_name,
    j.seniority,
    COUNT(j.job_id) AS total_postings,
    COUNT(j.salary_year_avg) AS postings_with_salary,
    ROUND(COUNT(j.salary_year_avg)::NUMERIC / COUNT(j.job_id) * 100, 2) AS pct_disclosed,
    ROUND(AVG(j.salary_year_avg), 2) AS avg_yearly_salary,
    ROUND(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY j.salary_year_avg)::NUMERIC, 2) AS median_yearly_salary,
    ROUND(MIN(j.salary_year_avg), 2) AS min_yearly_salary,
    ROUND(MAX(j.salary_year_avg), 2) AS max_yearly_salary
FROM job_postings_fact j
JOIN role_family_dim rf ON j.role_family_id = rf.role_family_id
GROUP BY rf.role_family_name, j.seniority
ORDER BY rf.role_family_name, j.seniority;
