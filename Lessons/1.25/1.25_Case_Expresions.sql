/*
These applies conditional logic in SQL transformations in order to categorize, clean, and standarize data
CASE
    WHEN condition 1 THEN result 1
    [ WHEN condition_2 THEN result_2 ]
    [ ELSE result_default ]
END AS
FROM
    table_name;
*/
--First Exercise
-- Bucket Salaries
-- <25 = 'Low'
-- 25-50 = 'Medium'
-- > 50 = 'High'

SELECT
    job_title_short,
    salary_hour_avg,
    CASE
        WHEN salary_hour_avg < 25 THEN 'Low'
        WHEN salary_hour_avg < 50 THEN 'Medium'
        ELSE 'High'
    END AS salary_category
FROM job_postings_fact
WHERE salary_hour_avg IS NOT NULL
LIMIT 20;
/*
┌─────────────────────┬─────────────────┬─────────────────┐
│   job_title_short   │ salary_hour_avg │ salary_category │
│       varchar       │     double      │     varchar     │
├─────────────────────┼─────────────────┼─────────────────┤
│ Data Analyst        │            20.0 │ Low             │
│ Data Scientist      │            20.0 │ Low             │
│ Data Analyst        │            15.0 │ Low             │
│ Data Analyst        │           35.75 │ Medium          │
│ Data Analyst        │            36.0 │ Medium          │
│ Data Analyst        │            55.0 │ High            │
│ Data Engineer       │            64.5 │ High            │
│ Data Scientist      │            20.0 │ Low             │
│ Data Scientist      │            20.0 │ Low             │
│ Data Engineer       │            25.5 │ Medium          │
│ Data Engineer       │            70.0 │ High            │
│ Data Engineer       │            28.5 │ Medium          │
│ Data Engineer       │            62.5 │ High            │
│ Senior Data Analyst │            13.0 │ Low             │
│ Data Analyst        │            60.0 │ High            │
│ Data Scientist      │            55.0 │ High            │
│ Data Analyst        │            20.0 │ Low             │
│ Senior Data Analyst │           112.5 │ High            │
│ Data Engineer       │            62.5 │ High            │
│ Data Engineer       │            65.0 │ High            │
└─────────────────────┴─────────────────┴─────────────────┘
*/
--Handling missing data (NULLS)
--Filter NULL salary values
SELECT
    job_title_short,
    salary_hour_avg,
    CASE
        WHEN salary_hour_avg IS NULL THEN 'Missing'
        WHEN salary_hour_avg < 25 THEN 'Low'
        WHEN salary_hour_avg < 50 THEN 'Medium'
        ELSE 'High'
    END AS salary_category
FROM job_postings_fact
LIMIT 20;
/*
┌─────────────────────┬─────────────────┬─────────────────┐
│   job_title_short   │ salary_hour_avg │ salary_category │
│       varchar       │     double      │     varchar     │
├─────────────────────┼─────────────────┼─────────────────┤
│ Data Analyst        │            NULL │ Missing         │
│ Data Analyst        │            NULL │ Missing         │
│ Data Analyst        │            NULL │ Missing         │
│ Senior Data Analyst │            NULL │ Missing         │
│ Data Analyst        │            NULL │ Missing         │
│ Data Analyst        │            NULL │ Missing         │
│ Data Analyst        │            NULL │ Missing         │
│ Data Analyst        │            NULL │ Missing         │
│ Senior Data Analyst │            NULL │ Missing         │
│ Business Analyst    │            NULL │ Missing         │
│ Data Analyst        │            NULL │ Missing         │
│ Data Analyst        │            NULL │ Missing         │
│ Data Analyst        │            NULL │ Missing         │
│ Data Analyst        │            NULL │ Missing         │
│ Data Analyst        │            NULL │ Missing         │
│ Data Analyst        │            NULL │ Missing         │
│ Data Analyst        │            NULL │ Missing         │
│ Data Analyst        │            20.0 │ Low             │
│ Data Analyst        │            NULL │ Missing         │
│ Data Analyst        │            NULL │ Missing         │
└─────────────────────┴─────────────────┴─────────────────┘
*/
-- Categorizing Categorical Values
-- Classify the 'job_title' column values as:
    -- 'Data Analyst'
    -- 'Data Engineer'
    -- 'Data Scientist'
SELECT
    job_title,
    CASE
        WHEN job_title LIKE '%Data%' AND job_title LIKE '%Analyst%' THEN 'Data Analyst'
        WHEN job_title LIKE '%Data%' AND job_title LIKE '%Engineer%' THEN 'Data Engineer'
        WHEN job_title LIKE '%Data%' AND job_title LIKE '%Scientist%' THEN 'Data Scientist'
        ELSE 'Other'
    END AS job_title_category,
    job_title_short
