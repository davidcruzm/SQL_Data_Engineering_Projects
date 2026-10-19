--Length & Count
SELECT LENGTH('SQL') AS length;
/*
┌────────┐
│ length │
│ int64  │
├────────┤
│      3 │
└────────┘
*/
--CASE CONVERSIONS
SELECT 
    LOWER('SQL') AS lower,
    UPPER('sql') AS upper;
/*
┌─────────┬─────────┐
│  lower  │  upper  │
│ varchar │ varchar │
├─────────┼─────────┤
│ sql     │ SQL     │
└─────────┴─────────┘
*/
--Substring/Extraction
SELECT
    LEFT('SQL',2) AS left,
    RIGHT('SQL',2) AS right,
    SUBSTRING('SQL',2,1) AS substring;--it takes two criterias, the first is when to start, and the second how many will be substracted
/*
┌─────────┬─────────┬───────────┐
│  left   │  right  │ substring │
│ varchar │ varchar │  varchar  │
├─────────┼─────────┼───────────┤
│ SQ      │ QL      │ Q         │
└─────────┴─────────┴───────────┘
*/
--Concatenation
SELECT 
    CONCAT ('SQL', '-', 'Functions') AS concat,
    'SQL'|| '-' || 'Functions' AS variety_of_concat;
/*
┌───────────────┬───────────────────┐
│    concat     │ variety_of_concat │
│    varchar    │      varchar      │
├───────────────┼───────────────────┤
│ SQL-Functions │ SQL-Functions     │
└───────────────┴───────────────────┘
*/
--Trimming
SELECT 
    'TRIM' AS function_name, 
    TRIM(' SQL ') AS result_value
UNION ALL
SELECT 
    'LEFT_TRIM' AS function_name, 
    LTRIM(' SQL ') AS result_value
UNION ALL
SELECT 
    'RIGHT_TRIM' AS function_name, 
    RTRIM(' SQL ') AS result_value;
/*
┌───────────────┬──────────────┐
│ function_name │ result_value │
│    varchar    │   varchar    │
├───────────────┼──────────────┤
│ TRIM          │ SQL          │
│ LEFT_TRIM     │ SQL          │
│ RIGHT_TRIM    │  SQL         │
└───────────────┴──────────────┘
*/
--Replacement
SELECT 
    REPLACE ('SQL','Q','_') AS replace,
    REGEXP_REPLACE('data.nerd@gmail.com', '^.*(@)', '\1') AS regexp_replace;
/*
┌─────────┬────────────────┐
│ replace │ regexp_replace │
│ varchar │    varchar     │
├─────────┼────────────────┤
│ S_L     │ @gmail.com     │
└─────────┴────────────────┘
*/
/*Clean this up with text functions
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
*/
WITH title_lower AS(
SELECT
    job_title,
    LOWER(TRIM(job_title)) AS job_title_l,
    job_title_short
FROM job_postings_fact)

SELECT
    job_title,
    CASE
        WHEN job_title_l LIKE '%data%' AND job_title_l LIKE '%analyst%' THEN 'Data Analyst'
        WHEN job_title_l LIKE '%data%' AND job_title_l LIKE '%engineer%' THEN 'Data Engineer'
        WHEN job_title_l LIKE '%data%' AND job_title_l LIKE '%scientist%' THEN 'Data Scientist'
        ELSE 'Other'
    END AS job_title_category,
    job_title_short
