select top 10 * from t_item_master
select top 10 * from t_item_uom
select top 10 * from t_stored_item 
select * from t_stored_item where location_id like 'M3%' and actual_qty>0 order by location_id
select top 10 * from t_location where location_id like 'M3%' ORDER BY location_id DESC



-- UOM as main table
select t.wh_id, t.item_number,pick_put_id, class_id, t.cube_factor, sto.actual_qty
from t_item_uom as t
left join (select wh_id, item_number, sum(actual_qty) actual_qty from t_stored_item group by item_number, wh_id) as sto on sto.item_number = t.item_number and sto.wh_id = t.wh_id
where sto.actual_qty>0 and pick_put_id = 'UPH'
order by t.item_number



-- check cube factors
select sto.wh_id, sto.item_number, sto.location_id, sum(sto.actual_qty) actual_qty, t.pick_put_id, t.class_id, t.cube_factor, l.capacity_volume
from t_stored_item as sto
left join t_item_uom as t on t.item_number = sto.item_number and t.wh_id = sto.wh_id
left join t_location as l on l.location_id = sto.location_id
where sto.actual_qty>0 and t.pick_put_id = 'UPH'
group by sto.wh_id, sto.item_number, sto.location_id, t.pick_put_id, t.class_id, t.cube_factor,  l.capacity_volume
order by sto.item_number





