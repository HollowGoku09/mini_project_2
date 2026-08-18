-- =============================================================================
-- Business Question 10: How does the health insurance offer rate vary by country and company size proxy?
-- (Company size proxy: Tier 1 [1-10 postings], Tier 2 [11-50 postings], Tier 3 [51-200 postings], Enterprise [>200 postings])
-- Tables Joined: job_postings_fact, location_dim, company_dim
-- Underlying Row Count: 787,686 job postings (11.0% overall health insurance mention)
-- =============================================================================

WITH company_posting_counts AS (
    SELECT 
        company_id,
        COUNT(job_id) AS total_company_postings,
        CASE 
            WHEN COUNT(job_id) > 200 THEN 'Enterprise (>200 postings)'
            WHEN COUNT(job_id) BETWEEN 51 AND 200 THEN 'Large (51-200 postings)'
            WHEN COUNT(job_id) BETWEEN 11 AND 50 THEN 'Mid-Size (11-50 postings)'
            ELSE 'Small (1-10 postings)'
        END AS company_size_tier
    FROM job_postings_fact
    WHERE company_id IS NOT NULL
    GROUP BY company_id
)
SELECT 
    l.country,
    cpc.company_size_tier,
    COUNT(j.job_id) AS total_postings,
    SUM(CASE WHEN j.job_health_insurance THEN 1 ELSE 0 END) AS health_insurance_offered_count,
    ROUND(SUM(CASE WHEN j.job_health_insurance THEN 1 ELSE 0 END)::NUMERIC / COUNT(j.job_id) * 100, 2) AS health_insurance_offer_pct
FROM job_postings_fact j
JOIN location_dim l ON j.location_id = l.location_id
JOIN company_posting_counts cpc ON j.company_id = cpc.company_id
GROUP BY l.country, cpc.company_size_tier
HAVING COUNT(j.job_id) >= 50
ORDER BY l.country, total_postings DESC;
