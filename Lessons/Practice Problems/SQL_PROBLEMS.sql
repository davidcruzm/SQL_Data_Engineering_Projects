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
"Hey David! We're reviewing our compensation strategy for Data Analysts vs. Data Engineers. 
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
"Hey David! We're auditing high-demand skills for Data Engineers.
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
