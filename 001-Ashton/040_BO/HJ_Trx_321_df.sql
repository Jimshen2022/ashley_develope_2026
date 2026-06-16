WITH employee AS (
    SELECT id, name, wh_id
    FROM Distribution_Warehouse_Wholesale.t_employee
    WHERE wh_id = '335'
),
-- 第一步：按 Trip 和 Employee 分组汇总每个人装载的数量
EmployeeTripSummary AS (
    SELECT 
        [tran_type],
        CAST([start_tran_date] AS DATE) AS [start_tran_date],
        [control_number_2] AS trip_number,
        [wh_id],
        [employee_id],
        SUM([tran_qty]) AS Emp_Qty -- 该员工在该 trip 下的总量
    FROM [PowerBI_Distribution].[TranLog]
    WHERE tran_type IN ('321', '621')
          AND start_tran_date > DATEADD(DAY, -80, GETDATE())
          AND [wh_id] = '335'
    GROUP BY [tran_type], CAST([start_tran_date] AS DATE), [control_number_2], [wh_id], [employee_id]
)
-- 第二步：最终聚合，并计算 Trip 总量和员工字符串
SELECT 
    t.[tran_type],
    t.[start_tran_date],
    t.[wh_id],
    -- 提取 Trip Number 数字部分
    CAST(LEFT(t.trip_number, CHARINDEX('-', t.trip_number + '-') - 1) AS INT) AS trip_number,
    -- 整个 Trip 的总装载量
    SUM(t.Emp_Qty) AS Qty,
    -- 拼接姓名和个人数量：Name (Qty)
    STRING_AGG(
        CAST(CONCAT(e.name, ' (', t.Emp_Qty, ')') AS VARCHAR(MAX)), 
        ', '
    ) AS Employees
FROM EmployeeTripSummary t
LEFT JOIN employee e ON t.wh_id = e.wh_id AND t.employee_id = e.id
GROUP BY 
    t.[tran_type], 
    t.[start_tran_date], 
    t.[wh_id], 
    LEFT(t.trip_number, CHARINDEX('-', t.trip_number + '-') - 1)
ORDER BY t.start_tran_date;