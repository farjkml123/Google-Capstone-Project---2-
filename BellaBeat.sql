-- Google Capstone Project - 2 
--How Can a Wellness Technology Company Play It Smart?

-- For the Data cleaning, preprocessing and mining I used PostgresSQL.


-- Analysing dailyActivity table (No. of Rows, Column Data type) 
-- No. of Rows
SELECT
	DISTINCT COUNT(*) AS "total_no_records"
FROM
	"dailyActivity_merged";


-- Column data type
SELECT 
    column_name,data_type 
FROM 
    information_schema.columns 
WHERE 
    table_name = 'dailyActivity_merged';


--  Casting columns and creating table for further analysis using Visualisation tool.

CREATE TABLE AvgActivity AS(
SELECT 
	CAST ("Id" AS NUMERIC) AS "Id",
	AVG(CAST (("VeryActiveMinutes") AS INT))::INT AS "Very",
	AVG(CAST (("ModeratelyActiveDistance") AS DOUBLE PRECISION)) AS "Moderate",
	AVG(CAST (("LightActiveDistance") AS DOUBLE PRECISION)) AS "Light",
	AVG(CAST (("SedentaryMinutes") AS INT))::INT AS "Inactive"
FROM 
	"dailyActivity_merged"
GROUP BY
	"Id"
);


-- Checking for duplicate entries
SELECT 
    "Id", "ActivityDate", "TotalSteps", Count(*)
FROM 
    "dailyActivity_merged"
GROUP BY 
    "Id", "ActivityDate", "TotalSteps"
HAVING 
    Count(*) > 1;
    

-- Converting and updating "SleepDay" format to Date
UPDATE 
	"sleepDay_merged"
SET 
	"SleepDay" = SUBSTRING("SleepDay", 1, 9)
RETURNING 
	*;
	
UPDATE
    "sleepDay_merged"
SET
    "SleepDay" = to_char(to_date("SleepDay", 'MM/DD/YYYY'), 'DD/MM/YYYY')	

SELECT "SleepDay" FROM "sleepDay_merged";


-- Converting and updating "ActivityDate" format to Date

UPDATE 
    "dailyActivity_merged"
SET
    "ActivityDate" = to_date("ActivityDate", 'mm/dd/yyyy')
RETURNING
    *;
 
UPDATE
    "dailyActivity_merged"
SET
    "ActivityDate" = to_char(to_date("ActivityDate", 'YYYY/MM/DD'), 'DD/MM/YYYY');   
 

-- Add day_of_week column to "dailyActivity_merged" table

ALTER TABLE 
    "dailyActivity_merged"
ADD 
    "day_of_week" VARCHAR(50);


-- Extract Datename from "ActivityDate"

UPDATE 
    "dailyActivity_merged"
SET 
    day_of_week =  EXTRACT(DOW FROM "ActivityDate");


-- Add Sleep Data columns to "dailyActivity_merged" table 

ALTER TABLE 
    "dailyActivity_merged"
ADD 
    TotalMinutesAsleep INT;
    
ALTER TABLE 
    "dailyActivity_merged"
ADD 
    TotalTimeInBed INT;
    
    
--Add sleep records into dailyActivity table
UPDATE 
    "dailyActivity_merged"
SET 
    "TotalMinutesAsleep" = sd."TotalMinutesAsleep",
    "TotalTimeInBed" = sd."TotalTimeInBed"
FROM 
    "dailyActivity_merged" AS da
FULL OUTER JOIN 
    "sleepDay_merged" AS sd
ON 
    da."Id" = sd."Id" AND da."ActivityDate" = sd."SleepDay";
    

--Adding specific date format to [dailyActivity_merged] table
ALTER TABLE 
    "dailyActivity_merged"
ADD 
    Date_d DATE; 
    
UPDATE
    "dailyActivity_merged"
SET
    Date_d = to_date("dailyActivity_merged"."ActivityDate", 'DD/MM/YYYY');

UPDATE
    "dailyActivity_merged"
SET
    date_d = to_char(to_date(date_d, 'YYYY/MM/DD'), 'DD/MM/YYYY');       


--Split date and time seperately for [hourlyCalories_merged] table

ALTER TABLE 
    "hourlyCalories_merged"
ADD 
    time_h INT;
UPDATE 
    "hourlyCalories_merged"
SET 
    "ActivityHour" = to_timestamp("ActivityHour", 'MM/DD/YYYY HH:MI:SS AM');
 
