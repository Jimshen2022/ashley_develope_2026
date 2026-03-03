select top 10 * from t_tran_log order by start_tran_date desc, start_tran_time desc 
select top 10 * from t_tran_log order by start_tran_date desc, start_tran_time desc 


-- by item outbound
SELECT t1.start_tran_date,t1.item_number,t1.control_number_2, t1.tran_type,  sum(t1.tran_qty) as tran_qty
from t_tran_log as t1
WHERE t1.wh_id = '335'
	AND t1.tran_type in ('347')
    AND t1.item_number IN ('A4000510')
    AND t1.start_tran_date >= '2025-12-28'
GROUP by  t1.start_tran_date,t1.item_number,t1.control_number_2,t1.tran_type
order by t1.item_number, t1.start_tran_date


-- by item inbound
SELECT t1.start_tran_date,t1.item_number,t1.control_number_2, t1.tran_type,  sum(t1.tran_qty) as tran_qty
from t_tran_log as t1
WHERE t1.wh_id = '335'
	AND t1.tran_type in ('165','851','855','151')
    AND t1.item_number IN ('9210346')
	AND t1.control_number_2 IN ('P2RNT74','P2RSC61','P2RSC85','P2RSD96')
    AND t1.start_tran_date >= '2025-12-28'
GROUP by  t1.start_tran_date,t1.item_number,t1.control_number_2,t1.tran_type
order by t1.item_number, t1.start_tran_date


-- by item inbound
SELECT t1.start_tran_date,t1.item_number,t1.control_number_2, t1.tran_type,  sum(t1.tran_qty) as tran_qty
from t_tran_log as t1
WHERE t1.wh_id = '335'
	--AND t1.tran_type in ('165','851','855','151')
    AND t1.item_number IN ('A4000510')

    AND t1.start_tran_date >= '2025-12-28'
GROUP by  t1.start_tran_date,t1.item_number,t1.control_number_2,t1.tran_type
order by t1.item_number, t1.start_tran_date

--PO
select t.start_tran_date, t.control_number as trailer_number,t.control_number_2 as po, t.item_number, sum(case when tran_type = '151' then t.tran_qty else -t.tran_qty end) as qty_received
from t_tran_log as t
where t.control_number_2 = 'P2RQ016' and t.tran_type in ('151','951')
group by t.start_tran_date, t.control_number, t.item_number, t.control_number_2


-- scoop qty
select t.item_number,t.uom, t.units_per_layer, t.layers_per_uom, t.max_in_layer,  t.max_hand_qty, 
t.uom_weight, t.length,t.width,t.height, t.nested_volume, t.unit_volume, t.equipment_class_id,  t.pick_put_id, t.class_id, 
t.std_hand_qty,f.replen_level, f.capacity_qty,t.pallet_id,  f.is_new_item, f.uom
from t_item_uom as t
join t_fwd_pick as f on t.item_number = f.item_number
where  t.item_number = 'W854-68'
where t.pick_put_id = 'SCOOP' and t.item_number = 'B650-31'


-- by item number 
select  top 10 * from t_fwd_pick where  item_number = 'A4000510' 
select  top 10 * from t_tran_log where  tran_type in ('347') order by start_tran_date desc, start_tran_time desc
select  top 10 * from t_tran_log where  tran_type in ('347') order by start_tran_date desc, start_tran_time desc


-- item and serial number query
select  * from t_tran_log where item_number = 'R405781'  and tran_type in  ('165','855') order by start_tran_date desc, start_tran_time desc
select  * from t_tran_log where lot_number = '661420018082'  order by start_tran_date desc, start_tran_time desc

select  * from t_tran_log where item_number = 'P2RQ088'  order by start_tran_date desc, start_tran_time desc
select  * from t_tran_log where item_number = 'R61320'  order by start_tran_date desc, start_tran_time desc
select  * from t_tran_log where item_number = 'RBB774'  order by start_tran_date desc, start_tran_time desc
select  * from t_tran_log where item_number = 'R79585'  order by start_tran_date desc, start_tran_time desc
select  * from t_tran_log where control_number_2 = 'P2RHQ94'  order by start_tran_date desc, start_tran_time desc
select  * from t_tran_log where control_number_2 = 'P2RJM06'  order by start_tran_date desc, start_tran_time desc

select  * from t_tran_log where control_number_2 = 'P2RJ172' and tran_type in ('151','951') and item_number like 'R%' order by start_tran_date desc, start_tran_time desc
select  * from t_tran_log where control_number_2 = 'P2RJ172' and tran_type in ('151','951') and item_number like 'R%' order by start_tran_date desc, start_tran_time desc
select  * from t_tran_log where control_number_2 = 'P2RJ172' and tran_type in ('151','951') and item_number like 'R%' order by start_tran_date desc, start_tran_time desc
select  * from t_tran_log where control_number_2 = 'P2RHQ32' and tran_type in ('151','951') and item_number like 'R%' order by start_tran_date desc, start_tran_time desc
select  * from t_ya_tran_log where carrier_trailer_number = 'VFCU4702540'  order by started  desc



-- loaded  trip# 
select t.start_tran_date, t.start_tran_time, t.control_number as trailer_number,t.control_number_2 as po, t.item_number, sum(case when tran_type = '347' then t.tran_qty else -t.tran_qty end) as qty_received
from t_tran_log as t
where t.control_number_2 like '%68806%' and t.tran_type in ('347')
group by t.start_tran_date,t.start_tran_time, t.control_number, t.item_number, t.control_number_2


-- loaded  trip# 
select t.start_tran_date, t.start_tran_time, t.control_number as trailer_number,t.control_number_2 as po_or_trip, t.routing_code, t.item_number, sum(case when tran_type = '347' then t.tran_qty else -t.tran_qty end) as qty_received
from t_tran_log as t
where t.control_number_2 like '%69346%' and t.tran_type in ('347')
group by t.start_tran_date,t.start_tran_time, t.control_number, t.item_number, t.control_number_2, t.routing_code


-- item number tran type query
select  tran_type,description,start_tran_date,start_tran_time,employee_id,control_number,control_number_2,wh_id,location_id,hu_id,item_number,lot_number,uom,tran_qty,
	wh_id_2,location_id_2,routing_code,sn_coo,process, equipment_zone
from t_tran_log where item_number = '9210346'  and tran_type in  ('347')   order by start_tran_date desc, start_tran_time desc


select  * from t_tran_log where item_number = 'A1001053'  and tran_type in  ('347') order by start_tran_date desc, start_tran_time desc


select  * from t_tran_log where control_number_2 in ('P2QFJ21','P2QFJ22')  and tran_type in  ('151','951') order by start_tran_date desc, start_tran_time desc
select  * from t_tran_log where control_number_2 in ('P2QFJ21','P2QFJ22')  and tran_type in  ('151','951') order by start_tran_date desc, start_tran_time desc



-- item mast and uom
select  * 
from t_item_master as t
join t_item_uom as u on t.item_number = u.item_number
where t.item_number in ('B476-65')

select * from t_loc_pallet_capacity as p
where p.wh_id = '335' and p.location_id = 'A3015HR2'






-- tranlog query

select   
	tran_type,
	description,
	start_tran_date,
	start_tran_time,
	employee_id,
	control_number,
	control_number_2,
	wh_id,
	location_id,
	hu_id,
	item_number,
	lot_number,
	uom,
	tran_qty,
	wh_id_2,
	location_id_2,
	routing_code,
	sn_coo,
	process,
	equipment_zone
from t_tran_log where item_number = 'A2000611'  and lot_number = '688806114632'  order by start_tran_date desc, start_tran_time desc



