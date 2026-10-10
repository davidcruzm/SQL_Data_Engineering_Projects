SELECT
    job_posted_date,
    job_posted_date::DATE AS date, --will provide year, month, and day
    job_posted_date::TIME AS time, --will provide time
    job_posted_date::TIMESTAMP AS timestamp, --will provide year, month, day, and time
    job_posted_date::TIMESTAMPTZ AS timestamptz --will provide year, month, day, time, and timezone
FROM job_postings_fact
ORDER BY RANDOM()
LIMIT 10;
/*
┌─────────────────────┬────────────┬──────────┬─────────────────────┬──────────────────────────┐
│   job_posted_date   │    date    │   time   │      timestamp      │       timestamptz        │
│      timestamp      │    date    │   time   │      timestamp      │ timestamp with time zone │
├─────────────────────┼────────────┼──────────┼─────────────────────┼──────────────────────────┤
│ 2024-07-26 14:49:36 │ 2024-07-26 │ 14:49:36 │ 2024-07-26 14:49:36 │ 2024-07-26 14:49:36-06   │
│ 2024-08-08 19:01:45 │ 2024-08-08 │ 19:01:45 │ 2024-08-08 19:01:45 │ 2024-08-08 19:01:45-06   │
│ 2023-10-15 07:46:53 │ 2023-10-15 │ 07:46:53 │ 2023-10-15 07:46:53 │ 2023-10-15 07:46:53-06   │
│ 2025-02-05 06:11:08 │ 2025-02-05 │ 06:11:08 │ 2025-02-05 06:11:08 │ 2025-02-05 06:11:08-06   │
│ 2023-03-24 09:53:04 │ 2023-03-24 │ 09:53:04 │ 2023-03-24 09:53:04 │ 2023-03-24 09:53:04-06   │
│ 2025-05-15 10:04:53 │ 2025-05-15 │ 10:04:53 │ 2025-05-15 10:04:53 │ 2025-05-15 10:04:53-06   │
│ 2023-01-26 05:02:49 │ 2023-01-26 │ 05:02:49 │ 2023-01-26 05:02:49 │ 2023-01-26 05:02:49-06   │
│ 2024-08-13 06:12:39 │ 2024-08-13 │ 06:12:39 │ 2024-08-13 06:12:39 │ 2024-08-13 06:12:39-06   │
│ 2023-03-13 06:24:11 │ 2023-03-13 │ 06:24:11 │ 2023-03-13 06:24:11 │ 2023-03-13 06:24:11-06   │
│ 2024-01-08 11:12:33 │ 2024-01-08 │ 11:12:33 │ 2024-01-08 11:12:33 │ 2024-01-08 11:12:33-06   │
└─────────────────────┴────────────┴──────────┴─────────────────────┴──────────────────────────┘
*/

/*
EXTRACT

SELECT
EXTRACT(part FROM column_name)
FROM
table_name

EXTRACT - Gets field (e.g., year, month, day) from a
date/time value
*/

SELECT
    job_posted_date,
    EXTRACT(YEAR FROM job_posted_date) AS job_posted_year,
    EXTRACT(MONTH FROM job_posted_date) AS job_posted_month,
    EXTRACT(DAY FROM job_posted_date) AS job_posted_day
FROM job_postings_fact
ORDER BY RANDOM()
LIMIT 10;
/*
┌─────────────────────┬─────────────────┬──────────────────┬────────────────┐
│   job_posted_date   │ job_posted_year │ job_posted_month │ job_posted_day │
│      timestamp      │      int64      │      int64       │     int64      │
├─────────────────────┼─────────────────┼──────────────────┼────────────────┤
│ 2024-07-19 06:18:21 │            2024 │                7 │             19 │
│ 2023-10-11 00:15:16 │            2023 │               10 │             11 │
│ 2025-03-22 02:08:37 │            2025 │                3 │             22 │
│ 2023-08-16 01:48:54 │            2023 │                8 │             16 │
│ 2024-08-09 20:01:19 │            2024 │                8 │              9 │
│ 2023-08-28 23:35:17 │            2023 │                8 │             28 │
│ 2025-06-26 14:02:36 │            2025 │                6 │             26 │
│ 2025-02-04 13:55:24 │            2025 │                2 │              4 │
│ 2023-10-07 11:11:27 │            2023 │               10 │              7 │
│ 2025-01-22 16:09:20 │            2025 │                1 │             22 │
└─────────────────────┴─────────────────┴──────────────────┴────────────────┘
*/
SELECT
    EXTRACT(YEAR FROM job_posted_date) AS job_posted_year,
    EXTRACT(MONTH FROM job_posted_date) AS job_posted_month,
    COUNT(job_id) AS data_engineer_count
FROM job_postings_fact
WHERE
    job_title_short = 'Data Engineer'
GROUP BY
    EXTRACT(YEAR FROM job_posted_date),
    EXTRACT(MONTH FROM job_posted_date)
ORDER BY
    job_posted_year,
    job_posted_month;