UPDATE 
    "hourlyCalories_merged"
SET 
    time_h = date_part('hour', "ActivityHour");
 
UPDATE 
    "hourlyCalories_merged"
SET
    "ActivityHour" = SUBSTRING("ActivityHour", 1, 10);
UPDATE
    "hourlyCalories_merged"
SET
    "ActivityHour" = to_char(to_date("ActivityHour", 'YYYY/MM/DD'), 'DD/MM/YYYY');
    

 
--Split date and time seperately for [hourlyIntensities_merged]

ALTER TABLE 
    "hourlyIntensities_merged"
ADD 
    time_h INT;
    
UPDATE   
    "hourlyIntensities_merged"
SET 
    "ActivityHour" = to_timestamp("ActivityHour", 'MM/DD/YYYY HH:MI:SS AM');

UPDATE 
    "hourlyIntensities_merged"
SET 
   time_h = date_part('hour', "ActivityHour");

UPDATE 
    "hourlyIntensities_merged"
SET
    "ActivityHour" = SUBSTRING("ActivityHour", 1, 10); 
    
UPDATE
    "hourlyIntensities_merged"
SET
    "ActivityHour" = to_char(to_date("ActivityHour", 'YYYY/MM/DD'), 'DD/MM/YYYY');
    
 
--Split date and time seperately for [minuteMETsNarrow_merged]

ALTER TABLE
    "minuteMETsNarrow_merged"
ADD     
    time_t  TIMESTAMP WITH TIME ZONE;

UPDATE 
    "minuteMETsNarrow_merged"
SET
    "ActivityMinute" = to_timestamp("ActivityMinute", 'MM/DD/YYY HH:MI:SS AM:PM');
 
UPDATE 
    "minuteMETsNarrow_merged"
SET 
    time_t = to_char("ActivityMinute", 'HH:MI:SS');

UPDATE 
    "minuteMETsNarrow_merged"
SET 
    "ActivityMinute" = SUBSTRING("ActivityMinute", 1, 10);
    
UPDATE
    "minuteMETsNarrow_merged"
SET
    "ActivityMinute" = to_char(to_date("ActivityMinute", 'YYYY/MM/DD'), 'DD/MM/YYYY');
    
 
--Split date and time seperately for [hourlySteps_merged]

ALTER TABLE 
    "hourlySteps_merged"
ADD     
    time_h INT;

UPDATE   
    "hourlySteps_merged"
SET 
    "ActivityHour" = to_timestamp("ActivityHour", 'MM/DD/YYYY HH:MI:SS');

UPDATE 
    "hourlySteps_merged"
SET
    time_h = date_part('hour', "ActivityHour");

UPDATE 
    "hourlySteps_merged"
SET
    "ActivityHour" = SUBSTRING("ActivityHour", 1, 10);  
 
UPDATE
    "hourlySteps_merged"
SET
    "ActivityHour" = to_char(to_date("ActivityHour", 'YYYY/MM/DD'), 'DD/MM/YYYY');


--Create new table to merge hourlyCalories, hourlyIntensities, and hourlySteps and later visualise 
CREATE TABLE hourly_cal_int_step_merge(
    Id NUMERIC(18, 0),
    Date_d VARCHAR(50),
    time_h INT,
    Calories NUMERIC(18, 0),
    TotalIntensity NUMERIC(18, 0),
    AverageIntensity DOUBLE PRECISION,
    StepTtoal NUMERIC(18, 0)
);


--Insert corresponsing data and merge multiple table into one table
INSERT INTO hourly_cal_int_step_merge(
    "Id", "Date_d", "Time_h", "Calories", "TotalIntensity", "AverageIntensity", "StepTotal"
)
(SELECT 
    t1."Id", t1."ActivityHour", t1."time_h", t1."Calories", t2."TotalIntensity", t2."AverageIntensity", t3."StepTotal"

FROM 
    "hourlyCalories_merged" AS t1
INNER JOIN 
    "hourlyIntensities_merged" AS t2
ON 
    t1."Id" = t2."Id" AND t1."ActivityHour" = t2."ActivityHour" AND t1."time_h" = t2."time_h"
INNER JOIN
    "hourlySteps_merged" AS t3
ON 
    t1."Id" = t3."Id" AND t1."ActivityHour" = t3."ActivityHour" AND t1."time_h" = t3."time_h");

SELECT 
    "Id", CAST("ActivityMinute" AS date) AS date_d, "METs", time_t
