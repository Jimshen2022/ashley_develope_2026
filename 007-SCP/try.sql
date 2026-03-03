select *
from PowerBI_SupplyChain.ItemABCCurrentSnapshot_335 as t1

select top 10 *
from PowerBI_SupplyChain.CubeAnalysis


select top 10 *
from  PowerBI_SupplyChain.Containers


select top 10 *
from   CostAccounting.InventoryHistoryWeightedAvg t1
where t1.ikey like '335%'


select top 10 *
from  Distribution_Warehouse_Wholesale.t_stored_item

select top 100 *
from  Inventory_Enh_History.MonthEndItemRevisionWeeklyHistory as t1
where t1.STID IN ('335')

SELECT  *
FROM Inventory_Enh_History.ItemBalance AS t1
WHERE t1.Warehouse = '335' and t1.DateWeekEnding>= '2024-06-01'
ORDER BY t1.DateWeekEnding

