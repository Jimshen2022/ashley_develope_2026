/*
SELECT TOP 10 *  FROM  t_asn where asn_id = '1725692'
SELECT TOP 10 *  FROM  t_asn_detail where asn_id = '1725692'
SELECT TOP 10  *  FROM  t_trailer   where trailer_id = '355197'
SELECT TOP 10 *  FROM  t_trailer_asn  where asn_id = '1725692'


SELECT TOP 10 *  FROM  t_ya_location 
SELECT *  FROM  t_vendor WHERE vendor_name like '%WANEK%'

vendor_id	vendor_code	vendor_name	inspection_flag	ownership_control	asn_required
6135	900515	WANEK FURNITURE 1	NO	NO	NULL
6548	600039	WANEK FURNITURE 3	NO	NO	NULL
6580	900639	WANEK FURNITURE 2	NO	NO	NULL


SELECT DISTINCT status  FROM  t_asn
SELECT * FROM  t_asn
SELECT *  FROM  t_asn where vendor_id in ('6135','6580','6548')
SELECT  *  FROM  t_trailer 
*/


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
    and t.[status] in ('NEW','CHECKED IN')
   -- and t3.[status] in ('NEW','CHECKED IN')



