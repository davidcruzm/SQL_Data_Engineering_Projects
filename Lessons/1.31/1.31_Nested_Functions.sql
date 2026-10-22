-- Array intro (Ordered collection of same-type values, indexed).
-- An Array (or List) is an ordered collection of values of the same data type stored inside a single cell.
SELECT [1, 2, 3] AS number_array;
/*
┌──────────────┐
│ number_array │
│   int32[]    │
├──────────────┤
│ [1, 2, 3]    │
└──────────────┘
*/
SELECT ['sql', 'python', 'r'] AS skills_array;
/*
┌──────────────────┐
│   skills_array   │
│    varchar[]     │
├──────────────────┤
│ [sql, python, r] │
└──────────────────┘
*/
--This is an example of how to create columns full of data of skills

WITH skills_cte AS(
    SELECT 'sql' AS skills
    UNION ALL
    SELECT 'python'
    UNION ALL
    SELECT 'r'
), skills_array_cte AS(
    SELECT ARRAY_AGG/*LIST() will work the same*/(skills ORDER BY skills) AS skills_array
    FROM skills_cte
)
SELECT
    skills_array[1] AS first_skill,
    skills_array[2] AS second_skill,
    skills_array[3] AS third_skill
FROM skills_array_cte; 


/*
First is to create a table if we don't have one
┌─────────┐
│ skills  │
│ varchar │
├─────────┤
│ sql     │
│ python  │
│ r       │
└─────────┘
Then combining into an array and ordering in alphabetical order
┌──────────────────┐
│   skills_array   │
│    varchar[]     │
├──────────────────┤
│ [python, r, sql] │
└──────────────────┘
The final output is to separate the array into single value columns
┌─────────────┬──────────────┬─────────────┐
│ first_skill │ second_skill │ third_skill │
│   varchar   │   varchar    │   varchar   │
├─────────────┼──────────────┼─────────────┤
│ python      │ r            │ sql         │
└─────────────┴──────────────┴─────────────┘
*/
-----------------------------------------------------------------------------------------------------------------------------------------
-- STRUCT/RECORD/ROW intro (Composite data type with multiple name fields). column_name.field_name
-- A Struct (short for Structure) is a fixed container of named key-value pairs, where each key (field) can have a different data type.
SELECT { skill:'python', type:'programming'} AS skill_struct;
/* In this table, the skill and "type" fields have varchar values (python, programming)
┌────────────────────────────────────────┐
│              skill_struct              │
│ struct(skill varchar, "type" varchar)  │
├────────────────────────────────────────┤
│ {'skill': python, 'type': programming} │
└────────────────────────────────────────┘
*/

-- STRUCT_PACK() and "{}" work the same
WITH skill_struct AS(
    SELECT
        STRUCT_PACK(
            skill := 'python',
            type := 'programming'
        ) AS s
)
SELECT
    s.skill, --(column_name.field_name) to access to the value
    s.type
FROM skill_struct;
/*
┌─────────┬─────────────┐
│  skill  │    type     │
│ varchar │   varchar   │
├─────────┼─────────────┤
│ python  │ programming │
└─────────┴─────────────┘
*/

WITH skill_table AS(
    SELECT 'sql' AS skills, 'query_language' AS types
    UNION ALL
    SELECT 'python', 'programming'
    UNION ALL
    SELECT 'r', 'programming'
),
/* First we need to create a table if we don't have one 
┌─────────┬────────────────┐
│ skills  │     types      │
│ varchar │    varchar     │
├─────────┼────────────────┤
│ sql     │ query_language │
│ python  │ programming    │
│ r       │ programming    │
└─────────┴────────────────┘
*/
packed_skill AS(
    SELECT
        {skill: skills,
        type: types} AS skill_struct
    FROM skill_table
)
/* And create a struct to pack multiple columns into a single nested object/cell per row.
┌────────────────────────────────────────┐
│              skill_struct              │
│ struct(skill varchar, "type" varchar)  │
├────────────────────────────────────────┤
│ {'skill': sql, 'type': query_language} │
│ {'skill': python, 'type': programming} │
│ {'skill': r, 'type': programming}      │
└────────────────────────────────────────┘
*/
SELECT
    skill_struct.skill,
    skill_struct.type
FROM packed_skill;
/* The final output is to unpack the struct into separate columns
┌─────────┬────────────────┐
│  skill  │      type      │
│ varchar │    varchar     │
├─────────┼────────────────┤
│ sql     │ query_language │
│ python  │ programming    │
│ r       │ programming    │
└─────────┴────────────────┘
*/
-----------------------------------------------------------------------------------------------------------------------------------------
-- ARRAY OF STRUCTS (Ordered collection of struct records)
-- An Array of Structs combines both types: it is a list containing multiple complex records.
SELECT [
    {skill: 'python', type: 'programming'},
    {skill: 'sql', type: 'query_language'}
] AS skills_array_of_struct;
/*
┌──────────────────────────────────────────────────────────────────────────────────┐
│                              skills_array_of_struct                              │
│                     struct(skill varchar, "type" varchar)[]                      │
├──────────────────────────────────────────────────────────────────────────────────┤
│ [{'skill': python, 'type': programming}, {'skill': sql, 'type': query_language}] │
└──────────────────────────────────────────────────────────────────────────────────┘
*/
WITH skill_table AS(
    SELECT 'sql' AS skills, 'query_language' AS types
    UNION ALL
    SELECT 'python', 'programming'
    UNION ALL
    SELECT 'r', 'programming'
), skills_array_struct AS (
    SELECT
    ARRAY_AGG(
        {skill: skills,
        type: types}
        ORDER BY skills
     ) AS skill_struct
    FROM skill_table
)
SELECT 
    skill_struct[1].type,
    skill_struct[2].skill,
    skill_struct[3]
