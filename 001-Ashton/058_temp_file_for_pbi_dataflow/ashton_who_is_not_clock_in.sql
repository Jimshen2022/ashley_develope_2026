select 
    e.employee_id,
    e.emp_number,
    e.name as employee_name,
    e.status,
    e.work_shift,
    e.audit_required,
    e.supervisor as supervisor_name,
    s.supervisor_nbr,
    g.group_nbr,
    g.description as group_name,
    d.department as department_nbr,
    d.description as department_name,
    ea.la_send_data,
    ea.la_cico_required,
    -- t_la_employee_clock_in_out 字段
    t.cico_key,
    t.wh_id,
    t.home_wh_id,
    t.work_day,
    t.work_shift_id,
    t.clock_in,
    t.clock_out,
    t.actual_clock_in,
    t.actual_clock_out,
    t.supervisor_nbr as cico_supervisor_nbr,
    t.home_supervisor_nbr,
    t.group_nbr as cico_group_nbr,
    t.home_group_nbr,
    t.department as cico_department,
    t.home_department,
    t.company_nbr,
    t.facility_nbr,
    t.date_created,
    t.date_modified,
    t.modified_by,
    t.source,
    t.processing_status,
    t.processing_status_approver,
    t.processing_status_date,
    t.processing_transmit_date,
    t.is_scheduled
from t_employee as e
left join t_department as d on e.dept = d.department
left join t_group as g on e.group_nbr = g.group_nbr
left join t_supervisor as s on e.supervisor_nbr = s.supervisor_nbr
left join t_employee_attribute as ea on e.emp_number = ea.id
left join t_la_employee_clock_in_out as t on e.employee_id = t.employee_id
where e.status = 'A'
  and t.actual_clock_out is null
order by t.work_day, t.actual_clock_in;