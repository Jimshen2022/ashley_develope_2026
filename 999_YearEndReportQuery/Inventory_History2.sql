WITH item AS
(SELECT 
     a.item_number
    ,a.description
    ,a.uom
    ,a.inventory_type
    ,a.commodity_code
    ,a.wh_id
    ,a.class_id
    ,a.unit_weight
    ,a.unit_volume
    ,a.nested_volume
    ,a.pick_put_id
    ,CASE
        WHEN a.commodity_code NOT LIKE 'Z%' THEN 'CG'  -- RP
        WHEN a.class_id IN ('SMALL','PAL3H','PAL5H','RAILS','FLOOR','RPFG','FLOOROP','PAL5L') THEN 'CG'
        WHEN a.class_id LIKE 'UPH%' THEN 'UPH'
        WHEN a.class_id IS NULL AND a.pick_put_id = 'UPH' THEN 'UPH'
        WHEN a.class_id IS NULL AND a.pick_put_id = 'PALLT' THEN 'CG'
        WHEN LEFT(a.item_number, 1) IN ('A','D','E','H','K','L','M','P','Q','R','T','W') THEN 'CG'
        WHEN LEN(a.item_number) >7 THEN 'CG'
        WHEN LEFT(a.item_number, 1) IN ('1','2','3','4','5','6','7','8','9','U') THEN 'UPH'
        ELSE 'CG'
    END AS product
FROM Distribution_Warehouse_Wholesale.t_item_master AS a
WHERE a.wh_id = '335' 
)
-- Main Query ---
SELECT  
	--t1.ItemNumber
 --   , t1.Warehouse
 --   , itm.commodity_code
    CASE 
            WHEN LEFT(t1.ItemNumber, 1) IN ('A','D','E','H','K','L','M','P','Q','R','T','W') THEN 'CG'
            WHEN LEN(t1.ItemNumber) >7 THEN 'CG'
            WHEN LEFT(t1.ItemNumber, 1) IN ('1','2','3','4','5','6','7','8','9','U') THEN 'UPH'
            else itm.product END as product
	, t1.DateWeekEnding
    , DATEPART(YYYY,t1.DateWeekEnding)*100 + DATEPART(MONTH, t1.DateWeekEnding) AS YearMonth
    , SUM(CAST(t1.OnHandQty AS INT)) AS MonthlyOnHandQty
    --, MAX(CAST(t1.OnHandQty AS INT)) AS MaxMonthlyOnHandQty
    --, MIN(CAST(t1.OnHandQty AS INT)) AS MinMonthlyOnHandQty
FROM (
    select * 
    from Inventory_Enh_History.ItemBalance as t0 
    where t0.Warehouse = '335' 
    and t0.DateWeekEnding >= '2024-01-01'
    and DATEPART(WEEKDAY, t0.DateWeekEnding) = 7
) AS t1
LEFT JOIN item as itm on t1.ItemNumber = itm.item_number
GROUP BY  
	--t1.ItemNumber
 --   , t1.Warehouse
 --   , itm.commodity_code
     CASE 
            WHEN LEFT(t1.ItemNumber, 1) IN ('A','D','E','H','K','L','M','P','Q','R','T','W') THEN 'CG'
            WHEN LEN(t1.ItemNumber) >7 THEN 'CG'
            WHEN LEFT(t1.ItemNumber, 1) IN ('1','2','3','4','5','6','7','8','9','U') THEN 'UPH'
            else itm.product END
    , DATEPART(YYYY,t1.DateWeekEnding)*100 + DATEPART(MONTH, t1.DateWeekEnding)
	, t1.DateWeekEnding
ORDER BY DATEPART(YYYY,t1.DateWeekEnding)*100 + DATEPART(MONTH, t1.DateWeekEnding)