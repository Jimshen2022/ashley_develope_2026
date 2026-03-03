-- trip report
SELECT top 10 * 
FROM Distribution_Warehouse_Wholesale.TripReport  as t  
WHERE t.WhID = '335' 
	--AND t.TripStatus NOT IN ('S','X') 
	--AND right(t.loadID,2) <> '00' 
	AND t.LoadID like '0004259-%'



select  * from Distribution_Warehouse_Wholesale.[t_import_WAORDER] (nolock)
where imported >'2025-01-01' and transaction_string like '%0004259-%'
order by import_id