/*
┌─────────────────┬──────────────────┬─────────────────────┐
│ job_posted_year │ job_posted_month │ data_engineer_count │
│      int64      │      int64       │        int64        │
├─────────────────┼──────────────────┼─────────────────────┤
│            2023 │                1 │               21448 │
│            2023 │                2 │               15886 │
│            2023 │                3 │               16123 │
│            2023 │                4 │               14859 │
│            2023 │                5 │               13593 │
│            2023 │                6 │               15503 │
│            2023 │                7 │               14521 │
│            2023 │                8 │               15691 │
│            2023 │                9 │               14918 │
│            2023 │               10 │               15459 │
│            2023 │               11 │               15003 │
│            2023 │               12 │               13623 │
│            2024 │                1 │               14119 │
│            2024 │                2 │               14571 │
│            2024 │                3 │               13120 │
│            2024 │                4 │               11979 │
│            2024 │                5 │               12151 │
│            2024 │                6 │               11085 │
│            2024 │                7 │               13636 │
│            2024 │                8 │               12826 │
│            2024 │                9 │                8197 │
│            2024 │               10 │                5057 │
│            2024 │               11 │                3852 │
│            2024 │               12 │                8464 │
│            2025 │                1 │               15296 │
│            2025 │                2 │               17676 │
│            2025 │                3 │               15648 │
│            2025 │                4 │                9542 │
│            2025 │                5 │                9269 │
│            2025 │                6 │                8842 │
└─────────────────┴──────────────────┴─────────────────────┘
*/
/*
DATE_TRUNC

DATE_TRUNC('precision', date_time)

DATE_TRUNC - truncates a date or timestamp to a
specified level of precision (e.g., year, month, day,
hour).

Returns a timestamp rounded down to the start of
the specified time unit
*/

SELECT
    job_posted_date,
    DATE_TRUNC('year',job_posted_date) AS truncated_year,
    DATE_TRUNC('quarter',job_posted_date) AS truncated_quarter,
    DATE_TRUNC('month',job_posted_date) AS truncated_month,
    DATE_TRUNC('week',job_posted_date) AS truncated_week,
    DATE_TRUNC('day',job_posted_date) AS truncated_day,
    DATE_TRUNC('hour',job_posted_date) AS truncated_hour
FROM job_postings_fact
ORDER BY RANDOM()
LIMIT 10;
/*
┌─────────────────────┬─────────────────────┬─────────────────────┬─────────────────────┬─────────────────────┬─────────────────────┬─────────────────────┐
│   job_posted_date   │   truncated_year    │  truncated_quarter  │   truncated_month   │   truncated_week    │    truncated_day    │   truncated_hour    │
│      timestamp      │      timestamp      │      timestamp      │      timestamp      │      timestamp      │      timestamp      │      timestamp      │
├─────────────────────┼─────────────────────┼─────────────────────┼─────────────────────┼─────────────────────┼─────────────────────┼─────────────────────┤
│ 2023-03-21 09:20:00 │ 2023-01-01 00:00:00 │ 2023-01-01 00:00:00 │ 2023-03-01 00:00:00 │ 2023-03-20 00:00:00 │ 2023-03-21 00:00:00 │ 2023-03-21 09:00:00 │
│ 2023-01-17 15:13:29 │ 2023-01-01 00:00:00 │ 2023-01-01 00:00:00 │ 2023-01-01 00:00:00 │ 2023-01-16 00:00:00 │ 2023-01-17 00:00:00 │ 2023-01-17 15:00:00 │
│ 2023-09-11 10:00:24 │ 2023-01-01 00:00:00 │ 2023-07-01 00:00:00 │ 2023-09-01 00:00:00 │ 2023-09-11 00:00:00 │ 2023-09-11 00:00:00 │ 2023-09-11 10:00:00 │
│ 2024-02-11 21:09:22 │ 2024-01-01 00:00:00 │ 2024-01-01 00:00:00 │ 2024-02-01 00:00:00 │ 2024-02-05 00:00:00 │ 2024-02-11 00:00:00 │ 2024-02-11 21:00:00 │
│ 2025-02-13 10:34:59 │ 2025-01-01 00:00:00 │ 2025-01-01 00:00:00 │ 2025-02-01 00:00:00 │ 2025-02-10 00:00:00 │ 2025-02-13 00:00:00 │ 2025-02-13 10:00:00 │
│ 2025-03-27 08:35:15 │ 2025-01-01 00:00:00 │ 2025-01-01 00:00:00 │ 2025-03-01 00:00:00 │ 2025-03-24 00:00:00 │ 2025-03-27 00:00:00 │ 2025-03-27 08:00:00 │
│ 2024-11-12 14:00:05 │ 2024-01-01 00:00:00 │ 2024-10-01 00:00:00 │ 2024-11-01 00:00:00 │ 2024-11-11 00:00:00 │ 2024-11-12 00:00:00 │ 2024-11-12 14:00:00 │
│ 2023-05-29 09:38:10 │ 2023-01-01 00:00:00 │ 2023-04-01 00:00:00 │ 2023-05-01 00:00:00 │ 2023-05-29 00:00:00 │ 2023-05-29 00:00:00 │ 2023-05-29 09:00:00 │
│ 2024-07-22 13:52:26 │ 2024-01-01 00:00:00 │ 2024-07-01 00:00:00 │ 2024-07-01 00:00:00 │ 2024-07-22 00:00:00 │ 2024-07-22 00:00:00 │ 2024-07-22 13:00:00 │
│ 2025-06-10 08:17:35 │ 2025-01-01 00:00:00 │ 2025-04-01 00:00:00 │ 2025-06-01 00:00:00 │ 2025-06-09 00:00:00 │ 2025-06-10 00:00:00 │ 2025-06-10 08:00:00 │
└─────────────────────┴─────────────────────┴─────────────────────┴─────────────────────┴─────────────────────┴─────────────────────┴─────────────────────┘
*/
--I want only the job count of 2024, and the month truncated
SELECT
    DATE_TRUNC('month',job_posted_date)::DATE AS job_posted_month,
    COUNT(job_id) AS data_engineer_count
