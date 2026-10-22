/*
SYNTAX
SELECT
    column_1,
    window_function () OVER (
        PARTITION BY <...>
        ORDER BY <...>
    ) AS window_column_alias
FROM
    table_name
*/


-- Count rows - Aggregation only
SELECT COUNT(*) AS row_count
FROM job_postings_fact;
/*
┌────────────────┐
│   row_count    │
│     int64      │
├────────────────┤
│    1615930     │
│ (1.62 million) │
└────────────────┘
*/

-- Count rows - Window Function
SELECT
    job_id,
    COUNT (*) OVER ()
FROM job_postings_fact;
/*
┌─────────┬─────────────────┐
│ job_id  │ count() OVER () │
│  int32  │      int64      │
├─────────┼─────────────────┤
│    4593 │         1615930 │
│    4594 │         1615930 │
│    4595 │         1615930 │
│    4596 │         1615930 │
│    4597 │         1615930 │
│    4598 │         1615930 │
│    4599 │         1615930 │
│    4600 │         1615930 │
│    4601 │         1615930 │
│    4602 │         1615930 │
│    4603 │         1615930 │
│    4604 │         1615930 │
│    4605 │         1615930 │
│    4606 │         1615930 │
│    4607 │         1615930 │
│    4608 │         1615930 │
│    4609 │         1615930 │
│    4610 │         1615930 │
│    4611 │         1615930 │
│    4612 │         1615930 │
│      ·  │            ·    │
│      ·  │            ·    │
│      ·  │            ·    │
│ 1620503 │         1615930 │
│ 1620504 │         1615930 │
│ 1620505 │         1615930 │
│ 1620506 │         1615930 │
│ 1620507 │         1615930 │
│ 1620508 │         1615930 │
│ 1620509 │         1615930 │
│ 1620510 │         1615930 │
│ 1620511 │         1615930 │
│ 1620512 │         1615930 │
│ 1620513 │         1615930 │
│ 1620514 │         1615930 │
│ 1620515 │         1615930 │
│ 1620516 │         1615930 │
│ 1620517 │         1615930 │
│ 1620518 │         1615930 │
│ 1620519 │         1615930 │
│ 1620520 │         1615930 │
│ 1620521 │         1615930 │
│ 1620522 │         1615930 │
└─────────┴─────────────────┘
      1.62 million rows    
  40 shown    1615930 total
*/
-- PARTITION BY - Find hourly salary

SELECT
    job_title_short,
    name AS company_name,
    salary_hour_avg,
    AVG(salary_hour_avg) OVER (
        PARTITION BY job_title_short, jpf.company_id
    ) AS avg_hourly_salary_per_company
FROM 
    job_postings_fact AS jpf
INNER JOIN company_dim AS cd
    ON jpf.company_id = cd.company_id
WHERE 
    salary_hour_avg IS NOT NULL
ORDER BY 
    RANDOM()
LIMIT 10;
/*
┌───────────────────────┬──────────────────────────────┬────────────────────┬───────────────────────────────┐
│    job_title_short    │         company_name         │  salary_hour_avg   │ avg_hourly_salary_per_company │
│        varchar        │           varchar            │       double       │            double             │
├───────────────────────┼──────────────────────────────┼────────────────────┼───────────────────────────────┤
│ Data Scientist        │ YO HR Consultancy            │               16.0 │                          17.5 │
│ Data Scientist        │ Trident Consulting Inc.      │               75.0 │                          75.0 │
│ Senior Data Scientist │ TransUnion                   │  40.09999847412109 │             40.27184061418499 │
│ Data Analyst          │ Akraya, Inc.                 │               36.5 │             53.11499998304579 │
│ Senior Data Engineer  │ Guidehouse                   │  61.15999603271485 │             59.11749744415283 │
│ Data Analyst          │ ComTec Information Systems   │               75.0 │                          75.0 │
│ Data Engineer         │ Allspring Global Investments │  49.41999816894531 │              54.7959098815918 │
│ Senior Data Analyst   │ Publicis Sapient             │ 20.950000762939453 │            20.950000762939453 │
│ Data Analyst          │ AbbVie                       │  26.38999938964844 │            23.207894877383584 │
│ Data Analyst          │ KLA                          │               29.0 │             26.31333287556966 │
└───────────────────────┴──────────────────────────────┴────────────────────┴───────────────────────────────┘
*/

