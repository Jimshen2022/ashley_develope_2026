-- sn data error check
select * from t_tran_log where lot_number IN ('630570024329') order by item_number, lot_number, start_tran_date desc, start_tran_time desc
select * from t_serial_active where serial_number in ('630570024329')
select * from t_serial_master where serial_number in ('630570024329')


