WITH item AS (
    SELECT 
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
            WHEN a.commodity_code NOT LIKE 'Z%' THEN 'CG'
            WHEN a.class_id IN ('SMALL','PAL3H','PAL5H','RAILS','FLOOR','RPFG','FLOOROP','PAL5L') THEN 'CG'
            WHEN a.class_id LIKE 'UPH%' THEN 'UPH'
            WHEN a.class_id IS NULL AND a.pick_put_id = 'UPH' THEN 'UPH'
            WHEN a.class_id IS NULL AND a.pick_put_id = 'PALLT' THEN 'CG'
            WHEN LEFT(a.item_number, 1) IN ('A','D','E','H','K','L','M','P','Q','R','T','W') THEN 'CG'
            WHEN LEN(a.item_number) > 7 THEN 'CG'
            WHEN LEFT(a.item_number, 1) IN ('1','2','3','4','5','6','7','8','9','U') THEN 'UPH'
            ELSE 'CG'
        END AS product
    FROM Distribution_Warehouse_Wholesale.t_item_master AS a
    WHERE a.wh_id = '335'
),
FilteredData AS (
    SELECT 
         t1.ItemNumber
        ,t1.Warehouse
        ,t1.DateWeekEnding
        ,itm.commodity_code
        ,itm.product
        ,CASE 
            WHEN LEFT(t1.ItemNumber, 1) IN ('A','D','E','H','K','L','M','P','Q','R','T','W') THEN 'CG'
            WHEN LEN(t1.ItemNumber) > 7 THEN 'CG'
            WHEN LEFT(t1.ItemNumber, 1) IN ('1','2','3','4','5','6','7','8','9','U') THEN 'UPH'
            ELSE itm.product 
         END AS product_adjusted
        ,DATEPART(YYYY, t1.DateWeekEnding) * 100 + DATEPART(MONTH, t1.DateWeekEnding) AS YearMonth
        ,ROW_NUMBER() OVER (
            PARTITION BY DATEPART(YYYY, t1.DateWeekEnding), DATEPART(MONTH, t1.DateWeekEnding)
            ORDER BY t1.DateWeekEnding DESC
        ) AS RowNum
        ,t1.OnHandQty
    FROM (
        SELECT * 
        FROM Inventory_Enh_History.ItemBalance AS t0 
        WHERE t0.Warehouse = '335' AND t0.DateWeekEnding >= '2024-01-01'
    ) AS t1
    LEFT JOIN item AS itm ON t1.ItemNumber = itm.item_number
)
-- Only keep the last week of each month
SELECT  
     ItemNumber
    ,Warehouse
    ,DateWeekEnding
    ,commodity_code
    ,product
    ,product_adjusted
    ,YearMonth
    ,SUM(CAST(OnHandQty AS INT)) AS OnHandQty
FROM FilteredData
WHERE RowNum = 1 -- Only keep the last week
GROUP BY  
     ItemNumber
    ,Warehouse
    ,DateWeekEnding
    ,commodity_code
    ,product
    ,product_adjusted
    ,YearMonth
ORDER BY YearMonth;
