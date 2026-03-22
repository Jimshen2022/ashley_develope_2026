-- who is clocked in 
select e.emp_number, e.name as employee_name, s.name as supervisor_name, t.*
from t_la_employee_clock_in_out as t
left join t_employee as e on t.employee_id = e.employee_id
left join t_employee as s on t.supervisor_nbr = s.emp_number
where actual_clock_out is null 
--and actual_clock_in < DATEADD(HOUR, 6, CAST(CAST(GETDATE() AS DATE) AS DATETIME))
--and work_day <= CAST(GETDATE() AS DATE)
order by t.work_day,t.actual_clock_in

-- 更新打卡表中，某个员工的打卡记录，补全缺失的打卡时间
update t_la_employee_clock_in_out 

set clock_out=dateadd(hh,10,clock_in),actual_clock_out=dateadd(hh,10,actual_clock_in) 
-- day shift
set actual_clock_out=DATEDIFF(d,0,clock_in)+19E0/24,clock_out=DATEDIFF(d,0,clock_in)+19E0/24
-- night shift
set actual_clock_out=DATEDIFF(d,0,clock_in)+31E0/24,clock_out=DATEDIFF(d,0,clock_in)+31E0/24
--set clock_out=DATEADD(HOUR,19,DATEDIFF(DAY,0,actual_clock_in)),actual_clock_out=DATEADD(HOUR,19,DATEDIFF(DAY,0,actual_clock_in))
--set clock_out=DATEADD(hh,19,DATEDIFF(d,0,actual_clock_in)),actual_clock_out=DATEADD(hh,19,DATEDIFF(d,0,actual_clock_in))
where  employee_id='1001997' and work_day= '2026-01-28 00:00:00.000' and clock_out is null





select e.emp_number,t.*
from t_la_employee_clock_in_out as t
left join t_employee as e on t.employee_id = e.employee_id
where t.employee_id = '1002106' and  work_day <= CAST(GETDATE() AS DATE)
order by t.work_day,t.clock_in


select * from t_la_employee_clock_in_out as t  where t.employee_id = '1000979'
select * from t_la_employee_clock_in_out_detail as t where t.employee_id = '1000979'