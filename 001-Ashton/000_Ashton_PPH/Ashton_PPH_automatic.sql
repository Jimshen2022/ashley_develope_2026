-- 首先用 CTE 创建基础查询，添加 product_category 分类
WITH CategoryBase AS (
    SELECT *,
           CASE
               WHEN LEFT(item_number, 1) IN ('0','1','2','3','4','5','6','7','8','9','U') THEN 'UPH'
               ELSE 'CG'
           END AS product_category,
           -- 正确的时间转换方式，确保不会出错
           CAST(start_tran_date AS DATETIME2) + CAST(start_tran_time AS TIME) AS actual_start_time,
           CAST(end_tran_date AS DATETIME2) + CAST(end_tran_time AS TIME) AS actual_end_time
    FROM [PowerBI_Distribution].[TranLog]
    WHERE start_tran_date = '2025-02-21' AND tran_type = '363'
),

-- 识别连续的时间窗口并计算不连续时间
TimeWindows AS (
    SELECT *,
           -- 使用 LAG 函数查看上一条记录的结束时间
           LAG(actual_end_time) OVER (
               PARTITION BY employee_id, product_category, CAST(start_tran_date AS DATE)
               ORDER BY actual_start_time
           ) AS prev_end_time,

           -- 计算与上一条记录的时间间隔（不连续时间）
           CASE
               WHEN DATEDIFF(SECOND,
                    LAG(actual_end_time) OVER (
                        PARTITION BY employee_id, product_category, CAST(start_tran_date AS DATE)
                        ORDER BY actual_start_time
                    ),
                    actual_start_time) > 60
               THEN DATEDIFF(SECOND,
                    LAG(actual_end_time) OVER (
                        PARTITION BY employee_id, product_category, CAST(start_tran_date AS DATE)
                        ORDER BY actual_start_time
                    ),
                    actual_start_time)
               ELSE 0
           END AS indirect_time_seconds,

           -- 为每个新的时间窗口分配一个组号
           SUM(
               CASE
                   WHEN DATEDIFF(SECOND,
                       LAG(actual_end_time) OVER (
                           PARTITION BY employee_id, product_category, CAST(start_tran_date AS DATE)
                           ORDER BY actual_start_time
                       ),
                       actual_start_time) > 60
                       OR LAG(actual_end_time) OVER (
                           PARTITION BY employee_id, product_category, CAST(start_tran_date AS DATE)
                           ORDER BY actual_start_time
                       ) IS NULL
                   THEN 1
                   ELSE 0
               END
           ) OVER (
               PARTITION BY employee_id, product_category, CAST(start_tran_date AS DATE)
               ORDER BY actual_start_time
           ) AS time_window_group
    FROM CategoryBase
)

-- 最终汇总结果
SELECT
    product_category,
    employee_id,
    CAST(start_tran_date AS DATE) AS work_date,
    time_window_group,
    COUNT(*) AS transaction_count,
    SUM(tran_qty) AS total_qty,
    -- 计算每个时间窗口的总工作时间（秒）
    DATEDIFF(SECOND,
        MIN(actual_start_time),
        MAX(actual_end_time)
    ) AS total_work_seconds,
    -- 计算每个时间窗口内的总不连续时间（秒）
    SUM(indirect_time_seconds) AS indirect_time
FROM TimeWindows
GROUP BY
    product_category,
    employee_id,
    CAST(start_tran_date AS DATE),
    time_window_group
ORDER BY
    product_category,
    employee_id,
    CAST(start_tran_date AS DATE),
    time_window_group;
