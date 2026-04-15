select top 10 * from t_employee
select top 10 * from t_tran_log 
select top 10 * from t_exception_log
select top 10 * from t_exception_tran_log
select top 10 * from t_control where description like '%cube%'




select * from t_tran_log where employee_id = '50544' and start_tran_date = '2026-01-27' order by start_tran_date, start_tran_time
select * from t_exception_tran_log where employee_id = '50544'  and exception_date = '2026-01-27' order by exception_date, exception_time