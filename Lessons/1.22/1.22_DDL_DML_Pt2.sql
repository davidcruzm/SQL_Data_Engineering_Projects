/*
THIS IS CALLED CTAS, OR CREATE TABLE AS SELECT, 
IN THIS QUERY I CREATED THE TABLE job_postings_flat BASED ON TWO TABLES THAT ALREADY EXISTS, 
job_postings_fact, and company_dim
*/
CREATE OR REPLACE TABLE staging.job_postings_flat AS
SELECT
    jpf.job_id,
    jpf.job_title_short,
    jpf.job_title,
    jpf.job_location,
    jpf.job_via,
    jpf.job_schedule_type,
    jpf.job_work_from_home,
    jpf.search_location,
    jpf.job_posted_date,
    jpf.job_no_degree_mention,
    jpf.job_health_insurance,
    jpf.job_country,
    jpf.salary_rate,
    jpf.salary_year_avg,
    jpf.salary_hour_avg,
    cd.name AS company_name
FROM data_jobs.job_postings_fact AS jpf
LEFT JOIN data_jobs.company_dim AS cd
    ON jpf.company_id = cd.company_id;

SELECT COUNT(*)
FROM staging.job_postings_flat;

/*
A view is basically an stored subquery, it doesn't store physical data, 
 it lives in the database as a query text. 
The issue is that it can be slow if the underlying query is huge.
*/
CREATE OR REPLACE VIEW staging.priority_jobs_flat_view AS
SELECT
    jpf.*
FROM staging.job_postings_flat AS jpf
JOIN staging.priority_roles AS r
    ON jpf.job_title_short = r.role_name
WHERE r.priority_lvl = 1;

SELECT 
    job_title_short,
    COUNT(*) AS job_count
FROM staging.priority_jobs_flat_view
GROUP BY job_title_short
ORDER BY job_count DESC;
/*
┌──────────────────────┬───────────┐
│   job_title_short    │ job_count │
│       varchar        │   int64   │
├──────────────────────┼───────────┤
│ Data Engineer        │    391957 │
│ Senior Data Engineer │     91295 │
└──────────────────────┴───────────┘
*/
/*
This query creates a temporary table that is stored in the physical memory, 
widely used for quick calculations inside a session,
 once logged out the table will dissapear.
 The table is only for you, until the end of your session.
*/
CREATE OR REPLACE TEMPORARY TABLE senior_jobs_flat_temp AS
SELECT *
FROM staging.priority_jobs_flat_view
WHERE job_title_short = 'Senior Data Engineer';

SELECT 
    job_title_short,
    COUNT(*) AS job_count
FROM senior_jobs_flat_temp
GROUP BY job_title_short
ORDER BY job_count DESC;
/*
┌──────────────────────┬───────────┐
│   job_title_short    │ job_count │
│       varchar        │   int64   │
├──────────────────────┼───────────┤
│ Senior Data Engineer │     91295 │
└──────────────────────┴───────────┘
*/

SELECT COUNT(*) FROM staging.job_postings_flat;
/*
├────────────────┤
│    1615930     │
│ (1.62 million) │
└────────────────┘
*/

SELECT COUNT(*) FROM staging.priority_jobs_flat_view;
/*
┌──────────────┐
│ count_star() │
│    int64     │
├──────────────┤
│       483252 │
└──────────────┘
*/
SELECT COUNT(*) FROM senior_jobs_flat_temp;
/*
┌──────────────┐
│ count_star() │
│    int64     │
├──────────────┤
│        91295 │
└──────────────┘
*/
--This query will delete rows based on a criteria. 
--The view table will change if the main source change values
--The temp table is static, it won't change whether add or delete rows from the main source
DELETE FROM staging.job_postings_flat
WHERE job_posted_date < '2024-01-01';

SELECT COUNT(*) FROM staging.job_postings_flat;
/*Less values
┌──────────────┐
│ count_star() │
│    int64     │
├──────────────┤
│       828574 │
└──────────────┘
*/
SELECT COUNT(*) FROM staging.priority_jobs_flat_view;
/*Less values
┌──────────────┐
│ count_star() │
│    int64     │
├──────────────┤
│       251946 │
└──────────────┘
*/
SELECT COUNT(*) FROM senior_jobs_flat_temp;
/*No changes
┌──────────────┐
│ count_star() │
│    int64     │
├──────────────┤
│        91295 │
└──────────────┘
*/
--This query will get rid of all the values in the table, but the columns will be still in there.
--This helps to refresh the main table whether we want to add or delete rows based on a criteria
TRUNCATE TABLE staging.job_postings_flat;
--Now I'm inserting the same values but with the condition of fresh values (>=2024-01-01)
INSERT INTO staging.job_postings_flat
SELECT
    jpf.job_id,
    jpf.job_title_short,
    jpf.job_title,
    jpf.job_location,
    jpf.job_via,
    jpf.job_schedule_type,
    jpf.job_work_from_home,
    jpf.search_location,
    jpf.job_posted_date,
    jpf.job_no_degree_mention,
    jpf.job_health_insurance,
    jpf.job_country,
    jpf.salary_rate,
    jpf.salary_year_avg,
    jpf.salary_hour_avg,
    cd.name AS company_name
FROM data_jobs.job_postings_fact AS jpf
LEFT JOIN data_jobs.company_dim AS cd
    ON jpf.company_id = cd.company_id
WHERE job_posted_date >= '2024-01-01';

SELECT COUNT(*) FROM staging.job_postings_flat;
/*Less values
┌──────────────┐
│ count_star() │
│    int64     │
├──────────────┤
│       828574 │
└──────────────┘
*/
SELECT COUNT(*) FROM staging.priority_jobs_flat_view;
/*Less values
┌──────────────┐
│ count_star() │
│    int64     │
├──────────────┤
│       251946 │
└──────────────┘
*/
SELECT COUNT(*) FROM senior_jobs_flat_temp;
/*No changes
┌──────────────┐
│ count_star() │
│    int64     │
├──────────────┤
│        91295 │
└──────────────┘
-- .read Lessons/1.22/1.22_DDL_DML_Pt2.sql
