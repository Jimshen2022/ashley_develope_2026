-- if AS400 hold, then cannot do direct pick up:
-- a. change t_hu_detail table status = 'A' and inspection_code is null 
-- b. change t_serial_active table serial_no_status = 'R'


select * from t_serial_active where item_number = 'A4000684'  AND po_number = 'P2QT095'
select * from t_serial_master where item_number = 'A4000684'  AND po_number = 'P2QT095'
SELECT TOP 1000 *  FROM t_hu_detail WHERE item_number = 'A4000684'
select * from t_serial_active (nolock) where 1=1 and item_number = 'A4000684' and location_id = 'RS040AA1' 
select * from t_serial_active (nolock) where 1=1 and item_number = 'A4000684'  and hu_id = '00000036678374'
select * from t_serial_active where serial_no_status = 'R' and item_number = 'A4000684'  AND location_id = 'A3019EH1'



update t_serial_active 
set serial_no_status = 'R'
where item_number = 'A4000684' and status = 'U'
hu_id = '00000036678374' ,'00000036678373'
