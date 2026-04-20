select top 1000 *  from t_exception_tran_log  where exception_date > '2025-11-02' and item_number = '1850743'
select * from t_serial_active  as t where t.item_number = '1850743'	and t.serial_no_status not in ('S','O') order by t.received_date desc
select * from t_item_master where item_number = '1850743'
select top 10 *  from t_item_master 
select top 1000 *  from t_location where location_id like 'A3%'

select *  from t_class_loca where location_id like 'A3025%1' and substring(location_id,6,1) in  ('C','E')  



select t.item_number,
	im.class_id,
	count(t.serial_number) as qty
from t_serial_active  as t
inner join t_item_master im
	on t.item_number = im.item_number
where 1=1 
	--AND t.item_number = 'R405451'
	and t.serial_no_status not in ('S','O')
	and im.pick_put_id in ('UPH')
group by t.item_number,im.class_id
having count(t.serial_number) >0

select *
from t_tran_log
where item_number = '1850743'
	and start_tran_date between '2025-10-25' and '2025-11-03'
	and tran_type = '347'
group by item_number,
start_tran_date,
	control_number,
	control_number_2



select *
from t_serial_active  as t
where t.item_number = '2940202'
	and t.serial_no_status not in ('S','O')


select item_number,
    start_tran_date,
	control_number,
	control_number_2,
	sum(tran_qty) as tran_qty
from t_tran_log
where item_number = 'B615-31'
	and start_tran_date between '2025-10-25' and '2025-11-03'
	and tran_type = '347'
group by item_number,
start_tran_date,
	control_number,
	control_number_2



select item_number,
    start_tran_date,
	control_number,
	control_number_2,
	sum(tran_qty) as tran_qty
from t_tran_log
where item_number = 'B615-46'
	and start_tran_date between '2025-10-25' and '2025-11-03'
	and tran_type = '347'
group by item_number,
start_tran_date,
	control_number,
	control_number_2



select item_number,
    start_tran_date,
	control_number,
	control_number_2,
	sum(tran_qty) as tran_qty
from t_tran_log
where item_number = 'B615-81'
	and start_tran_date between '2025-10-25' and '2025-11-03'
	and tran_type = '347'
group by item_number,
start_tran_date,
	control_number,
	control_number_2



select item_number,
    start_tran_date,
	control_number,
	control_number_2,
	sum(tran_qty) as tran_qty
from t_tran_log
where item_number = 'B615-92'
	and start_tran_date between '2025-10-25' and '2025-11-03'
	and tran_type = '347'
group by item_number,
start_tran_date,
	control_number,
	control_number_2




select item_number,
    start_tran_date,
	control_number,
	control_number_2,
	sum(tran_qty) as tran_qty
from t_tran_log
where item_number = 'B615-97'
	and start_tran_date between '2025-10-25' and '2025-11-03'
	and tran_type = '347'
group by item_number,
start_tran_date,
	control_number,
	control_number_2



	