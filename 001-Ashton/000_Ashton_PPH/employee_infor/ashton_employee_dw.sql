-- employee information
select  e.wh_id, 
	e.emp_number,
	e.name as employee_name, 
	e.work_shift,
	e.supervisor_nbr, 
	e.supervisor as supervisor_name, 
	e.dept as department_id, 
	d.description as department_name, 
	e.group_nbr, 
	g.description as group_name, 
	g.schedule_id, 
	--s.schedule_name, 
	--s.threshold_allowed,
	--ea.la_send_data, ea.la_cico_required, ea.skip_PIV_check, 
	e.employee_id
from Distribution_Warehouse_Wholesale.t_employee as e
left join Distribution_Warehouse_Wholesale.Department as d on e.dept = d.department
left join Distribution_Warehouse_Wholesale.Group as g on e.group_nbr = g.group_nbr
--left join Distribution_Warehouse_Wholesale.t_la_schedule as s on g.schedule_id = s.schedule_id
--left join Distribution_Warehouse_Wholesale.t_employee_attribute as ea on e.emp_number = ea.id
where e.status = 'A'  and e.wh_id = '335'
order by e.emp_number