-- =============================================================================
-- Business Question 13: Which skills appear disproportionately in Senior job postings
-- compared to Mid-Entry postings (Senior vs Entry skill delta)?
-- Tables Joined: job_postings_fact, skills_job_dim, skills_dim
-- Underlying Row Count: 787,686 job postings split into Senior vs Mid-Entry
-- =============================================================================

WITH total_by_seniority AS (
    SELECT 
        seniority,
        COUNT(job_id) AS total_postings
    FROM job_postings_fact
    GROUP BY seniority
),
skill_by_seniority AS (
    SELECT 
        s.skills AS skill_name,
        s.type AS skill_type,
        j.seniority,
        COUNT(j.job_id) AS skill_count
    FROM job_postings_fact j
    JOIN skills_job_dim sj ON j.job_id = sj.job_id
    JOIN skills_dim s ON sj.skill_id = s.skill_id
    WHERE s.is_canonical = TRUE
    GROUP BY s.skills, s.type, j.seniority
),
pivoted AS (
    SELECT 
        s.skill_name,
        s.skill_type,
        MAX(CASE WHEN s.seniority = 'Senior' THEN s.skill_count ELSE 0 END) AS senior_count,
        MAX(CASE WHEN s.seniority = 'Mid-Entry' THEN s.skill_count ELSE 0 END) AS entry_count
    FROM skill_by_seniority s
    GROUP BY s.skill_name, s.skill_type
)
SELECT 
    p.skill_name,
    p.skill_type,
    p.senior_count,
    p.entry_count,
    ROUND(p.senior_count::NUMERIC / (SELECT total_postings FROM total_by_seniority WHERE seniority = 'Senior') * 100, 2) AS senior_freq_pct,
    ROUND(p.entry_count::NUMERIC / (SELECT total_postings FROM total_by_seniority WHERE seniority = 'Mid-Entry') * 100, 2) AS entry_freq_pct,
    ROUND(
        (p.senior_count::NUMERIC / (SELECT total_postings FROM total_by_seniority WHERE seniority = 'Senior') * 100) -
        (p.entry_count::NUMERIC / (SELECT total_postings FROM total_by_seniority WHERE seniority = 'Mid-Entry') * 100), 2
    ) AS skill_delta_pct_points
FROM pivoted p
WHERE p.senior_count + p.entry_count >= 1000
ORDER BY skill_delta_pct_points DESC;
