select user_name,control_number as YA_SCANNER, count(log_id) as logged_in_times  
from t_ya_tran_log 
where control_number LIKE 'YAVT%' and tran_type = '100'  
group by  user_name,control_number
order by control_number