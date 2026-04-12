/*
SELECT  *  FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME LIKE '%xdock%'
SELECT  *  FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME LIKE 't_import%'
SELECT  table_name  FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME LIKE '%dispatch%' group by table_name
SELECT  *  FROM INFORMATION_SCHEMA.COLUMNS WHERE COLUMNS LIKE '%CROSS%'
select * from t_la_employee_clock_in_out_detail
select * from t_sod_eod_cico_log
select * from t_la_team_cico
select * from t_la_employee_clock_in_out
select * from INC0644370_t_la_employee_clock_in_out_bkp

SELECT  *  FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME LIKE '%t_%' and column_name like '%meter%'
SELECT  *  FROM INFORMATION_SCHEMA.COLUMNS WHERE COLUMN_NAME LIKE 'description'
SELECT  *  FROM INFORMATION_SCHEMA.COLUMNS WHERE COLUMN_NAME LIKE '%excel%'
SELECT  *  FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME LIKE '%xdock%'
SELECT  *  FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME LIKE '%import%'
*/

select top 10 * from t_import_XML
select top 10 * from t_import_error_logs
select top 10 * from v_xml_import_queue

-- location creation dynamic
select top 10 * from t_eil_xml_msg
select top 10 * from t_rei_master
select * from t_location where wh_id = '36'
