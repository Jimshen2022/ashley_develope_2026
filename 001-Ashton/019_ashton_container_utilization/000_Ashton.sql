WITH MaxEnteredYard AS (
  SELECT
	equipment_id,
    MAX(entered_yard) AS max_entered_yard
  FROM
    Distribution_Warehouse_Wholesale.Trailer
  WHERE
    wh_id = '335'
    AND entered_yard >= DATEADD(DAY, -120, GETDATE())
  GROUP BY
    equipment_id),
-- ctn_nbr + size + enter yard max time
ctn AS
(
SELECT
  Distinct t1.equipment_id,
  t1.trailer_type_id AS trailer_type_id,
  t1.entered_yard AS entered_yard,
  CASE
	WHEN t1.trailer_type_id IN ('86') THEN '20FT'
	WHEN t1.trailer_type_id IN ('87') THEN '40FT'
	WHEN t1.trailer_type_id IN ('88') THEN '45FT'
	WHEN t1.trailer_type_id IN ('177') THEN '40H'
	WHEN t1.trailer_type_id IN ('324') THEN '53FT'
	ELSE '40H' END AS Ctn_size
FROM
  Distribution_Warehouse_Wholesale.Trailer t1
INNER JOIN MaxEnteredYard mey ON
  t1.equipment_id = mey.equipment_id
  AND t1.entered_yard = mey.max_entered_yard
WHERE
  t1.wh_id = '335'
  AND t1.entered_yard >= DATEADD(DAY, -120, GETDATE())
),
i AS
(
SELECT T1.STID, T1.ITNBR, T1.ITCLS, T1.UNMSR, T1.WEGHT, T1.B2Z95S as Unit_Cube, T1.ITDSC
FROM MasterData_ItemMaster_AFI.ITMRVA AS T1
WHERE T1.STID IN ('335')
),
--Trip and container# and container size
tp AS
(
SELECT DISTINCT CAST(SUBSTRING(t1.control_number_2, 1, CHARINDEX('-', t1.control_number_2) - 1) AS INT) AS trip_nbr
	, t1.routing_code as ctn_nbr
	, t1.start_tran_date
	, ctn.Ctn_size
FROM Distribution_Warehouse_Wholesale.TranLog AS t1
LEFT JOIN ctn as ctn on ctn.equipment_id = t1.routing_code
WHERE t1.wh_id IN ('335') AND t1.start_tran_date >= DATEADD(DAY,-120,GETDATE()) AND t1.tran_type IN ('347')
),
--Mixed or None-Mixed container type
m AS
(
SELECT
	  b1.container#,
	  	  COUNT(DISTINCT b1.Product) AS Product_Category_Qty,
		CASE
			WHEN COUNT(DISTINCT b1.Product) = 1 THEN 'None-Mixed'
			ELSE 'Mixed'  END AS ContainerType
	 -- STRING_AGG(DISTINCT b1.Product, '-') AS Prodct_String
FROM
(
SELECT t1.item_number
	, CASE
		WHEN itm.ITCLS NOT LIKE 'Z%' THEN 'RP'
		WHEN SUBSTRING(t1.item_number,1,1) IN ('A','B','D','E','G','H','L','M','P','Q','R','T','W','Z') THEN 'CG'
		ELSE 'UPH' END AS Product
	, t1.routing_code AS 'container#'
	, CAST(SUBSTRING(t1.control_number_2,1,CHARINDEX('-',t1.control_number_2) -1) AS INT)  AS trip_nbr
FROM Distribution_Warehouse_Wholesale.TranLog AS t1
LEFT JOIN i AS itm ON t1.item_number = itm.ITNBR
WHERE t1.wh_id IN ('335') AND t1.start_tran_date >= DATEADD(DAY,-60,GETDATE()) AND t1.tran_type IN ('347')
) AS b1
GROUP BY  b1.container#
),
--trip join ctn_number
tjc AS
(
SELECT DISTINCT T1.wh_id
	, CAST(SUBSTRING(t1.load_id, 1, CHARINDEX('-', t1.load_id) - 1) AS INT) AS trip_nbr
	, CONCAT(CAST(SUBSTRING(t1.load_id, 1, CHARINDEX('-', t1.load_id) - 1) AS INT), '_',  t1.bill_number) as trip_ctn
	, t1.trailer_number as ctn_size_2
	, t1.bill_number as ctn_nbr
	, t1.shipment_status
	, t1.dispatch_date
	, t1.trip_type_id
FROM Distribution_Warehouse_Wholesale.LoadMaster AS T1
WHERE T1.wh_id IN ('335') AND T1.bill_number IS NOT NULL AND T1.dispatch_date >= DATEADD(DAY,-120,GETDATE())
	AND t1.shipment_status IN ('Shipped') AND T1.trailer_number IS NOT NULL
)
-------------------------------------------MAIN-------------------------------------------------------------------
SELECT
	  t1.tran_type
	, t1.start_tran_date AS INIVDT
	, t1.wh_id AS INWHSE
	, t1.item_number AS ITITNO
	, CASE
		WHEN itm.ITCLS NOT LIKE 'Z%' THEN 'RP'
		WHEN SUBSTRING(t1.item_number,1,1) IN ('A','B','D','E','G','H','L','M','P','Q','R','T','W','Z') THEN 'CG'
		ELSE 'UPH' END AS PRODUCT
	, t1.routing_code AS CONTAINER#
	, tp.Ctn_size
	, tjc.ctn_size_2
	, CASE WHEN tjc.ctn_size_2 IS NOT NULL THEN tjc.ctn_size_2 ELSE tp.Ctn_size END AS Container_size_final
	, CAST(SUBSTRING(t1.control_number_2,1,CHARINDEX('-',t1.control_number_2) -1) AS INT)  AS TRIP#
	, m.ContainerType
	, CASE
		WHEN m.ContainerType IN ('None-Mixed') THEN  (CASE
		WHEN itm.ITCLS NOT LIKE 'Z%' THEN 'RP'
		WHEN SUBSTRING(t1.item_number,1,1) IN ('A','B','D','E','G','H','L','M','P','Q','R','T','W','Z') THEN 'CG'
		ELSE 'UPH' END)
		ELSE m.ContainerType END AS Cont_Categories
	, itm.Unit_Cube
	, SUM(t1.tran_qty) AS ITSHQT
	, itm.Unit_Cube *  SUM(t1.tran_qty) AS CUBES
