/*
Question: What are the most optimal skills for data engineers—balancing both demand and salary?

* Create a ranking column that combines demand count and median salary to identify the most valuable skills.
* Focus only on remote Data Engineer positions with specified annual salaries.
* Why?
    * This approach highlights skills that balance market demand and financial reward. It weights core skills
     appropriately, rather than letting rare, outlier skills distort the results.
*/

SELECT
    sd.skills,
    ROUND(MEDIAN(jpf.salary_year_avg),0) AS median_salary,
    COUNT(jpf.*) AS demand_count,
    ROUND(LN(COUNT (jpf.*)),1) AS ln_demand_count,
    ROUND((MEDIAN(jpf.salary_year_avg) * LN(COUNT (jpf.*))/ 1_000_000),2) AS optimal_score
FROM job_postings_fact AS jpf
INNER JOIN skills_job_dim AS sjd
    ON sjd.job_id = jpf.job_id
INNER JOIN skills_dim AS sd
    ON sd.skill_id = sjd.skill_id
WHERE
    job_title_short = 'Data Engineer'
AND job_work_from_home
AND salary_year_avg IS NOT NULL
GROUP BY sd.skills
HAVING count (jpf.*) >100
ORDER BY optimal_score DESC
LIMIT 25;

/*
The table below shows the most popular skills for remote Data Engineers. 
It combines skill demand with median salary to calculate an 'optimal score,' 
helping identify the most valuable technologies for this role.

The Most Money: 
Terraform wins with the highest typical salary ($184,000). 
If you want the biggest paycheck on this list, this is it.

The Safest Bets: 
Python and SQL give you the best mix. 
Their pay is great ($130,000+) and they have the absolute highest job availability. 
They are the most required tools in the industry.

The Sweet Spot (Optimal Score): 
The list is ordered by "Optimal Score," which balances high pay with high job availability. 
Technologies at the top (like Terraform, Python, and SQL) offer the best return on your time investment.

        THE MOST OPTIMAL SKILLS FOR REMOTE DATA ENGINEERS
┌────────────┬───────────────┬──────────────┬─────────────────┬───────────────┐
│   skills   │ median_salary │ demand_count │ ln_demand_count │ optimal_score │
│  varchar   │    double     │    int64     │     double      │    double     │
├────────────┼───────────────┼──────────────┼─────────────────┼───────────────┤
│ terraform  │      184000.0 │          193 │             5.3 │          0.97 │
│ python     │      135000.0 │         1133 │             7.0 │          0.95 │
│ aws        │      137320.0 │          783 │             6.7 │          0.91 │
│ sql        │      130000.0 │         1128 │             7.0 │          0.91 │
│ airflow    │      150000.0 │          386 │             6.0 │          0.89 │
│ spark      │      140000.0 │          503 │             6.2 │          0.87 │
│ kafka      │      145000.0 │          292 │             5.7 │          0.82 │
│ snowflake  │      135500.0 │          438 │             6.1 │          0.82 │
│ azure      │      128000.0 │          475 │             6.2 │          0.79 │
│ java       │      135000.0 │          303 │             5.7 │          0.77 │
│ scala      │      137290.0 │          247 │             5.5 │          0.76 │
│ kubernetes │      150500.0 │          147 │             5.0 │          0.75 │
│ git        │      140000.0 │          208 │             5.3 │          0.75 │
│ databricks │      132750.0 │          266 │             5.6 │          0.74 │
│ redshift   │      130000.0 │          274 │             5.6 │          0.73 │
│ gcp        │      136000.0 │          196 │             5.3 │          0.72 │
│ nosql      │      134415.0 │          193 │             5.3 │          0.71 │
│ hadoop     │      135000.0 │          198 │             5.3 │          0.71 │
│ pyspark    │      140000.0 │          152 │             5.0 │           0.7 │
│ docker     │      135000.0 │          144 │             5.0 │          0.67 │
│ mongodb    │      135750.0 │          136 │             4.9 │          0.67 │
│ go         │      140000.0 │          113 │             4.7 │          0.66 │
│ r          │      134775.0 │          133 │             4.9 │          0.66 │
│ bigquery   │      135000.0 │          123 │             4.8 │          0.65 │
│ github     │      135000.0 │          127 │             4.8 │          0.65 │
└────────────┴───────────────┴──────────────┴─────────────────┴───────────────┘
  25 rows                                                           5 columns
*/