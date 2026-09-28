DESCRIBE data_jobs.job_postings_fact;

PRAGMA table_info('data_jobs.job_postings_fact');

SELECT  
    column_name,
    data_type
FROM
    information_schema.columns
WHERE   
    table_name = 'job_postings_fact'
    AND data_type IN ('DOUBLE', 'INTEGER', 'INT', 'BIGINT', 'FLOAT');

/*
 We're reviewing our compensation strategy for Data Analysts vs. Data Engineers. 
Could you pull a report showing the average yearly salary, minimum salary, and maximum salary for both titles?
Also, add a metric showing the salary spread (difference between max and min) for each title so we can see which role has wider pay ranges.
Please filter out any job listings that don't list a salary, and order it so the title with the highest average salary is at the top."

Data Analyst and Data Engineers
avg salary, min salary, max salary
max salary - min salary called salary spread
no null salaries and order in descending order
*/

SELECT
    job_title_short AS job_title,
    MIN(salary_year_avg) AS min_yearly_salary,
    ROUND(MEDIAN(salary_year_avg),2) AS avg_yearly_salary,
    MAX(salary_year_avg) AS max_yearly_salary,
    MAX(salary_year_avg) - MIN(salary_year_avg) AS salary_spread
FROM job_postings_fact
WHERE
    job_title_short IN ('Data Analyst', 'Data Engineer')
    AND salary_year_avg IS NOT NULL
GROUP BY
    job_title_short
ORDER BY avg_yearly_salary DESC;

/*
"We're updating our learning paths for Data Scientists. 
I need to know which 5 individual skills command the absolute highest average salary for 'Data Scientist' roles.
To make sure we aren't misled by a skill that only appears once in a weird $300k job, only include skills that appear in at least 10 different Data Scientist job postings.
For those top 5 skills, return the skill name, the average yearly salary (rounded to 2 decimals), and the total number of postings requiring that skill."

Data Scientist
top 5 skills with high salary
skills that appear at least in 10 data scientist job postings
skill name, avg salary, job count
*/

SELECT
    sd.skills AS skill_name,
    ROUND(AVG(jpf.salary_year_avg),2) AS avg_salary,
    COUNT(sjd.job_id) AS job_count
FROM job_postings_fact AS jpf
INNER JOIN skills_job_dim AS sjd
    ON jpf.job_id = sjd.job_id
INNER JOIN skills_dim AS sd
    ON sjd.skill_id = sd.skill_id
WHERE
    job_title_short = 'Data Scientist'
    AND salary_year_avg IS NOT NULL
GROUP BY
    sd.skills
HAVING
    COUNT(sjd.job_id) >= 10
ORDER BY
    ROUND(AVG(jpf.salary_year_avg),2) DESC
LIMIT 5;

/*
 We're auditing high-demand skills for Data Engineers.
Can you give us a report showing all skills that appear in more than 
500 Data Engineer job postings?

For those skills, we need:
The skill name
The total number of postings requiring that skill
The average annual salary (rounded to 2 decimal places)
The average monthly salary (average annual salary divided by 12, rounded to 2 decimal places)

Data Engineer
skills that appear in more than 500 job postings
skill name, job count, avg salary, avg monthly salary
*/

SELECT
    sd.skills AS skill_name,
    COUNT(sjd.job_id) AS data_engineer_count,
    ROUND(AVG(salary_year_avg),2) AS avg_yearly_salary,
    ROUND(AVG(salary_year_avg)/12,2) AS avg_monthly_salary
FROM
    job_postings_fact AS jpf
INNER JOIN skills_job_dim AS sjd
    ON jpf.job_id = sjd.job_id
INNER JOIN skills_dim AS sd
    ON sjd.skill_id = sd.skill_id
WHERE
    job_title_short = 'Data Engineer'
    AND salary_year_avg IS NOT NULL
GROUP BY sd.skills
HAVING COUNT(sjd.job_id) > 500
ORDER BY 
    data_engineer_count DESC;

/*
Subject: Top Employers for Data Analytics Talent
"We're tracking major tech employers hiring Data Analysts.
Please write a query that finds all companies that have posted at least 15 Data Analyst jobs.
For each qualifying company, return:
The company name
The total number of Data Analyst job postings
The lowest salary offered (min_salary)
The highest salary offered (max_salary)
The salary spread (max_salary - min_salary)
Constraints: Filter for job_title_short = 'Data Analyst' and non-null salaries. 
Order by total job postings descending so we see the biggest hiring companies first."

company name
count of data analyst roles
min salary
max salary
salary spread
no null values
order by job postings
*/

SELECT
    cd.name AS company_name,
    COUNT(job_id) AS data_analyst_count,
    ROUND(MIN(salary_year_avg),2) AS min_yearly_salary,
    ROUND(MAX(salary_year_avg),2) AS max_yearly_salary,
    ROUND(MAX(salary_year_avg) - MIN(salary_year_avg),2) AS salary_spread
