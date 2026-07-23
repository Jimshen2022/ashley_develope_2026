-- employee department supervisor
select  
     e.employee_id,
     e.emp_number,
     e.name as employee_name, 
     e.status,
     e.work_shift,
     e.audit_required,
     s.supervisor_nbr,
     e.supervisor as supervisor_name,
     g.group_nbr,
     g.description as group_name,
     t.department as department_nbr,
     t.description as department_name
from t_employee as e 
left join t_department as t on e.dept = t.department
left join t_group as g on e.group_nbr = g.group_nbr
left join t_supervisor as s on e.supervisor_nbr = s.supervisor_nbr
where  e.status = 'A'