/*
SELECT  *  FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME LIKE '%battery%'
SELECT  *  FROM INFORMATION_SCHEMA.COLUMNS WHERE COLUMN_NAME LIKE '%work_shift%'
select * from t_la_employee_clock_in_out_detail
select * from t_sod_eod_cico_log
select * from t_la_team_cico
select * from t_la_employee_clock_in_out
select * from INC0644370_t_la_employee_clock_in_out_bkp


*/



select  * from t_items_on_hold
select top 10 * from t_lms_process_time

-- Yard and transportation related tables
select top 1000 * from t_ya_tran_log where started > '2026-03-01' order by started 
select top 10 * from t_ya_zone 
select top 10 * from t_ya_location 
select top 10 * from t_ya_class_loca 
select top 10 * from t_ya_work_q 
select top 10 * from t_ya_tran 
select top 10 * from t_ya_class 
select top 10 * from t_ya_move_priority 
select top 10 * from t_ya_tractor_type_location 
select top 10 * from t_yard_checkin_details
select top 10 * from t_ya_message
select top 10 * from t_yard_health_report
select top 10 * from t_ya_exception_log
select top 10 * from t_ya_equipment_attributes
select top 10 * from t_import_yard_checkin
select top 10 * from t_import_yard_checkout
select top 10 * from t_ya_equipment_check_log
select top 10 * from t_ya_tran_types
select top 10 * from t_ya_equipment_class_loca
select top 10 * from t_ya_OSHA_attributes
select top 10 * from t_ya_replenishment
select top 10 * from t_ya_spotter_loc
select top 10 * from t_control WHERE control_type LIKE '%SEND_YA101_AT_CHKIN%'
select top 10 * From t_serial_active where hu_id is not null
SELECT top 10 * FROM t_item_plate_section 
SELECT top 10 * FROM t_la_employee_clock_in_out 
SELECT TOP 10 * FROM t_order_detail_breakdown where item_number = '6700616'

