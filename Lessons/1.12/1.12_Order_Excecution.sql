/*
Find the top 10 companies for posting jobs 
They must have >3000 postings
Limit this to only US jobs
*/
EXPLAIN ANALYZE
SELECT
    cd.name AS company_name,
    COUNT (jpf.job_id) AS job_count
--    jpf.job_country
FROM job_postings_fact AS jpf
LEFT JOIN company_dim AS cd
    ON cd.company_id = jpf.company_id
WHERE
    job_country = 'United States'
GROUP BY cd.name
HAVING 
    COUNT(jpf.job_id) > 3000
ORDER BY job_count DESC
LIMIT 10
;