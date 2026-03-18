with emp as (
	select t.id, t.name,t.emp_number, t.dept, t.supervisor, t1.description, t1.department_code
	from t_employee as t
	left join t_department as t1 on t.dept = t1.department_code
),
trx as (
	select t.tran_type,  t.description, cast(t.start_tran_date+ t.start_tran_time as datetime) as transaction_datetime, t.employee_id, t.item_number, t.lot_number, t.tran_qty, t.location_id as source_location, t.location_id_2 as destination_location, t.outside_id, t.process, t.equipment_zone,
	case
	    when t.outside_id = '171' then 'customer returned scan'
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
		when t.outside_id = '394'  then 'sn be unloaded scan twice'
		when t.outside_id = '800'  then 'cycle count correction'
		else 'check' end as exception_reason,
	case
		when t.outside_id = '171'  then 't.outside_id = ''171'''
		when t.outside_id = '201' and t.location_id like 'S%' then 'outside_id = ''201'' and location_id like ''S%'''
		when t.outside_id = '201' and t.location_id not like 'S%' then 'outside_id = ''201'' and location_id not like ''S%'''
		when t.outside_id = '202'  then 'outside_id = ''202'''
		when t.outside_id = '251'  then 'outside_id = ''251'''
		when t.outside_id = '253'  then 'outside_id = ''253'''
		when t.outside_id = '303' and t.location_id like 'S%' then 'outside_id = ''303'' and location_id like ''S%'''
		when t.outside_id = '303' and t.location_id not like 'S%' then 'outside_id = ''303'' and location_id not like ''S%'''
		when t.outside_id = '304' and t.location_id like 'S%'  then 'outside_id = ''304'' and location_id like ''S%'''
		when t.outside_id = '304' and t.location_id not like 'S%'  then 'outside_id = ''304'' and location_id not like ''S%'''
		when t.outside_id = '321'  then 'outside_id = ''321'''
		when t.outside_id = '394'  then 'outside_id = ''394'''
		when t.outside_id = '800'  then 'outside_id = ''800'''
		else 'No matching rule' end as [rule]
	from t_tran_log as t
	where tran_type in ('840') and start_tran_date >= '2026-01-01'
)
select t.*,
       -- 处理 shift_date：如果是 0:00 ~ 7:00，则减去 1 天
    CASE
        WHEN CAST(t.transaction_datetime AS TIME) < '07:00:00'
        THEN CAST(DATEADD(DAY, -1, t.transaction_datetime) AS DATE)
        ELSE CAST(t.transaction_datetime AS DATE)
    END AS shift_date,
    -- 处理 shift：7:00 ~ 19:00 为 D，其余为 N
    CASE
        WHEN CAST(t.transaction_datetime AS TIME) >= '07:00:00'
             AND CAST(t.transaction_datetime AS TIME) < '19:00:00'
        THEN 'D'
        ELSE 'N'
    END AS shift,
       e.emp_number, e.name, e.dept, e.supervisor,e.description as department,
case 
	when t.exception_reason like 'sn in small stage but be moving scan from other location%' then 'Major'
	when t.exception_reason like 'sn in location A but be moving scan from location B%' then 'Acceptable'
	when t.exception_reason like 'sn in location A but be moving scan on fork%' then 'Acceptable'
	when t.exception_reason like 'sn in location A but replenish moving scan from location B%' then 'Acceptable'
	when t.exception_reason like 'sn in location A but direct pickup moving scan from location B%' then 'Acceptable'
	when t.exception_reason like 'sn in small stage then be picking scan from other location again%' then 'Major'
	when t.exception_reason like 'sn in location A but be picking scan from location B%' then 'Acceptable'
	when t.exception_reason like 'sn in small stage then be picking scan on fork%' then 'Major'
	when t.exception_reason like 'sn without picking then be picking scan on fork%' then 'Major'
	when t.exception_reason like 'sn without picking but be loading scan%' then 'Major'
	when t.exception_reason like 'cycle count correction%' then 'Acceptable'
	when t.exception_reason like 'sn be unloaded scan twice%' then 'Acceptable'
	when t.exception_reason like 'customer returned scan%' then 'Acceptable'
	else 'Others' end as exception_severity
from trx as t
left join emp as e on t.employee_id = e.id
  
  