--Date: 12/4/23
-- added clockin, clockout difference filter where clockout is after clockin to remove  bad data

--Date: 11/30/23
-- added clockin, clockout difference filter of less than 24 hours to remove  bad data

--Date: 11/29/23
-- update code and time calculation for warehouse 335, 35 (Vietnam)
--Date: 8/2/23
-- updated query with parameters

--Date: 11/15/2022
-- removed worked days filter and added in the output

--Date: 6/21/2022
--comment: Added tran type 114(production casegood receipts). It will have only casegood category. Added warehouse 70(EST time zone)

--Date: 6/22/2022
--comment: Aggregated clock-in, clock out info for an employee on a work day as some employees having multiple clockins and clockout on same day due to lunch break being a clock out resulting in inflated PPH values (emp 138801)

DECLARE @wh_id_list AS VARCHAR(500);
DECLARE @tran_list AS VARCHAR(500);
DECLARE @tran_list_withoutPickPut AS VARCHAR(500);



SET @wh_id_list = '335, 35'; --both warehoueses are Vietnam, local time is 12 hours ahead 
SET @tran_list
    = '111, 119, 120, 151, 172, 201, 251, 253, 255, 262, 301, 303, 305, 307, 311, 313, 321, 325, 331, 401, 420, 601, 800, 810, 114';
SET @tran_list_withoutPickPut = '119, 120, 172, 251, 255, 301, 307, 331, 401, 420, 601, 800, 810, 114';



SELECT T1.wh_id
     , employee_id
     , employee_name
     --, supervisor_name
     , department_name
     , trantype_unit
     , tran_type
     , description
     , trantype_description
     --, concat(tran_type, '-', description)                            as trantype_description
     , l.[work_day]
     , l.actual_clock_in
     , l.actual_clock_out
     , l.WORKED_DAYS
     , DATEDIFF(SECOND, l.actual_clock_in, l.actual_clock_out) - 3600 AS spent_time_seconds
     , COUNT(DISTINCT [hu_id])                                        AS hu_id
     , COUNT([tran_qty])                                              AS count_of_tran
     , SUM([tran_qty])                                                AS sum_of_tran
     , CEILING(ABS(SUM(fractional_scoop)))                            AS fractional_hu_id
