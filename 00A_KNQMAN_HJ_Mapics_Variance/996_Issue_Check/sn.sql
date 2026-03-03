select top 1000 * from t_tran_log where lot_number = '503952016693' order by start_tran_date, start_tran_time 
select top 100 * from t_tran_log where item_number = 'A8010438 ' and tran_type in ('165','855') order by start_tran_date, start_tran_time desc 

