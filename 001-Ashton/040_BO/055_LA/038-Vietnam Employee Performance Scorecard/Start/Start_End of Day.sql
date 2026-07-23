DECLARE @wh_id_list AS VARCHAR(500);

SET @wh_id_list = '335, 35'; --both warehoueses are Vietnam, local time is 12 hours ahead 

SELECT 
t3.wh_id
,t3.employee_id
,t3.work_day
,t3.clock_in
,t3.clock_out
,t3.first_tran_date_time
,t3.last_tran_date_time
,t3.first_tran_type
,t3.first_tran_description
,t3.last_tran_type
,t3.last_tran_description
,t3.time_before_first_tran_minutes
,t3.time_after_last_tran_minutes

FROM
(
SELECT t2.*, tranlog_start.tran_type first_tran_type, tranlog_start.description first_tran_description, 
tranlog_end.tran_type last_tran_type, tranlog_end.description last_tran_description, 

DATEDIFF(MINUTE, clock_in, first_tran_date_time) AS time_before_first_tran_minutes, 
DATEDIFF(MINUTE, last_tran_date_time, clock_out) AS time_after_last_tran_minutes
, ROW_NUMBER() OVER (PARTITION BY t2.employee_id, t2.wh_id, t2.work_day ORDER BY t2.employee_id) row_number_rank
FROM
(

SELECT T1.wh_id
     , employee_id
     , l.[work_day]
     , l.clock_in
     , l.clock_out
	 , MIN(start_tran_date_time) first_tran_date_time 
	 , MAX(end_tran_date_time) last_tran_date_time
	 
	 
FROM
(
        SELECT wh_id
             , employee_id
             , item_number
             , start_tran_date
             , start_tran_time
             , end_tran_date
             , end_tran_time
             , hu_id
             , tran_qty
             , tran_type
             , description
             , CONCAT(CAST([start_tran_date] AS DATE), ' ', CAST([start_tran_time] AS TIME)) AS start_tran_date_time
             , CONCAT(CAST([end_tran_date] AS DATE), ' ', CAST([end_tran_time] AS TIME))     AS end_tran_date_time
        FROM [PowerBI_Distribution].[TranLog]
        WHERE CAST([start_tran_date] AS DATE)
              BETWEEN DATEADD(   DAY, -15, 
                                               
                                                   CAST(DATEADD(HOUR, 7, GETUTCDATE()) AS DATE)
                                           
                             ) AND DATEADD(   DAY, 1, 
                                                              CAST(DATEADD(HOUR, 7, GETUTCDATE()) AS DATE)
                                                      
                                          )
              AND [wh_id] IN
                  (
                      SELECT trim(value)FROM string_split(@wh_id_list, ',')
              
                  )
        AND [tran_type] <> '100'
)     t1
    LEFT JOIN
    (
        SELECT DISTINCT
               t.[work_day]
             , t.WhseEmpNumber
             , t.EmployeeNumber
             , t.EmployeeName
             , t.[home_department]
             , t.home_wh_id
             , MIN(t.clock_in)  clock_in
             , MAX(t.clock_out) clock_out
             , MAX(t.[End Time])       [End Time]
        FROM
        (
            SELECT [cico_key]
                 , [wh_id]
                 , b.WarehouseID
                 , a.home_wh_id
                 , [work_day]
                 , [work_shift_id]
                 , [employee_id]
                 , b.WhseEmpNumber
                 , b.EmployeeNumber
                 , b.EmployeeName
                 , [clock_in]
                 , [actual_clock_out] AS [clock_out]
                 , CASE
                       WHEN a.clock_out <> '' THEN
                           a.actual_clock_out
                       ELSE
                           DATEADD(HOUR, 7, GETUTCDATE())
                   END                                    AS [End Time]
                 , [supervisor_nbr]
                 , [home_supervisor_nbr]
                 , [group_nbr]
                 , [home_group_nbr]
                 , [department]
                 , [home_department]
            FROM [PowerBI_Distribution].[EmployeeClockInOut] a
                LEFT JOIN [PowerBI_Distribution].[DimEmployee]                        b
                    ON a.employee_id = b.EmployeeID
                       AND a.home_wh_id = b.WarehouseID
            WHERE CAST([work_day] AS DATE)
                  BETWEEN DATEADD(   DAY, -15, 
                                                       CAST(DATEADD(HOUR, 7, GETUTCDATE()) AS DATE)
                                               
                                 ) AND 
                                               CAST(DATEADD(HOUR, 7, GETUTCDATE()) AS DATE)
                                       

                  AND [home_wh_id] IN
                      (
                          SELECT trim(value) FROM string_split(@wh_id_list, ',')
                      )
        ) t
        GROUP BY t.work_day
               , t.WhseEmpNumber
               , t.EmployeeNumber
               , t.EmployeeName
               , t.home_department
               , t.home_wh_id

    ) l
        ON T1.[employee_id] = l.EmployeeNumber
           AND T1.[wh_id] = l.home_wh_id
WHERE

    T1.end_tran_date_time >= l.clock_in
    AND T1.end_tran_date_time <= CASE WHEN l.clock_out <> '' THEN l.clock_out ELSE [End Time] END
    AND T1.start_tran_date_time >= l.clock_in
    AND T1.start_tran_date_time <= CASE WHEN l.clock_out <> '' THEN l.clock_out ELSE [End Time] END
    AND l.clock_in IS NOT NULL
    AND l.clock_out IS NOT NULL
	AND DATEDIFF(Hour, l.clock_in, l.clock_out) < 24
GROUP BY
        t1.wh_id,
        t1.employee_id
       , l.work_day
       , l.clock_in
       , l.clock_out
	   ) t2

	   LEFT JOIN [PowerBI_Distribution].[TranLog] tranlog_start
	   ON t2.first_tran_date_time =  CONCAT(CAST(tranlog_start.[start_tran_date] AS DATE), ' ', CAST(tranlog_start.[start_tran_time] AS TIME))
	   and t2.employee_id = tranlog_start.employee_id
	   AND t2.wh_id = tranlog_start.wh_id

	   LEFT JOIN [PowerBI_Distribution].[TranLog] tranlog_end
	   ON t2.last_tran_date_time =   CONCAT(CAST(tranlog_end.[end_tran_date] AS DATE), ' ', CAST(tranlog_end.[end_tran_time] AS TIME))
	    and t2.employee_id = tranlog_end.employee_id
		AND t2.wh_id = tranlog_end.wh_id
) t3

WHERE row_number_rank = 1

