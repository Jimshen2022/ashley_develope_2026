WITH DeduplicatedLogs AS (
    -- 步骤 1：全量去重一次（包含查询所需的最小时间范围）
    -- 这里取 2026-02-01 是为了包含原逻辑中 next_rec 的时间范围
    SELECT 
        wh_id,
        equipment_id,
        employee_id,
        check_meter,
        MAX(check_performed) AS check_performed,
        MAX(equipment_check_log_id) AS equipment_check_log_id
    FROM Distribution_Warehouse_Wholesale.EquipmentCheckLog
    WHERE wh_id = '335'
      AND check_performed >= '2026-02-01' 
    GROUP BY
        wh_id,
        equipment_id,
        employee_id,
        check_meter,
        CAST(check_performed AS DATE)
),
NextRecordCalculated AS (
    -- 步骤 2：使用 LEAD() 窗口函数获取按时间排序的“下一条”记录
    SELECT 
        equipment_check_log_id,
        wh_id,
        equipment_id,
        employee_id,
        check_meter,
        check_performed,
        
        -- 获取下一条记录的数据
        LEAD(equipment_check_log_id) OVER (PARTITION BY wh_id, equipment_id ORDER BY check_performed ASC) AS next_equipment_check_log_id,
        LEAD(employee_id) OVER (PARTITION BY wh_id, equipment_id ORDER BY check_performed ASC) AS next_employee_id,
        LEAD(check_meter) OVER (PARTITION BY wh_id, equipment_id ORDER BY check_performed ASC) AS next_check_meter,
        LEAD(check_performed) OVER (PARTITION BY wh_id, equipment_id ORDER BY check_performed ASC) AS next_check_performed
    FROM DeduplicatedLogs
)
-- 步骤 3：最终结果筛选与 JOIN
SELECT 
    curr.wh_id,
    curr.equipment_check_log_id,
    curr.equipment_id,
    curr.employee_id,
    e.name AS employee_name,
    curr.check_meter,
    curr.check_performed,   
    
    curr.next_equipment_check_log_id,
    curr.next_employee_id,
    f.name AS next_employee_name, -- 修复了原代码中的 g.name bug
    curr.next_check_meter,
    curr.next_check_performed,
    
    curr.next_check_meter - curr.check_meter AS meter_difference,
    
    CASE 
        WHEN curr.next_check_meter - curr.check_meter >= 0 THEN 'OK'
        WHEN curr.next_check_meter - curr.check_meter < 0  THEN 'PIV check issue'
        ELSE NULL
    END AS meter_check_status
FROM NextRecordCalculated curr
-- 直接关联物理表并加上条件，避免在 JOIN 中使用派生子查询
LEFT JOIN Distribution_Warehouse_Wholesale.employee e 
    ON curr.employee_id = e.emp_number AND e.wh_id = '335'
LEFT JOIN Distribution_Warehouse_Wholesale.employee f 
    ON curr.next_employee_id = f.emp_number AND f.wh_id = '335'
WHERE curr.equipment_id LIKE 'V%'
  AND curr.check_performed >= '2026-03-01' -- 将主查询的条件放在最后过滤
ORDER BY 
    curr.equipment_id, 
    curr.check_performed;

