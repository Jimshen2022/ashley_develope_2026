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
SELECT  *  FROM INFORMATION_SCHEMA.COLUMNS WHERE COLUMN_NAME LIKE '%zone$name%'
SELECT  *  FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME LIKE '%xdock%'
SELECT  *  FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME LIKE '%import%'
SELECT  *  FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME LIKE '%zone%'
*/

-- menu
select * from t_process_department
select top 10 * from t_current_menu_option
select top 10 * from t_menu
select * from t_menu
select top 10 * from t_menu_pick_method
select top 10 * from t_ya_zone_loca



select  * from t_ww_release_orders
select  * from t_items_on_hold_released
select  * from t_order where wh_id = '35'
select  * from t_auto_release_setup where wh_id = '35'
select  * from t_order_release_queue where wh_id = '35'
select  * from t_order where wh_id = '36'
select top 10 * from t_order_c_number where wh_id = '35'
select top 10 * from t_order_detail where wh_id = '36'
select top 10 * from t_order_detail_breakdown where wh_id = '35'

select top 10 * from t_order_c_number where wh_id = '35'
select top 10 * from t_order_detail_hotload where wh_id = '36'
select top 10 * from t_order_detail_audit
select top 10 * from t_order_detail_breakdown_audit
select top 10 * from t_import_XML
select top 10 * from t_import_error_logs
select top 10 * from v_xml_import_queue
select top 10 * from t_import_WAORDER

-- location creation dynamic
select top 10 * from t_eil_xml_msg
select top 10 * from t_rei_master
select * from t_location where wh_id = '36'
