-- =============================================================================
-- Business Question 01: What are the top 25 skills demanded overall across all job postings?
-- Tables Joined: skills_dim, skills_job_dim, job_postings_fact
-- Underlying Row Count: 787,686 job postings, 3,669,604 skill-job bridge entries
-- =============================================================================

SELECT 
    s.skill_id,
    s.skills AS skill_name,
    s.type AS skill_type,
    COUNT(sj.job_id) AS demand_count,
    ROUND(COUNT(sj.job_id)::NUMERIC / (SELECT COUNT(*) FROM job_postings_fact) * 100, 2) AS pct_of_total_postings
FROM skills_dim s
JOIN skills_job_dim sj ON s.skill_id = sj.skill_id
JOIN job_postings_fact j ON sj.job_id = j.job_id
WHERE s.is_canonical = TRUE
GROUP BY s.skill_id, s.skills, s.type
ORDER BY demand_count DESC
LIMIT 25;