FROM job_postings_fact
ORDER BY RANDOM()
LIMIT 10;
/*
┌─────────────────────────────────────────────────────────────────────┬────────────────────┬───────────────────────────┐
│                              job_title                              │ job_title_category │      job_title_short      │
│                               varchar                               │      varchar       │          varchar          │
├─────────────────────────────────────────────────────────────────────┼────────────────────┼───────────────────────────┤
│ Sr HR Analytics Specialist at Mohawk Industries Inc in Kennesaw, GA │ Other              │ Data Analyst              │
│ SAP Master Data Systems Analyst                                     │ Data Analyst       │ Data Analyst              │
│ Net Core Software Engineer                                          │ Other              │ Software Engineer         │
│ Data Engineer                                                       │ Data Engineer      │ Data Engineer             │
│ Data Analyst                                                        │ Data Analyst       │ Data Analyst              │
│ Machine Learning Engineer, Fraud Discovery                          │ Other              │ Machine Learning Engineer │
│ Data Engineer - Data Integration                                    │ Data Engineer      │ Data Engineer             │
│ Data Analyst                                                        │ Data Analyst       │ Data Analyst              │
│ Data Scientist                                                      │ Data Scientist     │ Data Scientist            │
│ Staff Software Engineer Data Solutions                              │ Data Engineer      │ Software Engineer         │
└─────────────────────────────────────────────────────────────────────┴────────────────────┴───────────────────────────┘
*/
-- Conditional Aggregation
-- Calculate Median Salaries for Different Buckets
--< $100K
-- >= $100K
SELECT
    job_title_short,
    COUNT(*) AS job_count,
    MEDIAN(
        CASE
        WHEN salary_year_avg < 100000 THEN salary_year_avg
        END
    )::INT AS median_low_salary,
    MEDIAN(
        CASE
        WHEN salary_year_avg >= 10000 THEN salary_year_avg
        END
    )::INT AS median_high_salary
FROM job_postings_fact
WHERE salary_year_avg IS NOT NULL
GROUP BY job_title_short;
/*
┌───────────────────────────┬───────────┬───────────────────┬────────────────────┐
│      job_title_short      │ job_count │ median_low_salary │ median_high_salary │
│          varchar          │   int64   │       int32       │       int32        │
├───────────────────────────┼───────────┼───────────────────┼────────────────────┤
│ Senior Data Engineer      │      3283 │             87180 │             147500 │
│ Cloud Engineer            │       219 │             79200 │             120000 │
│ Senior Data Analyst       │      2603 │             87500 │             110000 │
│ Machine Learning Engineer │      1334 │             78262 │             135000 │
│ Senior Data Scientist     │      3271 │             89100 │             156500 │
│ Data Engineer             │     10551 │             87500 │             130000 │
│ Data Scientist            │     12625 │             80000 │             125320 │
│ Business Analyst          │      1962 │             80000 │              91575 │
│ Data Analyst              │     13600 │             75000 │              90000 │
│ Software Engineer         │      1578 │             79200 │             144000 │
└───────────────────────────┴───────────┴───────────────────┴────────────────────┘
*/
-- Final Example: Conditional Calculations
-- Compute a standardized_salary using yearly salary and adjusted hourly salary (e.g. 2080 hours/year)
-- Categorize salaries into tiers of:
--< 75K 'Low'
-- 75K - 150K 'Medium'
-- >= 150K 'High'
WITH salaries AS(    
    SELECT
        job_title_short,
        salary_hour_avg,
        salary_year_avg,
        CASE
            WHEN salary_year_avg IS NOT NULL THEN salary_year_avg
            WHEN salary_hour_avg IS NOT NULL THEN salary_hour_avg*2080
        END AS standardized_salary
    FROM job_postings_fact
    WHERE salary_year_avg IS NOT NULL OR salary_hour_avg IS NOT NULL
)

SELECT 
    *,
    CASE
        WHEN standardized_salary < 75000 THEN 'Low'
        WHEN standardized_salary < 150000 THEN 'Medium'
        ELSE 'High'
    END AS salary_category
FROM salaries
LIMIT 10;
/*
┌──────────────────┬─────────────────┬─────────────────┬─────────────────────┬─────────────────┐
│ job_title_short  │ salary_hour_avg │ salary_year_avg │ standardized_salary │ salary_category │
│     varchar      │     double      │     double      │       double        │     varchar     │
├──────────────────┼─────────────────┼─────────────────┼─────────────────────┼─────────────────┤
│ Data Analyst     │            20.0 │            NULL │             41600.0 │ Low             │
│ Data Scientist   │            NULL │        110000.0 │            110000.0 │ Medium          │
│ Data Engineer    │            NULL │         65000.0 │             65000.0 │ Low             │
│ Business Analyst │            NULL │         90000.0 │             90000.0 │ Medium          │
│ Data Analyst     │            NULL │         55000.0 │             55000.0 │ Low             │
│ Data Scientist   │            20.0 │            NULL │             41600.0 │ Low             │
│ Data Scientist   │            NULL │        120531.0 │            120531.0 │ Medium          │
│ Data Engineer    │            NULL │        300000.0 │            300000.0 │ High            │
│ Data Analyst     │            NULL │         51000.0 │             51000.0 │ Low             │
│ Data Scientist   │            NULL │        133500.0 │            133500.0 │ Medium          │
└──────────────────┴─────────────────┴─────────────────┴─────────────────────┴─────────────────┘
*/