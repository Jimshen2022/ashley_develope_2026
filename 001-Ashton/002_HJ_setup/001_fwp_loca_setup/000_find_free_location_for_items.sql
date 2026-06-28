
select top 10 * from t_location where location_id in ('A3010EF1','A3010FF1')

-- This query is designed to find free locations for items in the warehouse.
select  l.location_id,l.type, si.item_number, sum(si.actual_qty) as onhand 
from t_location  as l
left join t_stored_item as si on si.location_id = l.location_id
where l.location_id like 'A3010[CEGJLN]%[1]%' 
group by l.location_id, l.type, si.item_number


-- uom SCOOP
select top 10 * from t_class_loca where class_id in ('A3010C','A3010E','A3010G','A3010J','A3010L','A3010N')
select top 10 * from t_item_master
select top 10 * from t_item_uom


select u.item_number, u.uom, u.conversion_factor, units_per_layer,
layers_per_uom,max_in_layer, nested_volume,unit_volume, priority, class_id, 
pick_put_id, std_hand_qty, max_hand_qty, pallet_id, equipment_class_id, cube_factor
from t_item_uom as u 
where item_number like 'B%' AND uom = 'SCOOP'


-- location type I on ground
select l.location_id,l.type, si.item_number, sum(si.actual_qty) as onhand
from t_location  as l
left join t_stored_item as si on si.location_id = l.location_id
where l.location_id like 'A301[0-7]%[1]' and l.type not in ('P','X','ZZ')
group by l.location_id, l.type, si.item_number