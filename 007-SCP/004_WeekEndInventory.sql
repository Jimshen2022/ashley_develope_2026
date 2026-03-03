SELECT *
FROM Inventory_Enh_History.ItemBalance AS t1
WHERE t1.Warehouse = '335'
ORDER BY t1.DateWeekEnding


SELECT TOP 1000 *
FROM Inventory_Enh_History.ItemBalance_MIL AS t1
WHERE t1.Warehouse = '51'
ORDER BY t1.DateWeekEnding DESC