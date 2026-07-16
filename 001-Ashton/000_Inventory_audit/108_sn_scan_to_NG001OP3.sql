-- Scan to NG001OP3 check

select * 
from t_tran_log 
where (location_id_2 = 'NG001OP3' and (control_number_2 != 'NG001OP3' or location_id != 'NG001OP3') and item_number !='RP ORDER') and employee_id not in('00129','22888','50044','33999')  
order by employee_id, start_tran_date desc, start_tran_time desc

select * from t_employee where emp_number in ('50044','33999','50863')
select * from t_employee where emp_number in ('50863','50290') order by emp_number