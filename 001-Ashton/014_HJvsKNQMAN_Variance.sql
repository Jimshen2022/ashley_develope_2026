
SELECT CAST(t1.[start_tran_date] AS DATE) AS Transaction_Date
     , CAST(t1.[start_tran_time] AS time) AS Transaction_Time
	, t1.control_number_2
	, t1.control_number as Reference
    , t1.location_id
    , t1.location_id_2
    , t1.employee_id
	, t1.item_number
	, t1.tran_qty
	, t1.tran_type
	, t1.description
	, t2.ITCLS as Item_Class
	, (CASE
		WHEN t2.ITCLS NOT LIKE 'Z%' THEN 'RP'
		WHEN SUBSTRING(t1.item_number,1,1) IN ('1','2','3','4','5','6','7','8','9','U') THEN 'UPH'
		ELSE 'CG' END) AS Product
    , t1.tran_qty
	, t1.lot_number

FROM Distribution_Warehouse_Wholesale.TranLog AS t1
LEFT JOIN (SELECT a.ITNBR, a.ITCLS FROM MasterData_ItemMaster_AFI.ITMRVA AS a WHERE a.STID = '335') AS t2 ON t1.item_number = t2.ITNBR
WHERE t1.wh_id IN ('335')
AND t1.start_tran_date > '2024-10-29'
-- AND t1.control_number_2 IN ('0054998-00',
-- '0056455-00',
-- '0056457-00',
-- '0055007-00',
-- '0057045-00',
-- '0056454-00',
-- '0057046-00',
-- '0057047-00',
-- '0056456-00',
-- '0057043-00')
AND t1.item_number IN ('B100-13')
--AND t1.item_number IN ('5950535','B476-92','B5169-56SW1','B751-46','B844-31','B844-56S','B980-46','D394-425','D546-524','D760-45','D947-55B','T994-2')
--AND t1.tran_type IN ('347')
-- AND t1.tran_type IN ('347')
--AND t1.tran_type LIKE '40%'
ORDER BY  CAST(t1.[start_tran_date] AS DATE)



/*
SELECT TOP 10 *
FROM Distribution_Warehouse_Wholesale.TranLog AS t1

*/