SELECT TOP 10 * FROM t_order_detail_breakdown
SELECT TOP 10 * FROM t_import_ITEM where transaction_string like '%9810538%'
SELECT top 10 * FROM t_import_ASN where transaction_string like '5478704%'
SELECT TOP 10 * FROM t_item_master  where item_number like '9810538%'
SELECT TOP 10 * FROM t_item_uom
select top 10 * from t_asn_detail where customer_po_number = 'P2RCX31' and item_number = '5020617'
SELECT top 10 * FROM t_import_WAORDER where transaction_string like '%9810538%'
SELECT top 10 * FROM t_import_xml_msg order by date_received desc
SELECT top 10 * FROM t_import_ITMBOM
SELECT top 10 * FROM t_replenishment_rule
SELECT top 10 * FROM t_asn_snapshot
SELECT top 10 * FROM t_work_q_assignment
SELECT top 10 * FROM t_xdock_rule
SELECT top 10 * FROM t_control where control_type like 'SEND_YA101%'
SELECT top 10 * FROM t_inventory_position where planned_picks > 0
SELECT top 10 * FROM t_log_message_monitor
SELECT top 10 * FROM dbo.t_scr_mstr
SELECT top 10 * FROM dbo.t_page_header  
SELECT top 10 * FROM dbo.ea_t_transportconfig  
SELECT top 10 * FROM t_order_detail_breakdown  where item_number ='100-17'
select top 10 * from t_pick_detail where item_number ='100-17'
SELECT TOP 10 * FROM t_hu_detail where hu_id = '2559826'
SELECT TOP 10 * FROM t_hu_master 
SELECT TOP 10 * FROM t_log_message_monitor 
SELECT TOP 10 * FROM t_class_loca 
SELECT TOP 10 * FROM t_item_master 
SELECT TOP 10 * FROM t_item_uom
SELECT TOP 10 * FROM t_hu_detail 
SELECT TOP 10 * FROM t_work_q 
SELECT TOP 10 * FROM t_location 
SELECT TOP 10 * FROM t_prod_receipt_upholstery where serial_number = '503952146657'
SELECT TOP 10 * FROM t_prod_receipt_upholstery where serial_number = '503952149606'
SELECT TOP 10 * FROM t_ya_tran_log
SELECT TOP 10 * FROM t_trailer
SELECT TOP 10 * FROM t_trailer_type
SELECT TOP 10 * FROM t_trailer_master
SELECT TOP 10 * FROM t_equipment_check_log
SELECT TOP 10 * FROM t_equipment_attributes  -- last_check_meter
SELECT TOP 10 * FROM t_equipment_unload_proirity
SELECT TOP 10 * FROM t_import_ONHOLD
SELECT TOP 10 * FROM t_dynamic_survey_result.scanner_employee_id
select top 10 * from t_stored_item as t
select top 10 * from t_serial_active as t
select top 10 * from t_pick_detail as t
select top 10 * from t_fwd_priority	as t
select top 10 * from t_item_master_log_details
SELECT TOP 10 * FROM t_location
SELECT TOP 10 * FROM t_ma_tran_log
select top 10 * from t_serial_active as t
select top 10 * from t_user as t
select top 10 * from t_serial_active as t
select top 10 * from t_stored_item as t
select top 10 * from t_ya_tran
select top 10 * from t_ma_tran_log
select top 10 * from t_tran_log
select top 10 * from t_user as t
select top 10 * from t_pick_detail
select top 10 * from t_asn
select top 10 * from t_asn_detail
select top 100 * from t_trailer_asn
select top 100 * from t_trailer
select top 100 * from t_ya_location
select top 100 * from t_item_master
SELECT TOP 10 * FROM t_load_master ldm (nolock)
SELECT TOP 10 * FROM t_order orm (nolock)
SELECT TOP 10 * FROM t_order_detail_breakdown orb (nolock)
SELECT TOP 10 * FROM t_load_dispatch ldd
select top 10 * from t_stored_item
select top 10 * from t_location
select top 10 * from t_loc_pallet_capacity where location_id = 'A3018CY1'
select top 10 * from t_class_loca where location_id like 'A3011D%'
select top 10 * from t_class
select top 10 * from t_load_dispatch 
select top 10 * from t_hu_detail_shipped
select top 10 * from t_hu_master_shipped
select top 10 * from t_pick_run 
select top 10 * from t_order 
select top 10 * from t_tb_order
select top 10 * from t_order where order_number like '%80527%'
select top 10 * from t_order_detail  where order_number like '%80527%'
select top 10 * from t_order_detail_breakdown  where order_number like '%80527%'
select top 10 * from t_order_detail
select top 10 * from t_order_c_number 
select top 10 * from t_hu_master
select top 10 * from t_hu_detail
select top 10 * from t_container
select top 10 * from t_serial_loaded
select top 10 * from t_customer_large_orders
select top 10 * from t_customer 
select top 10 * from t_order_detail_breakdown  where order_number like '%80527%'
SELECT top 10 * FROM t_class_loca 
select top 10 * from t_asn
select top 10 * from t_asn_detail 
select top 10 * from t_exception_log
select top 10 * from t_exception_tran_log
select top 10 * from t_tran_log 
select top 10 * from t_item_master 
select top 10 * from t_item_comment
select top 10 * from t_item_uom 
select top 10 * from t_item_fifo_window 
select top 10 * from t_item_forecast_daily 
select top 10 * from t_item_forecast 
select top 10 * from t_item_attributes 
select top 10 * from t_items_on_hold 
select top 10 * from t_item_plate_section 
select top 10 * from t_slot_item_velocity 
select top 10 * from dt_item_uom_duplicates 
select top 10 * from t_item_planning 
select top 10 * from t_import_ASN where pick_put_id = 'SCOOP' and item_number = 'A1000540' 
select top 10 * from t_item_uom where pick_put_id = 'SCOOP' and item_number = 'A1000540' 
select top 10 * from t_fwd_pick where  item_number = 'A1000540' 
select top 10 * from t_exception_tran_log where tran_type ='LPHR'  order by exception_date desc
select top 10 * from t_hu_master where status = 'H'
select top 10 * from t_import_DISPATCH
select top 10 * from t_import_CDN
select top 10 * from t_import_SERIAL
select top 10 * from t_order_detail
select top 10 * from t_order_detail_breakdown
select top 10 * from t_order_detail where order_number like '%68433%'
select top 10 * from t_order_detail_breakdown where order_number like '%68433%'
select top 10 * from t_employee
select top 10 * from t_department
select top 10 * from t_exception_log where tran_type like '855%' and exception_date > '2026-01-01' order by exception_date desc
select top 10 * from t_exception_log 
select top 10 * from t_exception_tran_log
select  * from t_import_ONHOLD where imported >= '2026-03-19'


--battery table
select * from t_battery

-- cico
select * from t_la_schedule where active = 'Y'

-- item master
select top 10 * from t_item_master where item_number = '6700616'
select top 10 * from t_item_uom where item_number = '6700616'
select top 10 * from t_import_ITEM where transaction_string like '%6700616%'
select top 10 * from t_import_ITMBOM
SELECT TOP 10 unit_volume, * FROM t_order_detail_breakdown where item_number = '6700616'

-- trx
SELECT * FROM t_tran_log where item_number = '1080229' AND start_tran_date > '2026-03-17'  order by start_tran_date desc, start_tran_time desc
SELECT * FROM t_tran_log where item_number = '2590316' AND start_tran_date > '2026-03-18'  order by start_tran_date desc, start_tran_time desc
SELECT * FROM t_serial_active where item_number = '2590316' 

-- trx
SELECT start_tran_date, item_number, control_number, control_number_2, sum(case when tran_type = '951' then -tran_qty else tran_qty end) as qty
FROM t_tran_log
where tran_type in ('151','951') AND item_number = 'R66835'
group by  start_tran_date, item_number, control_number, control_number_2

select * from t_stored_item where item_number= '1080229'
select item_number, sum(actual_qty) as onhand from t_stored_item where item_number LIKE '1080229%' group by item_number

-- KNQMAN check
SELECT * 
FROM t_tran_log t
WHERE t.item_number IN ('D781-35') 
  AND t.tran_type = '165'  
  AND NOT EXISTS (
    SELECT 1 
    FROM t_tran_log t1 
    WHERE t1.tran_type = '151' 
      AND t1.lot_number = t.lot_number
  ) 
ORDER BY start_tran_date DESC, start_tran_time DESC


