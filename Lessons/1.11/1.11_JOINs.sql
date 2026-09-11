SELECT 
    COUNT (*)
FROM
    job_postings_fact;

SELECT
    jpf.job_id,
    jpf.job_title,
    cd.company_id
FROM
    job_postings_fact AS jpf
LEFT JOIN company_dim AS cd
    ON jpf.company_id = cd.company_id
;

SELECT *
FROM company_dim;
SELECT COUNT (*)
FROM job_postings_fact;
SELECT COUNT (*)
FROM skills_job_dim;
SELECT *
FROM skills_dim;

SELECT
    jpf.job_id,
    jpf.job_title,
    cd.company_id
FROM
    job_postings_fact AS jpf
RIGHT JOIN company_dim AS cd
    ON jpf.company_id = cd.company_id
;

SELECT
    jpf.job_id,
    jpf.job_title,
    cd.company_id
FROM
    job_postings_fact AS jpf
INNER JOIN company_dim AS cd
    ON jpf.company_id = cd.company_id
;

SELECT
    jpf.job_id,
    jpf.job_title,
    cd.company_id
FROM
    job_postings_fact AS jpf
FULL OUTER JOIN company_dim AS cd
    ON jpf.company_id = cd.company_id
;

SELECT
    jpf.job_id,
    jpf.job_title_short,
    sjd.skill_id,
    sd.skills,
    sd.type
FROM job_postings_fact AS jpf
LEFT JOIN skills_job_dim AS sjd
    ON jpf.job_id = sjd.job_id
LEFT JOIN skills_dim AS sd
    ON sjd.skill_id = sd.skill_id
LIMIT 10;