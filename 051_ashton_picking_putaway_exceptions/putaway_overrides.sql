-- ==============================================================================
-- 过滤条件设置 (Query configuration block)
-- 仅保留时间过滤参数，其余条件默认查询全部 (All)
-- ==============================================================================

DECLARE @in_start_tran_date   DATETIME = '2026-01-01';             -- 开始日期 / Start Date
DECLARE @in_end_tran_date     DATETIME = '2026-12-31';             -- 结束日期 / End Date
DECLARE @in_start_tran_time   DATETIME = '1900-01-01 00:00:00';    -- 开始时间 / Start Time
DECLARE @in_end_tran_time     DATETIME = '1900-01-01 23:59:59';    -- 结束时间 / End Time

-- ==============================================================================
-- 主查询逻辑 (采用 CTE 方式重写)
-- ==============================================================================

;WITH CTE_Filtered_Exception_Log AS (
    -- 第一步：基于日期和时间过滤主表异常日志数据
    SELECT *
    FROM t_exception_tran_log (NOLOCK)
    WHERE  
        exception_date >= CONVERT(VARCHAR(23), @in_start_tran_date, 121)   
        -- 确保包含结束日期当天的最后一毫秒
        AND exception_date <= CONVERT(DATETIME, CONVERT(VARCHAR(10), @in_end_tran_date, 120) + ' 23:59:59.998') 
        AND ( 
            CONVERT(TIME, exception_time) >= CONVERT(TIME, @in_start_tran_time)  
            OR DATEDIFF(dd, exception_date, @in_start_tran_date) <> 0 
        )   
        AND ( 
            CONVERT(TIME, exception_time) <= CONVERT(TIME, @in_end_tran_time)    
            OR DATEDIFF(dd, exception_date, @in_end_tran_date) <> 0 
        ) 
        and tran_type in ('101')
)
-- 第二步：将过滤后的数据与维度表进行关联查询
SELECT DISTINCT 
    t.item_number,  
    itm.commodity_code,  
    itm.pick_put_id,  
    CASE    
        WHEN t.lot_number IS NOT NULL THEN 1    
        ELSE uom.conversion_factor    
    END AS conversion_factor,  
    t.lot_number,  
    t.wh_id,  
    t.location_id,  
    l.type AS loc_type,            -- 优化了原先的内嵌子查询
    t.location_id_2,  
    l_2.type AS loc_type_2,        -- 优化了原先的内嵌子查询
    t.reference,  
    t.load_id,  
    t.quantity,  
    t.tran_type,  
    t.description,  
    t.employee_id,  
    ISNULL(e.name, u.full_name) AS employee_name,  
    ISNULL(e.supervisor, u.supervisor) AS supervisor,  
    ISNULL(d1.description, d2.description) AS department,  
    CONVERT(date, t.exception_date, 101) AS exception_date,  
    CONVERT(VARCHAR, t.exception_time, 108) AS exception_time,  
    t.suggested_value,  
    l2.type AS suggested_type, 
    t.suggested_loc_class,  
    t.entered_value,   
    l3.type AS entered_type, 
    t.entered_loc_class,  
    t.pick_run_id,  
    t.mo_number,  
    t.asn_no,  
    t.trailer_no,  
    t.equipment_zone
    --t.work_q_id,  
    --t.pallet_type,  
    --t.approved_on,  
    --t.approved_by,  
    --t.replen_qty,  
    --t.replen_level,  
    --t.capacity_qty,  
    --t.sto_qty,  
    --t.assign_qty,  
    --t.as400_qty,  
    --t.adjust_qty,  
    --t.remove_qty,  
    --t.hjorignqty_shipqty,  
    --t.openqty_unreleasedqty,  
    --t.remaining_qty,  
    --t.line_number,  
    --t.hu_id
FROM CTE_Filtered_Exception_Log t
LEFT JOIN t_item_master itm (NOLOCK)  
    ON t.item_number = itm.item_number AND t.wh_id = itm.wh_id
LEFT JOIN t_item_uom uom (NOLOCK)    
    ON itm.item_number = uom.item_number AND itm.uom = uom.uom AND itm.wh_id = uom.wh_id  
LEFT JOIN t_location l (NOLOCK)  
    ON l.location_id = t.location_id AND l.wh_id = t.wh_id
LEFT JOIN t_location l_2 (NOLOCK)  
    ON l_2.location_id = t.location_id_2 AND l_2.wh_id = t.wh_id
LEFT JOIN t_location l2 (NOLOCK)   
    ON t.suggested_value = l2.location_id AND t.wh_id = l2.wh_id
LEFT JOIN t_location l3 (NOLOCK)   
    ON t.entered_value = l3.location_id AND t.wh_id = l3.wh_id
LEFT JOIN t_employee e (NOLOCK)    
    ON CAST(t.employee_id AS VARCHAR) = CAST(e.id AS VARCHAR)  
LEFT JOIN t_user u (NOLOCK)  
    ON CAST(t.employee_id AS VARCHAR) = CAST(u.id AS VARCHAR)
LEFT JOIN t_department d1 (NOLOCK)  
    ON e.dept = d1.department AND e.wh_id = d1.wh_id   
LEFT JOIN t_department d2 (NOLOCK)    
    ON u.dept = d2.department AND u.wh_id = d2.wh_id;