-- by sn 
select * from t_tran_log where lot_number = '688075336774' order by start_tran_date desc, start_tran_time desc
select * from t_tran_log where lot_number = '605590406108' order by start_tran_date desc, start_tran_time desc
select * from t_tran_log where lot_number = '503950857188' order by start_tran_date desc, start_tran_time desc


-- STO
select * from t_stored_item where lot_number = '688075336774' order by start_tran_date desc, start_tran_time desc
select * from t_stored_item where item_number LIKE 'T173-13%'
select item_number, sum(actual_qty) as onhand from t_stored_item where item_number LIKE 'T173-13%' group by item_number
select item_number, sum(actual_qty) as onhand from t_stored_item where item_number in ('7907008','') group by item_number
select location_id, sum(actual_qty) as qty from t_stored_item where location_id like 'A3%' group by location_id


-- hold
select top 10 * from t_items_on_hold 
select  * from t_items_on_hold 

select  top 10 * from t_item_master   
select  top 10 * from t_serial_active 
select  top 10 * from t_serial_active
select  top 10 * from t_serial_master  
select  top 10 * from t_serial_master  
select  top 10 * from t_serial_master


-- HOLD SN
select sn.wh_id, sn.serial_number, sn.item_number, sn.po_number, sn.serial_no_status, sn.status_change, sn.trip_number, sn.location_id, sn.hu_id,
       sn.received_date, sn.ship_date, sn.order_number, sn.sscc_code, itm.serial_no_status as sn_master_status
from t_serial_active as sn
left join t_serial_master as itm on itm.wh_id = sn.wh_id and itm.item_number = sn.item_number and sn.serial_number = itm.serial_number
where sn.wh_id = '335' and sn.serial_no_status not in ('O',)


-- SN
SELECT * FROM t_tran_log where lot_number ='689251446936' order by start_tran_date, start_tran_time
 
select  distinct serial_no_status from t_serial_active  



-- by item inbound 
SELECT t1.start_tran_date+t1.start_tran_time as tran_datetime, t1.item_number,t1.control_number,t1.control_number_2, t1.tran_type, t1.lot_number,
       sum(CASE when  t1.tran_type = '951' then -t1.tran_qty else t1.tran_qty end) as tran_qty
from t_tran_log as t1
WHERE t1.wh_id = '335'
	AND t1.tran_type in ('151','851','951')
    AND t1.item_number IN ('A8010414')
	--AND t1.control_number_2 IN ('P2RNT74','P2RSC61','P2RSC85','P2RSD96')
    AND t1.start_tran_date >= '2026-01-28'
GROUP by  t1.start_tran_date+t1.start_tran_time,t1.item_number,t1.control_number, t1.control_number_2,t1.tran_type, t1.lot_number
order by t1.item_number, t1.start_tran_date+t1.start_tran_time desc

-- by PO inbound
SELECT t1.start_tran_date, t1.control_number,t1.control_number_2, t1.tran_type, t1.item_number,
       sum(CASE when  t1.tran_type = '951' then -t1.tran_qty else t1.tran_qty end) as tran_qty
from t_tran_log as t1
WHERE t1.wh_id = '335'
	AND t1.tran_type in ('151','851','951')
    --AND t1.item_number IN ('A8010414')
	AND t1.control_number_2 IN ('P2SNX90')
    AND t1.start_tran_date >= '2026-01-28'
GROUP by  t1.start_tran_date,t1.control_number, t1.control_number_2,t1.tran_type, t1.item_number
order by t1.start_tran_date desc


-- by item receiving by LP
SELECT t1.start_tran_date,t1.start_tran_time,t1.item_number,t1.control_number, t1.control_number_2, t1.employee_id,t1.hu_id,t1.location_id, t1.location_id_2,
    sum (CASE when  t1.tran_type = '151' then t1.tran_qty else 0 end) as tran_151_qty,
    sum (CASE when  t1.tran_type = '951' then -t1.tran_qty else 0 end) as tran_951_qty,
    sum (CASE when  t1.tran_type = '151' then t1.tran_qty else 0 end) +  sum (CASE when  t1.tran_type = '951' then -t1.tran_qty else 0 end) as total_received_qty
from t_tran_log as t1
WHERE t1.wh_id = '335'
	AND t1.tran_type in ('16','951')
    AND t1.item_number IN ('D781-35')
	--AND t1.control_number_2 IN ('P2RNP16','P2RNS50','P2RRC24','P2RMR77','P2RMQ29')
    AND t1.start_tran_date >= '2025-12-28'
GROUP by  t1.start_tran_date,t1.start_tran_time,t1.item_number,t1.control_number,  t1.control_number_2, t1.employee_id, t1.hu_id,t1.location_id, t1.location_id_2
order by t1.start_tran_date+t1.start_tran_time desc, t1.control_number




-- by sn
select * from t_tran_log where  lot_number = '503949566078' order by start_tran_date + start_tran_time desc
select * from t_tran_log where  lot_number = '503952343763' order by start_tran_date + start_tran_time desc


