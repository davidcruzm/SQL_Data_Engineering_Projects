--This lesson will provide information of the most common data types and its use.

SELECT 
    table_name,
    column_name,
    data_type
FROM information_schema.columns
WHERE table_catalog = 'data_jobs';

DESCRIBE
SELECT
    job_title_short,
    salary_year_avg
FROM
    job_postings_fact;

SELECT CAST('123DEF-@' AS VARCHAR); --VARCHAR allows numbers, words, symbols, etc. But it won't work on math operations 'cuz numbers will be stored as text characters
SELECT CAST(123 AS INTEGER); --INTEGER only allows whole numbers, whether is positive or negative. Example: 50,-50
--CAST(column_name AS data_type) = column_name :: data_type. Use as you please

SELECT
    CAST(job_id AS VARCHAR) || '-' || CAST(company_id AS VARCHAR) AS unique_id,                 --"more" unique identifier
    CAST(job_work_from_home AS INT) AS job_work_from_home,     --from boolean to numeric value
    CAST(job_posted_date AS DATE) AS job_posted_date,        --from timestamp to date only
    CAST(salary_year_avg AS INTEGER) AS salary_year_avg         --from double to no decimal places
FROM
    job_postings_fact
WHERE
    salary_year_avg IS NOT NULL
LIMIT 10;

SELECT
    job_id :: VARCHAR || '-' || company_id :: VARCHAR AS unique_id,                 --"more" unique identifier
    job_work_from_home :: INT AS job_work_from_home,     --from boolean to numeric value
    job_posted_date :: DATE AS job_posted_date,        --from timestamp to date only
    salary_year_avg :: INTEGER AS salary_year_avg         --from double to no decimal places
FROM
    job_postings_fact
WHERE
    salary_year_avg IS NOT NULL
LIMIT 10;

SELECT
    'JOB-' || CAST(job_id AS VARCHAR) || 
    '_COMP-' || CAST(company_id AS VARCHAR) || 
    '_YEAR-' || CAST(EXTRACT(YEAR FROM job_posted_date) AS VARCHAR) AS audit_id,
    
    CAST(salary_year_avg / 260.0 AS DECIMAL(10,2)) AS daily_rate,
    
    CASE 
        WHEN job_work_from_home = TRUE THEN 'Remote'
        ELSE 'On-Site'
    END AS work_type
FROM job_postings_fact
WHERE salary_year_avg IS NOT NULL
LIMIT 10;

/*
Problem 1: Complex Composite Key & Safe Division
Scenario: You need to create an audit key and calculate an adjusted daily salary rate.
Requirements:
Create a composite key named audit_id formatted as JOB-<job_id>_COMP-<company_id>_YEAR-<year> (Extract the 4-digit year from job_posted_date).
Calculate daily_rate by taking salary_year_avg and dividing it by 260 working days. The result must be rounded to an exact 2-decimal financial figure (DECIMAL(10,2)).
Convert job_work_from_home into a readable text label: 'Remote' if TRUE, 'On-Site' if FALSE.
Use EXTRACT(YEAR FROM job_posted_date) or CAST(job_posted_date AS DATE), combined with string concatenation (||) and a CASE statement.
*/