-- ORDER BY EXAMPLE - RANKING hourly salary
SELECT
    job_id,
    job_title_short,
    salary_hour_avg,
    RANK() OVER (
        ORDER BY salary_hour_avg DESC
    ) AS rank_hourly_salary
FROM 
    job_postings_fact
ORDER BY 
    salary_hour_avg DESC --For best practice is better to keep the order by
LIMIT 10;

-- COMBINE PARTITION BY with ORDER BY

SELECT
    job_posted_date,
    job_title_short,
    salary_hour_avg,
    AVG(salary_hour_avg) OVER (
        PARTITION BY job_title_short
        ORDER BY job_posted_date
    ) AS running_avg_salary_by_title
FROM 
    job_postings_fact
WHERE 
    salary_hour_avg IS NOT NULL AND 
    job_title_short = 'Data Engineer'
ORDER BY
    job_title_short,
    job_posted_date
LIMIT 10;
/*
┌─────────────────────┬─────────────────┬─────────────────┬─────────────────────────────┐
│   job_posted_date   │ job_title_short │ salary_hour_avg │ running_avg_salary_by_title │
│      timestamp      │     varchar     │     double      │           double            │
├─────────────────────┼─────────────────┼─────────────────┼─────────────────────────────┤
│ 2023-01-01 23:06:55 │ Data Engineer   │            64.5 │                        64.5 │
│ 2023-01-02 13:08:25 │ Data Engineer   │            25.5 │                        45.0 │
│ 2023-01-02 14:08:27 │ Data Engineer   │            70.0 │          53.333333333333336 │
│ 2023-01-02 14:49:19 │ Data Engineer   │            28.5 │                      47.125 │
│ 2023-01-02 15:07:38 │ Data Engineer   │            62.5 │                        50.2 │
│ 2023-01-03 16:38:29 │ Data Engineer   │            62.5 │                       52.25 │
│ 2023-01-03 16:38:52 │ Data Engineer   │            65.0 │           54.07142857142857 │
│ 2023-01-03 23:33:27 │ Data Engineer   │            24.0 │                     50.3125 │
│ 2023-01-03 23:39:47 │ Data Engineer   │            24.0 │          47.388888888888886 │
│ 2023-01-03 23:51:05 │ Data Engineer   │            20.0 │                       44.65 │
└─────────────────────┴─────────────────┴─────────────────┴─────────────────────────────┘
  10 rows                                                                     4 columns
*/
-- Example of how RANK() works using PARTITION BY and ORDER BY
SELECT
    job_id,
    job_title_short,
    salary_hour_avg,
    RANK() OVER (
        PARTITION BY job_title_short
        ORDER BY salary_hour_avg DESC
    ) AS rank_hourly_salary
FROM 
    job_postings_fact
WHERE
    salary_hour_avg IS NOT NULL
ORDER BY 
    salary_hour_avg DESC,
    job_title_short 
LIMIT 10;
/*
┌─────────┬───────────────────────────┬─────────────────┬────────────────────┐
│ job_id  │      job_title_short      │ salary_hour_avg │ rank_hourly_salary │
│  int32  │          varchar          │     double      │       int64        │
├─────────┼───────────────────────────┼─────────────────┼────────────────────┤
│  256566 │ Data Analyst              │           391.0 │                  1 │
│ 1004296 │ Data Scientist            │           250.0 │                  1 │
│  110897 │ Data Analyst              │           242.5 │                  2 │
│  646328 │ Data Scientist            │           237.5 │                  2 │
│  210821 │ Data Scientist            │           225.0 │                  3 │
│ 1203880 │ Data Engineer             │           221.0 │                  1 │
│ 1056728 │ Machine Learning Engineer │           220.0 │                  1 │
│  193693 │ Data Analyst              │           210.0 │                  3 │
│  452720 │ Data Analyst              │           200.0 │                  4 │
│ 1115709 │ Data Scientist            │           200.0 │                  4 │
└─────────┴───────────────────────────┴─────────────────┴────────────────────┘
*/
/*
 Ranking Functions - RANK() vs DENSE_RANK

*/
SELECT
    job_id,
    job_title_short,
    salary_hour_avg,
    DENSE_RANK() OVER (
        ORDER BY salary_hour_avg DESC
    ) AS rank_hourly_salary
