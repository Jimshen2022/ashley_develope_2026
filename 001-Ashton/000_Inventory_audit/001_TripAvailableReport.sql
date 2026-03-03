

SELECT  * FROM Distribution_Warehouse_Wholesale_History.t_stored_item as t where t.wh_id='335' and t.item_number = 'B742-31' order by t.SnapshotDatetime desc


select * from dw_developer.tabledictionary where tpktablename like '%TripAvailableSTO%'
-- TripAvailableSTO
SELECT *
FROM Distribution_Warehouse_Wholesale.TripAvailableSTO as t
where t.SearchType = 'All Items'
     AND t.WhID = '335'
	 AND t.ItemNumber = 'B857-51'
order by t.ItemNumber, t.DispatchDate, t.TripNumber

