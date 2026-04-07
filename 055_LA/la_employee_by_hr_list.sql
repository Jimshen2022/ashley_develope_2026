/*
select top 100 * from t_employee WHERE id = '80054'
select  * from t_employee as e where status = 'A'
select top 100 * from t_department as e
select  * from t_shift as e
select top 10000 * from t_group as e
select top 100 * from t_la_schedule as e
select top 100 * from t_la_break order by schedule_id
select top 100 * from t_employee_attribute WHERE id = '80054'
select top 10000 * from t_user_detail
*/





-- employee information -- NS -- April 1st, 2026
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
where e.status = 'A' and e.id IN (
    '00018','00129','00457','00640','00967','00974','01052','50043','50154','50180','50268','50269','50273','50279','50301','50338','50363','50385','50402','50416','50425','50460','50526','50539','50547','50555','50558','50560','50564','50572','50581','50597','50634','50635','50637','50659','50668','50679','50779','50807','50820','50835','50836','50857','50869','50870','50885','50890','50912','50917','50919','50927','50944','50957','50960','50962','50963','50964','50970','50979','50980','50998'
)
order by e.emp_number





-- employee information -- DS
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
where e.status = 'A' and e.id IN ('00179','00293','00396','00782','00891','00994','01007','01024','01036','01047','01061','50023','50044','50141','50233','50267','50290','50295','50296','50327','50368','50399','50437','50483','50497','50502','50506','50521','50561','50568','50576','50584','50600','50601','50615','50616','50618','50624','50647','50648','50667','50688','50694','50699','50702','50714','50736','50739','50808','50847','50863','50864','50878','50893','50902','50930','50939','50941','50953','50961','50968','50969','50971','50973','50978','50984','50985','50986','50987','50988','50989','50994','50995','50997','50999','51000','51001','51003','51004','51007','51008','51009','51010','51011','51012','51014')
order by e.emp_number



-- Employee details by supervisor (status = 'A')
select 
	sup.supervisor_nbr,
	sup.emp_first_name + ' ' + sup.emp_last_name as supervisor_name,
	e.emp_number,
	e.name as employee_name,
	e.work_shift,
	e.dept as department_id,
	d.description as department_name,
	e.group_nbr,
	g.description as group_name,
	e.employee_id,
	e.wh_id
from t_supervisor as sup
inner join t_employee as e on sup.supervisor_nbr = e.supervisor_nbr and e.status = 'A'
left join t_department as d on e.dept = d.department
left join t_group as g on e.group_nbr = g.group_nbr
order by sup.supervisor_nbr, e.emp_number


-- updated this employee 50885 supervisor as 179	PHAM VAN TOI in HJ
select * from t_employee where name like '%NGO HAI BAC%' 



-- employee information -- NS -- April 1st, 2026
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
where e.status = 'A' and e.id IN ('50290')
order by e.emp_number

