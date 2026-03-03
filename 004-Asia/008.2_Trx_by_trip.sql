SELECT 	t1.wh_id
	, t1.tran_type
	, t1.description
	, t1.start_tran_date
	, CAST(t1.start_tran_time AS TIME(0)) as star_tran_time
	, t1.end_tran_date
	, CAST(t1.end_tran_time AS TIME(0)) as end_tran_time
	, t1.employee_id
	, t1.control_number
	, t1.line_number
	, t1.control_number_2 as reference
	, t1.hu_id
	, t1.item_number
	, CAST(t1.lot_number as VARCHAR(20)) AS SN
	, t1.uom
	, t1.tran_qty
	, t1.location_id AS 'from Location'
	, t1.location_id_2 AS 'To Location'
	, t1.employee_id_2

FROM Distribution_Warehouse_Wholesale.TranLog AS t1
WHERE t1.wh_id IN ('335') AND t1.start_tran_date > '2024-11-19'
    --AND t1.item_number IN ('3090146')
    AND t1.control_number_2 LIKE '%31416%'
    AND t1.tran_type IN ('347')
ORDER BY t1.lot_number,t1.start_tran_date,t1.start_tran_time