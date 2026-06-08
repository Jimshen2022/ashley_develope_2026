

-- item consolidation, putaway pallet capacity
select  * from t_stored_item where item_number = 'A3000202'
select  * from t_serial_active where item_number = 'A3000202' order by location_id, serial_number
SELECT *  FROM  t_serial_master where item_number = 'A3000202'
select  * from t_stored_item where location_id  in ('A3015FW5','A3015KU2')
SELECT  *  FROM  t_loc_pallet_capacity where location_id in ('A3015FW5','A3015KU2')
SELECT  *  FROM  t_location where location_id in ('A3015FW5')
SELECT  *  FROM  t_location where location_id in ('A3015FW5')
SELECT  *  FROM  t_class_loca where location_id in ('A3015FW5')
SELECT  *  FROM  t_item_uom where item_number = 'A3000202'
SELECT TOP 10 *  FROM  t_fwd_pick where item_number = 'A3000202' 
SELECT  *  FROM  t_tran_log where item_number = 'A3000202' and start_tran_date >= '2026-06-04' order by start_tran_date desc, start_tran_time desc
SELECT  *  FROM  t_tran_log where employee_id = '80054' and start_tran_date >= '2026-06-04' order by start_tran_date desc, start_tran_time desc
select top 10 * from t_hu_master where hu_id like '%39485305'
select top 10 * from t_hu_detail where hu_id like '%39485305'
select top 10 * from t_hu_master where location_id in ('A3015FW5')
select top 10 * from t_hu_detail where location_id in ('A3015FW5')

-- Grace check sql
SELECT *
FROM t_hu_master hum (NOLOCK)
JOIN t_hu_detail hud (NOLOCK)
    ON hum.wh_id = hud.wh_id
   AND hum.hu_id = hud.hu_id
JOIN t_item_master itm (NOLOCK)
    ON hud.wh_id = itm.wh_id
   AND hud.item_number = itm.item_number
WHERE hum.location_id = 'A3015FW5'
  AND hum.wh_id = '335'
  AND itm.pallet_id = 3
--AND hum.type = 'IV'