FROM
(
    SELECT T.*
         , T.tran_qty / NULLIF(i1.SCOOPQTY, 0) AS fractional_scoop
         , i1.SCOOPQTY
         , e.[WarehouseID]
         , e.[EMPLOYEENAME]              AS employee_name
         , e.[currentlyassigneddepartment]          AS department_id
         --, e.[SupervisorName]                  AS supervisor_name
         , G.[description]                 AS department_name
         , CASE
               WHEN T.tran_type IN ( SELECT trim(value)FROM string_split(@tran_list_withoutPickPut, ',')
                                   ) THEN
                   T.[tran_type]
               ELSE
                   concat(T.tran_type, '-', CASE WHEN i.[pick_put_id] = 'UPH' THEN 'UPH' ELSE 'CG' END)
           END                                 AS trantype_unit
         , concat(
                     CASE
                         WHEN T.tran_type IN ( SELECT trim(value)FROM string_split(@tran_list_withoutPickPut, ',')
                                             ) THEN
                             T.[tran_type]
                         ELSE
                             concat(T.tran_type, '-', CASE WHEN i.[pick_put_id] = 'UPH' THEN 'UPH' ELSE 'CG' END)
                     END, '-', T.description
                 )                             AS trantype_description
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
        FROM [Distribution_Warehouse_Wholesale].[TranLog]
        WHERE CAST([start_tran_date] AS DATE)
              --between '20211128' and '20211205'
              BETWEEN DATEADD(   WEEK, -2, 
                                               
                                                   CAST(DATEADD(HOUR, 7, GETUTCDATE()) AS DATE)
                                           
                             ) AND DATEADD(   DAY, 1, 
                                                              CAST(DATEADD(HOUR, 7, GETUTCDATE()) AS DATE)
                                                      
                                          )
              AND [wh_id] IN
                  (
                      SELECT trim(value)FROM string_split(@wh_id_list, ',')
                  )
              AND tran_type IN ( SELECT trim(value)FROM string_split(@tran_list, ',')
                               )
              AND
              (
                  description NOT LIKE 'RETRO%'
                  OR description NOT LIKE 'Retro%'
              )
    )                                                                T
        LEFT JOIN [PowerBI_Distribution].[DimEmployee]               E
            ON T.[employee_id] = e.[employeenumber]
               AND T.[wh_id] = e.[WarehouseID]
        LEFT JOIN [Distribution_Warehouse_Wholesale].[Department]          G
            ON E.[currentlyassigneddepartment] = g.[department]
               AND e.[warehouseid] = g.[wh_id]
        LEFT JOIN [Distribution_Warehouse_Wholesale].[t_item_master] i
            ON CAST(T.[wh_id] AS varchar(10)) = CAST(i.[wh_id] AS varchar(10))
               AND CAST(T.[item_number] AS VARCHAR(10)) = CAST(i.[item_number] AS VARCHAR(10))
        LEFT JOIN MasterData_ItemMaster_AFI.ITBEXT                   i1
            ON T.[wh_id] = i1.HOUSE
               AND T.item_number = i1.ITNBR

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
             , MIN(t.actual_clock_in)  actual_clock_in
             , MAX(t.actual_clock_out) actual_clock_out
             , MAX(t.[End Time])       [End Time]
             , t.WORKED_DAYS
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
                 , [clock_out]
                 , [actual_clock_in]
                 , [actual_clock_out]
                 , CASE
                       WHEN a.actual_clock_out <> '' THEN
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
                 , DATEDIFF(DAY, b.[HireDate], GETDATE()) AS WORKED_DAYS
            FROM [Distribution_Warehouse_Wholesale].[EmployeeClockInOut] a
                LEFT JOIN [PowerBI_Distribution].[DimEmployee]                        b
                    ON a.employee_id = b.EmployeeID
                       AND a.home_wh_id = b.WarehouseID
            WHERE CAST([work_day] AS DATE)
                  --between '20211128' and '20211204'
                  BETWEEN DATEADD(   WEEK, -2, 
                                                       CAST(DATEADD(HOUR, 7, GETUTCDATE()) AS DATE)
                                               
                                 ) AND 
                                               CAST(DATEADD(HOUR, 7, GETUTCDATE()) AS DATE)
                                       

                  AND [home_wh_id] IN
                      (
                          SELECT trim(value)FROM string_split(@wh_id_list, ',')
                      )
        ) t
        --where t.WORKED_DAYS > 42
        --and t.EmployeeNumber = '153092'
        GROUP BY t.work_day
               , t.WhseEmpNumber
               , t.EmployeeNumber
               , t.EmployeeName
               , t.home_department
               , t.home_wh_id
               , t.WORKED_DAYS
    --order by t.work_day desc

    ) l
        ON T1.[employee_id] = l.EmployeeNumber
           AND T1.[wh_id] = l.home_wh_id
WHERE
    /*
T.employee_id IN ( '123362' )
AND T.[start_tran_date]
BETWEEN '20210926' AND '20210927'
*/
    --AND
    T1.end_tran_date_time >= l.actual_clock_in
    AND T1.end_tran_date_time <= CASE WHEN l.actual_clock_out <> '' THEN l.actual_clock_out ELSE [End Time] END
    AND T1.start_tran_date_time >= l.actual_clock_in
    AND T1.start_tran_date_time <= CASE WHEN l.actual_clock_out <> '' THEN l.actual_clock_out ELSE [End Time] END
    AND l.actual_clock_in IS NOT NULL
    AND l.actual_clock_out IS NOT NULL
	AND DATEDIFF(Hour, l.actual_clock_in, l.actual_clock_out) < 24 --difference in clockout and clock in should not be more than 24 hrs, adding this condition to remove bad data
	AND DATEDIFF(Hour, l.actual_clock_in, l.actual_clock_out) >= 0 --clockout should be after clock in, adding this condition to remove bad data
GROUP BY T1.wh_id
       , employee_id
       , employee_name
       --, supervisor_name
       , department_name
       , trantype_unit
       , tran_type
       , DESCRIPTION
       , trantype_description
       , l.[work_day]
       , l.actual_clock_in
       , l.actual_clock_out
       , l.WORKED_DAYS;

--) t2;