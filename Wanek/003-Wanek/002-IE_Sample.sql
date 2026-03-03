--IE Sample management in HJ,  Oct.24.2024 by Jim,Shen
SELECT t1.start_tran_date
	, t1.tran_type
	, t1.description
	, t1. employee_id
	, t1.control_number AS container_nbr
	, t1.line_number
	, t1.control_number_2 AS po_nbr
	, t1.wh_id
	, t1.location_id
	, t1.hu_id AS LP_nbr
	, t1.item_number
	, t1.lot_number
	, SUM(CASE WHEN t1.tran_type IN ('347') THEN -t1.tran_qty ELSE t1.tran_qty END) AS received_qty
FROM Distribution_Warehouse_Wholesale.TranLog AS t1 
WHERE t1.tran_type IN ('202') AND t1.wh_id = '35'
	AND t1.start_tran_date BETWEEN DATEADD(wk, DATEDIFF(wk, 0, GETDATE()) - 7, 0) AND GETDATE()
--  AND t1.control_number_2 IN ('P2GFW79')
GROUP BY 
	  t1.start_tran_date
	, t1.tran_type
	, t1.description
	, t1. employee_id
	, t1.control_number
	, t1.line_number
	, t1.control_number_2 
	, t1.wh_id
	, t1.location_id
	, t1.hu_id 
	, t1.item_number
	, t1.lot_number 

	-- AND t1.start_tran_date BETWEEN DATEADD(DAY, -, GETDATE()) AND GETDATE()
-- 	SELECT DATEADD(wk, DATEDIFF(wk, 0, GETDATE()) - 4, 0)
-- 	SELECT DATEADD(wk, DATEDIFF(wk, 0, GETDATE()) - 4,10)
-- HJ_SN_IN_WAREHOUSE+LOADED+HOLD

---IE STO 
SELECT t1.wh_id, 
    t1.serial_number, 
    t1.item_number, 
    t1.location_id,
    t1.received_date,
    t1.master_status,
    CASE 
        WHEN t1.location_id in ('IE001WN2') THEN 'Sample in WN2'
        WHEN t1.location_id in ('IE001WN3') THEN 'Sample in WN3'
    ELSE 'Wait for IE confirm site' END as Site 
FROM Distribution_Warehouse_Wholesale.t_serial_active AS t1
WHERE t1.wh_id in ('35','31')
    AND t1.serial_no_status IN ('R', 'L','H','O')
	AND t1.location_id IN ('IE001WN2','IE001WN3','IE001AA1')
