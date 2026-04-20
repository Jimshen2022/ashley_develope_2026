---IE STO 
SELECT t1.wh_id, 
    t1.serial_number, 
    t1.item_number, 
    t1.location_id,
    t1.received_date,
    t1.master_status,
    CASE 
        WHEN t1.location_id in ('IE001WN2') THEN 'Sample in WN2'
        WHEN t1.location_id in ('IE001WN3') THEN 'Sample in WN3'
    ELSE 'Wait for IE confirm site' END as Site 
FROM Distribution_Warehouse_Wholesale.t_serial_active AS t1
WHERE t1.wh_id in ('35','31')
    AND t1.serial_no_status IN ('R', 'L','H','O')
	AND t1.location_id IN ('IE001WN2','IE001WN3','IE001AA1')