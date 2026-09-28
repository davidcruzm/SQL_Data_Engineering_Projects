-- Subquery
SELECT *
FROM (
     SELECT *
     FROM job_postings_fact
     WHERE salary_year_avg IS NOT NULL OR salary_hour_avg IS NOT NULL
     ) AS valid_salaries;

--CTE
WITH valid_salaries AS (
     SELECT *
     FROM job_postings_fact
     WHERE salary_year_avg IS NOT NULL OR salary_hour_avg IS NOT NULL
     )
SELECT *
FROM valid_salaries;

--Scenario 1 - Subquery in SELECT
--Show each job's salary next to the overall market median:
SELECT 
    job_title_short,
    salary_year_avg,
    (SELECT MEDIAN(salary_year_avg) FROM job_postings_fact) AS market_median_salary
FROM job_postings_fact
WHERE salary_year_avg IS NOT NULL
LIMIT 10;
/*
┌──────────────────┬─────────────────┬──────────────────────┐
│ job_title_short  │ salary_year_avg │ market_median_salary │
│     varchar      │     double      │        double        │
├──────────────────┼─────────────────┼──────────────────────┤
│ Data Scientist   │        110000.0 │             116950.0 │
│ Data Engineer    │         65000.0 │             116950.0 │
│ Business Analyst │         90000.0 │             116950.0 │
│ Data Analyst     │         55000.0 │             116950.0 │
│ Data Scientist   │        120531.0 │             116950.0 │
│ Data Engineer    │        300000.0 │             116950.0 │
│ Data Analyst     │         51000.0 │             116950.0 │
│ Data Scientist   │        133500.0 │             116950.0 │
│ Data Analyst     │         77500.0 │             116950.0 │
│ Data Scientist   │        125000.0 │             116950.0 │
└──────────────────┴─────────────────┴──────────────────────┘
*/
--  Scenario 2 - Subquery in FROM
-- Stage only jobs that are remote before aggregating to determine the remote median salary per job
SELECT 
    job_title_short,
    MEDIAN(salary_year_avg) AS median_salary,
    (SELECT MEDIAN(salary_year_avg) FROM job_postings_fact WHERE job_work_from_home = TRUE) AS market_remote_median_salary
