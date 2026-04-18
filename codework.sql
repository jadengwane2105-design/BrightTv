--RUNNING THE ENTIRE TABLE FOR VIEWSHIP--
select * 
from `workspace`.`default`.`viewership` limit 100;

--CHANGING THE TIME ZONE--
SELECT 
    CAST(from_utc_timestamp(v.RecordDate2, 'Africa/Johannesburg') AS DATE) AS sast_date,
    from_utc_timestamp(v.RecordDate2, 'Africa/Johannesburg') AS sast_time,
    u.UserID,
    u.Name,
    u.Age,
    u.Province,
    v.Channel2,
    v.`Duration 2`
FROM workspace.default.user_profile AS u
INNER JOIN workspace.default.viewership AS v
    ON u.UserID = v.UserID0;


--RUNNING THE ENTIRE TABLE FOR USER PROFILE--
select * 
from `workspace`.`default`.`user_profile` limit 100;


--JOINING TABLE--
SELECT
    u.UserID,
    u.Name,
    u.Surname,
    u.Email,
    u.Gender,
    u.Race,
    u.Age,
    u.Province,
    v.UserID0,   -- the matching user ID column in viewership
    from_utc_timestamp(v.RecordDate2, 'Africa/Johannesburg') AS sast_time,
    v.Channel2,
    v.`Duration 2`
FROM workspace.default.user_profile AS u
INNER JOIN workspace.default.viewership AS v
    ON u.UserID = v.UserID0;


-- DAILY ACTIVE USERS IN SOUTH AFRICAN TIME --
SELECT CAST(CONVERT_TIMEZONE('UTC', 'Africa/Johannesburg', `RecordDate2`) AS DATE) AS event_date,
       COUNT(DISTINCT `UserID0`) AS daily_active_users
FROM `workspace`.`default`.`viewership`
GROUP BY CAST(CONVERT_TIMEZONE('UTC', 'Africa/Johannesburg', `RecordDate2`) AS DATE)
ORDER BY event_date;

-- DAILY ACTIVE USERS --
SELECT CAST(`RecordDate2` AS DATE) AS event_date,
       COUNT(DISTINCT `UserID0`) AS daily_active_users
FROM `workspace`.`default`.`viewership`
GROUP BY CAST(`RecordDate2` AS DATE)
ORDER BY event_date;

-- AVERAGE WATCH TIME PER USER --
SELECT `UserID0`,
       AVG(TIMESTAMPDIFF(SECOND, '1899-12-31', `Duration 2`)) AS avg_watch_seconds
FROM `workspace`.`default`.`viewership`
GROUP BY `UserID0`
ORDER BY avg_watch_seconds DESC;

--DAILY ACTIVE USERS--
SELECT CAST(`RecordDate2` AS DATE) AS event_date,
       COUNT(DISTINCT `UserID0`) AS daily_active_users
FROM `workspace`.`default`.`viewership`
GROUP BY CAST(`RecordDate2` AS DATE)
ORDER BY event_date;

-- HIGHEST STREAMING WEEK PER MONTH --
WITH weekly_streams AS (
    SELECT DATE_TRUNC('week', CAST(`RecordDate2` AS DATE)) AS week_start,
           DATE_TRUNC('month', CAST(`RecordDate2` AS DATE)) AS month_start,
           SUM(TIMESTAMPDIFF(SECOND, CAST('1899-12-31 00:00:00' AS TIMESTAMP), `Duration 2`)) AS total_watch_seconds
    FROM `workspace`.`default`.`viewership`
    GROUP BY DATE_TRUNC('week', CAST(`RecordDate2` AS DATE)),
             DATE_TRUNC('month', CAST(`RecordDate2` AS DATE))
)
SELECT month_start,
       week_start,
       total_watch_seconds,
       CASE 
         WHEN RANK() OVER (PARTITION BY month_start ORDER BY total_watch_seconds DESC) = 1
              THEN 'Highest Stream Week'
         ELSE 'Other Week'
       END AS week_category
FROM weekly_streams
ORDER BY month_start, week_start;

-- MOST POPULAR SHOW (BY WATCH TIME) --
SELECT v.`Channel2`,
       SUM(
         UNIX_TIMESTAMP(v.`Duration 2`) - UNIX_TIMESTAMP(CAST('1899-12-31 00:00:00' AS TIMESTAMP))
       ) AS total_watch_seconds
FROM `workspace`.`default`.`viewership` v
GROUP BY v.`Channel2`
ORDER BY total_watch_seconds DESC
LIMIT 1;


-- GROUP VIEWERS BY AGE (JOIN WITH USER PROFILE) --
SELECT CASE 
         WHEN age BETWEEN 13 AND 17 THEN 'Teen (13-17)'
         WHEN age BETWEEN 18 AND 24 THEN 'Young Adult (18-24)'
         WHEN age BETWEEN 25 AND 34 THEN 'Adult (25-34)'
         WHEN age BETWEEN 35 AND 49 THEN 'Middle Age (35-49)'
         ELSE '50+'
       END AS age_group,
       COUNT(DISTINCT `UserID0`) AS total_viewers,
       SUM(
         UNIX_TIMESTAMP(`Duration 2`) - UNIX_TIMESTAMP(CAST('1899-12-31 00:00:00' AS TIMESTAMP))
       ) AS total_watch_seconds
FROM `workspace`.`default`.`viewership` 
INNER JOIN `workspace`.`default`.`user_profile` 
  ON `userid4` = `userid4`
GROUP BY age_group
ORDER BY total_viewers DESC;