FROM 
    "minuteMETsNarrow_merged"
ORDER BY
    "Id";
    

--Change date type VARCHAR to date on MET table to join properly with other table

ALTER TABLE 
    "minuteMETsNarrow_merged"
ADD
    dates_d date;

UPDATE 
    "minuteMETsNarrow_merged"
SET
    dates_d = CAST("ActivityMinute" AS date);

X-------------------------------------------------------------------------------------------------X


-- ANALYSIS PHASE

--Calculate average met per day per user, and compare with the calories burned
UPDATE
    "dailyActivity_merged"
SET
    "ActivityDate" = to_char(to_date("ActivityDate", 'YYYY/MM/DD'), 'DD/MM/YYYY'); 


UPDATE
    "dailyActivity_merged"
SET
    "Date_d" = to_char(to_date("Date_d", 'YYYY/MM/DD'), 'DD/MM/YYYY');

UPDATE
    "minuteMETsNarrow_merged"
SET
    "dates_d" = to_char(to_date("dates_d", 'YYYY/MM/DD'), 'DD/MM/YYYY');
    
    
---------------------XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX---------------------------------------    
    
-- Creating tables for data visualisation, finding trends to answer the question.    
    
    
CREATE TABLE Avg_Met_Day AS(
SELECT DISTINCT  
    "t1"."Id", t1.dates_d, sum( "t1"."METs" ) AS sum_mets, "t2"."Calories"
FROM 
    "minuteMETsNarrow_merged" AS t1
INNER JOIN 
    "dailyActivity_merged" AS t2
ON 
    t1."Id" = t2."Id" AND t1.dates_d = "t2"."date_d"
GROUP BY 
    t1."Id", t1."dates_d", t2."Calories"
ORDER BY 
    t1.dates_d
);    
LIMIT 50;

--Activities and calories comparison

CREATE TABLE Act_VS_Cal AS(
SELECT "Id",
SUM("TotalSteps") AS total_steps,
SUM("VeryActiveMinutes") AS total_V_Active_mins,
Sum("FairlyActiveMinutes") AS total_F_Active_mins,
SUM("LightlyActiveMinutes") AS total_L_Active_mins,
SUM("Calories") AS total_calories_burned
FROM "dailyActivity_merged"
GROUP BY "Id" 
);


--Average Sleep Time per user

CREATE TABLE Avg_Sleep AS(
SELECT "Id", round(Avg("TotalMinutesAsleep")/60, 3) AS "Avg_Sleep_Time_Hour",
round(Avg("TotalTimeInBed")/60, 3) AS "Avg_Bed_Time_Hour",
round(AVG("TotalTimeInBed" - "TotalMinutesAsleep"), 3) AS "Idle_Bed_Time_Hour"
FROM "sleepDay_merged"
GROUP BY "Id"
);

--Sleep and calories comparison	

CREATE TABLE Slp_VS_Cal AS(
SELECT t1."Id", SUM("t1"."TotalMinutesAsleep") AS "TotalTimeAsleep",
SUM("t1"."TotalTimeInBed") AS "TotalTimeInBedMinutes",
SUM("Calories") AS "Calories"
FROM "dailyActivity_merged" AS t1
INNER JOIN "sleepDay_merged" AS t2
ON t1."Id" = t2."Id" AND "t1"."ActivityDate" = t2."SleepDay"
GROUP BY t1."Id"
);
 
--Daily Average analysis - No trends/patterns found

CREATE TABLE Avg_Daily AS(
SELECT DISTINCT AVG("TotalSteps") AS "Avg_Steps",
AVG("TotalDistance") AS "Avg_Dist",
AVG("Calories") AS "Avg_Calories",
to_char("ActivityDate", 'day') AS "Day_of_Week", day_of_week
FROM "dailyActivity_merged"
GROUP BY day_of_week, "ActivityDate"
ORDER BY day_of_week
);

--Time Expenditure per day
CREATE TABLE Time_Spent_Day AS(
SELECT DISTINCT "Id", SUM("SedentaryMinutes") AS "Sedentary_mins",
SUM("LightlyActiveMinutes") AS "LightActMin",
SUM("FairlyActiveMinutes") AS "FairlyActiveMin", 
SUM("VeryActiveMinutes") AS "VeryActiveMin"
FROM "dailyActivity_merged"
WHERE "TotalTimeInBed" IS NOT NULL
GROUP BY "Id"
ORDER BY "Id"
);