DECLARE @min_date       AS DATE          --minimum date of data pull
      , @whse_list      AS VARCHAR(MAX)  --whse list;
SET @min_date = DATEADD(DAY, -15, GETDATE());



SELECT [work_day]
     , [emp_number]
     , home_wh_id
     --, [t1].[work_shift_id]
     , [work_shift]
     , [source]
     , MIN([dept]) AS [dept]
     , [name]
     , [supervisor_nbr]
     , [supervisor]
     , [status]
     , [description]
	 , [return_date]
     , MIN(t1.clock_in)        clock_in   --aggregation to avoid data errors due to multiple clock ins
     , MAX(t1.[End Time])      [End Time] --accounting for cases where the shift is yet to complete
     , SUM(spent_time_minutes) AS spent_time_minutes
FROM
(
    SELECT DISTINCT
           t.[work_day]
         , t.[emp_number]
         , t.home_wh_id
         --, [t].[work_shift_id]
         , t.[source]
         , [work_shift]
         , t.[dept]
         , t.[name]
		 , t.[return_date]
         , t.[supervisor_nbr]
         , t.[supervisor]
         , t.[status]
         , t.[description]
         , t.clock_in
         , (t.[End Time])                                                    [End Time]
         , CAST(DATEDIFF(SECOND, t.clock_in, t.[End Time]) / 60.00 AS FLOAT) AS spent_time_minutes
    FROM
    (
        SELECT [home_wh_id]
             , CAST([work_day] AS DATE) [work_day]
             --, [work_shift_id]
             , [source]
             , b.[emp_number]
             , b.[work_shift]
             , [actual_clock_in]
             , [actual_clock_out]
             , [clock_in]
             , [clock_out]
             , a.[home_department] AS [dept]
             , b.[name]
             , b.[supervisor_nbr]
             , b.[supervisor]
             , b.[status]
             , c.[description]
			 , cast(b.[return_date] AS DATE) [return_date]
             , CASE
                   WHEN a.clock_out <> '' THEN
                       a.clock_out
                   ELSE
                       DATEADD(HOUR, 7, GETUTCDATE())
               END                      AS [End Time] --this case statement to assign correct end time if the shift is in progress for a current day and no clock out occured yet
        FROM [PowerBI_Distribution].[EmployeeClockInOut]  a
            LEFT JOIN [Distribution_Warehouse_Wholesale].[Employee]   b
                ON a.employee_id = b.employee_id
                   AND a.home_wh_id = b.wh_id
            LEFT JOIN [PowerBI_Distribution].[Department] c
                ON a.home_wh_id = c.wh_id
                   AND b.dept = c.department
        WHERE CAST([work_day] AS DATE)
              BETWEEN @min_date AND CAST(DATEADD(HOUR, 7, GETUTCDATE()) AS DATE) --this case statement to assign correct end time if the shift is in progress for a current day and no clock out occured yet

              AND a.home_wh_id IN ( '335','35' )
    --AND b.emp_number = '138801'
    ) t
    GROUP BY t.work_day
           , t.emp_number
           , t.home_wh_id
           --, t.work_shift_id
           , t.work_shift
           , t.[source]
           , t.[dept]
           , t.[name]
		   , t.[return_date]
           , t.[supervisor_nbr]
           , t.[supervisor]
           , t.[status]
           , t.[description]
           , t.clock_in
           , t.[End Time]
) t1 --aggregate table to calculate time spent between clock in and clock out
GROUP BY t1.work_day
       , t1.emp_number
       , t1.home_wh_id
       --, t1.work_shift_id
       , t1.work_shift
       , t1.[source]
       --, t1.[dept]
       , t1.[name]
	   , t1.[return_date]
       , t1.[supervisor_nbr]
       , t1.[supervisor]
       , t1.[status]
       , t1.[description]