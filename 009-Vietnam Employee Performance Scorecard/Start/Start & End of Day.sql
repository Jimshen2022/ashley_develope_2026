select [work_day]
     , [wh_id]
     , [employee_id]
     , [First_Move]
     , [Last_Move]
     , process_start_id
     , process_start_name
     , process_start_code
     , process_end_id
     , process_end_name
     , process_end_code
     , [employeenumber]
     , [Clock_In]
     , [Clock_out]
from
(
    select p.[work_day]
         , p.[wh_id]
         , p.[employee_id]
         , p.[employeenumber]
         , p.EmployeeName
         , p.Clock_In
         , p.First_Move
         , p.Last_Move
         , p.process_start_id
         , p.process_start_name
         , p.process_start_code
         , p.process_end_id
         , p.process_end_name
         , p.process_end_code
         , p.Clock_out
         , datediff(minute, p.Clock_In, p.First_Move) as [start_min]
         , datediff(minute, p.Last_Move, p.Clock_out) as [end_min]
    from
    (
        select a.[work_day]
             , a.[wh_id]
             , a.[employee_id]
             , (a.[process_start]) as [First_Move]
             , (a.[process_end])   as [Last_Move]
             , a.process_start_id
             , a.process_start_name
             , a.process_start_code
             , a.process_end_id
             , a.process_end_name
             , a.process_end_code
             , a.[home_department]
             , a.[labor_type]
             , a.[employeenumber]
             , a.EmployeeName
             , (z.[c_in])          as Clock_In
             , (z.[c_out])         as Clock_out
        from
        (
            select distinct
                   t1.*
                 , t2.process_id   as process_start_id
                 , t3.process_id   as process_end_id
                 , t4.process_name as process_start_name
                 , t4.process_code as process_start_code
                 , t5.process_name as process_end_name
                 , t5.process_code as process_end_code
            from
            (
                select distinct
                       a.[work_day]
                     , a.[wh_id]
                     , a.[employee_id]
                     , min(a.[process_start]) as [process_start]
                     , max(a.[process_end])   as [process_end]
                     , a.[home_department]
                     , a.[labor_type]
                     , b.[EmployeeNumber]
                     , b.EmployeeName
                from [Distribution_Warehouse_Wholesale].[ProcessReport]          a
                    inner join [PowerBI_Distribution].[DimEmployee]              b
                        on CONCAT(a.wh_id, a.employee_id) = concat(b.warehouseid, b.employeeid)
                    inner join [Distribution_Warehouse_Wholesale].[t_la_process] c
                        on a.wh_id = c.wh_id
                           and a.process_id = c.process_id
                           and c.labor_type = 'DIR'
                where a.[work_day] > dateadd(day, -15, getdate())
                      and a.[labor_type] = 'DIR'
                      and a.type = 'I'
                      and process_code not in ( 'LOG ON', 'MENU', 'TRAVEL', 'BREAK-OVER', 'LUNCH-OVER', 'REJECTED' )
                group by a.[work_day]
                       , a.[wh_id]
                       , a.[employee_id]
                       , a.[home_department]
                       , a.[labor_type]
                       , b.[employeenumber]
                       , b.EmployeeName
            )                                                               t1 --main table giving minimum process start and maximum process end
                left join
                (
                    select a.*
                    from [Distribution_Warehouse_Wholesale].[ProcessReport]          a
                        inner join [Distribution_Warehouse_Wholesale].[t_la_process] c
                            on a.wh_id = c.wh_id
                               and a.process_id = c.process_id
                               and c.labor_type = 'DIR'
                    where a.[work_day] > dateadd(day, -15, getdate())
                          and a.[labor_type] = 'DIR'
                          and a.type = 'I'
                          and process_code not in ( 'LOG ON', 'MENU', 'TRAVEL', 'BREAK-OVER', 'LUNCH-OVER', 'REJECTED' )
                )                                                           t2 --table to get process start id. filtering conditions applied similar to table t1 in order to make sure similar subset is selected
                    on t1.wh_id = t2.wh_id
                       and t1.[employee_id] = t2.employee_id
                       and t1.[process_start] = t2.process_start
                       and t1.[home_department] = t2.home_department
                left join
                (
                    select a.*
                    from [Distribution_Warehouse_Wholesale].[ProcessReport]          a
                        inner join [Distribution_Warehouse_Wholesale].[t_la_process] c
                            on a.wh_id = c.wh_id
                               and a.process_id = c.process_id
                               and c.labor_type = 'DIR'
                    where a.[work_day] > dateadd(day, -15, getdate())
                          and a.[labor_type] = 'DIR'
                          and a.type = 'I'
                          and process_code not in ( 'LOG ON', 'MENU', 'TRAVEL', 'BREAK-OVER', 'LUNCH-OVER', 'REJECTED' )
                )                                                           t3 --table to get process end id. filtering conditions applied similar to table t1 in order to make sure similar subset is selected
                    on t1.wh_id = t3.wh_id
                       and t1.[employee_id] = t3.employee_id
                       and t1.[process_end] = t3.process_end
                       and t1.[home_department] = t3.home_department
                left join [Distribution_Warehouse_Wholesale].[t_la_process] t4 --table to get process start code and process start name related to process start id
                    on t2.wh_id = t4.wh_id
                       and t2.process_id = t4.process_id
                left join [Distribution_Warehouse_Wholesale].[t_la_process] t5 --table to get process start code and process start name related to process start id
                    on t3.wh_id = t5.wh_id
                       and t3.process_id = t5.process_id

        --WHERE  t1.wh_id = '1' AND CAST(t1.work_day AS DATE) = '2023-09-01' AND t1.[employee_id] = '5749'
        --WHERE  t1.wh_id = '28' AND CAST(t1.work_day AS DATE) = '2023-09-01' AND t1.[employee_id] = '1057004'

        )     a
            inner join
            (
                select [wh_id]
                     , [work_day]
                     , [home_department]
                     , min([clock_in])  as c_in
                     , max([clock_out]) as _c_out -- by crystal
                     , MAX(DATEADD(MINUTE, 
                        DATEDIFF(MINUTE, '00:00:00', CAST([clock_out] AS TIME)) / 15 * 15,
                        CAST(CAST([clock_out] AS DATE) AS DATETIME)
                                )) AS [c_out] -- Aug.24.2024 - to round the clock out time to the nearest 15 minutes by Jim,Shen 
                     , employee_id
                from [Distribution_Warehouse_Wholesale].[EmployeeClockInOut]
                where cast([work_day] as date)
                between dateadd(day, -15, getdate()) and getdate()  
                group by [wh_id]
                       , [work_day]
                       , [home_department]
                       , employee_id
            ) z
                on a.[wh_id] = z.[wh_id]
                   and a.[employee_id] = z.employee_id
                   and cast(a.[work_day] as date) = cast(z.[work_day] as date)
        where cast(a.[work_day] as date)
              between dateadd(day, -15, getdate()) and getdate()
              and a.[wh_id] in ( '335','35' )
              --and a.[home_department] in ( '1322', '3619', '2642', '3345', '4402', '4005', '1344', '3613', '2634'
               --                          , '3316', '4403', '4003', '1448', '3646', '2664', '3366', '4460', '4015'
               --                          , '1364', '3719', '2637', '3335', '4404', '4072', '1421', '2627', '3338'
                --                         , '4438', '1443', '3642', '2662', '3364', '4457', '4024', '5512', '4915'
                 --                        , '4901', '4914', '4904', '4972', '4905', '4924', '4903','4450','1345','1369'
                --                         ,'1370','2608','2638','2640','3337','3341', '4028'
                 --                        )
    ) p
) t1;