FROM title_lower
ORDER BY RANDOM()
LIMIT 30;
/*
┌───────────────────────────────────────────────────────────────────┬────────────────────┬───────────────────────────┐
│                             job_title                             │ job_title_category │      job_title_short      │
│                              varchar                              │      varchar       │          varchar          │
├───────────────────────────────────────────────────────────────────┼────────────────────┼───────────────────────────┤
│ Azure Database Engineer                                           │ Data Engineer      │ Data Scientist            │
│ Software Engineer Senior - Google Cloud Platform Data Engineer... │ Data Engineer      │ Data Engineer             │
│ Accelerator Program Data Analyst                                  │ Data Analyst       │ Data Analyst              │
│ Data Engineer (12000 USD/Mes) [Remote]                            │ Data Engineer      │ Data Engineer             │
│ Senior Data Scientist, Totogi (Remote) - $200,000/year USD        │ Data Scientist     │ Senior Data Scientist     │
│ Data Scientist Expert (Gen AI)                                    │ Data Scientist     │ Data Scientist            │
│ Data Analyst                                                      │ Data Analyst       │ Data Analyst              │
│ Staff Data Architect (remote)                                     │ Other              │ Data Analyst              │
│ Data Scientist                                                    │ Data Scientist     │ Data Scientist            │
│ Lead I - Data Analysis                                            │ Other              │ Data Analyst              │
│ VIE - Business Data Analyst (M/W) - SWEDEN                        │ Data Analyst       │ Data Analyst              │
│ Lead Data Scientist                                               │ Data Scientist     │ Data Scientist            │
│ Data Scientist (m/w/d)                                            │ Data Scientist     │ Data Scientist            │
│ Sr Data Analyst                                                   │ Data Analyst       │ Data Analyst              │
│ Analyst, Business Administration                                  │ Other              │ Business Analyst          │
│ Senior Data Scientist: Machine Learning Specialist                │ Data Scientist     │ Senior Data Scientist     │
│ MLOps Engineer                                                    │ Other              │ Machine Learning Engineer │
│ Business Intelligence Analyst                                     │ Other              │ Business Analyst          │
│ Senior DevOps Engineer                                            │ Other              │ Software Engineer         │
│ Lead Data Strategist or Data Architect                            │ Other              │ Senior Data Scientist     │
│ BI Analyst                                                        │ Other              │ Business Analyst          │
│ Data Analyst H/F                                                  │ Data Analyst       │ Data Analyst              │
│ Senior Data Scientist                                             │ Data Scientist     │ Senior Data Scientist     │
│ Sr. Manager, Data Science                                         │ Other              │ Senior Data Scientist     │
│ Senior Data Engineer                                              │ Data Engineer      │ Senior Data Engineer      │
│ Data Scientist                                                    │ Data Scientist     │ Data Scientist            │
│ Principal Data Engineer                                           │ Data Engineer      │ Data Engineer             │
│ Principal Data Engineer                                           │ Data Engineer      │ Data Engineer             │
│ Data Analyst                                                      │ Data Analyst       │ Data Analyst              │
│ Data Engineer / Mudlogger (INSITE Specialists)                    │ Data Engineer      │ Data Engineer             │
└───────────────────────────────────────────────────────────────────┴────────────────────┴───────────────────────────┘
*/
--NULL Functions
SELECT 
    NULLIF(10,10) AS nullif_1,
    NULLIF(10,20) AS nullif_2;
/*
┌──────────┬──────────┐
│ nullif_1 │ nullif_2 │
│  int32   │  int32   │
├──────────┼──────────┤
│     NULL │       10 │
└──────────┴──────────┘
*/
SELECT
    NULLIF(salary_year_avg, 0) AS nullif_1,
    NULLIF(salary_hour_avg, 0) AS nullif_2
FROM
job_postings_fact
WHERE salary_hour_avg IS NOT NULL OR salary_year_avg IS NOT NULL
ORDER BY RANDOM()
LIMIT 10;
/*
┌──────────┬──────────────────┐
│ nullif_1 │     nullif_2     │
│  double  │      double      │
├──────────┼──────────────────┤
│ 185000.0 │             NULL │
│  90000.0 │             NULL │
│ 100000.0 │             NULL │
│ 237500.0 │             NULL │
│     NULL │ 56.7400016784668 │
│  88600.0 │             NULL │
│     NULL │             32.5 │
│ 120000.0 │             NULL │
│ 124000.0 │             NULL │
│  72800.0 │             NULL │
└──────────┴──────────────────┘
*/
--COALESCE RETURNS THE FIRST NON-NULL VALUE
SELECT 
    COALESCE(0,1,2) AS coalesce_1,
    COALESCE(NULL,1,2) AS coalesce_2,
    COALESCE(NULL,NULL,2) AS coalesce_3,
    COALESCE(0,NULL,2) AS coalesce_4;
/*
┌────────────┬────────────┬────────────┬────────────┐
│ coalesce_1 │ coalesce_2 │ coalesce_3 │ coalesce_4 │
│   int32    │   int32    │   int32    │   int32    │
├────────────┼────────────┼────────────┼────────────┤
│          0 │          1 │          2 │          0 │
└────────────┴────────────┴────────────┴────────────┘
*/
--Example of how COALESCE works
SELECT
    salary_year_avg,
    salary_hour_avg,
    COALESCE(salary_year_avg, salary_hour_avg * 2080) AS normalized_salary_avg
