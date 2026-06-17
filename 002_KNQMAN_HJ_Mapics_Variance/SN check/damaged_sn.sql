
--select top 100 * from t_asn as asn with (nolock)   
--select top 100 * from t_asn_detail as asn with (nolock)   
--select top 100 * from t_po_master as asn with (nolock)   
--select top 100 * from t_vendor as asn with (nolock)   

--select po_number from t_po_master as asn with (nolock)  group by po_number having count(*) > 1
--select vendor_code from t_vendor as asn with (nolock)  group by vendor_code having count(*) > 1

--select po.po_number, po.vendor_code, v.vendor_name
--from t_po_master as po with (nolock) 
--left join t_vendor as v with (nolock) on po.vendor_code = v.vendor_code



-- sn in damaged locations 

with po as (
select po.po_number, po.vendor_code, v.vendor_name
from t_po_master as po with (nolock) 
left join t_vendor as v with (nolock) on po.vendor_code = v.vendor_code
),
sn_in_damaged_loc as (
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
    lg.location_id_2
),
sn_in_warehouse as (
select sna.wh_id,sna.serial_number, sna.item_number, sna.po_number, sna.location_id, sna.received_date, sna.serial_no_status,snm.serial_no_status as master_sn_status, snm.country_code
from t_serial_active as sna
left join t_serial_master as snm on sna.serial_number = snm.serial_number and sna.wh_id = snm.wh_id
where sna.wh_id = '335' and (sna.serial_no_status != 'O' and sna.serial_number is not null and sna.serial_no_status != 'S')
    and sna.location_id in ('NG001CG3','NG001UP3','NG001VD3','NG001CK3','DM001AA1')
)
-- 以sn_in_warehouse为主表，左连接sn_in_damaged_loc获取扫描到残次品位置的时间和最后一次tran_type，再左连接po表获取po信息
select 
    d.scanned_into_damaged_loc_datetime,
    w.serial_number,
    1 as qty,
    w.location_id,  
    w.item_number,
    w.po_number,
    p.vendor_name,
    cast(w.received_date as date) as received_date,
    w.serial_no_status,
    w.master_sn_status,
    d.last_tran_type
    from sn_in_warehouse as w
    left join sn_in_damaged_loc as d on w.serial_number = d.lot_number and w.item_number = d.item_number
    left join po as p on w.po_number = p.po_number
    order by d.scanned_into_damaged_loc_datetime desc, w.serial_number



