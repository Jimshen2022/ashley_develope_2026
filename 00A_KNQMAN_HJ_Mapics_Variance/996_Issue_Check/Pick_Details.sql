--SELECT  *  FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME LIKE '%pick%'
--select top 10 * from t_stored_item as t where t.type like '%43748%'
--select top 10 * from t_serial_active as t where t.trip_number like '%43748%'
--select top 10 * from t_pick_detail as t 


select  t.item_number, t.status, 
	sum(t.unplanned_quantity) as unplanned_quantity, 
	sum(t.planned_quantity) as planned_quantity,
	sum(t.picked_quantity) as picked_quantity,
	sum(t.staged_quantity) as staged_quantity,
	sum(t.loaded_quantity) as loaded_quantity,
	sum(si.actual_qty) as sto_qty,
	count(sa.serial_number) as serial_qty
from t_pick_detail as t 
left join t_stored_item si on right(t.order_number,7)  = left(si.type,7) and t.item_number = trim(si.item_number)
left join t_serial_active sa on right(t.order_number,7)  = left(sa.trip_number,7) and t.item_number = sa.item_number
where t.order_number like '%43148%'
group by t.item_number, t.status
