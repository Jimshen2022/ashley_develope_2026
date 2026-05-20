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
    t1.serial_number_start,
    t1.serial_number_end,
    t1.quantity_shipped - t1.quantity_received as qty_remaining,
    t1.sn_coo,
    t3.status as trailer_status,
    t3.entered_yard,
    t4.location_name
from t_asn as t
left join t_asn_detail as t1 on t.asn_id = t1.asn_id
left join t_trailer_asn as t2 on t.asn_id = t2.asn_id
left join t_trailer as t3 on t2.trailer_id = t3.trailer_id
left join t_ya_location as t4 on t3.location_id = t4.location_id
where 1=1
    and t.[status] in ('CHECKED IN')




