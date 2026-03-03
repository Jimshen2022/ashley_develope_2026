SELECT TOP 1000 *  FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME LIKE '%work%'


SELECT top 10 *  FROM t_work_q where item_number in ('R408340')


SELECT *  FROM t_work_q  where work_type = '09' 
SELECT *  FROM t_location  where cycle_count_class = '2' 

SELECT  
    DATEADD(WEEK, DATEDIFF(WEEK, 0, date_due), 0) AS WeekStartDate,  -- ✅ 周一日期
    work_type,
    work_status,
    COUNT(DISTINCT work_q_id) AS work_qty 
FROM t_work_q 
WHERE work_type = '09' 
GROUP BY 
    DATEADD(WEEK, DATEDIFF(WEEK, 0, date_due), 0),
    work_type,
    work_status
ORDER BY 
    WeekStartDate DESC;




SELECT 
    CONCAT(YEAR(date_due), '-', RIGHT('00' + CAST(DATEPART(WEEK, date_due) AS VARCHAR), 2)) AS YearWeek,
    work_type,
    work_status,
    COUNT(DISTINCT work_q_id) AS work_qty
FROM t_work_q
WHERE work_type = '09'
GROUP BY 
    YEAR(date_due),
    DATEPART(WEEK, date_due),
    work_type,
    work_status
ORDER BY 
    YEAR(date_due) DESC,
    DATEPART(WEEK, date_due) DESC;


