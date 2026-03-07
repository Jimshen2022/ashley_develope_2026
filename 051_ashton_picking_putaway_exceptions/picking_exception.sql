with emp as (
	select t.id, t.name,t.emp_number, t.dept, t.supervisor, t1.description, t1.department_code
	from t_employee as t
	left join t_department as t1 on t.dept = t1.department_code
),
trx as (
	select t.tran_type,  t.description, cast(t.start_tran_date+ t.start_tran_time as datetime) as transaction_datetime, t.employee_id, t.item_number, t.lot_number, t.tran_qty, t.location_id as source_location, t.location_id_2 as destination_location, t.outside_id, t.process, t.equipment_zone,
	case
		when t.outside_id = '201' and t.location_id like 'S%' then 'sn in small stage but be moving scan from other location'
		when t.outside_id = '201' and t.location_id not like 'S%' then 'sn in location A but be moving scan from location B'
		when t.outside_id = '202'  then 'sn in location A but be moving scan on fork'
		when t.outside_id = '251'  then 'sn in location A but replenish moving scan from location B'
		when t.outside_id = '253'  then 'sn in location A but direct pickup moving scan from location B'
		when t.outside_id = '303' and t.location_id like 'S%' then 'sn in small stage then be picking scan from other location again'
		when t.outside_id = '303' and t.location_id not like 'S%' then 'sn in location A but be picking scan from location B'
		when t.outside_id = '304' and t.location_id like 'S%'  then 'sn in small stage then be picking scan on fork'
		when t.outside_id = '304' and t.location_id not like 'S%'  then 'sn without picking then be picking scan on fork'
		when t.outside_id = '321'  then 'sn without picking but be loading scan'
		when t.outside_id = '800'  then 'cycle count correction'
		else 'check' end as exception_reason
	from t_tran_log as t
	where tran_type in ('840') and start_tran_date >= '2026-01-01'
)
select t.*, e.emp_number, e.name, e.dept, e.supervisor,e.description,
case 
	when t.exception_reason like 'sn in small stage but be moving scan from other location%' then 'Major'
	when t.exception_reason like 'sn in location A but be moving scan from location B%' then 'Acceptable'
	when t.exception_reason like 'sn in location A but be moving scan on fork%' then 'Acceptable'
	when t.exception_reason like 'sn in location A but replenish moving scan from location B%' then 'Acceptable'
	when t.exception_reason like 'sn in location A but direct pickup moving scan from location B%' then 'Acceptable'
	when t.exception_reason like 'sn in small stage but be picking scan from other location again%' then 'Major'
	when t.exception_reason like 'sn in location A but be picking scan from location B%' then 'Acceptable'
	when t.exception_reason like 'sn in small stage but be picking scan on fork%' then 'Major'
	when t.exception_reason like 'sn without picking then be picking scan on fork%' then 'Major'
	when t.exception_reason like 'sn without picking but be loading scan%' then 'Major'
	when t.exception_reason like 'cycle count correction %' then 'Acceptable'
	else 'Others' end as exception_severity
from trx as t
left join emp as e on t.employee_id = e.id