-- 855 and 161 check
select *
from t_tran_log 
where item_number = 'A8010323' and tran_type in ('161','855')  
order by start_tran_date, start_tran_time

select * from t_tran_log 
where item_number = 'A8010323' and lot_number = '620450074504' 
order by start_tran_date, start_tran_time

select * from t_tran_log 
where  lot_number = '647720427669' 
order by start_tran_date, start_tran_time
