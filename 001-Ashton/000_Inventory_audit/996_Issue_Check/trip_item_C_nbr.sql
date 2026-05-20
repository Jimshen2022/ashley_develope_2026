
--select top 10 * from  t_order_detail_breakdown where order_number like '%30137%' and item_number  in ('B779-76','B779-92','B779-99')
--select top 10 * from  t_order_c_number 
--select top 10 * from  t_order
--select  * from  t_tran_log where tran_type in ('347','322','393') and control_number_2 like '%30137%' and item_number  in ('B779-76','B779-92','B779-99')
--t_pick_detail_audit


select top 10 * from  t_pick_detail_audit where order_number like '%30137%' 
select top 10 * from  t_pick_detail where order_number like '%30137%' 

select *
from t_tran_log as t
where t.tran_type in ('347','322','393','394') and t.control_number_2 like '%30137%' and t.item_number  in ('B779-76','B779-92','B779-99')
order by t.start_tran_date , t.start_tran_time 

select t.tran_type,
	   t.description,
	   t.start_tran_date,
	   t.start_tran_time,
	   t.employee_id,
	   t.control_number,
	   t.control_number_2,
	   t.wh_id,
	   t.location_id,
	   t.location_id_2,
	   t.item_number,
	   t.lot_number,
	   odb.c_number,
	   odb.ship_status
from t_tran_log as t 
join t_order_detail_breakdown as odb on t.control_number = odb.order_number and t.item_number = odb.item_number 
where t.tran_type in ('347','322','393','394') 
	and (t.control_number_2 like '%30137%' or t.control_number like '%30137%')
	and t.item_number  in ('B779-76','B779-92','B779-99')

