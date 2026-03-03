select top 100 * from t_serial_master
select top 100 * from t_serial_active
select * 
from t_serial_master (nolock) snm
join t_serial_active (nolock) sna on snm.serial_number=sna.serial_number
where 1=1
and snm.serial_no_status <> sna.serial_no_status
and snm.wh_id='335'
and sna.serial_no_status <> 'O'
order by sna.status_change

select distinct recv_equipment_class_id   from t_item_master where class_id='FLOOR' 



select * 
from t_item_master t
left join t_item_uom as u on u.item_number=t.item_number and u.wh_id=t.wh_id
where t.class_id='FLOOR' and t.recv_equipment_class_id <> '2' and t.wh_id='335'

select * from t_item_master where item_number = '1430388'
select * from t_cdn 
select * from t_cdfn 
