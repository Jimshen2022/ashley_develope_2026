SELECT TOP 1000 *  FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME LIKE '%work%'
SELECT TOP 10 *  FROM t_hu_detail 
SELECT TOP 10 *  FROM t_hu_master where location_id = 'D022'
SELECT TOP 1000 *  FROM t_employee where reader is not null


select top 10 * from  t_work_q where work_q_id = '01799488'
select * from  t_work_q where work_type = '08'
select * from  t_work_q where work_type = '09'

select * from  t_tran_log where item_number = 'A2000722' and start_tran_date = '2026-01-06' order by start_tran_date desc, start_tran_time desc 
select * from  t_tran_log where location_id = 'A3013CT3' order by start_tran_date desc, start_tran_time desc 

select  * from  where work_type = '50' and location_id = 'D022' and pick_ref_number ='MCCU3077172'
select top 10 * from t_work_q where work_type = '50' and location_id = 'D022' and work_q_id ='416776417'
select  * from t_work_q where work_type = '50' and location_id = 'D022' and pick_ref_number ='MCCU3077172'

select top 10 * from t_ya_work_q
select top 10 * from t_stored_item



select top 10 * from t_work_q where item_number = 'L207624' ORDER BY date_due, time_due 
select  * from t_work_q where item_number = 'D396-223'  AND work_type = '' ORDER BY date_due, time_due 
select top 10 * from t_work_q where work_q_id = '01761742' ORDER BY date_due, time_due 


select tran_type, description, item_number, start_tran_date,  control_number_2, location_id, location_id_2, sum(tran_qty) as qty, MIN(start_tran_time) as min_time, MAX(start_tran_time) as max_time
from t_tran_log 
where item_number = 'D396-223' 
	and start_tran_date >='2025-12-09'
	and tran_type in ('252','202')
group by tran_type, description, item_number, start_tran_date,  control_number_2,location_id, location_id_2
ORDER BY start_tran_date, MIN(start_tran_time) 


select *
from t_tran_log 
where item_number = 'L207624' 
	and start_tran_date >='2025-12-10'	
	and tran_type like '363'
	and control_number_2 like '0057267%'
ORDER BY start_tran_date, start_tran_time DESC


-- work q check
select top 10 * from t_work_q 
select  * from t_work_q where work_type = '07' and work_status != 'C'



select * from t_work_q where work_q_id in ('416608838', '416667379', '416702246', '416709311', '416713832', '416723196', '416726027', '416726762', '416727853', '416727569', '416728135', '416728153', '416728163', '416728963', '416729067', '416729680', '416729747')
select * from t_work_q where work_q_id in ('416738638')



select * from t_class_loca where location_id = 'A3025DA1'
select top 10  * from t_item_uom where item_number = 'B647-97W1'

select  item_number, equipment_class_id,class_id from t_item_uom where class_id = 'FLOOR' and equipment_class_id <> '5' GROUP BY item_number, equipment_class_id,

select top 10 * from t_item_master where item_number = 'B647-97W1' 

select t.*, si.* 
from t_work_q as t
join t_stored_item as si
 on t.item_number = si.item_number
where work_q_id = '416608838'

-- order detail breakdown
select top 10 * from t_order_detail as t where t.item_number = 'B647-97W1'
select top 10 * from t_order_detail_breakdown as t

select t.*, t1.*
from t_order_detail as t
join t_order_detail_breakdown as t1
 on t.order_number = t1.order_number and t.item_number = t1.item_number
where t.item_number = 'B647-97W1'

select top 50 *
from t_tran_log 
where 1=1
	and item_number = 'B947-56' 
	and location_id_2 = 'A3011KG5'

order by start_tran_date, start_tran_time desc