FROM job_postings_fact
WHERE salary_year_avg IS NOT NULL OR salary_hour_avg IS NOT NULL
ORDER BY RANDOM()
LIMIT 20;
/*
┌─────────────────┬───────────────────┬───────────────────────┐
│ salary_year_avg │  salary_hour_avg  │ normalized_salary_avg │
│     double      │      double       │        double         │
├─────────────────┼───────────────────┼───────────────────────┤
│        185000.0 │              NULL │              185000.0 │
│        125950.0 │              NULL │              125950.0 │
│        155000.0 │              NULL │              155000.0 │
│        140000.0 │              NULL │              140000.0 │
│            NULL │              50.0 │              104000.0 │
│        139095.0 │              NULL │              139095.0 │
│         75000.0 │              NULL │               75000.0 │
│        147500.0 │              NULL │              147500.0 │
│        150000.0 │              NULL │              150000.0 │
│            NULL │ 21.43000030517578 │    44574.400634765625 │
│        130000.0 │              NULL │              130000.0 │
│        125000.0 │              NULL │              125000.0 │
│         72900.0 │              NULL │               72900.0 │
│         74050.0 │              NULL │               74050.0 │
│        202500.0 │              NULL │              202500.0 │
│         57500.0 │              NULL │               57500.0 │
│         98301.5 │              NULL │               98301.5 │
│        111175.0 │              NULL │              111175.0 │
│            NULL │              16.5 │               34320.0 │
│            NULL │              70.0 │              145600.0 │
└─────────────────┴───────────────────┴───────────────────────┘
*/
/* Clean this query using COALESCE
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
*/

SELECT 
    job_title_short,
    salary_hour_avg,
    salary_year_avg,
    COALESCE(salary_year_avg,salary_hour_avg * 2080) AS normalized_salary_avg,
    CASE
        WHEN COALESCE(salary_year_avg,salary_hour_avg * 2080) IS NULL THEN 'Missing'
        WHEN COALESCE(salary_year_avg,salary_hour_avg * 2080) < 75000 THEN 'Low'
        WHEN COALESCE(salary_year_avg,salary_hour_avg * 2080) < 150000 THEN 'Medium'
        ELSE 'High'
    END AS salary_category
FROM job_postings_fact
ORDER BY RANDOM()
LIMIT 30;
/*
┌───────────────────────────┬────────────────────┬─────────────────┬───────────────────────┬─────────────────┐
│      job_title_short      │  salary_hour_avg   │ salary_year_avg │ normalized_salary_avg │ salary_category │
│          varchar          │       double       │     double      │        double         │     varchar     │
├───────────────────────────┼────────────────────┼─────────────────┼───────────────────────┼─────────────────┤
│ Senior Data Engineer      │               NULL │            NULL │                  NULL │ Missing         │
│ Data Engineer             │               NULL │        162500.0 │              162500.0 │ High            │
│ Data Analyst              │               NULL │            NULL │                  NULL │ Missing         │
│ Machine Learning Engineer │               NULL │            NULL │                  NULL │ Missing         │
│ Data Analyst              │               NULL │            NULL │                  NULL │ Missing         │
│ Data Analyst              │  24.01499938964844 │            NULL │     49951.19873046876 │ Low             │
│ Senior Data Scientist     │               NULL │            NULL │                  NULL │ Missing         │
│ Software Engineer         │               NULL │            NULL │                  NULL │ Missing         │
│ Data Scientist            │               NULL │        120000.0 │              120000.0 │ Medium          │
│ Data Scientist            │               NULL │            NULL │                  NULL │ Missing         │
│ Software Engineer         │               NULL │            NULL │                  NULL │ Missing         │
│ Data Analyst              │               NULL │        123800.0 │              123800.0 │ Medium          │
│ Data Engineer             │               NULL │            NULL │                  NULL │ Missing         │
│ Data Engineer             │               NULL │            NULL │                  NULL │ Missing         │
│ Data Engineer             │                8.0 │            NULL │               16640.0 │ Low             │
│ Data Analyst              │               NULL │            NULL │                  NULL │ Missing         │
│ Business Analyst          │               NULL │            NULL │                  NULL │ Missing         │
│ Senior Data Analyst       │               NULL │            NULL │                  NULL │ Missing         │
│ Data Scientist            │               NULL │            NULL │                  NULL │ Missing         │
│ Data Scientist            │               NULL │            NULL │                  NULL │ Missing         │
│ Data Engineer             │ 41.084999084472656 │            NULL │     85456.79809570312 │ Medium          │
│ Data Engineer             │               NULL │            NULL │                  NULL │ Missing         │
│ Data Engineer             │               NULL │            NULL │                  NULL │ Missing         │
│ Senior Data Analyst       │               NULL │            NULL │                  NULL │ Missing         │
│ Data Engineer             │               NULL │            NULL │                  NULL │ Missing         │
│ Data Analyst              │               NULL │            NULL │                  NULL │ Missing         │
│ Data Analyst              │               NULL │            NULL │                  NULL │ Missing         │
│ Business Analyst          │               NULL │            NULL │                  NULL │ Missing         │
│ Data Analyst              │               NULL │            NULL │                  NULL │ Missing         │
│ Data Scientist            │               NULL │            NULL │                  NULL │ Missing         │
└───────────────────────────┴────────────────────┴─────────────────┴───────────────────────┴─────────────────┘
*/
