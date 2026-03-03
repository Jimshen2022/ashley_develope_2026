-- Calculate the date once and reuse it
--DECLARE @RecentDate DATE = DATEADD(DAY, -380, GETDATE());
--DECLARE @RecentTranDate DATE = DATEADD(DAY, -60, GETDATE());
DECLARE @load_date DATE = '2023-12-01';
DECLARE @RecentTranDate DATE = DATEADD(DAY, -60, GETDATE());

WITH MaxEnteredYard AS (
  SELECT
    t1.wh_id, t1.equipment_id, MAX(t1.entered_yard) AS max_entered_yard
  FROM 
    (SELECT a.area_id as wh_id, a.equipment_id, a.entered_yard 
	 FROM Distribution_Warehouse_Wholesale.Trailer AS a 
	 WHERE a.wh_id = '31' 
	   AND a.entered_yard >= @load_date) as t1 
  GROUP BY t1.wh_id, t1.equipment_id),
-- ctn_nbr + size + enter yard max time
ctn AS
(
SELECT
  Distinct t1.wh_id 
  , t1.equipment_id
  , t1.trailer_type_id
  , t1.entered_yard
  , CASE
		WHEN t1.trailer_type_id IN ('86') THEN '20FT'
		WHEN t1.trailer_type_id IN ('87') THEN '40FT'
		WHEN t1.trailer_type_id IN ('88') THEN '45FT'
		WHEN t1.trailer_type_id IN ('177') THEN '40H'
		WHEN t1.trailer_type_id IN ('324') THEN '53FT'
	ELSE '40H' END AS ctn_size
FROM
   (SELECT a.area_id as wh_id, a.equipment_id, a.entered_yard, a.trailer_type_id 
    FROM Distribution_Warehouse_Wholesale.Trailer AS a 
	WHERE a.wh_id = '31' 
	    AND a.entered_yard >= @load_date) as t1 
INNER JOIN MaxEnteredYard mey ON t1.wh_id = mey.wh_id
  AND t1.equipment_id = mey.equipment_id
  AND t1.entered_yard = mey.max_entered_yard
),
-- Item infromation
i AS
(
--SELECT T1.ITNBR, T1.ITMITCLS AS ITCLS, T1.ITMWEGHT AS WEGHT,T1.CUBES as unit_cube
--FROM MasterData_ItemMaster_AFI.ITMEXT AS T1
SELECT 
    COALESCE(T1.ITNBR, T2.ITNBR) AS ITNBR,
    CASE 
        WHEN T1.CUBES > 0 THEN T1.ITMITCLS
        WHEN T1.CUBES = 0 AND T2.B2Z95S > 0 THEN T2.ITCLS
        ELSE NULL
    END AS ITCLS,
    CASE 
        WHEN T1.CUBES > 0 THEN T1.ITMWEGHT
        WHEN T1.CUBES = 0 AND T2.B2Z95S > 0 THEN T2.WEGHT
        ELSE NULL
    END AS WEGHT,
    CASE 
        WHEN T1.CUBES > 0 THEN T1.CUBES
        WHEN T1.CUBES = 0 AND T2.B2Z95S > 0 THEN T2.B2Z95S
        ELSE NULL
    END AS unit_cube
FROM 
    MasterData_ItemMaster_WNK.ITMEXT AS T1
FULL OUTER JOIN 
    (SELECT a.STID, a.ITNBR, a.ITCLS, a.B2Z95S, a.WEGHT FROM MasterData_ItemMaster_WNK.ITMRVA as a WHERE a.STID = '35') AS T2
ON 
    T1.ITNBR = T2.ITNBR
),
-- Trip and container# and container size
tp AS
(
SELECT DISTINCT 
      t1.wh_id
	, t1.control_number_2 AS trip_nbr
	, t1.routing_code as ctn_nbr
	, t1.start_tran_date
	, ctn.ctn_size
FROM (select a.wh_id, a.control_number_2, a.routing_code, a.start_tran_date 
	  from Distribution_Warehouse_Wholesale.TranLog as a 
	  where a.wh_id in ('35','31','33','34') 
		AND a.start_tran_date >= @load_date 
		AND a.tran_type IN ('361')) AS t1
LEFT JOIN ctn as ctn on ctn.equipment_id = t1.routing_code AND ctn.wh_id = t1.wh_id
),
--Mixed or None-Mixed container type
m AS
(
SELECT
	  b1.wh_id
	, b1.ctn_nbr
	, b1.trip_nbr
	, b1.employee_id
	, b1.supervisor
	, COUNT(DISTINCT b1.Product) AS Product_Category_Qty
	, COUNT(DISTINCT b1.item_number) as skus
	, CASE
		WHEN COUNT(DISTINCT b1.Product) = 1 THEN 'Non-Mixed'
		ELSE 'Mixed'  END AS container_type
	--, STRING_AGG(DISTINCT b1.Product, '-') AS Prodct_String
FROM
(
SELECT t1.wh_id, t1.item_number
	, CASE
		WHEN itm.ITCLS NOT LIKE 'Z%' THEN 'RP'
		WHEN SUBSTRING(t1.item_number,1,1) IN ('A','B','D','E','G','H','L','M','P','Q','R','T','Z') THEN 'CG'
		ELSE 'UPH' END AS Product
	, t1.routing_code AS ctn_nbr
	, t1.control_number_2 AS trip_nbr
	, t1.employee_id
	, t1.employee_id_2 as supervisor
FROM (select * 
	  from Distribution_Warehouse_Wholesale.TranLog as a 
	  where a.wh_id in ('35','31','33','34') 
	    and a.start_tran_date >= @load_date 
		AND a.tran_type IN ('361')) AS t1
LEFT JOIN i AS itm ON t1.item_number = itm.ITNBR
) AS b1
GROUP BY  b1.wh_id, b1.ctn_nbr, b1.trip_nbr, b1.employee_id, b1.supervisor
),
-- employee and department
emp AS 
(select t1.wh_id, t1.id, t1.name, t1.work_shift, t1.supervisor,
 t1.dept, t2.description as dept_name, t1.group_nbr, t3.Description as Grounp_name
from
    (select * from Distribution_Warehouse_Wholesale.t_employee a
     where a.wh_id IN ('35','31','33','34')
        and a.status <> 'T') as t1
left join
    (select * from PowerBI_Distribution.Department as c where c.wh_id IN ('35','31','33','34')) as t2
     on t1.wh_id = t2.wh_id and t1.dept=t2.department
left join 
	 (select * from Distribution_Warehouse_Wholesale.[Group] as t1 where t1.wh_id IN ('35','31','33','34')) as t3
	 on t1.wh_id = t3.wh_id  and t1.group_nbr = t3.GroupNbr)
    
