/*
select * from Distribution_Warehouse_Wholesale.employee
*/

SELECT 
    curr.wh_id,
    curr.equipment_check_log_id,
    curr.equipment_id,
    curr.employee_id,
    e.name AS employee_name,
    curr.check_meter,
    curr.check_performed,   
    
    -- 下一次check的信息
    next_rec.equipment_check_log_id    AS next_equipment_check_log_id,
    next_rec.employee_id               AS next_employee_id,
    f.name AS next_employee_name,
    next_rec.check_meter               AS next_check_meter,
    next_rec.check_performed           AS next_check_performed,
    
    -- check_meter 差值
    next_rec.check_meter - curr.check_meter AS meter_difference,
    
    -- 判断列
    CASE 
        when next_rec.check_performed is null and CAST(curr.check_performed AS DATE) IN (CAST(GETDATE() AS DATE), DATEADD(DAY, -1, CAST(GETDATE() AS DATE))) then 'equipment is working'
        when next_rec.check_performed is null and DATEDIFF(DAY, CAST(curr.check_performed AS DATE), CAST(GETDATE() AS DATE)) > 2  then 'equipment cannot work?'

        WHEN next_rec.check_meter - curr.check_meter >= 0 and next_rec.check_meter - curr.check_meter <= 10 THEN 'OK'
        ELSE 'PIV check issue'
    END AS meter_check_status

FROM (
    -- 先去重：相同日期 + employee + equipment + check_meter，取 check_performed 最大值
    SELECT 
        wh_id,
        equipment_id,
        employee_id,
        check_meter,
        MAX(check_performed) AS check_performed,
        -- 取对应最大check_performed的 equipment_check_log_id
        MAX(equipment_check_log_id) AS equipment_check_log_id
    FROM Distribution_Warehouse_Wholesale.EquipmentCheckLog
    WHERE wh_id        = '335'
      AND equipment_id LIKE 'V%'
      AND check_performed >= '2026-03-01'  -- 可以根据需要调整时间范围
    GROUP BY
        wh_id,
        equipment_id,
        employee_id,
        check_meter,
        CAST(check_performed AS DATE)  -- 同一天
) AS curr

OUTER APPLY (
    SELECT TOP 1
        dedup.equipment_check_log_id,
        dedup.employee_id,
        dedup.check_meter,
        dedup.check_performed
    FROM (
        -- 下一条记录同样先去重
        SELECT 
            wh_id,
            equipment_id,
            employee_id,
            check_meter,
            MAX(check_performed) AS check_performed,
            MAX(equipment_check_log_id) AS equipment_check_log_id
        FROM Distribution_Warehouse_Wholesale.EquipmentCheckLog
        WHERE wh_id        = '335'
          AND check_performed >= '2026-02-01'
        GROUP BY
            wh_id,
            equipment_id,
            employee_id,
            check_meter,
            CAST(check_performed AS DATE)
    ) AS dedup
    WHERE dedup.equipment_id   = curr.equipment_id
      AND dedup.wh_id          = curr.wh_id
      AND dedup.check_performed > curr.check_performed
    ORDER BY dedup.check_performed ASC
) AS next_rec
left join (select * from Distribution_Warehouse_Wholesale.employee where wh_id = '335') as e on curr.employee_id = e.emp_number
left join (select * from Distribution_Warehouse_Wholesale.employee where wh_id = '335') as f on next_rec.employee_id = f.emp_number
ORDER BY curr.equipment_id, curr.check_performed;

