/*
select top 100 * from t_employee as e
select  * from t_employee as e where status = 'A'
select top 100 * from t_department as e
select  * from t_shift as e
select top 10000 * from t_group as e
select top 100 * from t_la_schedule as e
select top 100 * from t_employee_attribute
select top 10000 * from t_user_detail
*/




-- employee information
select  e.wh_id, e.emp_number,e.name as employee_name, e.work_shift,
	e.supervisor_nbr, 
	e.supervisor as supervisor_name, 
	e.dept as department_id, 
	d.description as department_name, 
	e.group_nbr, g.description as group_name, 
	g.schedule_id, s.schedule_name, s.threshold_allowed,
	ea.la_send_data, ea.la_cico_required, ea.skip_PIV_check, e.employee_id
from t_employee as e
left join t_department as d on e.dept = d.department
left join t_group as g on e.group_nbr = g.group_nbr
left join t_la_schedule as s on g.schedule_id = s.schedule_id
left join t_employee_attribute as ea on e.emp_number = ea.id
where e.status = 'A' and e.emp_number in ('50885','50807')
order by e.emp_number