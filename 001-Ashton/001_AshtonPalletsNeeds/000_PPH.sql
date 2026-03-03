WITH CategoryBase AS (
    -- 计算 product_category，并正确转换时间
    SELECT *,
           CASE 
               WHEN LEFT(item_number, 1) IN ('0','1','2','3','4','5','6','7','8','9','U') THEN 'UPH'
               ELSE 'CG'
           END AS product_category,
           -- 正确合并日期和时间
           DATEADD(SECOND, DATEDIFF(SECOND, '00:00:00', CAST(start_tran_time AS TIME)), CAST(start_tran_date AS DATETIME2)) AS actual_start_time,
           DATEADD(SECOND, DATEDIFF(SECOND, '00:00:00', CAST(end_tran_time AS TIME)), CAST(end_tran_date AS DATETIME2)) AS actual_end_time
    FROM [PowerBI_Distribution].[TranLog]
    WHERE 
    start_tran_date >= '2025-01-01 07:00:00' 
      AND start_tran_date < DATEADD(HOUR, 7, DATEADD(DAY, -1, GETDATE()))  
    AND tran_type = '363'
	AND wh_id = '335'
),
TimeWindows AS (
    -- 计算 prev_end_time 和 indirect_time_seconds
    SELECT *,
           LAG(actual_end_time) OVER (
               PARTITION BY employee_id, product_category, CAST(start_tran_date AS DATE)
               ORDER BY actual_start_time
           ) AS prev_end_time,

           -- 计算不连续时间
           CASE 
               WHEN DATEDIFF(SECOND, 
                    LAG(actual_end_time) OVER (
                        PARTITION BY employee_id, product_category, CAST(start_tran_date AS DATE)
                        ORDER BY actual_start_time
                    ), 
                    actual_start_time) > 1800 
               THEN DATEDIFF(SECOND, 
                    LAG(actual_end_time) OVER (
                        PARTITION BY employee_id, product_category, CAST(start_tran_date AS DATE)
                        ORDER BY actual_start_time
                    ), 
                    actual_start_time)
               ELSE 0 
           END AS indirect_time_seconds
    FROM CategoryBase
),
TimeWindowsWithGroup AS (
    -- 计算 time_window_group
    SELECT *,
           CASE 
               WHEN prev_end_time IS NULL OR DATEDIFF(SECOND, prev_end_time, actual_start_time) > 1800 THEN 1
               ELSE 0
           END AS new_window_flag,

           SUM(
               CASE 
                   WHEN prev_end_time IS NULL OR DATEDIFF(SECOND, prev_end_time, actual_start_time) > 1800 THEN 1
                   ELSE 0
               END
           ) OVER (
               PARTITION BY employee_id, product_category, CAST(start_tran_date AS DATE)
               ORDER BY actual_start_time
               ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
           ) AS time_window_group

    FROM TimeWindows
),
FinalAggregation AS (
    -- 以时间窗口为单位计算每个员工的生产数据
    SELECT 
        product_category,
        employee_id,
        CAST(start_tran_date AS DATE) AS work_date,
        time_window_group,
        SUM(tran_qty) AS total_qty,
        DATEDIFF(SECOND, MIN(actual_start_time), MAX(actual_end_time)) AS total_work_seconds,
        DATEDIFF(SECOND, MIN(actual_start_time), MAX(actual_end_time)) / 3600.0 AS total_work_hours
    FROM TimeWindowsWithGroup
    GROUP BY 
        product_category,
        employee_id,
        CAST(start_tran_date AS DATE),
        time_window_group
)
-- 按 product_category 和 work_date 汇总
SELECT 
    product_category,
    CONVERT(VARCHAR(10), work_date, 120) AS work_date, -- 格式化日期为 YYYY-MM-DD
    SUM(total_qty) AS total_qty,
    SUM(total_work_seconds) AS total_work_seconds,
    ROUND(SUM(total_work_hours), 2) AS total_work_hours,
    COUNT(DISTINCT employee_id) AS unique_employee_count,

    -- 计算平均 PPH（每个员工的平均生产效率）
    ROUND(
        CASE 
            WHEN SUM(total_work_hours) = 0 OR COUNT(DISTINCT employee_id) = 0 
            THEN NULL 
            ELSE SUM(total_qty) / SUM(total_work_hours) 
        END, 2
    ) AS avg_pph_by_employee,

    -- 计算每个员工的平均日工作时长
    ROUND(
        CASE 
            WHEN COUNT(DISTINCT employee_id) = 0 
            THEN NULL
            ELSE SUM(total_work_hours) / NULLIF(COUNT(DISTINCT employee_id), 0) 
        END, 2
    ) AS avg_daily_work_hours,

    -- 计算基于每日工作小时的 PPH
    ROUND(
        CASE 
            WHEN SUM(total_work_hours) = 0 OR COUNT(DISTINCT employee_id) = 0 
            THEN NULL
            ELSE SUM(total_qty) / NULLIF(
                SUM(total_work_hours) / NULLIF(COUNT(DISTINCT employee_id), 0), 0) 
        END, 2
    ) AS avg_PPH_by_daily
FROM FinalAggregation
GROUP BY 
    product_category,
    work_date
ORDER BY 
    product_category,
    work_date;
