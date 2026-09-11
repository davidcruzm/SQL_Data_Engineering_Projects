/*
Question: What are the highest-paying skills for data engineers?

• Calculate the median salary for each skill required in data engineer positions
• Focus on remote positions with specified salaries
• Include skill frequency to identify both salary and demand
• Why?
    ◦ Helps identify which skills command the highest compensation while also showing how common those skills are,
     providing a more complete picture for skill development priorities.
    ◦ The median is used instead of the average to reduce the impact of outlier salaries.
    */

SELECT 
    sd.skills,
   ROUND (MEDIAN (salary_year_avg),0) AS median_salary,
    COUNT (jpf.*) AS demand_count,
   ROUND((COUNT( jpf.job_id) / 
        (SELECT COUNT(*) FROM job_postings_fact WHERE job_title_short = 'Data Engineer' 
        AND job_work_from_home)) * 100, 2) AS percentage
FROM job_postings_fact AS jpf
INNER JOIN skills_job_dim AS sjd
    ON sjd.job_id = jpf.job_id
INNER JOIN skills_dim AS sd
    ON sd.skill_id = sjd.skill_id
WHERE 
    job_title_short = 'Data Engineer'
AND
    job_work_from_home
GROUP BY sd.skills
HAVING COUNT(jpf.*) > 100
ORDER BY median_salary DESC
LIMIT 25;

/*
Here's the breakdown of the median salary, skills frequency
and percentage of Data Engineer focusing on remote jobs

The information is summarized into three key points:

1.  The highest-paying skills (Median Salary): 
Rust tops the list with the highest median salary ($210,000), 
followed by Golang and Terraform ($184,000). 
This demonstrates that specializing in systems programming and 
infrastructure as Code carries high financial compensation.

2.  The most popular skills (Frequency and Percentage): 
Airflow is the most requested tool on the list, 
appearing in 9,996 job postings, 
which represents 22.79% of the total analyzed market,
making it essential for large-scale data orchestration.

3.  The relationship between scarcity and salary: 
There is a clear trend where skills with lower frequency (such as Rust or Neo4j) 
offer very high salaries due to a shortage of qualified professionals, 
whereas standard industry tools (such as Airflow) 
maintain massive demand but with more standardized salaries ($150,000). 

            DIFFERENCE BETWEEN SALARY AND SKILL DEMAND
                    ON DATA ENGINEERS JOBS
┌────────────┬───────────────┬──────────────┬────────────┐
│   skills   │ median_salary │ demand_count │ percentage │
│  varchar   │    double     │    int64     │   double   │
├────────────┼───────────────┼──────────────┼────────────┤
│ rust       │      210000.0 │          232 │       0.53 │
│ golang     │      184000.0 │          912 │       2.08 │
│ terraform  │      184000.0 │         3248 │       7.41 │
│ spring     │      175500.0 │          364 │       0.83 │
│ neo4j      │      170000.0 │          277 │       0.63 │
│ gdpr       │      169616.0 │          582 │       1.33 │
│ zoom       │      168438.0 │          127 │       0.29 │
│ graphql    │      167500.0 │          445 │       1.01 │
│ mongo      │      162250.0 │          265 │        0.6 │
│ fastapi    │      157500.0 │          204 │       0.47 │
│ django     │      155000.0 │          265 │        0.6 │
│ bitbucket  │      155000.0 │          478 │       1.09 │
│ crystal    │      154224.0 │          129 │       0.29 │
│ c          │      151500.0 │          444 │       1.01 │
│ atlassian  │      151500.0 │          249 │       0.57 │
│ typescript │      151000.0 │          388 │       0.88 │
│ kubernetes │      150500.0 │         4202 │       9.58 │
│ css        │      150000.0 │          262 │        0.6 │
│ ruby       │      150000.0 │          736 │       1.68 │
│ airflow    │      150000.0 │         9996 │      22.79 │
│ node       │      150000.0 │          179 │       0.41 │
│ redis      │      149000.0 │          605 │       1.38 │
│ vmware     │      148798.0 │          136 │       0.31 │
│ ansible    │      148798.0 │          475 │       1.08 │
│ jupyter    │      147500.0 │          400 │       0.91 │
└────────────┴───────────────┴──────────────┴────────────┘
  25 rows                                      4 columns
  */