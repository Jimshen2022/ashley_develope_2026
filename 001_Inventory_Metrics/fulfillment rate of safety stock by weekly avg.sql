
/*
select top 100 * from SupplyChain_Enh.PlanDetailTimelineSnapshot as t1 where t1.PTLDATATYPE = 'SAFETY STK' AND T1.PTLWHSE = '335' order by t1.SnapShotDate DESC
*/
-- 按产品汇总，履约率上限100%
SELECT 
    itm.product,
    COUNT(DISTINCT t1.PTLITNBR) AS TotalItems,
    SUM(t1.PTLWEEK1) AS TotalSafetyStockQty,
    SUM(ISNULL(sd.OnHandQty, 0)) AS TotalOnHandQty,
    
    -- 整体履约率，上限100%
    CASE 
        WHEN CAST(SUM(ISNULL(sd.OnHandQty, 0)) AS FLOAT) / NULLIF(SUM(t1.PTLWEEK1), 0) * 100 > 100
        THEN 100.00
        ELSE CAST(SUM(ISNULL(sd.OnHandQty, 0)) AS FLOAT) / NULLIF(SUM(t1.PTLWEEK1), 0) * 100
    END AS OverallFulfillmentRate_Pct,
    
    SUM(CASE WHEN ISNULL(sd.OnHandQty, 0) >= t1.PTLWEEK1 THEN 1 ELSE 0 END) AS ItemsMet,
    COUNT(*) AS TotalRecords,
    
    -- 达标率（满足安全库存的item占比）
    CAST(SUM(CASE WHEN ISNULL(sd.OnHandQty, 0) >= t1.PTLWEEK1 THEN 1 ELSE 0 END) AS FLOAT) / COUNT(*) * 100 AS ItemMetRate_Pct
    
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
GROUP BY itm.product
ORDER BY itm.product;