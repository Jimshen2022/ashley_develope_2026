
--SELECT TOP 1000 *  FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME LIKE '%serial%'
--select top 10 * from t_serial_active where wh_id='335'
--select top 10 * from t_serial_active
--select top 10 * from t_serial_master


with sn as (
	SELECT t1.wh_id, t1.serial_number, t1.item_number, t1.serial_no_status,t1.po_number, t1.location_id, t1.received_date, t1.trip_number  
	FROM t_serial_active  AS t1
	WHERE  t1.wh_id  IN ('335') AND  t1.serial_no_status = 'O' 
),
im as (
	select item_number,serial_number, wh_id, serial_no_status
	from t_serial_master
	where wh_id in ('335') and serial_no_status <> 'S'
)
SELECT t1.wh_id, t1.serial_number, t1.item_number, t1.serial_no_status,  im.serial_no_status as master_status, t1.trip_number, t1.po_number, t1.location_id, t1.received_date  
FROM sn t1
inner join im on t1.serial_number = im.serial_number





/*SELECT t1.item_number, t1.location_id, t1.serial_number, t1.serial_no_status, im.serial_no_status as master_status
FROM t_serial_active  AS t1
inner join t_serial_master im on t1.item_number = im.item_number and t1.wh_id = im.wh_id
WHERE  t1.wh_id  IN ('335') AND  t1.serial_no_status NOT IN ('O') and im.serial_no_status NOT IN ('S') */






