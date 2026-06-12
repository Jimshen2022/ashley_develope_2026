SELECT 
    sto.item_number, sto.actual_qty, sto.status, sto.wh_id, sto.location_id, loc.type, sto.type
FROM t_stored_item sto
JOIN t_location loc ON sto.location_id = loc.location_id
    AND sto.wh_id = loc.wh_id 
JOIN t_item_master itm ON sto.item_number = itm.item_number
    AND sto.wh_id = itm.wh_id  
WHERE sto.wh_id = '335' 
and loc.type  IN ( 'I', 'M', 'P','X','S','D','V','F' ) 
and sto.status='A' 
and sto.location_id NOT IN ('RP998XL1','SH001AA1','NG001VD3','NG001OP3','RP998XL3') 
and sto.item_number ! = 'RP ORDER'
ORDER BY sto.item_number, sto.location_id;