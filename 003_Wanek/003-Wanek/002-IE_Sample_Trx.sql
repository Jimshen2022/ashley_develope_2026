WITH s1 as 
(SELECT t1.wh_id, t1.lot_number, t1.
)



SELECT t1.wh_id 
	, t1.start_tran_date
	, t1.tran_type
	, t1.description
	, t1.location_id as from_location
	, t1.location_id_2 as to_location
	, t1.control_number_2 AS reference
	, t1.employee_id
	, t1.item_number
	, t1.tran_qty
	, t1.lot_number as SN
	, CASE 
		WHEN t1.location_id_2 in ('IE001WN2','IE001WN3','IE001AA1') THEN 'Received Sample'
		WHEN t1.location_id_2 in ('IE001SA1') THEN 'Sample Sale'
		WHEN t1.location_id_2 in ('IE001SC1') THEN 'Sample Scrapped'
		WHEN t1.location_id_2 in ('NG001SS1','NG001AS1','NG001SS2') AND t1.control_number_2 in ('IE001WN2','IE001WN3','IE001AA1') THEN 'Sample Scrapped'
		WHEN t1.location_id_2 in ('NG001IA1') AND t1.control_number_2 in ('IE001WN2','IE001WN3','IE001AA1') THEN 'Sample Inventory Adjustment'
		ELSE 'None-IE-Sample' END as Tran_Type
FROM Distribution_Warehouse_Wholesale.TranLog AS t1 
WHERE  t1.wh_id = '35'
	AND t1.location_id_2 in ('IE001SA1','IE001SC1','IE001WN2','IE001WN3','IE001AA1','NG001SS1','NG001IA1','NG001AS1','NG001SS2')
	AND t1.start_tran_date BETWEEN '2024-08-01' AND GETDATE()