FROM skills_array_struct;
/*First we need to acces to our table
┌─────────┬────────────────┐
│ skills  │     types      │
│ varchar │    varchar     │
├─────────┼────────────────┤
│ sql     │ query_language │
│ python  │ programming    │
│ r       │ programming    │
└─────────┴────────────────┘
Then create an array of struct to wrap it up all the values into a single cell
┌─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
│                                                    skill_struct                                                     │
│                                       struct(skill varchar, "type" varchar)[]                                       │
├─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┤
│ [{'skill': python, 'type': programming}, {'skill': sql, 'type': query_language}, {'skill': r, 'type': programming}] │
└─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
The final output is to unpack the struct into separate columns (the third column is maintained as struct)
┌──────────────────────────┬─────────────────────────┬────────────────────────────────────────┐
│ (skill_struct[1])."type" │ (skill_struct[1]).skill │            skill_struct[3]             │
│         varchar          │         varchar         │ struct(skill varchar, "type" varchar)  │
├──────────────────────────┼─────────────────────────┼────────────────────────────────────────┤
│ programming              │ python                  │ {'skill': sql, 'type': query_language} │
└──────────────────────────┴─────────────────────────┴────────────────────────────────────────┘
*/
-----------------------------------------------------------------------------------------------------------------------------------------
-- MAP / OBJECT / DICTIONARY (Unordered collection of dynamic key-value pairs)
-- A Map (or Dictionary) is a collection of dynamic key-value pairs where all keys share one data type and all values share another data type.
SELECT MAP{'skill':'python', 'type':'programming'} AS skill_type; --MAP{'key-value':'value'}
/*
┌──────────────────────────────────┐
│            skill_type            │
│      map(varchar, varchar)       │
├──────────────────────────────────┤
│ {skill=python, type=programming} │
└──────────────────────────────────┘
*/
WITH skill_map AS(
    SELECT MAP{'skill':'python', 'type':'programming'} AS skill_type --the key value must be unique and the value the same data type
)
SELECT
    skill_type['skill'],
    skill_type['type']
FROM skill_map;
/*
┌─────────────────────┬────────────────────┐
│ skill_type['skill'] │ skill_type['type'] │
│       varchar       │      varchar       │
├─────────────────────┼────────────────────┤
│ python              │ programming        │
└─────────────────────┴────────────────────┘
*/

-----------------------------------------------------------------------------------------------------------------------------------------
-- JSON (text-based serialization format for nested data)
-- JSON (JavaScript Object Notation) is a text-based format that can represent all four structures above in a single, unstructured or semi-structured string.
-- JSON is commonly used for ingestion and serving

SELECT '{"skill":"python", "type":"programming"}'::JSON AS skill_json;
/*
┌──────────────────────────────────────────┐
│                skill_json                │
│                   json                   │
├──────────────────────────────────────────┤
│ {"skill":"python", "type":"programming"} │
└──────────────────────────────────────────┘
*/
WITH raw_skill_json AS (
    SELECT '{"skill":"python", "type":"programming"}'::JSON AS skill_json
)
SELECT
    {skill: json_extract_string(skill_json, '$.skill'),
     type: json_extract_string(skill_json, '$.type')} AS json_converted_to_struct

FROM
    raw_skill_json;
/* we converted a json file to a struct to query more easily 
┌────────────────────────────────────────┐
│        json_converted_to_struct        │
│ struct(skill varchar, "type" varchar)  │
├────────────────────────────────────────┤
│ {'skill': python, 'type': programming} │
*/

WITH raw_json AS(
    SELECT
        '[
        {"skill":"python","type":"programming"},
        {"skill":"sql","type":"query_language"},
        {"skill":"r","type":"programming"}
        ]' :: JSON AS skills_json
)
SELECT
    ARRAY_AGG(
        {skill: json_extract_string(e.value, 'skill'),
         type: json_extract_string(e.value, 'type')}
        ORDER BY json_extract_string(e.value, 'skill')
    ) as Sskills
FROM raw_json, json_each(skills_json) AS e;
    
