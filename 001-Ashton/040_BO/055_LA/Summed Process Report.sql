SELECT
     a.[wh_id]
    ,b.[EmployeeName]
    ,b.[EmployeeNumber]
    ,a.[process_transaction]
    ,CAST(a.[work_day] AS DATE)                              AS [work_day]
    ,COUNT(a.[process_id])                                   AS total_transactions
    ,SUM(a.[total_sam])                                      AS Total_SAM_MINS
    ,a.[labor_type]
    ,a.[process_id]
    ,c.process_code
    ,SUM(
        CASE
            WHEN c.process_code LIKE 'LUNCH-OVER%'
             AND DATEPART(HOUR, a.process_start) >= 7
             AND DATEPART(HOUR, a.process_start) <  16
            THEN CASE
                    WHEN a.actual_elapsed_time - 15 < 0 THEN 0
                    ELSE a.actual_elapsed_time - 15
                 END
            ELSE a.actual_elapsed_time
        END
     )                                                       AS total_mins
    ,MIN(a.process_start)                                    AS process_start_min
    ,MAX(a.process_end)                                      AS process_end_max

FROM [Distribution_Warehouse_Wholesale].[ProcessReport]         a
    LEFT JOIN [PowerBI_Distribution].[DimEmployee]              b
           ON a.[employee_id]  = b.[EmployeeID]
          AND a.[wh_id]        = b.[WarehouseID]
    LEFT JOIN [Distribution_Warehouse_Wholesale].[t_la_process] c
           ON a.[process_id]   = c.[process_id]
          AND a.[wh_id]        = c.[wh_id]

WHERE a.[wh_id] IN ('335','35')
  AND  a.[work_day]    >  DATEADD(DAY, -15, GETDATE())
  AND  a.[application] =  'WA'

GROUP BY
     a.[wh_id]
    ,b.[EmployeeName]
    ,b.[EmployeeNumber]
    ,a.[process_transaction]
    ,CAST(a.[work_day] AS DATE)
    ,a.[labor_type]
    ,a.[process_id]
    ,c.[process_code]