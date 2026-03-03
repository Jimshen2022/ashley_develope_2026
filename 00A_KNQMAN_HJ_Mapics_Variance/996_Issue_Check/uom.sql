select top 10 * from t_item_uom as t where t.item_number = 'A4000664'
select top 10 * from t_item_master as t where t.item_number = 'A4000664'
select top 10 * from t_fwd_pick as t where t.item_number = 'A4000664'

--select top 10 * from t_serial_master 
--select top 10 * from t_item_master 
--select top 1000 * from t_item_uom  where item_number like 'B%' AND pick_put_id = 'PALLT' order by item_number
t_fwd_pick

select t.*, im.std_hand_qty, si.actual_qty 
from t_fwd_pick as t
left join t_item_master as im on im.item_number = t.item_number
left join (select item_number, sum(actual_qty) as actual_qty from t_stored_item group by item_number)as si on si.item_number = t.item_number
where si.actual_qty>0 and capacity_qty = 0 and im.commodity_code like 'Z%' AND  im.commodity_code not like 'Z%K' and t.location_id not in ('A1001AA9','A1001AA1')
order by t.item_number


select top 10 * from t_fwd_pick as t where t.item_number = 'A4000664'



select distinct t.item_number,
	im.description,
	t.uom,
	t.units_per_layer,
	t.layers_per_uom,
	t.max_in_layer,
	t.class_id,
	t.pick_put_id,
	case 
		when t.pallet_id = '1' then '5x5'
		when t.pallet_id = '3' then '5x7'
		when t.pallet_id = '4' then '3.5x5'
		when t.pallet_id = '5' then '3.5x7'
		When t.pallet_id = '18'then '5x8'
		When t.pallet_id = '16'then 'No Skid'
		else 'Check' END as pallet_type
from t_item_uom as t 
join t_item_master as im on im.item_number = t.item_number
join t_stored_item as si on si.item_number = t.item_number
where t.pick_put_id = 'SCOOP' 
    and im.inventory_type = 'FG'
	and im.commodity_code like 'Z%' AND  im.commodity_code not like 'Z%K' 
	and t.class_id not in ( 'NEW','Small')
	and t.wh_id = '335'
	and si.actual_qty > 0
