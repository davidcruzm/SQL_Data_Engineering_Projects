--This lesson will provide information of how to create and delete a database, a schema, and a table, alongside altering values into a table (add,drop,rename,alter)
-- Using IF EXISTS and IF NOT EXISTS allows to re-run the query as many times as it takes, it is called idempotent

--.read Lessons/1.21/1.21_DDL_DML_pt1.sql

USE data_jobs;

SHOW DATABASES;

DROP DATABASE IF EXISTS job_mart;

SHOW DATABASES;

--CREATE DATABASE job_mart;                   --Will create a database, if exist it will throw an error
CREATE DATABASE IF NOT EXISTS job_mart;     --Will create a database, if exist it will ignore the CREATE statement

--DROP DATABASE job_mart;                   --Will delete a database, if not exist it will throw an error
--DROP DATABASE IF EXISTS job_mart;         --Will delete a database, if not exist it will ignore the DROP statement

--Create an schema in the staging area means it is in the preparation area, it is raw.
CREATE SCHEMA IF NOT EXISTS job_mart.staging;
--DROP SCHEMA job_mart.staging;

CREATE TABLE IF NOT EXISTS job_mart.staging.preferred_roles (
    role_id INTEGER PRIMARY KEY,
    role_name VARCHAR
);

USE job_mart;

--DROP TABLE job_mart.main.preferred_roles;

SELECT *
FROM information_schema.schemata;

SELECT *
FROM information_schema.tables
WHERE table_catalog = 'job_mart';

INSERT INTO staging.preferred_roles (role_id, role_name)
VALUES
    (1, 'Data Engineer'),
    (2, 'Senior Data Engineer'),
    (3, 'Software Engineer');

/*
SELECT *
FROM staging.preferred_roles;
*/

ALTER TABLE staging.preferred_roles
ADD COLUMN preferred_role BOOLEAN;

/*
ALTER TABLE staging.preferred_roles
DROP COLUMN preferred_role;
*/

UPDATE staging.preferred_roles
SET preferred_role = TRUE
WHERE role_id IN (1,2);

UPDATE staging.preferred_roles
SET preferred_role = FALSE
WHERE role_id IN (3);

ALTER TABLE staging.preferred_roles
RENAME TO priority_roles;

ALTER TABLE staging.priority_roles
RENAME COLUMN preferred_role TO priority_lvl;

ALTER TABLE staging.priority_roles
ALTER COLUMN priority_lvl TYPE INTEGER;

UPDATE staging.priority_roles
SET priority_lvl = 3
WHERE role_id = 3;

SELECT *
FROM staging.priority_roles;

.read Lessons/1.21/1.21_DDL_DML_pt1.sql