SELECT CAST(t1.[start_tran_date] AS DATE) AS Transaction_Date
	, t1.control_number_2
	, t1.control_number as Reference
	, t1.item_number
	, t1.tran_type
	, t1.description
	, t2.ITCLS as Item_Class
	, (CASE
		WHEN t2.ITCLS NOT LIKE 'Z%' THEN 'RP'
		WHEN SUBSTRING(t1.item_number,1,1) IN ('1','2','3','4','5','6','7','8','9','U') THEN 'UPH'
		ELSE 'CG' END) AS Product
    , t1.tran_qty
	, t1.lot_number
    , t1.tran_qty * t2.B2Z95S AS ITMRVA_CUBES
	, t1.tran_qty * t3.CUBES AS ITMEXT_CUBES

FROM (SELECT *
      FROM Distribution_Warehouse_Wholesale.TranLog AS a
      WHERE a.wh_id = '335'
        AND a.control_number_2 like '0008650-%' ) AS t1
LEFT JOIN (SELECT a.ITNBR, a.ITCLS, a.B2Z95S FROM MasterData_ItemMaster_AFI.ITMRVA AS a WHERE a.STID = '335') AS t2 ON t1.item_number = t2.ITNBR
LEFT JOIN (SELECT b.ITNBR, b.CUBES FROM MasterData_ItemMaster_AFI.ITMEXT AS b) AS t3 ON t1.item_number = T3.ITNBR
WHERE t1.start_tran_date > '2024-06-01'
-- AND t1.control_number_2 IN ('0054998-00')
-- AND t1.item_number IN ('A4000325')
--AND t1.item_number IN ('5950535','B476-92','B5169-56SW1','B751-46','B844-31','B844-56S','B980-46','D394-425','D546-524','D760-45','D947-55B','T994-2')
AND t1.tran_type IN ('347')
--AND t1.tran_type LIKE '40%'
ORDER BY  CAST(t1.[start_tran_date] AS DATE)




SELECT *
FROM MasterData_ItemMaster_AFI.ITMRVA as a
WHERE a.ITNBR IN ('5230466')


SELECT *
FROM MasterData_ItemMaster_AFI.ITMEXT as a
WHERE a.ITNBR IN ('5230466')