/*
First we create the json file
┌──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
│                                                                 skills_json                                                                  │
│                                                                     json                                                                     │
├──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┤
│ [\n    {"skill":"python","type":"programming"},\n    {"skill":"sql","type":"query_language"},\n    {"skill":"r","type":"programming"}\n    ] │
└──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
Then we change to a more querable structure, in this case an array of struct
┌─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
│                                                       skills                                                        │
│                                       struct(skill varchar, "type" varchar)[]                                       │
├─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┤
│ [{'skill': python, 'type': programming}, {'skill': r, 'type': programming}, {'skill': sql, 'type': query_language}] │
└─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
*/


--Arrays - Final Example
--Build a flat skill table for co-workers to acess job titles, salary info, and skills in one table
CREATE OR REPLACE TEMP TABLE job_skills_array AS
SELECT
    jpf.job_id,
    jpf.job_title_short,
    jpf.salary_year_avg,
    ARRAY_AGG(sd.skills) AS skills_array
FROM job_postings_fact AS jpf
LEFT JOIN skills_job_dim AS sjd
    ON jpf.job_id = sjd.job_id
LEFT JOIN skills_dim AS sd
    ON sjd.skill_id = sd.skill_id
GROUP BY ALL;

-- From the perspective of a Data Analyst, analyze the median salary per skill

WITH flat_skills AS(
    SELECT
        job_id,
        job_title_short,
        salary_year_avg,
        UNNEST(skills_array) AS skills
    FROM job_skills_array
)
SELECT
    skills,
    MEDIAN(salary_year_avg) AS median_salary
FROM flat_skills
WHERE salary_year_avg IS NOT NULL
GROUP BY skills
ORDER BY median_salary DESC;
/*
┌─────────────────┬───────────────┐
│     skills      │ median_salary │
│     varchar     │    double     │
├─────────────────┼───────────────┤
│ fedora          │      182350.0 │
│ mongo           │      173500.0 │
│ debian          │      173000.0 │
│ haskell         │      165000.0 │
│ apl             │      160000.0 │
│ hugging face    │     157956.75 │
│ puppet          │      157500.0 │
│ watson          │     155391.25 │
│ rust            │      155000.0 │
│ dplyr           │      155000.0 │
│ ruby on rails   │      155000.0 │
│ golang          │      155000.0 │
│ theano          │      150000.0 │
│ pytorch         │      150000.0 │
│ cassandra       │      150000.0 │
│ node            │      150000.0 │
│ redis           │      150000.0 │
│ swift           │      147750.0 │
│ airflow         │      147500.0 │
│ gatsby          │      147500.0 │
│   ·             │          ·    │
│   ·             │          ·    │
│   ·             │          ·    │
│ spreadsheet     │       90000.0 │
│ laravel         │       90000.0 │
│ microsoft teams │       89833.5 │
│ kali            │       89100.0 │
│ trello          │       89100.0 │
│ planner         │       87761.0 │
│ sheets          │       87500.0 │
│ sass            │       87500.0 │
│ ms access       │  87379.890625 │
│ cobol           │       85000.0 │
│ ringcentral     │       83999.5 │
│ wrike           │       83980.0 │
│ outlook         │       83862.5 │
│ webex           │       81250.0 │
│ smartsheet      │       80811.0 │
│ powerbi         │       80000.0 │
│ colocation      │       67500.0 │
│ nuix            │       63700.0 │
│ symfony         │       61150.0 │
│ nuxt.js         │       33000.0 │
└─────────────────┴───────────────┘
  231 rows (40 shown)   2 columns
*/

-- Array of struct - Final Example
-- Build a flat skill & type table for co-workers to access job titles, salary info, skills, and type in one table

CREATE OR REPLACE TEMP TABLE job_skills_array_struct AS
SELECT
    jpf.job_id,
    jpf.job_title_short,
    jpf.salary_year_avg,
    ARRAY_AGG({
        skill_type: sd.type,
        skill_name: sd.skills
    }) AS skills_type
FROM job_postings_fact AS jpf
LEFT JOIN skills_job_dim AS sjd
    ON jpf.job_id = sjd.job_id
LEFT JOIN skills_dim AS sd
    ON sjd.skill_id = sd.skill_id
GROUP BY ALL;

-- From the perspective of a Data Analyst, analyze the median salary per type of skill

WITH flat_skill_table AS(
    SELECT
        job_id,
        job_title_short,
        salary_year_avg,
        UNNEST(skills_type).skill_type AS skill_type,
        UNNEST(skills_type).skill_name AS skill_name
    FROM job_skills_array_struct
)
SELECT
    skill_type,
    MEDIAN(salary_year_avg) AS median_salary
FROM flat_skill_table
GROUP BY 
    skill_type
ORDER BY median_salary DESC;
/*
┌───────────────┬───────────────┐
│  skill_type   │ median_salary │
│    varchar    │    double     │
├───────────────┼───────────────┤
│ libraries     │      140000.0 │
│ cloud         │      132500.0 │
│ other         │      130000.0 │
│ databases     │      125000.0 │
│ sync          │      125000.0 │
│ webframeworks │      125000.0 │
│ programming   │      125000.0 │
│ os            │      122087.0 │
│ async         │      120000.0 │
│ analyst_tools │      103000.0 │
│ NULL          │      100430.0 │
└───────────────┴───────────────┘
*/