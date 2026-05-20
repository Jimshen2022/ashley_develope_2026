with sn as ( 
SELECT 
    t.wh_id,
    t.lot_number, 
    t.item_number, 
    t.location_id_2,
    MAX(CONVERT(DATETIME, CONVERT(VARCHAR(10), t.start_tran_date, 120) + ' ' + 
        CONVERT(VARCHAR(8), t.start_tran_time, 108))) AS max_DateTime
FROM Distribution_Warehouse_Wholesale.Tranlog AS t
WHERE t.wh_id = '335' 
  AND t.location_id_2 = 'A3018MP1'
GROUP BY t.wh_id, t.lot_number, t.item_number, t.location_id_2
)
SELECT t.serial_number, 
       t.item_number, 
	   t.location_id,
       s.max_DateTime as received_into_loc_datetime
FROM Distribution_Warehouse_Wholesale.t_serial_active AS t 
LEFT JOIN sn AS s ON t.serial_number = s.lot_number 
                 AND t.item_number = s.item_number 
                 AND t.location_id = s.location_id_2
WHERE t.serial_number IS NOT NULL 
    and t.wh_id = '335' 
  AND t.location_id = 'A3018MP1'
ORDER BY  s.max_DateTime desc