-- by sn 2
select t.tran_type, t.description, t.start_tran_date, t.start_tran_time, t.employee_id, t.control_number_2, t.wh_id, t.location_id, t.item_number, t.tran_qty, t.location_id_2, t.routing_code, t.hu_id
from t_tran_log as t  
where  lot_number = '503949566078' 
order by start_tran_date + start_tran_time desc

select t.tran_type, t.description, t.start_tran_date, t.start_tran_time, t.employee_id, t.control_number_2, t.wh_id, t.location_id, t.item_number, t.tran_qty, t.location_id_2, t.routing_code, t.hu_id
from Distribution_Warehouse_Wholesale.TranLog as t  
where  lot_number = '618268701624' 
order by start_tran_date desc, start_tran_time desc

-- by sn
select *  from Distribution_Warehouse_Wholesale.TranLog  where  lot_number = '503951145940' order by start_tran_date desc, start_tran_time desc
select *  from Distribution_Warehouse_Wholesale.TranLog  where  lot_number = '618268701624' order by start_tran_date desc, start_tran_time desc
select *  from Distribution_Warehouse_Wholesale.TranLog where wh_id = '335' and item_number = 'A2000629' AND lot_number like '606%28' 
select *  from Distribution_Warehouse_Wholesale.TranLog where wh_id = '335' and item_number = 'A2000629' AND lot_number like '606%28' 
select *  from t_tran_log  where lot_number = '803952452209' order by start_tran_date desc, start_tran_time desc
select *  from t_tran_log  where lot_number = '503952452433' order by start_tran_date desc, start_tran_time desc
select *  from t_tran_log  where lot_number = '503951145940' order by start_tran_date desc, start_tran_time desc
select *  from t_tran_log  where lot_number = '503952147520' order by start_tran_date desc, start_tran_time desc


-- picking exceptions

select top 10 * from t_tran_log where tran_type in ('840') 
select * from t_tran_log where lot_number in ('503952534734') order by start_tran_date+start_tran_time desc
select * from t_tran_log where lot_number in ('503952609035') order by start_tran_date+start_tran_time desc
select * from t_tran_log where lot_number in ('666001070015') order by start_tran_date+start_tran_time desc
select top 10 * from t_employee 
select top 100 * from t_department 

with emp as (
	select t.id, t.name,t.emp_number, t.dept, t.supervisor, t1.description, t1.department_code
	from t_employee as t
	left join t_department as t1 on t.dept = t1.department_code
),
trx as (
	select t.tran_type,  t.description, cast(t.start_tran_date+ t.start_tran_time as datetime) as transaction_datetime, t.employee_id, t.item_number, t.lot_number, t.tran_qty, t.location_id as source_location, t.location_id_2 as destination_location, t.outside_id, t.process, t.equipment_zone,
	case
		when t.outside_id = '201' and t.location_id like 'S%' then 'sn in small stage but be moving scan from other location'
		when t.outside_id = '201' and t.location_id not like 'S%' then 'sn in location A but be moving scan from location B'
		when t.outside_id = '202'  then 'sn in location A but be moving scan on fork'
		when t.outside_id = '251'  then 'sn in location A but replenish moving scan from location B'
		when t.outside_id = '253'  then 'sn in location A but direct pickup moving scan from location B'
		when t.outside_id = '303' and t.location_id like 'S%' then 'sn in small stage then be picking scan from other location again'
		when t.outside_id = '303' and t.location_id not like 'S%' then 'sn in location A but be picking scan from location B'
		when t.outside_id = '304' and t.location_id like 'S%'  then 'sn in small stage then be picking scan on fork'
		when t.outside_id = '304' and t.location_id not like 'S%'  then 'sn without picking then be picking scan on fork'
		when t.outside_id = '321'  then 'sn without picking but be loading scan'
		when t.outside_id = '800'  then 'cycle count correction'
		else 'check' end as exception_reason
	from t_tran_log as t
	where tran_type in ('840') and start_tran_date >= '2026-01-01'
)
select t.*, e.emp_number, e.name, e.dept, e.supervisor,e.description,
case 
	when t.exception_reason like 'sn in small stage but be moving scan from other location%' then 'Major'
	when t.exception_reason like 'sn in location A but be moving scan from location B%' then 'Acceptable'
	when t.exception_reason like 'sn in location A but be moving scan on fork%' then 'Acceptable'
	when t.exception_reason like 'sn in location A but replenish moving scan from location B%' then 'Acceptable'
	when t.exception_reason like 'sn in location A but direct pickup moving scan from location B%' then 'Acceptable'
	when t.exception_reason like 'sn in small stage but be picking scan from other location again%' then 'Major'
	when t.exception_reason like 'sn in location A but be picking scan from location B%' then 'Acceptable'
	when t.exception_reason like 'sn in small stage but be picking scan on fork%' then 'Major'
	when t.exception_reason like 'sn without picking then be picking scan on fork%' then 'Major'
	when t.exception_reason like 'sn without picking but be loading scan%' then 'Major'
	when t.exception_reason like 'cycle count correction %' then 'Acceptable'
	else 'Others' end as exception_severity
from trx as t
left join emp as e on t.employee_id = e.id


-- picking
select  * from t_pick_detail where order_number like '%68433%' and status = 'PICKED'


-- onahnd
select  * from t_stored_item where type like '%68433%' 

