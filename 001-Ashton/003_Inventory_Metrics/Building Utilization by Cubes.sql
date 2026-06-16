WITH itm AS
(
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
            WHEN a.class_id IN ('SMALL','PAL3H','PAL5H','RAILS','FLOOR','RPFG','FLOOROP','PAL5L','RUGS') THEN 'CG'
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
main_data AS (
        SELECT t0.Warehouse,                       
               t0.DateWeekEnding,
               t0.ItemNumber,
               CASE 
                   WHEN itm.product IS NOT NULL THEN itm.product
                   WHEN LEFT(t0.ItemNumber, 1) IN ('0','1','2','3','4','5','6','7','8','9','U') THEN 'UPH'
                   ELSE 'CG'
               END AS product,
               itm.unit_volume,
               Sum(t0.OnHandQty) as OnHandQty,
               Sum(t0.OnHandQty)*itm.unit_volume as OnHandCubes
        FROM Inventory_Enh_History.ItemBalance AS t0 
        LEFT JOIN itm AS itm ON t0.ItemNumber = itm.item_number
        WHERE t0.Warehouse = '335' 
          AND t0.DateWeekEnding >= '2025-01-01'
        GROUP BY t0.Warehouse, 
                 t0.DateWeekEnding,
                 t0.ItemNumber, 
                 CASE 
                     WHEN itm.product IS NOT NULL THEN itm.product
                     WHEN LEFT(t0.ItemNumber, 1) IN ('0','1','2','3','4','5','6','7','8','9','U') THEN 'UPH'
                     ELSE 'CG'
                 END,
                 itm.unit_volume
)
SELECT 
    md.DateWeekEnding,
    md.product,
    CASE 
        WHEN md.product = 'CG' THEN 2588424  -- cubic feet in CG area
        WHEN md.product = 'UPH' THEN 4543126  -- cubic feet in UPH area
        ELSE 0
    END AS Racking_Capacity_Cubic_feet,
    SUM(md.OnHandQty) AS TotalOnHandQty,
    SUM(md.OnHandCubes) AS TotalOnHandCubes
FROM main_data AS md
GROUP BY 
    md.DateWeekEnding,
    md.product
ORDER BY md.DateWeekEnding ASC, md.product