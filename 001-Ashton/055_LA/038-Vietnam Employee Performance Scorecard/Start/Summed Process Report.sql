SELECT a.[wh_id]
         , b.[EmployeeName]
         , b.[EmployeeNumber]
         ,[process_transaction]
         , CAST([work_day] AS DATE)   [work_day]
         , SUM([actual_elapsed_time]) AS total_mins
         , count(a.[process_id])AS total_transactions
         , SUM([total_sam]) AS Total_SAM_MINS
         , a.[labor_type]
		 ,a.[process_id]
		 ,c.[process_code]
         , MIN(a.process_start) process_start_min
         , MAX(a.process_end)  process_end_max
    FROM [Distribution_Warehouse_Wholesale].[ProcessReport] a
        LEFT JOIN [PowerBI_Distribution].[DimEmployee]               b
            ON a.[employee_id] = b.[EmployeeID]
               AND a.[wh_id] = b.[WarehouseID]
         Left Join [Distribution_Warehouse_Wholesale].[t_la_process] c
		    ON a.[process_id] = c.[process_id]
               AND a.[wh_id] = c.[wh_id]
    WHERE a.[wh_id] IN ('335')
          AND [work_day] > DATEADD(DAY, -15, GETDATE())
          and a.[application]='WA'
    GROUP BY b.[EmployeeName]
           , b.[EmployeeNumber]
           , [work_day]
           , a.[wh_id]
           ,a.[process_transaction]
           ,a.[labor_type]
		   ,a.[process_id]
		   ,c.[process_code]


/*

select top 10 *
from Distribution_Warehouse_Wholesale.[t_la_process] as a
where a.[wh_id] = '335'

select top 10 *
FROM [Distribution_Warehouse_Wholesale].[ProcessReport]
where a.[wh_id] = '335'
-- 选择从 ProcessReport 表中提取的列以及与 DimEmployee 和 t_la_process 表联接后的相关数据
SELECT 
    a.[wh_id]                              -- 仓库 ID
    , b.[EmployeeName]                     -- 员工姓名
    , b.[EmployeeNumber]                   -- 员工编号
    , a.[process_transaction]              -- 处理交易信息
    , CAST(a.[work_day] AS DATE) AS [work_day]   -- 将工作日字段转换为日期格式
    , SUM(a.[actual_elapsed_time]) AS total_mins  -- 实际经过时间的总和（分钟）
    , COUNT(a.[process_id]) AS total_transactions -- 处理 ID 的数量，表示总交易数
    , SUM(a.[total_sam]) AS Total_SAM_MINS     -- 总 SAM（标准时间）的分钟数
    , a.[labor_type]                        -- 劳动类型
    , a.[process_id]                        -- 处理 ID
    , c.[process_code]                      -- 处理代码
    , MIN(a.process_start) AS process_start_min  -- 处理开始时间的最小值
    , MAX(a.process_end) AS process_end_max   -- 处理结束时间的最大值
FROM 
    [Distribution_Warehouse_Wholesale].[ProcessReport] a
    -- 从 DimEmployee 表联接以获取员工信息
    LEFT JOIN [PowerBI_Distribution].[DimEmployee] b
        ON a.[employee_id] = b.[EmployeeID]    -- 匹配员工 ID
        AND a.[wh_id] = b.[WarehouseID]       -- 匹配仓库 ID
    -- 从 t_la_process 表联接以获取处理代码信息
    LEFT JOIN [Distribution_Warehouse_Wholesale].[t_la_process] c
        ON a.[process_id] = c.[process_id]    -- 匹配处理 ID
        AND a.[wh_id] = c.[wh_id]             -- 匹配仓库 ID
WHERE 
    a.[wh_id] IN ('335')                    -- 仅选择仓库 ID 为 335 的记录
    AND a.[work_day] > DATEADD(DAY, -15, GETDATE())  -- 仅选择最近 15 天内的记录
    AND a.[application] = 'WA'              -- 仅选择应用类型为 'WA' 的记录
GROUP BY 
    b.[EmployeeName]                       -- 按员工姓名分组
    , b.[EmployeeNumber]                   -- 按员工编号分组
    , a.[work_day]                         -- 按工作日分组
    , a.[wh_id]                            -- 按仓库 ID 分组
    , a.[process_transaction]              -- 按处理交易信息分组
    , a.[labor_type]                       -- 按劳动类型分组
    , a.[process_id]                       -- 按处理 ID 分组
    , c.[process_code]                     -- 按处理代码分组

*/