FROM 
    job_postings_fact
WHERE job_title_short = 'Senior Data Engineer'
ORDER BY 
    salary_hour_avg DESC 
LIMIT 10;
/*
┌─────────┬──────────────────────┬─────────────────┬────────────────────┐
│ job_id  │   job_title_short    │ salary_hour_avg │ rank_hourly_salary │
│  int32  │       varchar        │     double      │       int64        │
├─────────┼──────────────────────┼─────────────────┼────────────────────┤
│  193101 │ Senior Data Engineer │           170.0 │                  1 │
│  192893 │ Senior Data Engineer │           170.0 │                  1 │
│ 1062277 │ Senior Data Engineer │           152.5 │                  2 │
│  278422 │ Senior Data Engineer │           122.5 │                  3 │
│  517777 │ Senior Data Engineer │           120.0 │                  4 │
│  490396 │ Senior Data Engineer │           120.0 │                  4 │
│  267541 │ Senior Data Engineer │           117.5 │                  5 │
│  174654 │ Senior Data Engineer │           117.5 │                  5 │
│  554957 │ Senior Data Engineer │           117.5 │                  5 │
│  799559 │ Senior Data Engineer │           111.5 │                  6 │
└─────────┴──────────────────────┴─────────────────┴────────────────────┘
*/
SELECT
    job_id,
    job_title_short,
    salary_hour_avg,
    RANK() OVER (
        ORDER BY salary_hour_avg DESC
    ) AS rank_hourly_salary
FROM 
    job_postings_fact
WHERE job_title_short = 'Senior Data Engineer'
ORDER BY 
    salary_hour_avg DESC 
LIMIT 10;
/*
┌─────────┬──────────────────────┬─────────────────┬────────────────────┐
│ job_id  │   job_title_short    │ salary_hour_avg │ rank_hourly_salary │
│  int32  │       varchar        │     double      │       int64        │
├─────────┼──────────────────────┼─────────────────┼────────────────────┤
│  193101 │ Senior Data Engineer │           170.0 │                  1 │
│  192893 │ Senior Data Engineer │           170.0 │                  1 │
│ 1062277 │ Senior Data Engineer │           152.5 │                  3 │
│  278422 │ Senior Data Engineer │           122.5 │                  4 │
│  517777 │ Senior Data Engineer │           120.0 │                  5 │
│  490396 │ Senior Data Engineer │           120.0 │                  5 │
│  554957 │ Senior Data Engineer │           117.5 │                  7 │
│  267541 │ Senior Data Engineer │           117.5 │                  7 │
│  174654 │ Senior Data Engineer │           117.5 │                  7 │
│  799559 │ Senior Data Engineer │           111.5 │                 10 │
└─────────┴──────────────────────┴─────────────────┴────────────────────┘
*/

-- ROW_NUMBER() - Providing a new job_id

    SELECT 
        *,
        ROW_NUMBER() OVER(
            ORDER BY job_posted_date
        ) AS new_job_id
    FROM job_postings_fact
    ORDER BY
        job_posted_date
    LIMIT 20;
