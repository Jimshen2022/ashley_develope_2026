/*select top 100 * from SupplyChain_Enh.PlanDetailTimelineSnapshot as t1 where t1.PTLDATATYPE = 'SAFETY STK' AND T1.PTLWHSE = '335' order by t1.SnapShotDate DESC*/
--DECLARE @YearStart DATE = DATEFROMPARTS(YEAR(GETDATE()), 1, 1);
DECLARE @YearStart DATE = DECLARE @YearStart DATE = '2025-01-01';

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
stock_data AS (
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
          AND t0.DateWeekEnding >= @YearStart
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
    t1.PTLITNBR,
    itm.product,
    itm.description,
    t1.PTLWHSE,
    t1.PTLDATATYPE,
    t1.SnapShotDate AS SnapShotDateTime,
    CAST(t1.SnapShotDate AS date) AS SnapShotDate,
    SUM(t1.PTLWEEK1) AS SafetyStockQty,
    SUM(ISNULL(sd.OnHandQty, 0)) AS OnHandQty,
    
    -- 计算 Fulfillment Rate，上限为 100%
    CASE 
        WHEN SUM(t1.PTLWEEK1) > 0 THEN 
            CASE 
                WHEN CAST(SUM(ISNULL(sd.OnHandQty, 0)) AS FLOAT) / SUM(t1.PTLWEEK1) * 100 > 100 
                THEN 100.00
                ELSE CAST(SUM(ISNULL(sd.OnHandQty, 0)) AS FLOAT) / SUM(t1.PTLWEEK1) * 100
            END
        ELSE NULL 
    END AS FulfillmentRate_Pct,
    
    -- 判断是否满足 Safety Stock
    CASE 
        WHEN SUM(ISNULL(sd.OnHandQty, 0)) >= SUM(t1.PTLWEEK1) THEN 'Met'
        ELSE 'Not Met'
    END AS SafetyStockStatus,
    
    -- 缺口数量（超过目标则显示0）
    CASE 
        WHEN SUM(t1.PTLWEEK1) - SUM(ISNULL(sd.OnHandQty, 0)) > 0 
        THEN SUM(t1.PTLWEEK1) - SUM(ISNULL(sd.OnHandQty, 0))
        ELSE 0
    END AS ShortfallQty

FROM SupplyChain_Enh.PlanDetailTimelineSnapshot AS t1 WITH (NOLOCK)
LEFT JOIN stock_data AS sd 
    ON t1.PTLITNBR = sd.ItemNumber 
    AND sd.DateWeekEnding = CAST(t1.SnapShotDate AS date)
LEFT JOIN itm AS itm 
    ON t1.PTLITNBR = itm.item_number
WHERE t1.PTLDATATYPE = 'SAFETY STK' 
  AND t1.PTLWHSE = '335'
  AND t1.PTLWEEK1 > 0
  AND t1.SnapShotDate >= @YearStart
  AND DATEPART(WEEKDAY, t1.SnapShotDate) = 7
GROUP BY 
    t1.PTLITNBR,
    itm.product,
    itm.description,
    t1.PTLWHSE,
    t1.PTLDATATYPE,
    t1.SnapShotDate
ORDER BY t1.SnapShotDate DESC;