select top 10 * from t_item_forecast_allocation 
select top 10 * from t_item_allocation_hotload 
select top 10 * from t_item_plate_section 

-- locations
select top 10 * from t_location
select top 10 * from t_loc_pallet_capacity
select top 10 * from t_loc_depth_strata_stage
select top 10 * from t_loc_depth_strata
select top 10 * from t_loc_height_strata_stage
select top 10 * from t_loc_height_strata
select top 10 * from t_location_snapshot
select top 10 * from t_slot_location_forecast_statistics
select top 10 * from t_slot_location_statistics

select Distinct zone from t_zone_loca where zone  like '%BULK%'
select top 10 *  from t_zone_loca where zone  like '%BULK%'
select top 10 * from t_class_loca
select top 10 * from t_printer  

--asn

select  *  from t_zone_loca WHERE zone = 'A3CGBULK'
select  *  from t_class_loca where class_id = 'FLOOR' and location_id like 'A3%' ORDER BY location_id 
select distinct status from t_asn
select top 10 * from t_email_distribution 

select top 10 * from t_asn_detail 
select top 10 * from t_printer  


-- by po
select start_tran_date, tran_type, description,item_number, control_number_2,sum(case when tran_type = '951' then -tran_qty else tran_qty end ) as qty 
from t_tran_log 
where tran_type in ('151','951','183') and start_tran_date >= '2025-01-26' and control_number_2 in ('P2SWQ93')
group by start_tran_date ,tran_type, description,item_number, control_number_2
order by start_tran_date ,tran_type, description,item_number, control_number_2

select start_tran_date, tran_type, description,item_number, control_number_2,sum(case when tran_type = '951' then -tran_qty else tran_qty end ) as qty 
from t_tran_log 
where tran_type in ('151','951','183') and start_tran_date >= '2025-01-26' and control_number_2 in ('P2SD358')
group by start_tran_date ,tran_type, description,item_number, control_number_2
order by start_tran_date ,tran_type, description,item_number, control_number_2

-- by item 
select start_tran_date,start_tran_time, tran_type, description,item_number, control_number_2, lot_number, employee_id, sum(case when tran_type = '951' then -tran_qty else tran_qty end ) as qty 
from t_tran_log 
where tran_type in ('151','951') and start_tran_date >= '2026-01-26' and item_number in ('D781-35') and control_number_2 in ('P2SWQ93')
group by start_tran_date ,start_tran_time, tran_type, description,item_number, control_number_2, lot_number, employee_id
order by start_tran_date ,start_tran_time, tran_type, description,item_number, control_number_2


-- returned containers
select *
from t_serial_active where serial_number in (select distinct lot_number from t_tran_log where tran_type = '347' AND (control_number_2 LIKE '%89296-%' or control_number_2 LIKE '%90774-%' ) )


-- Trip shipped by sn
SELECT 
    t.tran_type,  
    t.description, 
    t.start_tran_date, 
    t.control_number_2,
    -- 提取 '-' 之前的部分并转为整数以自动去除前导零
    CAST(LEFT(t.control_number_2, CHARINDEX('-', t.control_number_2 + '-') - 1) AS INT) AS clean_control_number,
    t.lot_number,
	t1.po_number,
	t1.serial_no_status,
	t1.status_change,
	t1.location_id,
	t1.received_date,
	t1.ship_date,
    t.employee_id, 
    t.item_number, 
    SUM(t.tran_qty) AS tran_qty 
FROM t_tran_log AS t
LEFT JOIN t_serial_active as t1 ON t.lot_number = t1.serial_number
WHERE t.wh_id = '335' 
    AND t.start_tran_date > '2025-01-01'
    AND t.tran_type IN ('347')
    -- 过滤条件：确保包含连字符且截取后是数字格式（防止报错）
    AND (t.control_number_2 LIKE '%89296-%' or t.control_number_2 LIKE '%90774-%' )
GROUP BY 
    t.tran_type,  
    t.description, 
    t.start_tran_date, 
    t.control_number_2,
    CAST(LEFT(t.control_number_2, CHARINDEX('-', t.control_number_2 + '-') - 1) AS INT),
    t.lot_number,
	t1.po_number,
	t1.serial_no_status,
	t1.status_change,
	t1.location_id,
	t1.received_date,
	t1.ship_date,
    t.employee_id, 
    t.item_number

-- by transactions type  
select start_tran_date,start_tran_time, tran_type, description,item_number, control_number_2, lot_number, employee_id, sum(case when tran_type = '951' then -tran_qty else tran_qty end ) as qty 
from t_tran_log 
where tran_type in ('151','951') and start_tran_date >= '2026-01-26' and item_number in ('D781-35') and control_number_2 in ('P2SWQ93')
group by start_tran_date ,start_tran_time, tran_type, description,item_number, control_number_2, lot_number, employee_id
order by start_tran_date ,start_tran_time, tran_type, description,item_number, control_number_2



-- by sn
select top 100 * from t_tran_log where lot_number in ('585683806')  order by start_tran_date+start_tran_time desc

-- onhand
select top 10 * from t_serial_active where serial_number in ('635930176074') 

select top 10 * from t_item_master 
select top 10 * from t_item_master where item_number LIKE 'D769-%'
select top 10 * from t_item_uom where pick_put_id != 'SCOOP' AND  item_number LIKE 'D769-%'

