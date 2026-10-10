SELECT UNNEST([1, 1, 1, 2]) AS UNION
UNION
SELECT UNNEST ([1, 1, 3]);
/* UNION returns all rows from A and B. Duplicates removed
┌───────┐
│ UNION │
│ int32 │
├───────┤
│     1 │
│     2 │
│     3 │
└───────┘
*/
SELECT UNNEST([1, 1, 1, 2]) AS UNION_ALL
UNION ALL
SELECT UNNEST ([1, 1, 3]);
/* UNION ALL returns all rows from A and B. Duplicates preserved
┌───────────┐
│ UNION_ALL │
│   int32   │
├───────────┤
│         1 │
│         1 │
│         1 │
│         2 │
│         1 │
│         1 │
│         3 │
└───────────┘
*/
SELECT UNNEST([1, 1, 1, 2]) AS INTERSECT
INTERSECT
SELECT UNNEST ([1, 1, 3]);
/* Returns rows common to A and B. Duplicates removed.
┌───────────┐
│ INTERSECT │
│   int32   │
├───────────┤
│         1 │
└───────────┘
*/
SELECT UNNEST([1, 1, 1, 2]) AS INTERSECT_ALL
INTERSECT ALL
SELECT UNNEST ([1, 1, 3]);
/* Returns rows common to A and B. Duplicates preserved.
┌───────────────┐
│ INTERSECT_ALL │
│     int32     │
├───────────────┤
│             1 │
│             1 │
└───────────────┘
*/
SELECT UNNEST([1, 1, 1, 2]) AS EXCEPT
EXCEPT
SELECT UNNEST ([1, 1, 3]);
/* Returns rows in A but not in B. Duplicates removed.
┌────────┐
│ EXCEPT │
│ int32  │
├────────┤
│      2 │
└────────┘
*/
SELECT UNNEST([1, 1, 1, 2]) AS EXCEPT_ALL
EXCEPT ALL
SELECT UNNEST ([1, 1, 3]);
/*Returns rows in A minus rows in B. Duplicates removed one-for-one.
┌────────────┐
│ EXCEPT_ALL │
│   int32    │
├────────────┤
│          2 │
│          1 │
└────────────┘
*/

CREATE OR REPLACE TEMPORARY TABLE job_postings_2023 AS
SELECT * EXCLUDE (job_id, job_posted_date)
FROM job_postings_fact
WHERE EXTRACT(YEAR FROM job_posted_date) = 2023;

CREATE OR REPLACE TEMPORARY TABLE job_postings_2024 AS
SELECT * EXCLUDE (job_id, job_posted_date)
FROM job_postings_fact
WHERE EXTRACT(YEAR FROM job_posted_date) = 2024;

--1) Which unique job postings appeared in either 2023 or 2024?
SELECT * FROM job_postings_2023
UNION
SELECT * FROM job_postings_2024;
--1.08 million rows (40 shown, 1081500 total)        

--2) Which job postings appeared across both years, counting duplicates?
SELECT *
FROM job_postings_2023
UNION ALL
SELECT *
FROM job_postings_2024;
-- 1.27 million rows (40 shown, 1271315 total)   

--3) Which job postings appeared in both 2023 and 2024?
SELECT *
FROM job_postings_2023
INTERSECT
SELECT *
FROM job_postings_2024;
--18761 rows (40 shown)

--4) Which job postings appeared in both years, preserving duplicate counts?
SELECT *
FROM job_postings_2023
INTERSECT ALL
SELECT *
FROM job_postings_2024;
-- 21204 rows (40 shown)

--5) Which job postings appeared in 2023 but not in 2024?
SELECT *
FROM job_postings_2023
EXCEPT
SELECT *
FROM job_postings_2024;
--  709716 rows (40 shown)

--6) Which job postings appeared more times in 2023 than 2024, one-for-one?
SELECT *
FROM job_postings_2023
EXCEPT ALL
SELECT *
FROM job_postings_2024;
-- 766152 rows (40 shown)  