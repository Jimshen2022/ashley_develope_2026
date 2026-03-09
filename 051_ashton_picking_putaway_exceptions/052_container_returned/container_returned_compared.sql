
-- returned containers
select *
from t_serial_active where serial_number in (select distinct lot_number from t_tran_log where tran_type = '347' AND (control_number_2 LIKE '%89296-%' or control_number_2 LIKE '%90774-%' ) )

-- SN
select * from t_tran_log where lot_number in ('631051104192') order by start_tran_date +start_tran_time desc
select * from t_tran_log where lot_number in ('631051104193') order by start_tran_date +start_tran_time desc



-- returned containers 171
select *
from t_tran_log 
where tran_type = '171'



-- Trip shipped by sn
SELECT 
    t.tran_type,  
    t.description, 
    t.start_tran_date, 
    t.control_number_2,
    -- 提取 '-' 之前的部分并转为整数以自动去除前导零
    CAST(LEFT(t.control_number_2, CHARINDEX('-', t.control_number_2 + '-') - 1) AS INT) AS clean_control_number,
    t.lot_number,
	t1.po_number,
	t1.serial_no_status,
	t1.status_change,
	t1.location_id,
	t1.received_date,
	t1.ship_date,
    t.employee_id, 
    t.item_number, 
    SUM(t.tran_qty) AS tran_qty 
FROM t_tran_log AS t
LEFT JOIN t_serial_active as t1 ON t.lot_number = t1.serial_number
WHERE t.wh_id = '335' 
    AND t.start_tran_date > '2025-01-01'
    AND t.tran_type IN ('347')
    -- 过滤条件：确保包含连字符且截取后是数字格式（防止报错）
    AND (t.control_number_2 LIKE '%89296-%' or t.control_number_2 LIKE '%90774-%' or t.control_number_2 LIKE '%93108-%' or t.control_number_2 LIKE '%91344-%' )
GROUP BY 
    t.tran_type,  
    t.description, 
    t.start_tran_date, 
    t.control_number_2,
    CAST(LEFT(t.control_number_2, CHARINDEX('-', t.control_number_2 + '-') - 1) AS INT),
    t.lot_number,
	t1.po_number,
	t1.serial_no_status,
	t1.status_change,
	t1.location_id,
	t1.received_date,
	t1.ship_date,
    t.employee_id, 
    t.item_number