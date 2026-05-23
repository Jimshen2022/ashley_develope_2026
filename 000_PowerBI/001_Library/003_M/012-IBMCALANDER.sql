WITH NUMS (N) AS (
    SELECT 1 FROM SYSIBM.SYSDUMMY1
    UNION ALL
    SELECT N+1 FROM NUMS WHERE N < 180
),
dates AS (
    SELECT 
        CURRENT_DATE - N DAYS AS date
    FROM 
        NUMS
),
time_table AS (
    SELECT 
        date,
        DAYNAME(date) AS Weekday,
        YEAR(date) AS year,
        QUARTER(date) AS quarter,
        WEEK(date) AS weeknum,
        YEAR(date) || WEEK(date) AS yearweek,
        WEEK(date) AS week
    FROM 
        dates
)
SELECT * FROM time_table
