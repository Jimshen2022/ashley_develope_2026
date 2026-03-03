WITH employee AS (
    SELECT id, name, wh_id
    FROM Distribution_Warehouse_Wholesale.t_employee
    WHERE wh_id = '335'
),
-- 第一步：预处理，先统一截取 trip_number
CleanedLog AS (
    SELECT 
        [tran_type],
        CAST([start_tran_date] AS DATE) AS [start_tran_date],
        -- 在这里就完成截取，确保后续分组逻辑一致
        CAST(LEFT([control_number_2], CHARINDEX('-', [control_number_2] + '-') - 1) AS INT) AS trip_number,
        [wh_id],
        [employee_id],
        [tran_qty]
    FROM [PowerBI_Distribution].[TranLog]
    WHERE tran_type IN ('321', '621')
        AND start_tran_date > DATEADD(DAY, -80, GETDATE())
        AND [wh_id] = '335'
),
-- 第二步：聚合每个 Trip 中每个人的总量
EmployeeMetrics AS (
    SELECT 
        [tran_type],
        [start_tran_date],
        trip_number,
        [wh_id],
        [employee_id],
        SUM([tran_qty]) AS Emp_Qty,
        SUM(SUM([tran_qty])) OVER(PARTITION BY trip_number) AS Trip_Total_Qty
    FROM CleanedLog
    GROUP BY [tran_type], [start_tran_date], trip_number, [wh_id], [employee_id]
)
-- 第三步：最终字符串拼接
SELECT 
    t.[tran_type],
    t.[start_tran_date],
    t.[wh_id],
    t.trip_number,
    MAX(t.Trip_Total_Qty) AS Qty,
    STRING_AGG(
        CAST(
            CONCAT(
                ISNULL(e.name, 'Unknown'), 
                ' (', 
                FORMAT(t.Emp_Qty * 100.0 / NULLIF(t.Trip_Total_Qty, 0), 'N1'), 
                '%)'
            ) AS VARCHAR(MAX)), 
        ', '
    ) AS [employee_contribution_percentages]
FROM EmployeeMetrics t
LEFT JOIN employee e ON t.wh_id = e.wh_id AND t.employee_id = e.id
GROUP BY 
    t.[tran_type], 
    t.[start_tran_date], 
    t.[wh_id], 
    t.trip_number
ORDER BY t.start_tran_date, t.trip_number;