select distinct control_number_2 from t_tran_log where tran_type = '100' and control_number_2 like 'WAVT%' order by control_number_2 desc

select *, case when lot_number in (select distinct lot_number  from t_tran_log where tran_type = '855' and routing_code = '151R') then 'trailer_checked out or ASN closed' else 'others reason' end as reason_type from t_exception_log where exception_date > '2026-01-01' and tran_type like '%855%' 

select * from t_exception_log where exception_date > '2026-01-01' and tran_type like '%855%' 
select * from t_exception_tran_log where exception_date > '2026-01-01' and tran_type like '%855%' 
select * from t_tran_log where lot_number  in (select lot_number from t_exception_log where tran_type like '%855%')  order by lot_number, start_tran_date+start_tran_time 

select * from t_tran_log where control_number_2 like '%89713%' and tran_type like '363%' order by lot_number, start_tran_date+start_tran_time 
select * from t_tran_log where control_number_2 like '%89713%' and tran_type like '363%' order by lot_number, start_tran_date+start_tran_time 

-- move too fast?
select * from t_tran_log where lot_number  in ('633122439539')  order by lot_number, start_tran_date+start_tran_time 
select * from t_tran_log where lot_number  in ('635094222466')  order by lot_number, start_tran_date+start_tran_time 
select * from t_tran_log where lot_number  in ('503952458060')  order by lot_number, start_tran_date+start_tran_time 
select * from t_tran_log where lot_number  in ('605590406108')  order by lot_number, start_tran_date+start_tran_time 

-- over/short caused 855
select * from t_tran_log where lot_number  in ('620450068928')  order by lot_number, start_tran_date+start_tran_time 
select * from t_tran_log where lot_number  in ('503952832280')  order by lot_number, start_tran_date+start_tran_time 
select * from t_tran_log where lot_number  in ('637460222971')  order by lot_number, start_tran_date+start_tran_time 

-- scan issue caused 855
select * from t_tran_log where lot_number  in ('503952387659')  order by lot_number, end_tran_date, end_tran_time 
select * from t_tran_log where lot_number  in ('605590410189')  order by lot_number, end_tran_date, end_tran_time 
select * from t_tran_log where lot_number  in ('688806127127')  order by lot_number, end_tran_date, end_tran_time 
select * from t_tran_log where lot_number  in ('503952387659')  order by lot_number, end_tran_date, end_tran_time 
select * from t_tran_log where lot_number  in ('503952387659')  order by lot_number, end_tran_date, end_tran_time 
select * from t_tran_log where lot_number  in ('688806129506')  order by lot_number, end_tran_date, end_tran_time 
select * from t_tran_log where lot_number  in ('688075756037')  order by lot_number, end_tran_date, end_tran_time 
select * from t_tran_log where lot_number  in ('688075719050')  order by lot_number, end_tran_date, end_tran_time 
select * from t_tran_log where lot_number  in ('633121630592')  order by lot_number, end_tran_date, end_tran_time 

select * from t_tran_log where lot_number  in ('503952387659')  order by lot_number, end_tran_date, end_tran_time 
select * from t_tran_log where lot_number  in ('609890101606')  order by lot_number, end_tran_date, end_tran_time 


select * from t_item_master where item_number in ('R408340')
select * from t_item_uom where item_number in ('R408340')
select * from t_tran_log where item_number  in ('R408340')  order by lot_number, end_tran_date, end_tran_time 
select * from t_tran_log where lot_number  in ('605590414947')  order by lot_number, end_tran_date, end_tran_time 

select top 10 * from t_hu_master where hu_id in ('00000038255797')
select top 10 * from t_hu_detail where hu_id in ('00000038255797')
select top 10 * from t_location where location_id = 'A3018CY1'




select * from t_tran_log where lot_number  in ('503952412173')  order by lot_number, start_tran_date+start_tran_time 
select * from t_tran_log where tran_type = '855' and routing_code = '151R' order by lot_number, start_tran_date+start_tran_time 
select * from t_tran_log where item_number  in ('8254056') and tran_type = '855'  order by start_tran_date+start_tran_time desc
select * from t_tran_log where item_number  in ('8254056') and tran_type = '202'  order by start_tran_date+start_tran_time desc
select top 10 * from t_order_detail_breakdown 
select top 10 * from t_order_detail_breakdown 



-- employee
select top 10 * from t_employee where id in ('50771', '30008')


select im.item_number, im.description,im.unit_weight*0.4536 as [unit_Weight(Kg)], im.unit_volume*0.000016387 as [Unit_Cube(m3)],im.class_id, im.pick_put_id,
	uom.uom, uom.units_per_layer as width,uom.layers_per_uom as height, uom.max_in_layer as depth, im.std_hand_qty as SCOOP_Qty, im.pallet_id
from t_item_master as im 
inner join (select * from t_item_uom where pick_put_id != 'SCOOP') as uom on im.item_number = uom.item_number



-- item master
select top 10 * from t_item_master where item_number = '1130449'
select top 10 * from t_item_uom where item_number in ('1320138','5200438','3310438','4500338')



-- asn

select * 
from t_asn_detail as asd
inner join t_asn asn on asn.asn_id = asd.asn_id




