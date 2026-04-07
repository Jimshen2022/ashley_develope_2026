-- who is clocked in report
select e.emp_number, e.name as employee_name, s.name as supervisor_name, t.*,
	ea.la_send_data, ea.la_cico_required
from t_la_employee_clock_in_out as t
left join t_employee as e on t.employee_id = e.employee_id
left join t_employee as s on t.supervisor_nbr = s.emp_number
left join t_employee_attribute as ea on e.emp_number = ea.id
where actual_clock_out is null 
order by t.work_day,t.actual_clock_in


-- who is clocked check by employee
select e.emp_number, e.name as employee_name, s.name as supervisor_name, t.*,
	ea.la_send_data, ea.la_cico_required
from t_la_employee_clock_in_out as t
left join t_employee as e on t.employee_id = e.employee_id
left join t_employee as s on t.supervisor_nbr = s.emp_number
left join t_employee_attribute as ea on e.emp_number = ea.id
where e.emp_number in ('50290')
order by t.work_day,t.actual_clock_in




--- last 7 days clock in record history
select e.emp_number, e.name as employee_name, s.name as supervisor_name, t.*,
	ea.la_send_data, ea.la_cico_required
from t_la_employee_clock_in_out as t
left join t_employee as e on t.employee_id = e.employee_id
left join t_employee as s on t.supervisor_nbr = s.emp_number
left join t_employee_attribute as ea on e.emp_number = ea.id
where actual_clock_in >= DATEADD(DAY, -6, CAST(CAST(GETDATE() AS DATE) AS DATETIME))
--and t.employee_id='1001817' 
--and cico_key = '174200'
order by t.work_day,t.actual_clock_in

-- udpate employee shift
update t_employee
set work_shift = 'D' 
where employee_id = '1000979'


-- 更新打卡表 CLOCK OUTOUTOUTOUTOUTOUTOUTOUTOUTOUTOUTOUTOUTOUT
update t_la_employee_clock_in_out   
-- day shift
set actual_clock_out=DATEDIFF(d,0,clock_in)+19E0/24,clock_out=DATEDIFF(d,0,clock_in)+19E0/24
-- night shift
set actual_clock_out=DATEDIFF(d,0,clock_in)+31E0/24,clock_out=DATEDIFF(d,0,clock_in)+31E0/24
WHERE employee_id='1000979' AND work_day='2026-03-20' AND clock_out IS NULL


-- 更新打卡表 CLOCK ININININININININININININININININININININ
update t_la_employee_clock_in_out 
set actual_clock_in= '2026-03-30 20:00:00:000', clock_in =  '2026-03-30 20:00:00:000'
WHERE employee_id='1001799' AND cico_key='1000008798' 

-- delete record from clock in out table
delete t_la_employee_clock_in_out
WHERE employee_id='1002510' AND cico_key in ('1000008815' ,'1000008799','1000008785')

select top 10 * from t_la_process_report



-- employee tran log
SELECT 
    start_tran_date,
    DATEPART(HOUR, start_tran_time) AS hours,
    tran_type, 
    description,
    SUM(tran_qty) AS tran_qty,
    employee_id
FROM t_tran_log  
WHERE employee_id IN ('50960') 
  AND start_tran_date >= DATEADD(DAY, -6, CAST(GETDATE() AS DATE))
GROUP BY 
    start_tran_date,
    DATEPART(HOUR, start_tran_time),
    tran_type,
    description,
    employee_id
ORDER BY 
    start_tran_date DESC,
    hours,
    tran_type
  









-- employee number 80054
select e.emp_number,t.*
from t_la_employee_clock_in_out as t
left join t_employee as e on t.employee_id = e.employee_id
where e.emp_number = '80054' and  work_day <= CAST(GETDATE() AS DATE)
order by t.work_day,t.clock_in

select *
from t_employee as e
where e.emp_number = '80054'

select * from t_la_employee_clock_in_out as t  where t.employee_id = '1000979'
select * from t_la_employee_clock_in_out_detail as t where t.employee_id = '1000979'