/*
┌────────┬────────────┬─────────────────────┬────────────────────────────────┬───┬───────────────┬─────────────┬─────────────────┬─────────────────┬────────────┐
│ job_id │ company_id │   job_title_short   │           job_title            │ … │  job_country  │ salary_rate │ salary_year_avg │ salary_hour_avg │ new_job_id │
│ int32  │   int32    │       varchar       │            varchar             │ … │    varchar    │   varchar   │     double      │     double      │   int64    │
├────────┼────────────┼─────────────────────┼────────────────────────────────┼───┼───────────────┼─────────────┼─────────────────┼─────────────────┼────────────┤
│   4593 │       4593 │ Data Analyst        │ Data Analyst                   │ … │ United States │ NULL        │            NULL │            NULL │          1 │
│   4594 │       4594 │ Data Analyst        │ Data Analyst                   │ … │ United States │ NULL        │            NULL │            NULL │          2 │
│   4595 │       4595 │ Data Analyst        │ Data Analyst                   │ … │ United States │ NULL        │            NULL │            NULL │          3 │
│   4596 │       4596 │ Senior Data Analyst │ Senior Data Analyst / Platfor… │ … │ United States │ NULL        │            NULL │            NULL │          4 │
│   4597 │       4597 │ Data Analyst        │ Data Analyst                   │ … │ United States │ NULL        │            NULL │            NULL │          5 │
│   4598 │       4598 │ Data Analyst        │ Jr. Data Analyst               │ … │ United States │ NULL        │            NULL │            NULL │          6 │
│   4599 │       4599 │ Data Analyst        │ Data Analyst                   │ … │ United States │ NULL        │            NULL │            NULL │          7 │
│   4600 │       4600 │ Data Analyst        │ Loyalty Data Analyst III       │ … │ United States │ NULL        │            NULL │            NULL │          8 │
│   4601 │       4601 │ Senior Data Analyst │ Senior data analyst            │ … │ United States │ NULL        │            NULL │            NULL │          9 │
│   4602 │       4602 │ Business Analyst    │ Business Analyst - Taxonomy/O… │ … │ United States │ NULL        │            NULL │            NULL │         10 │
│   4603 │       4603 │ Data Analyst        │ Technical Data Analyst / Desi… │ … │ United States │ NULL        │            NULL │            NULL │         11 │
│   4604 │       4604 │ Data Analyst        │ Neuroscience Research Data An… │ … │ United States │ NULL        │            NULL │            NULL │         12 │
│   4605 │       4605 │ Data Analyst        │ Data Analyst                   │ … │ United States │ NULL        │            NULL │            NULL │         13 │
│   4606 │       4606 │ Data Analyst        │ BI Data Analyst                │ … │ United States │ NULL        │            NULL │            NULL │         14 │
│   4607 │       4607 │ Data Analyst        │ EDI Data Analyst               │ … │ United States │ NULL        │            NULL │            NULL │         15 │
│   4608 │       4608 │ Data Analyst        │ Data Analyst for Member Conta… │ … │ United States │ NULL        │            NULL │            NULL │         16 │
│   4609 │       4609 │ Data Analyst        │ BI Data Analyst                │ … │ United States │ NULL        │            NULL │            NULL │         17 │
│   4610 │       4610 │ Data Analyst        │ Data Analyst, Partner Operati… │ … │ United States │ hour        │            NULL │            20.0 │         18 │
│   4611 │       4611 │ Data Analyst        │ Guidewire Policy Data Analyst  │ … │ United States │ NULL        │            NULL │            NULL │         19 │
│   4612 │       4612 │ Data Analyst        │ Sr. Data Analyst               │ … │ United States │ NULL        │            NULL │            NULL │         20 │
└────────┴────────────┴─────────────────────┴────────────────────────────────┴───┴───────────────┴─────────────┴─────────────────┴─────────────────┴────────────┘
*/

-- LAG() - Time Based Comparison of Company Yearly Salary
SELECT
    job_id,
    company_id,
    job_title,
    job_title_short,
    job_posted_date,
    salary_year_avg,
    LAG(salary_year_avg,1,0) OVER (
        PARTITION BY company_id
        ORDER BY job_posted_date
    ) AS previous_posting_salary,
    salary_year_avg - LAG(salary_year_avg,1,0) OVER (
        PARTITION BY company_id
        ORDER BY job_posted_date
    ) AS salary_change
FROM
    job_postings_fact
WHERE
    salary_year_avg IS NOT NULL
ORDER BY
    company_id, job_posted_date
