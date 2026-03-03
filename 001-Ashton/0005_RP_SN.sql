SELECT t1.item_number, t1.location_id, t1.serial_number
FROM Distribution_Warehouse_Wholesale.t_serial_active  AS T1
WHERE  t1.wh_id  IN ('335') AND T1.location_id LIKE 'RP%' AND t1.serial_no_status NOT IN ('O') and t1.master_status NOT IN ('S') 

SELECT  * FROM Distribution_Warehouse_Wholesale.t_serial_active  AS T1 
WHERE T1.item_number IN ('RP ORDER')
    AND T1.po_number IN ('7340536','7340536','7340536','7340536','7340537','7348556','7355123','7355124','7355132','7355132','7355134','7355135','7355135','7355138','7355140','7356450','7356450','7356465','7356465','7356467','7360224','7362665','7362675')
