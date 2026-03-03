/* =======================
   统一日期参数区
   ======================= */
DECLARE @BCS_StartDate  DATETIME = DATEADD(DAY, -400, GETDATE());  -- BCS 用 400 天
--DECLARE @TRAN_StartDate DATETIME = DATEADD(DAY,  -60, GETDATE());  -- TranLog 用 60 天
DECLARE @TRAN_StartDate DATETIME = '2025-01-01';  -- TranLog 用 60 天

--Trip and container# and container size from BCS system
WITH bcs AS (
    SELECT BokTripNumber,BokContainerNumBer,BokContainerSize, 
           ROW_NUMBER() OVER (PARTITION BY BokTripNumber,BokContainerNumBer ORDER BY BokTripCreateDate DESC) AS rn
    FROM [Wholesale_ProductSourcing_AFI].[Bookings]
    WHERE BokWarehouse = '335' 
      AND BokTripCreateDate > @BCS_StartDate
),
tp as (
SELECT t.BokTripNumber as trip_nbr,
	   LEFT(BokContainerNumBer, 10) as ctn_nbr,
	   t.BokContainerSize as Ctn_size
FROM bcs AS t
WHERE t.rn = 1
),
i AS
(
SELECT T1.STID, T1.ITNBR, T1.ITCLS, T1.UNMSR, T1.WEGHT, T1.B2Z95S as Unit_Cube, T1.ITDSC
FROM MasterData_ItemMaster_AFI.ITMRVA AS T1
WHERE T1.STID IN ('335')
),
--Mixed or None-Mixed container type 
m AS
(
SELECT 
	  b1.container#, b1.trip_nbr, 
	  COUNT(DISTINCT b1.Product) AS Product_Category_Qty,
	  CASE 
		WHEN COUNT(DISTINCT b1.Product) = 1 THEN 'None-Mixed'
		ELSE 'Mixed'  
	  END AS ContainerType
FROM
(
	SELECT t1.item_number
		, CASE 
			WHEN itm.ITCLS NOT LIKE 'Z%' THEN 'RP'
			WHEN SUBSTRING(t1.item_number,1,1) IN ('A','B','D','E','G','H','L','M','P','Q','R','T','W','Z') THEN 'CG'
			ELSE 'UPH' 
		  END AS Product
		, LEFT(t1.routing_code,10) AS 'container#'
		, CAST(SUBSTRING(t1.control_number_2,1,CHARINDEX('-',t1.control_number_2) -1) AS INT)  AS trip_nbr
	FROM Distribution_Warehouse_Wholesale.TranLog AS t1
	LEFT JOIN i AS itm ON t1.item_number = itm.ITNBR
	WHERE t1.wh_id IN ('335') 
	  AND t1.start_tran_date >= @TRAN_StartDate
	  AND t1.tran_type IN ('347') 
) AS b1
GROUP BY  b1.container#,b1.trip_nbr
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
		ELSE 'UPH' 
	  END AS PRODUCT
	, LEFT(t1.routing_code,10) AS CONTAINER#
	, tp.Ctn_size
	, CASE WHEN tp.Ctn_size is null THEN 'Unknown' ELSE tp.Ctn_size END AS Container_size_final
	, CAST(SUBSTRING(t1.control_number_2,1,CHARINDEX('-',t1.control_number_2) -1) AS INT)  AS TRIP#
	, m.ContainerType
	, CASE 
		WHEN m.ContainerType IN ('None-Mixed') THEN  
			(CASE 
				WHEN itm.ITCLS NOT LIKE 'Z%' THEN 'RP'
				WHEN SUBSTRING(t1.item_number,1,1) IN ('A','B','D','E','G','H','L','M','P','Q','R','T','W','Z') THEN 'CG'
				ELSE 'UPH' 
			 END)		
		ELSE m.ContainerType 
	  END AS Cont_Categories
	, itm.Unit_Cube
	, SUM(t1.tran_qty) AS ITSHQT
	, itm.Unit_Cube *  SUM(t1.tran_qty) AS CUBES
FROM Distribution_Warehouse_Wholesale.TranLog AS t1
LEFT JOIN i  AS itm ON t1.item_number = itm.ITNBR
LEFT JOIN m  AS m   ON LEFT(t1.routing_code,10)  = m.container# and 
					   CAST(SUBSTRING(t1.control_number_2,1,CHARINDEX('-',t1.control_number_2) -1) AS INT) = m.trip_nbr
LEFT JOIN tp AS tp  
       ON CAST(SUBSTRING(t1.control_number_2,1,CHARINDEX('-',t1.control_number_2) -1) AS INT) = tp.trip_nbr 
      AND LEFT(t1.routing_code,10) = tp.ctn_nbr
WHERE t1.wh_id IN ('335') 
  AND t1.start_tran_date >= @TRAN_StartDate
  AND t1.tran_type IN ('347') and t1.control_number_2 like '0012280-%'
GROUP BY t1.tran_type
		, t1.start_tran_date
		, t1.wh_id
		, t1.item_number
		, CASE 
			WHEN itm.ITCLS NOT LIKE 'Z%' THEN 'RP'
			WHEN SUBSTRING(t1.item_number,1,1) IN ('A','B','D','E','G','H','L','M','P','Q','R','T','W','Z') THEN 'CG'
			ELSE 'UPH' 
		  END
		, LEFT(t1.routing_code,10)
		, tp.Ctn_size
		, CAST(SUBSTRING(t1.control_number_2,1,CHARINDEX('-',t1.control_number_2) -1) as int)
		, m.ContainerType
		, CASE 
			WHEN m.ContainerType IN ('None-Mixed') THEN 
				(CASE 
					WHEN itm.ITCLS NOT LIKE 'Z%' THEN 'RP'
					WHEN SUBSTRING(t1.item_number,1,1) IN ('A','B','D','E','G','H','L','M','P','Q','R','T','W','Z') THEN 'CG'
					ELSE 'UPH' 
				 END)
			ELSE m.ContainerType 
		  END 
		, itm.Unit_Cube
ORDER BY 
	t1.start_tran_date, 
	CAST(SUBSTRING(t1.control_number_2,1,CHARINDEX('-',t1.control_number_2) -1) AS INT), 
	t1.item_number;
