/*
ashley-edw.database.windows.net
ASHLEY_EDW

select top 10 * from dw_developer.tabledictionary where tpktablename like '%TripAvailableSTO%'

select  * from dw_developer.tabledictionary where tpktablename like '%t_stored_item%'

SELECT *
FROM INFORMATION_SCHEMA.TABLES


SELECT top 10 * FROM INFORMATION_SCHEMA.TABLES as t 
WHERE t.table_schema ='Distribution_Warehouse_Wholesale' 
	and t.TABLE_NAME LIKE '%tran%'

*/

select left(t.item_number,1)
from Distribution_Warehouse_Wholesale.TranLog as t 
where t.wh_id in ('51')
	and t.start_tran_date > '2025-01-01' 
	and t.tran_type in  ('111','301','368','374')
GROUP BY left(t.item_number,1)




with RankedRoutes as (
    select
        t.wh_id,
        t.routing_code,
        t.start_tran_date,
        ROW_NUMBER() over (
            partition by t.wh_id
            order by t.start_tran_date desc
        ) as rn
    from Distribution_Warehouse_Wholesale.TranLog as t
    where t.wh_id in ('51', '35')
        and t.start_tran_date >= '2025-06-01'
        and t.tran_type = '361'
        and t.wh_id_2 = '17'
)
select wh_id, routing_code, start_tran_date
from RankedRoutes
where rn <= 10
order by wh_id, start_tran_date desc;


DECLARE @keyword NVARCHAR(255) = 'CRM';  -- 替换为你的关键字

SELECT 
    t.TABLE_SCHEMA,
    t.TABLE_NAME,
    t.TABLE_TYPE,
    c.COLUMN_NAME
FROM 
    INFORMATION_SCHEMA.COLUMNS c
JOIN 
    INFORMATION_SCHEMA.TABLES t
    ON c.TABLE_NAME = t.TABLE_NAME AND c.TABLE_SCHEMA = t.TABLE_SCHEMA
WHERE 
    c.COLUMN_NAME LIKE '%' + @keyword + '%'
ORDER BY 
    t.TABLE_SCHEMA, 
    t.TABLE_NAME;



SELECT *
FROM Distribution_Warehouse_Wholesale.TripAvailableSTO as t
where t.SearchType = 'All Items'
     AND t.WhID = '335'
	 AND t.ItemNumber = 'D631-01'
order by t.ItemNumber, t.DispatchDate, t.TripNumber


-- STO
SELECT top 10* 
FROM Distribution_Warehouse_Wholesale.t_stored_item sto  
WHERE sto.wh_id = '335' 
	AND sto.item_number = 'D631-01'

	--AND sto.type = 'STORAGE' 
	--AND sto.location_id LIKE 'A3%'
	--AND sto.item_number = 'B742-31'
	


-- IMPORTED TRIP INFORMATION
select  * from Distribution_Warehouse_Wholesale.[t_import_WAORDER] (nolock)
where imported >'2025-01-01' and transaction_string like 'L%4259%'
order by import_id

-- query by item for out
SELECT
CAST(LEFT(t3.control_number_2, CHARINDEX('-', t3.control_number_2) - 1) AS INT) AS trip_nbr,
t3.start_tran_date,
t3.item_number,
t3.routing_code,
SUM(t3.tran_qty) AS tran_qty
--SUM(t3.tran_qty * i.B2Z95S) AS bo_tran_cube	
FROM [PowerBI_Distribution].[TranLog] AS t3
WHERE t3.wh_id = '335'
AND t3.tran_type = '347'
AND t3.item_number ='2740338'
--AND t3.control_number_2 like '%87357%'
AND t3.start_tran_date > DATEADD(DAY, -1080, GETDATE())
GROUP BY
CAST(LEFT(t3.control_number_2, CHARINDEX('-', t3.control_number_2) - 1) AS INT),
t3.start_tran_date,
t3.item_number,
t3.routing_code
ORDER BY t3.item_number, t3.start_tran_date DESC


------------------------------------

SELECT TOP 10 * FROM [PowerBI_Distribution].[TranLog] AS t3 WHERE t3.wh_id = '335' AND t3.tran_type IN  ('151')
SELECT TOP 10 * FROM [PowerBI_Distribution].[TranLog] AS t3 WHERE t3.wh_id = '335' AND t3.tran_type IN  ('951')
SELECT TOP 10 * FROM [PowerBI_Distribution].[TranLog] AS t3 WHERE t3.wh_id = '335' AND t3.tran_type IN  ('183')
SELECT TOP 10 * FROM [PowerBI_Distribution].[TranLog] AS t3 WHERE t3.wh_id = '335' AND t3.tran_type IN  ('347')
-- query by item for inbound
SELECT
	t.tran_type,
	t.description,
	t.start_tran_date,
	t.control_number,
	t.control_number_2,
	t.item_number,
	SUM(case when t.tran_type = '951' then -t.tran_qty else t.tran_qty end) AS tran_qty
FROM [PowerBI_Distribution].[TranLog] AS t
WHERE t.wh_id = '335'
AND t.tran_type IN  ('951','151')
AND t.item_number ='T383-13'
AND t.start_tran_date > '2025-05-01'
GROUP BY
	t.tran_type,
	t.description,
	t.start_tran_date,
	t.control_number,
	t.control_number_2,
	t.item_number
ORDER BY t.item_number, t.start_tran_date DESC


-- Query by Item number
SELECT *
FROM Distribution_Warehouse_Wholesale.TranLog AS t1
WHERE 
	t1.wh_id = '335' and 
	--AND t1.tran_type = '347'
     --t1.lot_number IN ('561300114544')
     t1.start_tran_date >= '2025-06-01'
	AND t1.item_number = 'T383-13'  