FROM 
    job_postings_fact AS jpf
INNER JOIN company_dim AS cd
    ON cd.company_id = jpf.company_id
WHERE
    job_title_short = 'Data Analyst'
    AND salary_year_avg IS NOT NULL
GROUP BY cd.name
HAVING
    COUNT(job_id) >= 15
ORDER BY
    COUNT(job_id) DESC;

/*
"We're comparing base compensation between two core foundational skills across the entire database: 
python and sql.
Write a query that groups by the skill name and returns:
The skill name
Total postings requiring that skill
Average annual salary (rounded to 2 decimal places)
The yearly-to-hourly equivalent rate (take the average annual 
salary and divide it by 2080 working hours in a year, rounded to 2 decimal places)
Constraints: Do NOT use CASE or FILTER. Simply filter the skills directly 
to only include 'python' and 'sql' where salaries are not null. 
Group by the skill name and order by average annual salary descending."

python and sql
skill name
count of postings requiring the skill
avg annual salary
yearly to hourly (divided to 2080)
salary is not null
order by the avg salary
*/

SELECT
    sd.skills AS skill_name,
    COUNT (sjd.job_id) AS posting_count_with_salary,
    ROUND(AVG(salary_year_avg),2) AS avg_yearly_salary,
    ROUND(AVG(salary_year_avg)/2080,2) AS avg_hourly_salary
FROM
    job_postings_fact AS jpf
INNER JOIN skills_job_dim AS sjd
    ON jpf.job_id = sjd.job_id
INNER JOIN skills_dim AS sd
    ON sjd.skill_id = sd.skill_id
WHERE
    (LOWER(sd.skills) IN ('python','sql'))
    AND salary_year_avg IS NOT NULL
GROUP BY sd.skills
ORDER BY avg_yearly_salary DESC;
---------------------------------------------------------------------- subqueries and CTES
/*
Goal: Find all job postings that offer a salary higher than the average salary of the entire dataset.
Requirements:
Select job_id, job_title_short, and salary_year_avg.
Filter out NULL values for salary_year_avg.
Use a scalar subquery in the WHERE clause to filter for jobs paying strictly above the overall dataset average.
*/
SELECT
    job_id,
    job_title_short,
    salary_year_avg
FROM job_postings_fact
WHERE 
    salary_year_avg IS NOT NULL
    AND salary_year_avg > (SELECT AVG(salary_year_avg)
        FROM job_postings_fact
        WHERE salary_year_avg IS NOT NULL)
ORDER BY salary_year_avg DESC;
/*
┌─────────┬───────────────────────────┬─────────────────┐
│ job_id  │      job_title_short      │ salary_year_avg │
│  int32  │          varchar          │     double      │
├─────────┼───────────────────────────┼─────────────────┤
│  296745 │ Data Scientist            │        960000.0 │
│ 1231950 │ Data Scientist            │        920000.0 │
│  673003 │ Senior Data Scientist     │        890000.0 │
│ 1575798 │ Machine Learning Engineer │        875000.0 │
│ 1007105 │ Data Scientist            │        870000.0 │
│  856772 │ Data Scientist            │        850000.0 │
│ 1443865 │ Senior Data Engineer      │        800000.0 │
│ 1591743 │ Machine Learning Engineer │        800000.0 │
│ 1574285 │ Data Scientist            │        680000.0 │
│  142665 │ Data Analyst              │        650000.0 │
│  871759 │ Data Engineer             │        640000.0 │
│ 1335282 │ Data Scientist            │        640000.0 │
│  785438 │ Data Scientist            │        585000.0 │
│  499552 │ Data Scientist            │        550000.0 │
│  234407 │ Data Engineer             │        525000.0 │
│  543480 │ Data Scientist            │        525000.0 │
│ 1218524 │ Data Scientist            │        475000.0 │
│   95558 │ Senior Data Scientist     │        475000.0 │
│  685280 │ Senior Data Scientist     │        463500.0 │
│  770779 │ Data Scientist            │        450000.0 │
│     ·   │       ·                   │            ·    │
│     ·   │       ·                   │            ·    │
│     ·   │       ·                   │            ·    │
│ 1208147 │ Data Engineer             │        123800.0 │
│  966782 │ Data Scientist            │        123800.0 │
│  962150 │ Data Scientist            │        123800.0 │
│  965748 │ Data Analyst              │        123800.0 │
│  971469 │ Data Scientist            │        123800.0 │
│  974571 │ Data Scientist            │        123800.0 │
│  963712 │ Data Scientist            │        123800.0 │
│  967313 │ Data Scientist            │        123800.0 │
│ 1487983 │ Data Analyst              │        123800.0 │
│ 1234149 │ Data Scientist            │        123800.0 │
│ 1219217 │ Data Scientist            │        123800.0 │
│ 1224995 │ Data Engineer             │        123800.0 │
│ 1244412 │ Data Analyst              │        123800.0 │
│ 1283913 │ Data Engineer             │        123800.0 │
│ 1317979 │ Senior Data Analyst       │        123800.0 │
│ 1249507 │ Data Engineer             │        123800.0 │
│ 1295298 │ Data Engineer             │        123800.0 │
│ 1253270 │ Data Engineer             │        123800.0 │
│ 1254574 │ Data Scientist            │        123800.0 │
│ 1219114 │ Data Scientist            │        123800.0 │
└─────────┴───────────────────────────┴─────────────────┘
*/
/*
Goal: Retrieve a list of unique companies that have posted at least one remote job paying over $100,000.
Requirements:
Select company_id and name from company_dim.
Use WHERE EXISTS with a correlated subquery targeting job_postings_fact.
Ensure your subquery properly links company_id between both tables and applies 
the filter conditions (job_work_from_home = TRUE and salary_year_avg > 100000).
*/
SELECT
    cd.company_id,
    cd.name AS company_name
