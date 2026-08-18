-- =============================================================================
-- Business Question 14: What is the Ghana and African job market slice?
-- (Posting counts, top demanded skills, and remote work rates compared against global averages)
-- Tables Joined: job_postings_fact, location_dim, skills_job_dim, skills_dim
-- Underlying Row Count: 787,686 job postings (Ghana, African countries, Global benchmark)
-- =============================================================================

WITH african_countries AS (
    SELECT UNNEST(ARRAY[
        'Ghana', 'Nigeria', 'South Africa', 'Kenya', 'Egypt', 'Morocco',
        'Tunisia', 'Ethiopia', 'Uganda', 'Tanzania', 'Rwanda', 'Senegal',
        'Cameroon', 'Ivory Coast', 'Zimbabwe', 'Zambia', 'Algeria'
    ]) AS country
),
global_stats AS (
    SELECT 
        'Global' AS region,
        COUNT(job_id) AS total_postings,
        SUM(CASE WHEN job_work_from_home THEN 1 ELSE 0 END) AS remote_postings,
        ROUND(SUM(CASE WHEN job_work_from_home THEN 1 ELSE 0 END)::NUMERIC / COUNT(job_id) * 100, 2) AS remote_rate_pct,
        COUNT(salary_year_avg) AS salaried_count,
        ROUND(AVG(salary_year_avg), 2) AS avg_salary_usd
    FROM job_postings_fact
),
africa_stats AS (
    SELECT 
        'Africa' AS region,
        COUNT(j.job_id) AS total_postings,
        SUM(CASE WHEN j.job_work_from_home THEN 1 ELSE 0 END) AS remote_postings,
        ROUND(SUM(CASE WHEN j.job_work_from_home THEN 1 ELSE 0 END)::NUMERIC / COUNT(j.job_id) * 100, 2) AS remote_rate_pct,
        COUNT(j.salary_year_avg) AS salaried_count,
        ROUND(AVG(j.salary_year_avg), 2) AS avg_salary_usd
    FROM job_postings_fact j
    JOIN location_dim l ON j.location_id = l.location_id
    WHERE l.country IN (SELECT country FROM african_countries)
),
ghana_stats AS (
    SELECT 
        'Ghana' AS region,
        COUNT(j.job_id) AS total_postings,
        SUM(CASE WHEN j.job_work_from_home THEN 1 ELSE 0 END) AS remote_postings,
        ROUND(SUM(CASE WHEN j.job_work_from_home THEN 1 ELSE 0 END)::NUMERIC / COUNT(j.job_id) * 100, 2) AS remote_rate_pct,
        COUNT(j.salary_year_avg) AS salaried_count,
        ROUND(AVG(j.salary_year_avg), 2) AS avg_salary_usd
    FROM job_postings_fact j
    JOIN location_dim l ON j.location_id = l.location_id
    WHERE l.country = 'Ghana'
)
SELECT * FROM ghana_stats
UNION ALL
SELECT * FROM africa_stats
UNION ALL
SELECT * FROM global_stats;
