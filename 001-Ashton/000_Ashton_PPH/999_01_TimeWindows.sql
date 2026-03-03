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
    start_tran_date >= '2025-04-06 07:00:00'
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
)
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