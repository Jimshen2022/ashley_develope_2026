SELECT t1.equipment_id, t1.wh_id, t1.asn_id, t1.asn_number, t1.vendor_id, t1.carrier_id, t1.expected_arrival, t1.shipped, t1.total_quantity
	, t1.total_weight, t1.total_volume, t1.trailer_type_name, t1.status, t1.sent_103_flag, t1.sent_101_flag, t2.asn_detail_id, t2.customer_po_number
	, t2.item_number, t2.uom, t2.quantity_shipped, t2.serial_number_start, t2.serial_number_end, t2.quantity_received, t2.born_on_date, t2.sn_coo
	, t4.entered_yard, t4.status, t4.location_id, t5.location_name, CONCAT(t1.equipment_id, '_', t2.customer_po_number) AS equipment_po
        , t2.quantity_shipped - t2.quantity_received AS Yard_open_qty
FROM (SELECT * FROM Distribution_Warehouse_Wholesale.t_asn as a1
WHERE a1.wh_id = '335' and a1.status in ('NEW','CHECKED IN')) AS t1
LEFT JOIN (SELECT * FROM Distribution_Warehouse_Wholesale.ASN_Detail AS a2 where a2.wh_id = '335') as t2 ON t1.asn_id = t2.asn_id and t1.wh_id = t2. wh_id
LEFT JOIN (SELECT  * FROM Distribution_Warehouse_Wholesale.t_trailer_asn as a3 WHERE a3.Wh_id = '335') as t3 ON t1.asn_id = t3.AsnId and t1.wh_id= t3.Wh_id
LEFT JOIN (SELECT a4.trailer_id, a4.carrier_id, a4.equipment_id, a4.wh_id, a4.entered_yard,a4.status, a4.location_id FROM Distribution_Warehouse_Wholesale.Trailer  AS a4
           WHERE a4.Wh_id = '335' and a4.status in ('IN DOOR','IN YARD CHASSIS') Group by a4.trailer_id, a4.carrier_id, a4.equipment_id, a4.wh_id, a4.entered_yard,a4.status,a4.location_id ) as t4
	on t3.TrailerId = t4.trailer_id and t3.Wh_id = t4.wh_id and t3.EquipmentId = t4.equipment_id
LEFT JOIN (SELECT * FROM Distribution_Warehouse_Wholesale.YaLocation as a5 WHERE a5.area_id in ('335')) as t5 on t4.location_id = t5.location_id and t4.wh_id = t5.area_id
WHERE t1.status in ('CHECKED IN')