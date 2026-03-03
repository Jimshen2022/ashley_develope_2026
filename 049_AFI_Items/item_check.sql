-- location
select top 10 * from t_location where location_id in ('A3018CY1')
select top 10 * from t_class_loca where location_id in ('A3018CY1') order by location_id


-- transaction history for item
select  *  from t_tran_log  where control_number in ('P2RFJ51')

select * from t_stored_item where item_number in ('L329104')

select  
	start_tran_date,
	item_number,
	control_number,
	control_number_2,
	sum(case when tran_type = '951' then -tran_qty else tran_qty end) as tran_qty,
	tran_type
from t_tran_log  
where control_number_2 in ('P2RFJ51') AND tran_type in ('151','951')
group by 	start_tran_date,
	item_number,
	control_number,
	control_number_2,
		tran_type


--- item basic 
select top 10 * from t_item_master where item_number in ('70413S')
select top 10 * from t_item_master where pick_put_id  in ('RPFG')

select top 10 * from t_item_uom where item_number in ('B922-36')
select top 10 * from t_stored_item where item_number in ('B922-36')
select item_number, std_hand_qty,pallet_id, recv_equipment_class_id * from t_item_master where item_number in ('B922-36')
select location_id, status, type,  capacity_volume  from t_location where location_id like 'A3099A%' 
select top 10 * from t_load_master
select top 10 * from t_load_details



select item_number, sum(actual_qty) as actual_qty, location_id from t_stored_item where location_id like 'A3%' group by item_number, location_id 

-- item, qty, location
select t.item_number,
	sum(t.actual_qty) as actual_qty,
	t.location_id
from t_stored_item t 
where location_id like 'A30%' AND item_number != 'RP ORDER'
group by t.item_number,t.location_id
ORDER BY t.location_id

-- location master
select location_id,status, type,  capacity_volume
from t_location 
where location_id like 'A30%'
order by location_id


-- item with uom scoop
select s.*, 
	i.commodity_code, i.inventory_type, i.description, i.std_hand_qty AS std_hand_qty_Master, i.pick_put_id as pick_put_id_master, i.nested_volume, i.unit_volume, i.unit_weight, i.length,i.width, i.height, i.recv_equipment_class_id, 
	u.*
from t_stored_item as s
join t_item_master as i on i.item_number = s.item_number
join (select item_number as itm, uom, units_per_layer, layers_per_uom, max_in_layer, class_id, pick_put_id as pick_put_id_uom, std_hand_qty as std_hand_qty_uom, max_hand_qty, pallet_id, cube_factor from t_item_uom where pick_put_id = 'SCOOP') as u on u.itm = s.item_number 
--where s.item_number like 'B%-36'
where s.item_number in ('B922-36')


select top 10 * from t_item_uom where item_number in ('R78891','R78908','78830','3410587181')
select top 10 * from t_item_attributes where item_number in ('R78891','R78908','78830','3410587181')
select topA3017GC2 10 * from t_fwd_pick where item_number in ('R78891','R78908','78830','3410587181')




select t.item_number,t.location_id, i. description,t.serial_number, t.received_date 
from t_serial_active as t
left join t_item_master as i on i.item_number = t.item_number
where t.location_id in ('EX001AA1','EX001AA2')
group by  t.item_number, t.location_id, i. description, t.serial_number,  t.received_date 
