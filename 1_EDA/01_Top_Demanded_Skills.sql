/* What are the most in-demand skills for data engineers?
Identify the top 10 in-demand skills for data engineers
Focus on remote job postings
Why?
Retrieve the top 10 skills with the highest demand 
in the remote job market, providing insights into
the most valuable skills for data engineers seeking 
remote jobs
*/

SELECT
    sd.skills,
    COUNT (sd.skills) AS skill_count,
ROUND(
        (COUNT(jpf.job_id) / 
        (SELECT COUNT(*) FROM job_postings_fact WHERE job_title_short = 'Data Engineer' 
        AND job_work_from_home)) * 100, 2) AS percentage
FROM job_postings_fact AS jpf
INNER JOIN skills_job_dim AS sjd
    ON jpf.job_id = sjd.job_id
INNER JOIN skills_dim AS sd
    ON sd.skill_id = sjd.skill_id
WHERE job_title_short = 'Data Engineer' 
    AND job_work_from_home
GROUP BY sd.skills
ORDER BY skill_count DESC
LIMIT 10;

/*
The table below highlights the most demanded skills for remote Data Engineers in the US.

Key takeaway from this table:
1. The Core Fundations (SQL & Python): They are practically mandatory skills.
Over two-thirds of all remote Data Engineering jobs list both.

2. Cloud Dominance (AWS vs. Azure vs. GCP): AWS leads cloud adoption at 40.64%, 
followed by Azure at 32.25%, while GCP trails at 14.7%.

3. Data Processing & Orchestration: Spark (29.19%) and Airflow (22.79%) 
remain the primary compute and pipeline standards for enterprise data workflows.

        TOP SKILLS FOR DATA ENGINEER
┌────────────┬─────────────┬────────────┐
│   skills   │ skill_count │ percentage │
│  varchar   │    int64    │   double   │
├────────────┼─────────────┼────────────┤
│ sql        │       29221 │      66.63 │
│ python     │       28776 │      65.62 │
│ aws        │       17823 │      40.64 │
│ azure      │       14143 │      32.25 │
│ spark      │       12799 │      29.19 │
│ airflow    │        9996 │      22.79 │
│ snowflake  │        8639 │       19.7 │
│ databricks │        8183 │      18.66 │
│ java       │        7267 │      16.57 │
│ gcp        │        6446 │       14.7 │
└────────────┴─────────────┴────────────┘
*/