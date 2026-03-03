WITH d AS
(
SELECT 
	 t1.wh_id
	, t1.tran_type
	, t1.description
	, t1.start_tran_date AS DATE
	, t1.item_number
	, t1.employee_id
	, t1.control_number
	, t1.location_id AS 'from Location'
	, t1.location_id_2 AS 'To Location'
	, t1.control_number_2 as reference
	, t1.hu_id AS LP
	, sum(t1.tran_qty) as tran_qty
	, 1 AS Pallet_Qty 
	, STRING_AGG(t1.lot_number, '-') AS SN_String
	, STRING_AGG(t1.hu_id, '-') AS LP_String,
	CASE
		WHEN t1.tran_type IN ('252') THEN 'REPLENISH' 
		WHEN t1.tran_type IN ('254') THEN 'RECEIVING PUTAWAY'
		ELSE 'SCOOP Pick' END AS Trx_Type
FROM Distribution_Warehouse_Wholesale.TranLog AS t1
WHERE 
	t1.wh_id IN ('335') AND 
	t1.start_tran_date > '2024-06-01' AND
	t1.tran_type IN ('364','254','252') AND
	(t1.location_id Like 'VR%' or t1.location_id IN ('VF501','VF502')) AND 
	(t1.control_number IN ('REPLENISH') OR t1.control_number_2 LIKE 'RS%' or t1.control_number_2 LIKE '0%')
GROUP BY 
	 t1.wh_id
	, t1.tran_type
	, t1.description
	, t1.start_tran_date
	, t1.item_number
	, t1.employee_id
	, t1.control_number
	, t1.location_id 
	, t1.location_id_2 
	, t1.control_number_2 
	, t1.hu_id 
)

---- MAIN -----

SELECT d1.Date, d1.Trx_Type, d1.employee_id, SUM(d1.Pallet_Qty) as Pallet_Qty
FROM d as d1
GROUP BY d1.Date, d1.Trx_Type, d1.employee_id
Order by d1.Date
	
/*
SELECT 	
	 *
FROM Distribution_Warehouse_Wholesale.TranLog AS t1
WHERE 
	t1.wh_id IN ('335') AND 
	t1.start_tran_date > '2024-09-01' AND
	t1.tran_type IN ('364') AND
	(t1.location_id Like 'VR%' or t1.location_id IN ('VF501','VF502')) AND 
	(t1.control_number IN ('REPLENISH') OR t1.control_number_2 LIKE 'RS%' or t1.control_number_2 LIKE '0%')
order by t1.start_tran_date, t1.start_tran_time 
GROUP BY 
	  t1.wh_id
	, t1.tran_type
	, t1.description
	, t1.start_tran_date
	, t1.employee_id
	, t1.control_number
	, t1.control_number_2 
	, t1.location_id
	, t1.location_id_2

*/