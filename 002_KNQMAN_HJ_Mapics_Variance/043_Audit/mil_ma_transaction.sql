/*
SELECT  *  FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME LIKE '%t_ma%'
SELECT TOP 100 *  FROM INFORMATION_SCHEMA.COLUMNS WHERE COLUMN_NAME LIKE '%WEB%'

*/

select top 1000 * from t_ma_tran_log where tran_type in ('608','609') and start_tran_date >= '2026-01-01' and item_number = '112898' order by start_tran_date desc,start_tran_time desc
select top 1000 * from t_ma_tran_log where tran_type in ('151') and start_tran_date >= '2026-01-01' and item_number = '112898' order by start_tran_date desc,start_tran_time desc