select top 10 * from Inventory_Enh_History.ItemBalance where Warehouse = '335' and DateWeekEnding >= '2026-06-01' order by DateWeekEnding desc

        FROM Inventory_Enh_History.ItemBalance AS t0 
        LEFT JOIN itm AS itm ON t0.ItemNumber = itm.item_number
        WHERE t0.Warehouse = '335' 
          AND t0.DateWeekEnding >= '2025-10-01'
        GROUP BY t0.Warehouse, 
                 t0.DateWeekEnding,
                 t0.ItemNumber, 
                 CASE 
                     WHEN itm.product IS NOT NULL THEN itm.product
                     WHEN LEFT(t0.ItemNumber, 1) IN ('0','1','2','3','4','5','6','7','8','9','U') THEN 'UPH'
                     ELSE 'CG'
                 END,
                 itm.unit_volume
