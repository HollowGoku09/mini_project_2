-- =============================================================================
-- Business Question 03: What are the top skills within each skill category (type)?
-- Tables Joined: skills_dim, skills_job_dim
-- Underlying Row Count: 259 skills across 10 categories, 3,669,604 bridge entries
-- =============================================================================

WITH skill_type_ranks AS (
    SELECT 
        s.type AS skill_type,
        s.skills AS skill_name,
        COUNT(sj.job_id) AS demand_count,
        DENSE_RANK() OVER (
            PARTITION BY s.type 
            ORDER BY COUNT(sj.job_id) DESC
        ) AS rank_in_type
    FROM skills_dim s
    JOIN skills_job_dim sj ON s.skill_id = sj.skill_id
    WHERE s.is_canonical = TRUE
    GROUP BY s.type, s.skills
)
SELECT 
    skill_type,
    rank_in_type,
    skill_name,
    demand_count
FROM skill_type_ranks
WHERE rank_in_type <= 10
ORDER BY skill_type, rank_in_type;
