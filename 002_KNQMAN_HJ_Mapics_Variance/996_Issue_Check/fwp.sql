SELECT TOP 1000 *  FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME LIKE '%fwd%'
SELECT TOP 1000 *  FROM INFORMATION_SCHEMA.COLUMNS WHERE COLUMN_NAME LIKE '%sscc%'
SELECT TOP 1000 *  FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME LIKE '%import%'


select * from t_fwd_pick where location_id not in ('A1001AA1','A1001AA9')

select top 100 * from t_pick_detail where item_number like '2940203%'

select top 100 * from t_pick_run_detail 
select top 100 * from t_pick_detail_temp 
select top 100 * from v_planned_pick_qty_work_type 
select top 100 * from t_pick_detail_audit where item_number like '2940203%'
select top 100 * from  t_old_fwd_pick
select top 100 * from  t_new_fwd_pick

--sscc
select top 100 * from  tmp_AS400_loaded where trip_number like '%39556%'
select top 100 * from  t_order_detail_breakdown where order_number like '%39556%'


t_order_detail_breakdown
t_wa_tran_345_log
t_track_serial_sto
t_tb_ship_status
t_ship_request
t_ship_request_interface_log
tmp_AS400_loaded
t_serial_active_audit
t_serial_active
v_xml_ship_request_interface_log

