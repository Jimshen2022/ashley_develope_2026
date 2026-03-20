-- HOLD SN
select sn.wh_id, sn.serial_number, sn.item_number, sn.po_number, sn.serial_no_status, sn.status_change, sn.trip_number, sn.location_id, sn.hu_id,
       sn.received_date, sn.ship_date, sn.order_number, sn.sscc_code, itm.serial_no_status as sn_master_status
from t_serial_active as sn
left join t_serial_master as itm on itm.wh_id = sn.wh_id and itm.item_number = sn.item_number and sn.serial_number = itm.serial_number
where sn.wh_id = '335' and sn.serial_no_status  in ('H')