-- CHECK IN YARD OF VENDOR TRAILER
select top 10 * from t_control WHERE description LIKE '%YA101%'
select top 10 * from t_control WHERE control_type LIKE '%SEND_YA101_AT_CHKIN%'

-- uph section

 

-- order and picked cubes




-- UPH RECEIVING
with i as (
	select top 10 * from t_import_RECEIPT where transaction_string like '%UPH%'
)






/*
CustomerID	CustomerName
8888600	STONELEDGE FURNITURE, LLC
8888000	SOUTHWEST FURN OF WI LLC
8888300	KINGSWERE FURNITURE LLC
Customer#	Ship to#	Customer name
3824800	ECR	ASHLEY DISTRIBUTION CTR
3824800	70	ASHLEY DISTRIBUTION CTR
3824800	42	ASHLEY DISTRIBUTION CTR
3824800	28	ASHLEY DISTRIBUTION CTR
3824800	242	ASHLEY DISTRIBUTION CTR
3824800	17	ASHLEY DISTRIBUTION CTR
3824800	15	ASHLEY DISTRIBUTION CTR

*/

-- item master


-- order by c# and customer id

select top 10 * from t_order_c_number where customer_number = '03824800'
select top 10 * from t_order_detail_breakdown  where order_number like '%80527%'
select t.*, c.customer_id, c.bill_to_name, c.customer_number
from t_order_detail_breakdown as t
join t_order_c_number as c on t.c_number = c.c_number 
where c.customer_number like '%3824800'
--where t.order_number like '%80527%'


-- ASN
select * from t_control where description like '%YA%'
select * from t_import_ASN where transaction_string like '%P2RNP16%'
select top 10 * from t_asn where equipment_id = 'MSMU5907480'
select t.*, t1.* 
from t_asn as t 
join t_asn_detail as t1 on t.asn_id = t1.asn_id
where equipment_id = 'MSMU5907480'
select top 10 * from t_asn_detail where equipment_id = 'MSMU5907480'

--- item basic 
select top 10 * from t_item_master where item_number in ('R78891','R78908','78830','3410587181')
select top 10 * from t_item_master where  item_number = 'D947-81'
select top 10 * from t_item_master where  item_number = 'R405102'
select top 10 * from t_item_uom where item_number in ('R405102')
select top 10 * from t_item_attributes where item_number in ('R78891','R78908','78830','3410587181')
select top 10 * from t_fwd_pick where item_number in ('R78891','R78908','78830','3410587181')


-- location basic
select top 10 * from t_location where location_id in ('A3015HA1','A3015HA2','A3015HA3','A3015HA4')
select top 10 * from t_ya_location
select top 10 * from t_class_loca where location_id in ('A3015HA1','A3015HA2','A3015HA3','A3015HA4')


select * FROM t_quality_detail
select * FROM t_quality_check
select top 10 * FROM t_work_q where work_type = 11 and pick_ref_number like '%71814%'


SELECT top 1 *
FROM t_quality_detail qud (NOLOCK)
INNER JOIN t_quality_check qum (NOLOCK) ON qum.work_type = qud.work_type
WHERE qud.work_type = '11'
    AND 25 IN (SELECT * FROM udf_ListToTable(qud.threshold,','))
ORDER BY qud.id

select * from t_quality_detail (nolock)
select * from t_quality_check (nolock)








select top 10 * from t_item_uom where item_number like 'B%' AND pick_put_id = 'PALLT'
select top 10 * from t_loc_pallet_capacity
select top 10 * from t_tbl_highjump_mapics_inventorysum where  (Mapics<>0 and HighJump<>0 AND KNQMAN_Qty<>0)
select top 10 * from t_tbl_highjump_mapics_inventorysum_staging where  (Mapics<>0 and HighJump<>0 AND KNQMAN_Qty<>0)
select top 10 * from t_tbl_highjump_mapics_inventorysumexc where  (Mapics<>0 and HighJump<>0 AND KNQMAN_Qty<>0)
select top 10 * from t_tbl_highjump_mapics_inventorysumexc_staging where  (Mapics<>0 and HighJump<>0 AND KNQMAN_Qty<>0)
select top 10 * from t_zone_loca where location_id like 'A3020HA1%'
select top 10 * from t_active_door_unload
select top 10 *  from t_import_WAORDER
SELECT TOP 10 * FROM t_load_master ldm (nolock)
select top 10 *  from t_exception_tran_log 
select top 10 *  from  t_tran_log ORDER BY start_tran_date DESC
select top 10 *  from  t_class_loca
select top 10 *  from t_exception_tran_log  where exception_date > '2025-09-20' and tran_type = '99G' and location_id NOT IN ('NG001OP3')
SELECT *  FROM t_employee where device is not null order by last_tran_datetime desc
SELECT top 10 *  FROM t_order_detail_breakdown  
select top 10 * from t_serial_master 
select top 10 * from t_serial_master 
select top 10 * from t_serial_master 

SELECT 
    t.name AS TableName,
    c.name AS ColumnName
FROM sys.tables t
JOIN sys.columns c ON t.object_id = c.object_id
WHERE c.name LIKE '%page%'