FROM (SELECT job_title_short, salary_year_avg FROM job_postings_fact WHERE job_work_from_home = TRUE) AS remote_jobs
GROUP BY job_title_short
ORDER BY median_salary DESC;
/*
┌───────────────────────────┬───────────────┬─────────────────────────────┐
│      job_title_short      │ median_salary │ market_remote_median_salary │
│          varchar          │    double     │           double            │
├───────────────────────────┼───────────────┼─────────────────────────────┤
│ Software Engineer         │      180000.0 │                    130000.0 │
│ Senior Data Scientist     │      160000.0 │                    130000.0 │
│ Senior Data Engineer      │      145000.0 │                    130000.0 │
│ Machine Learning Engineer │      138433.5 │                    130000.0 │
│ Data Engineer             │      135000.0 │                    130000.0 │
│ Data Scientist            │      132500.0 │                    130000.0 │
│ Cloud Engineer            │      132000.0 │                    130000.0 │
│ Senior Data Analyst       │      105000.0 │                    130000.0 │
│ Business Analyst          │       90000.0 │                    130000.0 │
│ Data Analyst              │       87500.0 │                    130000.0 │
└───────────────────────────┴───────────────┴─────────────────────────────┘
*/
-- Scenario 3 - Subquery in`HAVING
-- Keep only job titles whose median salary is above the overall median:
SELECT 
    job_title_short,
    MEDIAN(salary_year_avg) AS median_salary,
    (SELECT MEDIAN(salary_year_avg) FROM job_postings_fact WHERE job_work_from_home = TRUE) AS market_remote_median_salary
FROM (SELECT job_title_short, salary_year_avg FROM job_postings_fact WHERE job_work_from_home = TRUE) AS remote_jobs
GROUP BY job_title_short
HAVING MEDIAN(salary_year_avg) > (SELECT MEDIAN(salary_year_avg) FROM job_postings_fact WHERE job_work_from_home = TRUE)
ORDER BY median_salary DESC;
/*
┌───────────────────────────┬───────────────┬─────────────────────────────┐
│      job_title_short      │ median_salary │ market_remote_median_salary │
│          varchar          │    double     │           double            │
├───────────────────────────┼───────────────┼─────────────────────────────┤
│ Software Engineer         │      180000.0 │                    130000.0 │
│ Senior Data Scientist     │      160000.0 │                    130000.0 │
│ Senior Data Engineer      │      145000.0 │                    130000.0 │
│ Machine Learning Engineer │      138433.5 │                    130000.0 │
│ Data Engineer             │      135000.0 │                    130000.0 │
│ Data Scientist            │      132500.0 │                    130000.0 │
│ Cloud Engineer            │      132000.0 │                    130000.0 │
└───────────────────────────┴───────────────┴─────────────────────────────┘
*/

-- CTE Example
-- Compare how much more (or less) remote roles pay compared to onsite roles for each job title.
-- Use a CTE to calculate the median salary by title and work arrangement, then compare those medians.

WITH median_roles AS
    (SELECT
        job_title_short,
        job_work_from_home,
        MEDIAN(salary_year_avg)::INT AS median_salary
    FROM job_postings_fact
    GROUP BY job_title_short,job_work_from_home)
SELECT 
    rm.job_title_short,
    rm.median_salary AS remote_median_salary,
    os.median_salary AS onsite_median_salary,
    rm.median_salary - os.median_salary AS remote_premium
FROM median_roles AS rm
INNER JOIN median_roles AS os
    ON os.job_title_short = rm.job_title_short
WHERE rm.job_work_from_home = TRUE
    AND os.job_work_from_home = FALSE
ORDER BY remote_premium DESC;
/*
┌───────────────────────────┬──────────────────────┬──────────────────────┬────────────────┐
│      job_title_short      │ remote_median_salary │ onsite_median_salary │ remote_premium │
│          varchar          │        int32         │        int32         │     int32      │
├───────────────────────────┼──────────────────────┼──────────────────────┼────────────────┤
│ Software Engineer         │               180000 │               130000 │          50000 │
│ Cloud Engineer            │               132000 │               117625 │          14375 │
│ Data Scientist            │               132500 │               125000 │           7500 │
│ Senior Data Scientist     │               160000 │               155000 │           5000 │
│ Data Engineer             │               135000 │               130000 │           5000 │
│ Machine Learning Engineer │               138434 │               135000 │           3434 │
│ Business Analyst          │                90000 │                92500 │          -2500 │
│ Data Analyst              │                87500 │                90000 │          -2500 │
│ Senior Data Engineer      │               145000 │               147500 │          -2500 │
│ Senior Data Analyst       │               105000 │               110432 │          -5432 │
└───────────────────────────┴──────────────────────┴──────────────────────┴────────────────┘
*/
SELECT * 
FROM range (5) AS src(key);
/*
┌───────┐
│  key  │
│ int64 │
├───────┤
│     0 │
│     1 │
│     2 │
│     3 │
│     4 │
└───────┘
*/
SELECT *
FROM RANGE (3) AS tgt(key);
/*
┌───────┐
│  key  │
│ int64 │
├───────┤
│     0 │
│     1 │
│     2 │
└───────┘
*/
SELECT *
FROM 
    RANGE (5) AS src(key)
WHERE EXISTS
    (SELECT 1 FROM RANGE (3) AS tgt(key) WHERE src.key = tgt.key);
/*
┌───────┐
│  key  │
│ int64 │
├───────┤
│     0 │
│     1 │
│     2 │
└───────┘
*/
SELECT *
FROM 
    RANGE (5) AS src(key)
WHERE NOT EXISTS
    (SELECT 1 FROM RANGE (3) AS tgt(key) WHERE src.key = tgt.key);
/*
┌───────┐
│  key  │
│ int64 │
├───────┤
│     3 │
│     4 │
└───────┘
*/
-- Final Example
-- Identify job postings that have no associated skills before loading them into a data mart

SELECT
    job_id,
    job_title
FROM job_postings_fact jpf
WHERE NOT EXISTS 
    (SELECT 1 FROM skills_job_dim AS sjd WHERE jpf.job_id = sjd.job_id)
ORDER BY job_id
LIMIT 50;