FROM company_dim AS cd
WHERE EXISTS 
    (SELECT 1 FROM job_postings_fact AS jpf
    WHERE jpf.company_id = cd.company_id 
    AND job_work_from_home = TRUE 
    AND salary_year_avg >100000);
/*
┌────────────┬──────────────────────────────────────────────────┐
│ company_id │                   company_name                   │
│   int32    │                     varchar                      │
├────────────┼──────────────────────────────────────────────────┤
│       4619 │ Intellisoft Technologies                         │
│       4629 │ SynergisticIT                                    │
│       4635 │ Cox Automotive                                   │
│       4638 │ PayPal                                           │
│       4641 │ Jobot                                            │
│       4642 │ ApTask                                           │
│       4645 │ Pyramid Consulting, Inc                          │
│       4646 │ Marathon TS                                      │
│       4652 │ Ancestry                                         │
│       4659 │ IBM                                              │
│       4662 │ The Walt Disney Company                          │
│       4765 │ Confidential                                     │
│       4782 │ Citi                                             │
│       4794 │ Infinity Consulting Solutions, Inc.              │
│       4816 │ Burtch Works                                     │
│       4821 │ Labcorp                                          │
│       4830 │ Capital One                                      │
│       4838 │ General Dynamics Information Technology          │
│       4846 │ Datadog                                          │
│       4867 │ Harnham                                          │
│         ·  │   ·                                              │
│         ·  │   ·                                              │
│         ·  │   ·                                              │
│    1255504 │ WorkOS                                           │
│    1257340 │ Sony Group Corporation                           │
│    1271344 │ BuildOps                                         │
│    1303340 │ Chartis                                          │
│    1308135 │ hermeneutic Investments                          │
│    1335284 │ 01460 Continental Casualty Company               │
│    1359035 │ IR                                               │
│    1366035 │ EBSCO                                            │
│    1366403 │ Confirmo                                         │
│    1378454 │ Optimiza                                         │
│    1437853 │ MGA Entertainment                                │
│    1443940 │ Healthfirst, Inc                                 │
│    1550389 │ Colossus Technologies Group                      │
│    1593119 │ TMP Worldwide India Private Limited for ERS US   │
│    1605732 │ PayScale                                         │
│    1616078 │ 174 Power Global                                 │
│    1616786 │ National Association of State Workforce Agencies │
│    1618409 │ ADVANCED MONITORED CAREGIVING INC                │
│    1619857 │ Axyde Analytics                                  │
│    1619929 │ Beehive Industries, LLC                          │
└────────────┴──────────────────────────────────────────────────┘
*/
/*
Goal: Identify job roles where the median salary exceeds $120,000, and count how many postings exist for those roles.
Requirements:
Step 1 (CTE): Create a CTE named role_stats that calculates job_title_short, MEDIAN(salary_year_avg) AS median_sal, 
and COUNT(*) AS posting_count, grouped by job_title_short (excluding NULL salaries).
Step 2 (Main Query): Query role_stats, filtering for median_sal > 120000 and ordering by median_sal DESC.
*/
WITH role_stats AS(
        SELECT
            job_title_short,
            MEDIAN(salary_year_avg)::INT AS median_salary,
            COUNT(*) AS posting_count
        FROM job_postings_fact AS jpf
        WHERE salary_year_avg IS NOT NULL
        GROUP BY job_title_short)
SELECT *
FROM role_stats
WHERE median_salary > 120000
ORDER BY median_salary DESC;
/*
┌───────────────────────────┬───────────────┬───────────────┐
│      job_title_short      │ median_salary │ posting_count │
│          varchar          │     int32     │     int64     │
├───────────────────────────┼───────────────┼───────────────┤
│ Senior Data Scientist     │        156500 │          3271 │
│ Senior Data Engineer      │        147500 │          3283 │
│ Software Engineer         │        144000 │          1578 │
│ Machine Learning Engineer │        135000 │          1334 │
│ Data Engineer             │        130000 │         10551 │
│ Data Scientist            │        125320 │         12625 │
└───────────────────────────┴───────────────┴───────────────┘
*/