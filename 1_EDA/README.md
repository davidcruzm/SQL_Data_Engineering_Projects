
# Exploratory Data Analysis w/ SQL: Job Market Analysis
![Project 1 Overview](../Images/1_1_Project1_EDA.png)
This is a SQL project analyzing the Data Engineer job market using real world job posting data. It demostrates my ability to **write production-quality, and turn business questions into data-driven insights**.

## Executive Summary  
- ✅ **Project scope:** Built **3 analytical queries** that answer key questions about the Data Engineer job market.  
- ✅ **Data modeling:** Used **multi-table joins** across fact, **subqueries** and dimension tables to extract insights.  
- ✅ **Analytics:** Applied **aggregations, filtering, subqueries and sorting** to find top skills by demand, salary, percentage and overall value.  
- ✅ **Outcomes:** Delivered **actionable insights** on SQL/Python dominance, cloud trends and salary patterns.  

If you only have a minute, review these:  
1. [`01_Top_Demanded_Skills_.sql`](../1_EDA/01_Top_Demanded_Skills.sql) - demand analysis.  
2. [`02_Top_Paying_Skills.sql`](../1_EDA/02_Top_Paying_Skills.sql) - salary analysis.  
3. [`03_Optimal_Skills.sql`](../1_EDA/03_Optimal_Skills.sql) - combined demand/salary optimization query.

## Problem & Context

Job market for Data Engineers need to answer questions like:  

- 🎯 **Most in-demand:** *Which skills are worth learning?*  
- 💰 **Highest paid:** *Which skills command the highest salaries?*
- ⚖️ **Best trade-off:** *What is the optimal skill set balancing demand and compensation?*  
This Project analyzes a **Data warehouse** build using a star schema design. The warehouse structure consists of:  
![Data Warehouse](../Images/1_2_Data_Warehouse.png)  
- **Fact Table:** `job_postings_fact` - Central table containing job posting details (job title, locations, salaries, dates, etc.)
- **Dimension Tables:**  
    - `company_dim` - Company information linked to job postings.
    - `skills_dim` - Skills catalog with skill names and types.  
- **Bridge Table:** `skills_job_dim` - Resolves the many-to-many relationhsip between job postings and skills.  
By querying across these interconnected tables I extracted insights about skill demand, salary patterns, and optimal skills combinations for Data Engineering roles.
## Tech Stack
- **Query Engine:** DuckDB for fast OLAP-Style analytical queries.
- **Language:** SQL (ANSI-Style with analytical functions).
- **Data Model:** Star schema with fact + dimension + bridge tables.
- **Development:** VS Code for SQL editing + Terminal (Git Bash) for DuckDB CLI.
- **Version Control:** Git/GitHub for versioned SQL scripts. 
## Analysis overview
### Query Structure
1. [**Top Demanded Skills**](../1_EDA/01_Top_Demanded_Skills.sql) - Identifies the 10 most in-demand skills for remote Data Engineer positions.
2. [**Top Paying Skills**](../1_EDA/02_Top_Paying_Skills.sql) - Analyzes the 25 highest-paying skills with salary and demand metrics.
3. [**Optimal Skills**](../1_EDA/03_Optimal_Skills.sql) - Calculates an optimal score using natural log of demand combined with median salary to identify the most valuable skills to learn.
### Key Insights
- 🧠 **Core languages:** SQL and Python each appear in ~29,000 job postings, making them the most demanded skills.
- ☁️ **Cloud Platform:** AWS and Azure are critical for modern Data Engineering roles.
- 🏗️ **Infra & Tooling:** Kubernetes, Docker, and Terraform are associated with premium salaries.
- 🔥**Big Data Tools:** Apache Spark shows strong demand with competitive compensation.
## SQL Skills Demostrated
### Query Design & Optimization  
- **Complex Joins:** Multi-Table `INNER JOIN` operations across `job_postings_fact`, `skills_job_dim` and `skills_dim`.
- **Advanced Subqueries:** Integrated uncorrelated subqueries to calculate dynamic market baselines and normalize metrics.
- **Aggregations:** `COUNT()`, `MEDIAN()`, `ROUND()` for statistical analysis.
- **Filtering:** Boolean logic with `WHERE` clauses and multiple conditions (`job_title_short = 'Data Engineer'`,`job_work_from_home`,`salary_year_avg IS NOT NULL`).
- **Sorting & Limiting:** `ORDER BY` with `DESC` and `LIMIT`.