-------------------------------------------MAIN-------------------------------------------------------------------
SELECT
	  t1.tran_type
	, t1.start_tran_date
	, t1.wh_id
	, t1.item_number
	, CASE
		WHEN itm.ITCLS NOT LIKE 'Z%' THEN 'RP'
		WHEN SUBSTRING(t1.item_number,1,1) IN ('A','B','D','E','G','H','L','M','P','Q','R','T','Z') THEN 'CG'
		ELSE 'UPH' END AS product
	, t1.routing_code AS ctn_nbr
	--, CONCAT(CAST(t1.control_number_2 AS VARCHAR), '_',  t1.routing_code) as trip_ctn
	, tp.ctn_size
	, t1.control_number_2 AS trip_nbr
	, m.container_type
	, m.skus
	, m.employee_id
	, e.name as employee_name
	, e.supervisor
	, CASE
		WHEN m.container_type IN ('Non-Mixed') THEN  
		(CASE
			WHEN itm.ITCLS NOT LIKE 'Z%' THEN 'RP'
			WHEN SUBSTRING(t1.item_number,1,1) IN ('A','B','D','E','G','H','L','M','P','Q','R','T','Z') THEN 'CG'
			ELSE 'UPH' END)
		ELSE m.container_type END AS container_category
	, itm.unit_cube
	, SUM(t1.tran_qty) AS tran_qty
	, itm.Unit_Cube *  SUM(t1.tran_qty) AS cubes
	, CAST(
		itm.Unit_Cube * SUM(t1.tran_qty) /
		CASE 
			WHEN TRIM(SUBSTRING(tp.ctn_size, 1, 3)) = '40H' THEN 2650.0
			WHEN TRIM(SUBSTRING(tp.ctn_size, 1, 3)) = '40' THEN 2383.0
			WHEN TRIM(SUBSTRING(tp.ctn_size, 1, 3)) = '45' THEN 3058.0
			WHEN SUBSTRING(tp.ctn_size, 1, 1) = '2' THEN 1191.0
			ELSE 2650.0 END AS DECIMAL(10, 4)) AS Utilization
FROM (select * 
	  from Distribution_Warehouse_Wholesale.TranLog as a 
	  where a.wh_id in ('35','31','33','34') 
	    AND a.start_tran_date Between '2024-01-01' AND GETDATE() 
		AND a.tran_type IN ('361')) AS t1
LEFT JOIN i AS itm ON t1.item_number = itm.ITNBR
LEFT JOIN m AS m ON t1.wh_id = m.wh_id and t1.control_number_2 = m.trip_nbr and t1.routing_code = m.ctn_nbr
LEFT JOIN tp AS tp ON t1.wh_id = tp.wh_id AND t1.routing_code = tp.ctn_nbr and t1.control_number_2 = tp.trip_nbr
LEFT JOIN emp as e ON t1.wh_id = e.wh_id and t1.employee_id = e.id 
GROUP BY t1.tran_type
		, t1.start_tran_date
		, t1.wh_id
		, t1.item_number
		, CASE
			WHEN itm.ITCLS NOT LIKE 'Z%' THEN 'RP'
			WHEN SUBSTRING(t1.item_number,1,1) IN ('A','B','D','E','G','H','L','M','P','Q','R','T','Z') THEN 'CG'
			ELSE 'UPH' END
		, t1.routing_code
       --, CONCAT(CAST(t1.control_number_2 AS VARCHAR), '_',  t1.routing_code)
		, tp.ctn_size      -- get the data from Trailer maximum(container entered into yard time)
		, t1.control_number_2
		, m.container_type
	    , m.skus
		, m.employee_id
		, e.name 
		, e.supervisor
		, CASE
			WHEN m.container_type IN ('None-Mixed') THEN
			(CASE
				WHEN itm.ITCLS NOT LIKE 'Z%' THEN 'RP'
				WHEN SUBSTRING(t1.item_number,1,1) IN ('A','B','D','E','G','H','L','M','P','Q','R','T','Z') THEN 'CG'
				ELSE 'UPH' END)
				ELSE m.container_type END
		, itm.unit_cube
ORDER BY t1.start_tran_date, t1.control_number_2, t1.item_number