FROM Distribution_Warehouse_Wholesale.TranLog AS t1
LEFT JOIN i AS itm ON t1.item_number = itm.ITNBR
LEFT JOIN m AS m ON t1.routing_code = m.container#
LEFT JOIN tp AS tp ON CAST(SUBSTRING(t1.control_number_2,1,CHARINDEX('-',t1.control_number_2) -1) AS INT) = tp.trip_nbr
LEFT JOIN tjc AS tjc ON tjc.trip_ctn = CONCAT(CAST(SUBSTRING(t1.control_number_2,1,CHARINDEX('-',t1.control_number_2) -1) AS INT),'_',t1.routing_code)
WHERE t1.wh_id IN ('335') AND t1.start_tran_date >= DATEADD(DAY,-60,GETDATE()) AND t1.tran_type IN ('347')
GROUP BY t1.tran_type
		, t1.start_tran_date
		, t1.wh_id
		, t1.item_number
		, CASE
			WHEN itm.ITCLS NOT LIKE 'Z%' THEN 'RP'
			WHEN SUBSTRING(t1.item_number,1,1) IN ('A','B','D','E','G','H','L','M','P','Q','R','T','W','Z') THEN 'CG'
			ELSE 'UPH' END
		, t1.routing_code
		, tp.Ctn_size      -- get the data from Trailer maximum(container entered into yard time)
		, tjc.ctn_size_2   -- get the data from loadMast that include trip_container#_size
		, CASE WHEN tjc.ctn_size_2 IS NOT NULL THEN tjc.ctn_size_2 ELSE tp.Ctn_size END
		, CAST(SUBSTRING(t1.control_number_2,1,CHARINDEX('-',t1.control_number_2) -1) as int)
		, m.ContainerType
		, CASE
			WHEN m.ContainerType IN ('None-Mixed') THEN
			(CASE
				WHEN itm.ITCLS NOT LIKE 'Z%' THEN 'RP'
				WHEN SUBSTRING(t1.item_number,1,1) IN ('A','B','D','E','G','H','L','M','P','Q','R','T','W','Z') THEN 'CG'
				ELSE 'UPH' END)
				ELSE m.ContainerType END
		, itm.Unit_Cube
ORDER BY t1.start_tran_date, CAST(SUBSTRING(t1.control_number_2,1,CHARINDEX('-',t1.control_number_2) -1) AS INT), t1.item_number