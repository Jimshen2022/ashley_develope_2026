WITH DeduplicatedLogs AS (
    SELECT 
        equipment_id,
        employee_id,
        check_meter,
        MAX(check_performed)        AS check_performed,
        MAX(equipment_check_log_id) AS equipment_check_log_id
    FROM t_equipment_check_log
    WHERE 
      -- 多抓 60 天，保证 30 天内第一条记录能找到它的上一条
        check_performed >= DATEADD(DAY, -60, CAST(GETDATE() AS DATE))
    GROUP BY
        equipment_id,
        employee_id,
        check_meter,
        CAST(check_performed AS DATE)
),
NextRecordCalculated AS (
    SELECT 
        equipment_check_log_id,
        equipment_id,
        employee_id,
        check_meter,
        check_performed,
        LEAD(equipment_check_log_id) OVER (PARTITION BY equipment_id ORDER BY check_performed ASC) AS next_equipment_check_log_id,
        LEAD(employee_id)            OVER (PARTITION BY equipment_id ORDER BY check_performed ASC) AS next_employee_id,
        LEAD(check_meter)            OVER (PARTITION BY equipment_id ORDER BY check_performed ASC) AS next_check_meter,
        LEAD(check_performed)        OVER (PARTITION BY equipment_id ORDER BY check_performed ASC) AS next_check_performed
    FROM DeduplicatedLogs
),
TransactionSummary AS (
    SELECT
        location_id AS equipment_id,
        CAST(start_tran_date AS DATE) AS tran_date,
        SUM(tran_qty) AS equipment_performed_qty
    FROM t_tran_log
    WHERE tran_type IN ('364', '252','254', '202')
      AND start_tran_date >= DATEADD(DAY, -60, CAST(GETDATE() AS DATE))
    GROUP BY
        location_id,
        CAST(start_tran_date AS DATE)
)
SELECT 
    curr.equipment_check_log_id,
    curr.equipment_id,
    curr.employee_id,
    e.name                                   AS employee_name,
    curr.check_meter,
    curr.check_performed,
    curr.next_equipment_check_log_id,
    curr.next_employee_id,
    f.name                                   AS next_employee_name,
    curr.next_check_meter,
    curr.next_check_performed,
    curr.next_check_meter - curr.check_meter AS meter_difference,

    CASE 
        WHEN curr.next_check_performed IS NULL 
             AND CAST(curr.check_performed AS DATE) IN (
                 CAST(GETDATE() AS DATE), 
                 DATEADD(DAY, -1, CAST(GETDATE() AS DATE))
             ) 
            THEN 'equipment is working'
        
        WHEN curr.next_check_performed IS NULL 
             AND DATEDIFF(DAY, CAST(curr.check_performed AS DATE), CAST(GETDATE() AS DATE)) > 2  
            THEN 'equipment cannot work?'
        
        WHEN curr.next_check_meter - curr.check_meter >= 0 
             AND curr.next_check_meter - curr.check_meter <= 10 
            THEN 'OK'
        
        ELSE 'PIV check issue'
    END AS meter_check_status,
    ISNULL(ts.equipment_performed_qty, 0) AS equipment_qty,

    CASE
        WHEN (curr.next_check_meter - curr.check_meter) > 0
             AND (curr.next_check_meter - curr.check_meter) <= 11
            THEN CAST(ISNULL(ts.equipment_performed_qty, 0) * 1.0 / (curr.next_check_meter - curr.check_meter) AS DECIMAL(18, 2))
        ELSE 0
    END AS [equipment_PPH(pieces/hour)],

    CASE
        WHEN curr.equipment_id LIKE 'VE%' THEN 'ClampTruck'
        WHEN curr.equipment_id LIKE 'VF%' THEN 'ForkLift'
        WHEN curr.equipment_id LIKE 'VJ%' THEN 'PalletJack'
        WHEN curr.equipment_id LIKE 'VR%' THEN 'ReachTruck'
        WHEN curr.equipment_id LIKE 'VS%' THEN 'OrderPicker'
        ELSE 'Check'
    END AS Equipment_Type,

    CAST(YEAR(curr.check_performed) AS VARCHAR(4)) + RIGHT('0' + CAST(DATEPART(iso_week, curr.check_performed) AS VARCHAR(2)), 2) AS YearWeek

FROM NextRecordCalculated curr
LEFT JOIN t_employee e ON curr.employee_id      = e.emp_number
LEFT JOIN t_employee f ON curr.next_employee_id = f.emp_number
LEFT JOIN TransactionSummary ts
       ON curr.equipment_id = ts.equipment_id
      AND CAST(curr.check_performed AS DATE) = ts.tran_date
WHERE curr.equipment_id   LIKE 'V%'
  -- 最终展示只看 30 天，但计算用了 60 天的数据做支撑
  AND curr.check_performed >= DATEADD(DAY, -30, CAST(GETDATE() AS DATE))
ORDER BY 
    curr.equipment_id, 
    curr.check_performed;