order by t1.item_number, t1.start_tran_date, t1.start_tran_time



-- by sn query
-- SN trx
SELECT *
FROM Distribution_Warehouse_Wholesale.TranLog AS t1
WHERE
	t1.wh_id = '335' and 
     t1.lot_number IN ('677410592503')
    --AND t1.start_tran_date >= '2025-05-01'
order by t1.item_number, t1.start_tran_date, t1.start_tran_time



   SELECT * FROM Distribution_Warehouse_Wholesale.YaTranLog AS t WHERE t.Wh_id = '335'  and t.trailer_id <>0
	and t.carrier_trailer_number like 'WHSU648004%'

select top 10 *
FROM [PowerBI_Distribution].[TranLog] AS t3 WHERE t3.wh_id = '335' AND t3.tran_type = '347'

-- by trip number to query
SELECT
CAST(LEFT(t3.control_number_2, CHARINDEX('-', t3.control_number_2) - 1) AS INT) AS trip_nbr,
t3.start_tran_date,
t3.item_number,
t3.routing_code,
SUM(t3.tran_qty) AS tran_qty
--SUM(t3.tran_qty * i.B2Z95S) AS bo_tran_cube	
FROM [PowerBI_Distribution].[TranLog] AS t3
WHERE t3.wh_id = '335'
AND t3.tran_type = '347'
AND t3.control_number_2 like '%24989%'
AND t3.start_tran_date > DATEADD(DAY, -180, GETDATE())
GROUP BY
CAST(LEFT(t3.control_number_2, CHARINDEX('-', t3.control_number_2) - 1) AS INT),
t3.start_tran_date,
t3.item_number,
t3.routing_code
ORDER BY t3.item_number



-- summary by containers
SELECT DISTINCT T1.wh_id
	, CAST(SUBSTRING(t1.load_id, 1, CHARINDEX('-', t1.load_id) - 1) AS INT) AS trip_nbr
	, CONCAT(CAST(SUBSTRING(t1.load_id, 1, CHARINDEX('-', t1.load_id) - 1) AS INT), '_',  t1.bill_number) as trip_ctn
	, t1.trailer_number as ctn_size
	, t1.bill_number as ctn_nbr
	, t1.shipment_status
	, t1.dispatch_date
	, t1.trip_type_id	
FROM Distribution_Warehouse_Wholesale.LoadMaster AS T1
WHERE T1.wh_id IN ('335') AND T1.bill_number IS NOT NULL AND T1.dispatch_date >= DATEADD(DAY,-120,GETDATE())
	AND t1.shipment_status IN ('Shipped') AND T1.trailer_number IS NOT NULL;




SELECT DISTINCT T1.wh_id
	, CAST(SUBSTRING(t1.load_id, 1, CHARINDEX('-', t1.load_id) - 1) AS INT) AS trip_nbr
	, SUBSTRING(t1.load_id, 1, CHARINDEX('-', t1.load_id) - 1) + '_'  +  t1.bill_number
	, t1.trailer_number as ctn_size
	, t1.bill_number as ctn_nbr
	, t1.shipment_status
	, t1.dispatch_date
	, t1.trip_type_id	
FROM Distribution_Warehouse_Wholesale.LoadMaster AS T1
WHERE T1.wh_id IN ('335') AND T1.bill_number IS NOT NULL AND T1.dispatch_date >= DATEADD(DAY,-120,GETDATE())
	AND t1.shipment_status IN ('Shipped') AND T1.trailer_number IS NOT NULL



SELECT
FROM Wholesale_ProductSourcing_AFI.Container as t1


SELECT top 10 *
FROM Wholesale_ProductSourcing.ContainerDirectBookingDetail


-- BCS
SELECT top 10 *
FROM PowerBI_QTIL.ContainerBooking


-- TRIP AVAILABLE
SELECT *
FROM Distribution_Warehouse_Wholesale.TripAvailableSTO as t
where t.SearchType = 'All Items'
     AND t.WhID = '335'
	 AND t.ItemNumber = 'D631-01'
order by t.ItemNumber, t.DispatchDate, t.TripNumber

B742-31




-- PO ASN QUERY
--ASN YARD
SELECT top 10 * FROM Distribution_Warehouse_Wholesale.t_asn as a1  where a1.wh_id = '335'
SELECT * FROM Distribution_Warehouse_Wholesale.ASN_Detail AS a2 where a2.wh_id = '335' and a2.customer_po_number in ('P2LGS98')
SELECT top 10  * FROM Distribution_Warehouse_Wholesale.t_trailer_asn as a3 WHERE a3.Wh_id = '335'
SELECT top 10 * FROM Distribution_Warehouse_Wholesale.Trailer  AS a4
SELECT top 10 * FROM Distribution_Warehouse_Wholesale.YaLocation as a5 WHERE a5.area_id in ('335')
SELECT * FROM Distribution_Warehouse_Wholesale.t_po_master as t where t.wh_id = '335'


-- RUGS PUTAWAY CLASS
SELECT *  
FROM Distribution_Warehouse_Wholesale.t_item_master AS t 
WHERE t.wh_id = '335' 
  AND t.item_number LIKE 'R%'
  AND EXISTS (
        SELECT 1 
        FROM (
            SELECT a.item_number
            FROM Distribution_Warehouse_Wholesale.t_stored_item AS a 
            WHERE a.wh_id = '335'
              AND a.item_number LIKE 'R%'
              AND a.location_id NOT LIKE 'RP%'
              AND a.actual_qty > 0 
              AND a.type = 'STORAGE'
            GROUP BY a.item_number
        ) AS a1
        WHERE a1.item_number = t.item_number
    )
  AND t.description LIKE '%RUG%'
  --AND t.class_id <> 'RUGS';

*/