LIMIT 60;
/*
┌─────────┬────────────┬──────────────────────────────┬───────────────────────┬─────────────────────┬─────────────────┬─────────────────────────┬───────────────┐
│ job_id  │ company_id │          job_title           │    job_title_short    │   job_posted_date   │ salary_year_avg │ previous_posting_salary │ salary_change │
│  int32  │   int32    │           varchar            │        varchar        │      timestamp      │     double      │         double          │    double     │
├─────────┼────────────┼──────────────────────────────┼───────────────────────┼─────────────────────┼─────────────────┼─────────────────────────┼───────────────┤
│  842003 │       4593 │ Data Scientist               │ Data Scientist        │ 2024-01-30 14:28:11 │         75000.0 │                     0.0 │       75000.0 │
│  995381 │       4593 │ Lead Data Engineer           │ Data Engineer         │ 2024-05-02 16:08:57 │        150000.0 │                 75000.0 │       75000.0 │
│  128388 │       4594 │ Data Scientist               │ Data Scientist        │ 2023-02-14 06:02:22 │         90000.0 │                     0.0 │       90000.0 │
│  134272 │       4594 │ AI/ML Health Data Scientist… │ Senior Data Scientist │ 2023-02-16 11:06:48 │        112450.0 │                 90000.0 │       22450.0 │
│  143916 │       4594 │ Data Scientist               │ Data Scientist        │ 2023-02-21 07:23:56 │         90000.0 │                112450.0 │      -22450.0 │
│  159423 │       4594 │ Data Scientist - Analyst     │ Data Scientist        │ 2023-02-28 10:52:05 │         90000.0 │                 90000.0 │           0.0 │
│  164436 │       4594 │ Data Scientist - Senior Con… │ Data Scientist        │ 2023-03-02 09:49:47 │         90000.0 │                 90000.0 │           0.0 │
│  167525 │       4594 │ AI/ML Health Data Scientist… │ Senior Data Scientist │ 2023-03-03 11:03:16 │        115000.0 │                 90000.0 │       25000.0 │
│  179599 │       4594 │ Data Analyst - Business Int… │ Data Analyst          │ 2023-03-09 09:00:18 │        129050.0 │                115000.0 │       14050.0 │
│  235865 │       4594 │ Cleared Data Scientist       │ Data Scientist        │ 2023-04-06 09:57:40 │        115000.0 │                129050.0 │      -14050.0 │
│  320213 │       4594 │ Data Scientist, Senior Cons… │ Data Scientist        │ 2023-05-16 12:40:22 │         90000.0 │                115000.0 │      -25000.0 │
│  324613 │       4594 │ AI/ML Health Data Scientist… │ Senior Data Scientist │ 2023-05-24 09:04:38 │        112450.0 │                 90000.0 │       22450.0 │
│  327941 │       4594 │ AI/ML Health Data Scientist… │ Senior Data Scientist │ 2023-05-25 18:04:36 │        112450.0 │                112450.0 │           0.0 │
│  361103 │       4594 │ AI/ML Health Data Science M… │ Data Scientist        │ 2023-06-12 03:04:10 │        142550.0 │                112450.0 │       30100.0 │
│  363685 │       4594 │ Database and Data Analyst    │ Data Analyst          │ 2023-06-13 08:00:03 │        115000.0 │                142550.0 │      -27550.0 │
│  372043 │       4594 │ Database and Data Analyst    │ Data Analyst          │ 2023-06-16 22:00:13 │        116250.0 │                115000.0 │        1250.0 │
│  372044 │       4594 │ Database and Data Analyst    │ Data Analyst          │ 2023-06-16 22:00:21 │        116250.0 │                116250.0 │           0.0 │
│  378568 │       4594 │ Cleared Data Scientist - Da… │ Data Scientist        │ 2023-06-20 15:02:44 │         84800.0 │                116250.0 │      -31450.0 │
│  390355 │       4594 │ Cleared Data Scientist - Da… │ Data Scientist        │ 2023-06-26 08:02:57 │         84800.0 │                 84800.0 │           0.0 │
│  390367 │       4594 │ Financial Data Science, Sen… │ Senior Data Scientist │ 2023-06-26 08:05:17 │        112450.0 │                 84800.0 │       27650.0 │
│     ·   │         ·  │            ·                 │       ·               │          ·          │            ·    │                    ·    │          ·    │
│     ·   │         ·  │            ·                 │       ·               │          ·          │            ·    │                    ·    │          ·    │
│     ·   │         ·  │            ·                 │       ·               │          ·          │            ·    │                    ·    │          ·    │
│  781700 │       4594 │ Data Science Consultant      │ Data Scientist        │ 2023-12-25 09:01:40 │        100000.0 │                 72000.0 │       28000.0 │
│  801450 │       4594 │ Big Data Analyst             │ Data Analyst          │ 2024-01-06 08:00:50 │         80000.0 │                100000.0 │      -20000.0 │
│  840111 │       4594 │ Data Scientist               │ Data Scientist        │ 2024-01-29 15:38:00 │         75000.0 │                 80000.0 │       -5000.0 │
│  865929 │       4594 │ Data Scientist               │ Data Scientist        │ 2024-02-12 11:12:23 │         75000.0 │                 75000.0 │           0.0 │
│  865934 │       4594 │ Data Science                 │ Data Scientist        │ 2024-02-12 11:12:45 │        100000.0 │                 75000.0 │       25000.0 │
│  879740 │       4594 │ Data Science Consultant      │ Data Scientist        │ 2024-02-19 16:12:09 │        100000.0 │                100000.0 │           0.0 │
│  896270 │       4594 │ Senior Consultant (full tim… │ Data Analyst          │ 2024-02-28 07:50:55 │        136500.0 │                100000.0 │       36500.0 │
│  898520 │       4594 │ Senior Consultant (full tim… │ Data Analyst          │ 2024-02-29 08:00:14 │        136500.0 │                136500.0 │           0.0 │
│  899932 │       4594 │ Data Scientist               │ Data Scientist        │ 2024-02-29 19:02:36 │        100000.0 │                136500.0 │      -36500.0 │
│ 1211909 │       4594 │ Consultant Manager-Pharma B… │ Data Scientist        │ 2024-10-05 12:01:10 │        136500.0 │                100000.0 │       36500.0 │
│ 1212494 │       4594 │ Associate Director, Data An… │ Data Analyst          │ 2024-10-06 11:00:35 │        151782.0 │                136500.0 │       15282.0 │
│ 1337452 │       4594 │ Business Intelligence Analy… │ Business Analyst      │ 2025-01-29 21:00:16 │        130500.0 │                151782.0 │      -21282.0 │
│ 1608236 │       4594 │ Lead Analyst, People Analyt… │ Data Scientist        │ 2025-06-18 17:00:11 │        150500.0 │                130500.0 │       20000.0 │
│  142923 │       4598 │ Senior Analyst Planning, Fo… │ Business Analyst      │ 2023-02-20 17:00:10 │         85000.0 │                     0.0 │       85000.0 │
│  586669 │       4598 │ Analytics Supervisor         │ Senior Data Analyst   │ 2023-09-22 16:02:56 │         78500.0 │                 85000.0 │       -6500.0 │
│ 1097057 │       4598 │ Data Scientist               │ Data Scientist        │ 2024-07-11 18:04:11 │        135000.0 │                 78500.0 │       56500.0 │
│ 1610710 │       4598 │ Marketing Analyst            │ Business Analyst      │ 2025-06-20 22:00:59 │        128000.0 │                135000.0 │       -7000.0 │
│    9006 │       4599 │ Data Analyst, Reporting      │ Data Analyst          │ 2023-01-02 08:29:05 │        111202.0 │                     0.0 │      111202.0 │
│   76921 │       4599 │ Senior People Analytics Ana… │ Data Scientist        │ 2023-01-25 07:01:04 │        185000.0 │                111202.0 │       73798.0 │
│   79945 │       4599 │ Data Analyst, Developer Rel… │ Data Analyst          │ 2023-01-26 03:04:13 │        111175.0 │                185000.0 │      -73825.0 │
└─────────┴────────────┴──────────────────────────────┴───────────────────────┴─────────────────────┴─────────────────┴─────────────────────────┴───────────────┘
*/
-- LEAD() - Time Based Comparison of Company Yearly Salary
SELECT
    job_id,
    company_id,
    job_title,
    job_title_short,
    job_posted_date,
    salary_year_avg,
    LEAD(salary_year_avg) OVER (
        PARTITION BY company_id
        ORDER BY job_posted_date
    ) AS next_posting_salary,
    salary_year_avg - LEAD(salary_year_avg) OVER (
        PARTITION BY company_id
        ORDER BY job_posted_date
    ) AS salary_change
