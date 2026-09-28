-- -- Create TEMP Table
CREATE OR REPLACE TABLE src_priority_jobs AS
SELECT 
    jpf.job_id,
    jpf.job_title_short,
    cd.name AS company_name,
    jpf.job_posted_date,
    jpf.salary_year_avg,
    r.priority_lvl,
    CURRENT_TIMESTAMP AS updated_at
FROM data_jobs.job_postings_fact AS jpf
LEFT JOIN data_jobs.company_dim AS cd
    ON jpf.company_id = cd.company_id
INNER JOIN staging.priority_roles AS r
    ON jpf.job_title_short = r.role_name; 
-- -- UPDATE statement
-- UPDATE main.priority_jobs_snapshot AS tgt
-- SET
--     priority_lvl = src.priority_lvl,
--     updated_at = src.updated_at
-- FROM src_priority_jobs AS src
-- WHERE tgt.job_id = src.job_id
--     AND tgt.priority_lvl IS DISTINCT FROM src.priority_lvl;
-- -- INSERT Statement
-- INSERT INTO main.priority_jobs_snapshot (
--     job_id,
--     job_title_short,
--     company_name,
--     job_posted_date,
--     salary_year_avg,
--     priority_lvl,
--     updated_at
-- )
-- SELECT
--     src.job_id,
--     src.job_title_short,
--     src.company_name,
--     src.job_posted_date,
--     src.salary_year_avg,
--     src.priority_lvl,
--     src.updated_at
-- FROM src_priority_jobs AS src
-- WHERE NOT EXISTS(
--     SELECT 1
--     FROM main.priority_jobs_snapshot AS tgt
--     WHERE src.job_id = tgt.job_id
-- );

-- -- DELETE Statement
-- DELETE FROM main.priority_jobs_snapshot AS tgt
-- WHERE NOT EXISTS(
--     SELECT 1
--     FROM src_priority_jobs AS src
--     WHERE src.job_id = tgt.job_id
-- );

--MERGE INTO 
MERGE INTO main.priority_jobs_snapshot AS tgt
USING src_priority_jobs AS src
ON tgt.job_id = src.job_id

WHEN MATCHED AND tgt.priority_lvl IS DISTINCT FROM src.priority_lvl THEN
    UPDATE SET
        priority_lvl = src.priority_lvl,
        updated_at = src.updated_at

WHEN NOT MATCHED THEN 
INSERT (
    job_id,
    job_title_short,
    company_name,
    job_posted_date,
    salary_year_avg,
    priority_lvl,
    updated_at
)
VALUES (
    src.job_id,
    src.job_title_short,
    src.company_name,
    src.job_posted_date,
    src.salary_year_avg,
    src.priority_lvl,
    src.updated_at
)
WHEN NOT MATCHED BY SOURCE THEN DELETE;
-- Final Chek Query
SELECT
    job_title_short,
    COUNT(*) AS job_count,
    MIN(priority_lvl) AS priority_lvl,
    MIN(updated_at) AS updated_at
FROM priority_jobs_snapshot
GROUP BY job_title_short
ORDER BY job_count DESC;
/*
┌──────────────────────┬───────────┬──────────────┬────────────────────────────┐
│   job_title_short    │ job_count │ priority_lvl │         updated_at         │
│       varchar        │   int64   │   varchar    │         timestamp          │
├──────────────────────┼───────────┼──────────────┼────────────────────────────┤
│ Data Engineer        │    391957 │ 2            │ 2026-09-27 03:47:33.269353 │
│ Software Engineer    │     92271 │ 3            │ 2026-09-27 03:12:37.329899 │
│ Senior Data Engineer │     91295 │ 1            │ 2026-09-26 04:29:02.526123 │
└──────────────────────┴───────────┴──────────────┴────────────────────────────┘
*/