FROM job_postings_fact
WHERE
    job_title_short = 'Data Engineer' AND
    EXTRACT(YEAR FROM job_posted_date) = 2024
GROUP BY
    DATE_TRUNC('month',job_posted_date)
ORDER BY job_posted_month;
/*
┌──────────────────┬─────────────────────┐
│ job_posted_month │ data_engineer_count │
│       date       │        int64        │
├──────────────────┼─────────────────────┤
│ 2024-01-01       │               14119 │
│ 2024-02-01       │               14571 │
│ 2024-03-01       │               13120 │
│ 2024-04-01       │               11979 │
│ 2024-05-01       │               12151 │
│ 2024-06-01       │               11085 │
│ 2024-07-01       │               13636 │
│ 2024-08-01       │               12826 │
│ 2024-09-01       │                8197 │
│ 2024-10-01       │                5057 │
│ 2024-11-01       │                3852 │
│ 2024-12-01       │                8464 │
└──────────────────┴─────────────────────┘
*/

SELECT '2026-01-01 00:00:00+00'::TIMESTAMPTZ AT TIME ZONE 'CST' AS timestamp;
/*
┌─────────────────────┐
│      timestamp      │
│      timestamp      │
├─────────────────────┤
│ 2025-12-31 18:00:00 │
└─────────────────────┘
*/
SELECT
    job_title_short,
    job_location,
    job_posted_date AT TIME ZONE 'UTC' AT TIME ZONE 'EST' AS job_posted_date
FROM 
    job_postings_fact
WHERE job_location LIKE 'New York, NY'
ORDER BY RANDOM()
LIMIT 10;
/*
┌───────────────────────┬──────────────┬─────────────────────┐
│    job_title_short    │ job_location │   job_posted_date   │
│        varchar        │   varchar    │      timestamp      │
├───────────────────────┼──────────────┼─────────────────────┤
│ Senior Data Analyst   │ New York, NY │ 2023-08-22 07:00:01 │
│ Business Analyst      │ New York, NY │ 2024-01-09 09:02:24 │
│ Data Analyst          │ New York, NY │ 2023-07-21 02:00:07 │
│ Senior Data Scientist │ New York, NY │ 2023-07-27 13:03:14 │
│ Data Analyst          │ New York, NY │ 2024-05-27 04:00:39 │
│ Senior Data Analyst   │ New York, NY │ 2024-02-24 08:00:24 │
│ Data Scientist        │ New York, NY │ 2024-04-14 04:03:29 │
│ Data Analyst          │ New York, NY │ 2023-12-19 18:00:06 │
│ Data Scientist        │ New York, NY │ 2024-08-14 03:02:34 │
│ Data Engineer         │ New York, NY │ 2024-08-09 04:33:18 │
└───────────────────────┴──────────────┴─────────────────────┘
*/
SELECT
    EXTRACT(HOUR FROM job_posted_date AT TIME ZONE 'UTC' AT TIME ZONE 'EST') AS job_posted_hour,
    COUNT(job_id) AS job_count
FROM 
    job_postings_fact
WHERE 
    job_location LIKE 'New York, NY'
GROUP BY 
    EXTRACT(HOUR FROM job_posted_date AT TIME ZONE 'UTC' AT TIME ZONE 'EST')
ORDER BY 
    job_posted_hour;
/*job_posted_hour in New York city
┌─────────────────┬───────────┐
│ job_posted_hour │ job_count │
│      int64      │   int64   │
├─────────────────┼───────────┤
│               0 │       150 │
│               1 │      1203 │
│               2 │       946 │
│               3 │       864 │
│               4 │      2192 │
│               5 │      1238 │
│               6 │       882 │
│               7 │      1236 │
│               8 │      1180 │
│               9 │      1001 │
│              10 │      1011 │
│              11 │      1030 │
│              12 │      1126 │
│              13 │       965 │
│              14 │       817 │
│              15 │       702 │
│              16 │       755 │
│              17 │       658 │
│              18 │       686 │
│              19 │       952 │
│              20 │       259 │
│              21 │       181 │
│              22 │       183 │
│              23 │       110 │
└─────────────────┴───────────┘
*/