-- ASN and detail
select top 100 * from t_asn_detail where customer_po_number = 'P2R6Z63'
select top 100 * from t_asn where asn_id = '1361382'
select top 100 * from t_asn_detail where asn_id = '1361382'
select top 10000 * from t_tran_log where control_number_2 = 'P2R6Z63' and tran_type = '151'




select * from t_serial_active where item_number = 'A4000684'  AND po_number = 'P2QT095'
select * from t_serial_master where item_number = 'A4000684'  AND po_number = 'P2QT095'
select * from t_serial_master where item_number = 'A4000684'  AND po_number = 'P2QT095'
select * from t_serial_master where item_number = 'A4000684'  AND po_number = 'P2QT095'
SELECT TOP 1000 *  FROM t_hu_detail WHERE item_number = 'A4000684'
select * from t_serial_active (nolock) where 1=1 and item_number = 'A4000684' and location_id = 'RS040AA1' 
select * from t_serial_active (nolock) where 1=1 and item_number = 'A4000684'  and hu_id = '00000036678374'
select * from t_serial_active where serial_no_status = 'R' and item_number = 'A4000684'  AND location_id = 'A3019EH1'




update t_serial_active 
set serial_no_status = 'R'
where item_number = 'A4000684' and status = 'U'
hu_id = '00000036678374' ,'00000036678373'



select top 1000 * from t_tran_log order by start_tran_date desc

select * from t_tran_log where item_number = 'L207624' and start_tran_date >= '2025-12-08' and control_number like '%57267%'

SELECT  *
FROM t_ya_tran_log as t 
join t_trailer as t1 on t.carrier_trailer_number = t1.carrier_trailer_number
join t_trailer_type as t2 on t1.trailer_type_id = t2.trailer_type_id
where t.carrier_trailer_number like 'TIIU711013%' 



select top 10 * from t_item_uom where item_number like 'D372-01%' AND pick_put_id = 'PALLT'

-- replenishment related columns
SELECT TOP 1000 *  FROM INFORMATION_SCHEMA.COLUMNS WHERE Column_name LIKE '%replen%'
SELECT TOP 1000 *  FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME LIKE '%replen%'
select top 1000 *  from t_replenishment_task_log order by requested_datetime
select top 1000 *  from t_replenishment_task_log where unique_id = '416608838' order by requested_datetime

select DISTINCT class_id from t_class_loca where location_id like 'A3021%' and substring(location_id,6,1) in  ('C','E','G','J','L','N') 
and class_id in ('UPHH','UPHL','UPHOT','UPHXH')

select DISTINCT class_id from t_class_loca where location_id like 'A3021%' and substring(location_id,6,1) in  ('D') and class_id in ('UPHH','UPHL','UPHOT','UPHXH')
select DISTINCT class_id from t_class_loca where location_id like 'A3021%' and substring(location_id,6,1) in  ('D','F','H','K','M','P') and class_id in ('UPHH','UPHL','UPHOT','UPHXH')
select DISTINCT class_id from t_class_loca where location_id like 'A3021%' and substring(location_id,6,1) in  ('D','F','H','K','M','P') and class_id in ('UPHH','UPHL','UPHOT','UPHXH')
select DISTINCT class_id from t_class_loca where location_id like 'A3021%' and substring(location_id,6,1) in  ('D','F','H','K','M','P') and class_id in ('UPHH','UPHL','UPHOT','UPHXH')
select DISTINCT class_id from t_class_loca where location_id like 'A3021%' and substring(location_id,6,1) in  ('D','F','H','K','M','P') and class_id in ('UPHH','UPHL','UPHOT','UPHXH')


SELECT  *  FROM t_location where status = 'E' AND type in ('I')
SELECT  *  FROM t_item_master where item_number = 'B5168-197W1'
SELECT  top 10 *  FROM t_item_uom where item_number = 'B5168-197W1'
SELECT  top 10 *  FROM t_stored_item where item_number = 'B5168-197W1'
SELECT  top 10 *  FROM t_serial_active where item_number = 'B5168-197W1'


B5168-197W1


SELECT DISTINCT right(t.location_id,1), COUNT(t.location_id) AS loct_qty
FROM t_location AS t
where 1=1
	and t.location_id like 'A3015%'
	and t.type not in ('ZZ')
GROUP BY right(t.location_id,1)


select t.item_number, sum(t.tran_qty) as qty
from t_tran_log as t
where t.tran_type = '347'
    and t.item_number = 'A1000420'
	and t.start_tran_date >= '2024-08-20'
group by t.item_number


-- asn and detail
select top 100 t.*, t1.*, t2.*, t3.*, t4.*
from t_asn as t
inner join t_asn_detail as t1 on t.asn_id = t1.asn_id
inner join t_trailer_asn as t2 on t.asn_id = t2.asn_id
inner join t_trailer as t3 on t2.trailer_id = t3.trailer_id
inner join t_ya_location as t4 on t3.location_id = t4.location_id
where 1=1



-- pkd
select top 100 * from t_pick_detail as t
where 1=1
	and t.status = 'RELEASED'

-- sn in warehouse
select t.*, t2.* 
from t_serial_active as t
inner join t_location as t2 on t.location_id = t2.location_id 
where 1=1
	and t.item_number = '1400394'

select top 10 * from v_order