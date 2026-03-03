--select top 10 * from t_item_uom where item_number like 'D%'

with uom as (
select t1.item_number,
    t1.class_id,
    t1.units_per_layer,
    t1.layers_per_uom,
    t1.max_in_layer,    
    case 
        when t1.pallet_id = '1' then '5x5'
        when t1.pallet_id = '3' then '5x7'
        when t1.pallet_id = '4' then '3.5x5'
        when t1.pallet_id = '5' then '3.5x7'
        when t1.pallet_id = '18' then '5x8'
        else null end as pallet_type,
    t2.std_hand_qty as SCOOP_qty
 from t_item_uom t1
 left JOIN (select item_number, std_hand_qty from t_item_uom where pick_put_id = 'SCOOP') t2 on t1.item_number = t2.item_number
 where pick_put_id = 'PALLT'
)
-- asn and detail
select 
    t.asn_number,
    t.asn_id,
    t.status,    
    t.equipment_id, 
    t.trailer_type_name,
    t.expected_arrival,
    t.vendor_id,
    t.total_quantity,
    t.total_volume,
    t1.item_number,
    t1.uom,
    t1.customer_po_number,
    t1.quantity_shipped - t1.quantity_received as qty_remaining,
    u.class_id,
    u.units_per_layer,
    u.layers_per_uom,
    u.max_in_layer,
    u.pallet_type,
    u.SCOOP_qty,
    CASE 
        WHEN t1.quantity_shipped - t1.quantity_received <= 0 THEN 0
        WHEN u.SCOOP_qty IS NULL OR u.SCOOP_qty = 0 THEN NULL
        ELSE CEILING(CAST(t1.quantity_shipped - t1.quantity_received AS DECIMAL(18,2)) / NULLIF(u.SCOOP_qty, 0))
    END as pallet_needs, 
    t1.sn_coo,
    t3.status as trailer_status,
    t3.entered_yard,
    t4.location_name,
    case when t3.status is null then 'In_transit' else t3.status end final_asn_status
from t_asn as t
left join t_asn_detail as t1 on t.asn_id = t1.asn_id
left join t_trailer_asn as t2 on t.asn_id = t2.asn_id
left join t_trailer as t3 on t2.trailer_id = t3.trailer_id
left join t_ya_location as t4 on t3.location_id = t4.location_id
left join uom as u on u.item_number = t1.item_number
where 1=1
    and t.[status] in ('NEW','CHECKED IN')
