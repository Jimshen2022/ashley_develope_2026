
-- sn status summary
select sna.serial_no_status, count(sna.serial_number) as qty 
from t_serial_active as sna
left join t_serial_master as snm on sna.serial_number = snm.serial_number and sna.wh_id = snm.wh_id
where sna.wh_id = '335' and (sna.serial_no_status != 'O' and sna.serial_number is not null and sna.serial_no_status != 'S')
group by sna.serial_no_status

-- sn status summary
select 
    sna.serial_no_status, 
    count(sna.serial_number) as qty,
    sum(count(sna.serial_number)) over () as total_qty
from t_serial_active as sna
left join t_serial_master as snm 
    on sna.serial_number = snm.serial_number 
   and sna.wh_id = snm.wh_id
where sna.wh_id = '335' 
  and sna.serial_number is not null
  and sna.serial_no_status not in ('O', 'S')
group by sna.serial_no_status;


-- sn inwarehouse 
select sna.wh_id,sna.serial_number, sna.item_number, sna.po_number, sna.location_id, sna.received_date, sna.serial_no_status,snm.serial_no_status as master_sn_status, snm.country_code
from t_serial_active as sna
left join t_serial_master as snm on sna.serial_number = snm.serial_number and sna.wh_id = snm.wh_id
where sna.wh_id = '335' and (sna.serial_no_status != 'O' and sna.serial_number is not null and sna.serial_no_status != 'S')


-- sn in damaged locations 
select 
    lg.lot_number, 
    lg.item_number, 
    lg.location_id_2, 
    convert(varchar(19), min(cast(lg.start_tran_date + lg.start_tran_time as datetime)), 120) 
        as scanned_into_damaged_loc_datetime,
    max(lg.tran_type) as last_tran_type
from t_tran_log as lg with (nolock)  
where lg.start_tran_date >= '2026-01-01' 
    and lg.location_id_2 in ('NG001CG3','NG001UP3','NG001VD3','NG001CK3','DM001AA1')
    and lg.lot_number is not null
group by 
    lg.lot_number, 
    lg.item_number, 
    lg.location_id_2;


-- sn in damaged locations 
select lg.lot_number, lg.item_number, location_id_2, min(cast(lg.start_tran_date + lg.start_tran_time as datetime)) as scanned_into_damaged_loc_datetime,max(lg.tran_type) as last_tran_type
from t_tran_log as lg with (nolock)  
where start_tran_date >= '2026-01-01' 
    and location_id_2 in ('NG001CG3','NG001UP3','NG001VD3','NG001CK3','DM001AA1')
    and lg.lot_number is not null
group by lg.lot_number, lg.item_number, location_id_2






select sna.wh_id,sna.serial_number, sna.item_number, sna.po_number, sna.location_id, sna.received_date, sna.serial_no_status,snm.serial_no_status as master_sn_status, snm.country_code
from t_serial_active as sna with (nolock)  
left join t_serial_master as snm with (nolock)   on sna.serial_number = snm.serial_number and sna.wh_id = snm.wh_id
where sna.wh_id = '335' and (sna.serial_no_status != 'O' and sna.serial_number is not null and sna.serial_no_status != 'S')
    and sna.location_id in ('NG001CG3','NG001UP3','NG001VD3','NG001CK3','DM001AA1')

