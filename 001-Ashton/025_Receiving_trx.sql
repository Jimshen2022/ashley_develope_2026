-- JimShen on Oct.24.2024
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
	, t1.tran_qty
FROM Distribution_Warehouse_Wholesale.TranLog AS t1 
WHERE t1.tran_type IN ('202') 
	AND t1.wh_id = '335' 
	AND t1.location_id_2 in ('EX001AA1','SH001AA1')
	AND t1.start_tran_date BETWEEN DATEADD(wk, DATEDIFF(wk, 0, GETDATE()) - 7, 0) AND GETDATE()
ORDER BY t1.start_tran_date

	-- AND t1.start_tran_date BETWEEN DATEADD(DAY, -, GETDATE()) AND GETDATE()
-- 	SELECT DATEADD(wk, DATEDIFF(wk, 0, GETDATE()) - 4, 0)
-- 	SELECT DATEADD(wk, DATEDIFF(wk, 0, GETDATE()) - 4,10)

--SELECT TOP 10 *
--FROM Distribution_Warehouse_Wholesale.TranLog AS t1 
--WHERE t1.tran_type IN ('202') AND t1.wh_id = '335' AND t1.location_id_2 in ('EX001AA1','SH001AA1')
