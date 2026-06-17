-- sn check
Select * from Distribution_Warehouse_Wholesale.tranlog where wh_id = '51' and tran_type = '361' and start_tran_date > '2026-01-01' and item_number like 'M%' order by start_tran_date
Select * from Distribution_Warehouse_Wholesale.ExceptionLog where wh_id = '335' and tran_type like '855%'  order by lot_number, exception_date
Select * from Distribution_Warehouse_Wholesale.tranlog where wh_id = '335' and employee_id = '50165' and start_tran_date > '2021-01-01' order by start_tran_date desc, start_tran_time desc
Select * from Distribution_Warehouse_Wholesale.tranlog where wh_id = '335' and tran_type = '855' and start_tran_date >= '2026-01-01' order by lot_number, start_tran_date, start_tran_time
Select * from Distribution_Warehouse_Wholesale.tranlog where wh_id = '335' and lot_number = '503952384062' and start_tran_date >= '2024-01-01' order by lot_number, start_tran_date, start_tran_time
Select * from Distribution_Warehouse_Wholesale.tranlog where wh_id = '335' and lot_number = '503952820543' and start_tran_date >= '2024-01-01' order by lot_number, start_tran_date, start_tran_time
Select * from Distribution_Warehouse_Wholesale.tranlog where wh_id = '335' and lot_number = '635930176074' and start_tran_date >= '2024-01-01' order by lot_number, start_tran_date, start_tran_time
Select * from Distribution_Warehouse_Wholesale.tranlog where wh_id = '335' and lot_number = '666001038790' and start_tran_date >= '2024-01-01' order by lot_number, start_tran_date, start_tran_time



-- item in whse
select * from t_stored_item WHERE item_number in ('T236-13','T247-13','T251-13') 
select * from t_serial_active WHERE item_number in ('T236-13','T247-13','T251-13') 

select * from t_stored_item WHERE item_number in ('T236-13','T247-13','T251-13')
select * from t_serial_active WHERE item_number in ('T236-13','T247-13','T251-13') 

-- by item and location
select * from t_stored_item WHERE item_number in ('T236-13','T247-13','T251-13') order by item_number, location_id
select item_number, location_id, po_number, count(serial_number) as on_hand_sn_qty
from t_serial_active
where wh_id = '335' and item_number in ('T236-13','T247-13','T251-13')
    and (serial_no_status != 'S' and serial_no_status != 'O')
GROUP BY item_number, location_id, po_number
order by item_number, po_number, location_id

-- 2026/06/16
Select wh_id, tran_type, description,start_tran_date, cast(start_tran_time as time) as start_tran_time, employee_id,
	control_number as wa_order, control_number_2 as reference, item_number, lot_number, tran_qty, location_id as from_location_id, location_id_2 as to_location_id, routing_code as pick_run_id
from Distribution_Warehouse_Wholesale.tranlog 
where wh_id = '335' 
	and lot_number in ('666001038787','666001038788','666001038790','666001038337','601820053104','601820053088')
	and start_tran_date >= '2024-01-01' 
	order by lot_number, start_tran_date, start_tran_time

-- 2026/06/16
Select wh_id, tran_type, description,start_tran_date, cast(start_tran_time as time) as start_tran_time, employee_id,
	control_number as wa_order, control_number_2 as reference, item_number, lot_number, tran_qty, location_id as from_location_id, location_id_2 as to_location_id, routing_code as pick_run_id
from Distribution_Warehouse_Wholesale.tranlog 
where
	 lot_number in ('503953156470')
	and start_tran_date >= '2024-01-01' 
	order by wh_id,lot_number, start_tran_date, start_tran_time


-- in warehouse
select *
from t_serial_active
where wh_id = '335' and item_number in ('T236-13','T247-13','T251-13')
	and (serial_no_status = 'R' or serial_no_status is null)
