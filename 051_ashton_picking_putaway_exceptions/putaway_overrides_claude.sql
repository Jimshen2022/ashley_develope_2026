-- ==============================================================================
-- 过滤条件设置 (Query configuration block)
-- 仅保留时间过滤参数,其余条件默认查询全部 (All)
-- ==============================================================================

DECLARE @in_start_tran_date   DATETIME = '2025-12-31';             -- 开始日期 / Start Date
DECLARE @in_end_tran_date     DATETIME = '2038-12-31';             -- 结束日期 / End Date
DECLARE @in_start_tran_time   DATETIME = '1900-01-01 00:00:00';    -- 开始时间 / Start Time
DECLARE @in_end_tran_time     DATETIME = '1900-01-01 23:59:59';    -- 结束时间 / End Time

-- ==============================================================================
-- 主查询逻辑 (采用 CTE 方式重写)
-- ==============================================================================

WITH CTE_Filtered_Exception_Log AS (
    -- 第一步:基于日期和时间过滤主表异常日志数据
    SELECT *
    FROM t_exception_tran_log (NOLOCK)
    WHERE  
        exception_date > CONVERT(VARCHAR(23), @in_start_tran_date, 121)   
        -- 确保包含结束日期当天的最后一毫秒
        --AND exception_date <= CONVERT(DATETIME, CONVERT(VARCHAR(10), @in_end_tran_date, 120) + ' 23:59:59.998') 
        --AND ( 
        --    CONVERT(TIME, exception_time) >= CONVERT(TIME, @in_start_tran_time)  
        --    OR DATEDIFF(dd, exception_date, @in_start_tran_date) <> 0 
        --)   
        --AND ( 
        --    CONVERT(TIME, exception_time) <= CONVERT(TIME, @in_end_tran_time)    
        --    OR DATEDIFF(dd, exception_date, @in_end_tran_date) <> 0 
        --) 
        AND tran_type IN ('101')
),
-- 第二步:将过滤后的数据与维度表进行关联查询
eda AS (
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
        ISNULL(d1.department_code, d2.department_code) AS department_code,  
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
        ON u.dept = d2.department AND u.wh_id = d2.wh_id
)
SELECT 
    t.*,
    -- 根据业务规则添加异常严重程度分类    
    -- Reason 列
    CASE 
        -- Major 级别
        WHEN pick_put_id = 'UPH' AND equipment_zone LIKE 'A3CG%' 
        THEN 'Picked zone incorrect'
        
        WHEN pick_put_id = 'PALLT' AND equipment_zone LIKE 'A3UPH%'
        THEN 'Picked zone incorrect'
        
        WHEN equipment_zone = 'A3UPHO21' AND entered_value NOT LIKE 'A3021%'
        THEN 'Picked special zone but putaway overrides'
        
        WHEN pick_put_id = 'PALLT' AND suggested_type = 'P' AND entered_type = 'I'
        THEN 'Suggested primary location but putaway to other location'
        
        WHEN pick_put_id = 'UPH' AND suggested_value LIKE 'A%1' AND entered_value NOT LIKE 'A%1'  
        THEN 'UPH suggested ground location but overrides to upper location'
        
        WHEN pick_put_id = 'UPH' AND suggested_value NOT LIKE 'A%1' AND entered_value LIKE 'A%1'
        THEN 'Suggested upper location but put to ground location'
        
        -- Acceptable 级别
        
        WHEN entered_type = 'X'
        THEN 'Consolidation overrides'
        
        WHEN entered_value IN ('DM001AA1', 'NG001CK3', 'NG001UP3', 'NG001VD3', 'NG001CG3', 'NG001OP3')
        THEN 'NG product moving overrides'
        
        WHEN entered_value LIKE 'EX%'
        THEN 'Vendor over shipment putaway overrides'
        
        WHEN entered_type IN ('Z', 'ZZ')
        THEN 'Damaged&Defect moving overrides'        
                
        WHEN suggested_value IS NULL 
        THEN 'New Item Moving Overrids'   

        WHEN reference IN ('RPFG', 'RPORDER')
        THEN 'RP putaway overrids'
        
        WHEN entered_value IN ('SH001AA1')
        THEN 'Vendor short shipment correction overrids'        
    ELSE 'Suggest location A but putaway to location B'
    END AS Reason,
    
    -- Type 列
    CASE 
        -- Major 级别规则
        WHEN pick_put_id = 'UPH' AND equipment_zone LIKE 'A3CG%' 
        THEN 'Major'
        
        WHEN suggested_value IS NULL AND equipment_zone LIKE 'A3CG%' AND pick_put_id = 'UPH'
        THEN 'Major'
        
        WHEN pick_put_id = 'PALLT' AND equipment_zone LIKE 'A3UPH%'
        THEN 'Major'
        
        WHEN equipment_zone = 'A3UPHO21' AND entered_value NOT LIKE 'A3021%'
        THEN 'Major'
        
        WHEN pick_put_id = 'PALLT' AND suggested_type = 'P' AND entered_type = 'I'
        THEN 'Major'
        
        WHEN pick_put_id = 'UPH' AND suggested_value LIKE 'A%1' AND entered_value NOT LIKE 'A%1'
        THEN 'Major'
        
        WHEN pick_put_id = 'UPH' AND suggested_value NOT LIKE 'A%1' AND entered_value LIKE 'A%1'
        THEN 'Major'
        
        -- 其他所有情况都是 Acceptable
        ELSE 'Acceptable'
    END AS exception_severity,
    
    -- Rule 列 - 显示触发条件的表达式
    CASE 
        WHEN pick_put_id = 'UPH' AND equipment_zone LIKE 'A3CG%' 
        THEN 'pick_put_id = ''UPH'' and equipment_zone like ''A3CG%'''
        
        WHEN pick_put_id = 'PALLT' AND equipment_zone LIKE 'A3UPH%'
        THEN 'pick_put_id = ''PALLT'' and equipment_zone like ''A3UPH%'''
        
        WHEN equipment_zone = 'A3UPHO21' AND entered_value NOT LIKE 'A3021%'
        THEN 'equipment_zone = ''A3UPHO21'' and entered_value not like ''A3021%'''
        
        WHEN pick_put_id = 'PALLT' AND suggested_type = 'P' AND entered_type = 'I'
        THEN 'pick_put_id = ''PALLT'' and suggested_type = ''P'' and entered_type = ''I'''
        
        WHEN pick_put_id = 'UPH' AND suggested_value LIKE 'A%1' AND entered_value NOT LIKE 'A%1'  
        THEN 'pick_put_id = ''UPH'' and suggested_value like ''A%1'' and entered_value not like ''A%1'''
        
        WHEN pick_put_id = 'UPH' AND suggested_value NOT LIKE 'A%1' AND entered_value LIKE 'A%1'
        THEN 'pick_put_id = ''UPH'' and suggested_value not like ''A%1'' and entered_value like ''A%1'''
        
        WHEN entered_type = 'X'
        THEN 'entered_type = ''X'''
        
        WHEN entered_value IN ('DM001AA1', 'NG001CK3', 'NG001UP3', 'NG001VD3', 'NG001CG3', 'NG001OP3')
        THEN 'entered_value in (''DM001AA1'', ''NG001CK3'', ''NG001UP3'', ''NG001VD3'', ''NG001CG3'', ''NG001OP3'')'
        
        WHEN entered_value LIKE 'EX%'
        THEN 'entered_value like ''EX%'''
        
        WHEN entered_type IN ('Z', 'ZZ')
        THEN 'entered_type in (''Z'', ''ZZ'')'
                
        WHEN suggested_value IS NULL 
        THEN 'suggested_value is null'

        WHEN reference IN ('RPFG', 'RPORDER')
        THEN 'reference in (''RPFG'', ''RPORDER'')'
        
        WHEN entered_value IN ('SH001AA1')
        THEN 'entered_value in (''SH001AA1'')'
        
        ELSE 'Other conditions'
    END AS [rule]

FROM eda AS t;