FROM
    job_postings_fact
WHERE
    salary_year_avg IS NOT NULL
ORDER BY
    company_id, job_posted_date
LIMIT 60;
/*
┌─────────┬────────────┬──────────────────────────────────┬───────────────────────┬─────────────────────┬─────────────────┬─────────────────────┬───────────────┐
│ job_id  │ company_id │            job_title             │    job_title_short    │   job_posted_date   │ salary_year_avg │ next_posting_salary │ salary_change │
│  int32  │   int32    │             varchar              │        varchar        │      timestamp      │     double      │       double        │    double     │
├─────────┼────────────┼──────────────────────────────────┼───────────────────────┼─────────────────────┼─────────────────┼─────────────────────┼───────────────┤
│  842003 │       4593 │ Data Scientist                   │ Data Scientist        │ 2024-01-30 14:28:11 │         75000.0 │            150000.0 │      -75000.0 │
│  995381 │       4593 │ Lead Data Engineer               │ Data Engineer         │ 2024-05-02 16:08:57 │        150000.0 │                NULL │          NULL │
│  128388 │       4594 │ Data Scientist                   │ Data Scientist        │ 2023-02-14 06:02:22 │         90000.0 │            112450.0 │      -22450.0 │
│  134272 │       4594 │ AI/ML Health Data Scientist - S… │ Senior Data Scientist │ 2023-02-16 11:06:48 │        112450.0 │             90000.0 │       22450.0 │
│  143916 │       4594 │ Data Scientist                   │ Data Scientist        │ 2023-02-21 07:23:56 │         90000.0 │             90000.0 │           0.0 │
│  159423 │       4594 │ Data Scientist - Analyst         │ Data Scientist        │ 2023-02-28 10:52:05 │         90000.0 │             90000.0 │           0.0 │
│  164436 │       4594 │ Data Scientist - Senior Consult… │ Data Scientist        │ 2023-03-02 09:49:47 │         90000.0 │            115000.0 │      -25000.0 │
│  167525 │       4594 │ AI/ML Health Data Scientist - S… │ Senior Data Scientist │ 2023-03-03 11:03:16 │        115000.0 │            129050.0 │      -14050.0 │
│  179599 │       4594 │ Data Analyst - Business Intelli… │ Data Analyst          │ 2023-03-09 09:00:18 │        129050.0 │            115000.0 │       14050.0 │
│  235865 │       4594 │ Cleared Data Scientist           │ Data Scientist        │ 2023-04-06 09:57:40 │        115000.0 │             90000.0 │       25000.0 │
│  320213 │       4594 │ Data Scientist, Senior Consulta… │ Data Scientist        │ 2023-05-16 12:40:22 │         90000.0 │            112450.0 │      -22450.0 │
│  324613 │       4594 │ AI/ML Health Data Scientist - S… │ Senior Data Scientist │ 2023-05-24 09:04:38 │        112450.0 │            112450.0 │           0.0 │
│  327941 │       4594 │ AI/ML Health Data Scientist - S… │ Senior Data Scientist │ 2023-05-25 18:04:36 │        112450.0 │            142550.0 │      -30100.0 │
│  361103 │       4594 │ AI/ML Health Data Science Manag… │ Data Scientist        │ 2023-06-12 03:04:10 │        142550.0 │            115000.0 │       27550.0 │
│  363685 │       4594 │ Database and Data Analyst        │ Data Analyst          │ 2023-06-13 08:00:03 │        115000.0 │            116250.0 │       -1250.0 │
│  372043 │       4594 │ Database and Data Analyst        │ Data Analyst          │ 2023-06-16 22:00:13 │        116250.0 │            116250.0 │           0.0 │
│  372044 │       4594 │ Database and Data Analyst        │ Data Analyst          │ 2023-06-16 22:00:21 │        116250.0 │             84800.0 │       31450.0 │
│  378568 │       4594 │ Cleared Data Scientist - Data M… │ Data Scientist        │ 2023-06-20 15:02:44 │         84800.0 │             84800.0 │           0.0 │
│  390355 │       4594 │ Cleared Data Scientist - Data M… │ Data Scientist        │ 2023-06-26 08:02:57 │         84800.0 │            112450.0 │      -27650.0 │
│  390367 │       4594 │ Financial Data Science, Senior … │ Senior Data Scientist │ 2023-06-26 08:05:17 │        112450.0 │             90000.0 │       22450.0 │
│     ·   │         ·  │            ·                     │       ·               │          ·          │            ·    │                ·    │          ·    │
│     ·   │         ·  │            ·                     │       ·               │          ·          │            ·    │                ·    │          ·    │
│     ·   │         ·  │            ·                     │       ·               │          ·          │            ·    │                ·    │          ·    │
│  781700 │       4594 │ Data Science Consultant          │ Data Scientist        │ 2023-12-25 09:01:40 │        100000.0 │             80000.0 │       20000.0 │
│  801450 │       4594 │ Big Data Analyst                 │ Data Analyst          │ 2024-01-06 08:00:50 │         80000.0 │             75000.0 │        5000.0 │
│  840111 │       4594 │ Data Scientist                   │ Data Scientist        │ 2024-01-29 15:38:00 │         75000.0 │             75000.0 │           0.0 │
│  865929 │       4594 │ Data Scientist                   │ Data Scientist        │ 2024-02-12 11:12:23 │         75000.0 │            100000.0 │      -25000.0 │
│  865934 │       4594 │ Data Science                     │ Data Scientist        │ 2024-02-12 11:12:45 │        100000.0 │            100000.0 │           0.0 │
│  879740 │       4594 │ Data Science Consultant          │ Data Scientist        │ 2024-02-19 16:12:09 │        100000.0 │            136500.0 │      -36500.0 │
│  896270 │       4594 │ Senior Consultant (full time) -… │ Data Analyst          │ 2024-02-28 07:50:55 │        136500.0 │            136500.0 │           0.0 │
│  898520 │       4594 │ Senior Consultant (full time) -… │ Data Analyst          │ 2024-02-29 08:00:14 │        136500.0 │            100000.0 │       36500.0 │
│  899932 │       4594 │ Data Scientist                   │ Data Scientist        │ 2024-02-29 19:02:36 │        100000.0 │            136500.0 │      -36500.0 │
│ 1211909 │       4594 │ Consultant Manager-Pharma Biote… │ Data Scientist        │ 2024-10-05 12:01:10 │        136500.0 │            151782.0 │      -15282.0 │
│ 1212494 │       4594 │ Associate Director, Data Analyt… │ Data Analyst          │ 2024-10-06 11:00:35 │        151782.0 │            130500.0 │       21282.0 │
│ 1337452 │       4594 │ Business Intelligence Analyst    │ Business Analyst      │ 2025-01-29 21:00:16 │        130500.0 │            150500.0 │      -20000.0 │
│ 1608236 │       4594 │ Lead Analyst, People Analytics   │ Data Scientist        │ 2025-06-18 17:00:11 │        150500.0 │                NULL │          NULL │
│  142923 │       4598 │ Senior Analyst Planning, Foreca… │ Business Analyst      │ 2023-02-20 17:00:10 │         85000.0 │             78500.0 │        6500.0 │
│  586669 │       4598 │ Analytics Supervisor             │ Senior Data Analyst   │ 2023-09-22 16:02:56 │         78500.0 │            135000.0 │      -56500.0 │
│ 1097057 │       4598 │ Data Scientist                   │ Data Scientist        │ 2024-07-11 18:04:11 │        135000.0 │            128000.0 │        7000.0 │
│ 1610710 │       4598 │ Marketing Analyst                │ Business Analyst      │ 2025-06-20 22:00:59 │        128000.0 │                NULL │          NULL │
│    9006 │       4599 │ Data Analyst, Reporting          │ Data Analyst          │ 2023-01-02 08:29:05 │        111202.0 │            185000.0 │      -73798.0 │
│   76921 │       4599 │ Senior People Analytics Analyst… │ Data Scientist        │ 2023-01-25 07:01:04 │        185000.0 │            111175.0 │       73825.0 │
│   79945 │       4599 │ Data Analyst, Developer Relatio… │ Data Analyst          │ 2023-01-26 03:04:13 │        111175.0 │            166000.0 │      -54825.0 │
└─────────┴────────────┴──────────────────────────────────┴───────────────────────┴─────────────────────┴─────────────────┴─────────────────────┴───────────────┘
*/

