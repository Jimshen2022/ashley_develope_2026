
-- location creation dynamic
select * from t_eil_xml_msg
select top 10 * from t_rei_master
select * from t_location where location_id like 'A3025[DF][A-Z]2%'

-- yard door location
select * from t_ya_location where type = 'DOOR'
select * from t_ya_zone
select * from t_ya_zone_loca

-- step1: add location
select '335' as area_id, location_id as location_name, location_id  as description, 'DOOR' as type, 'EMPTY' as status from t_location where location_id like '[D]%' and type ='D' and location_id not in (select location_name from t_ya_location)

-- step2： add zone
select location_name as zone_name, location_name as description,  'N' as container_flag, '335' as area_id from t_ya_location where type ='DOOR' and location_name not in (select zone_name from t_ya_zone)

-- step3: add zone loca
SELECT '1' as zone_id, location_id, '335' as area_id
FROM t_ya_zone_loca AS t0
WHERE NOT EXISTS (
    SELECT 1
    FROM t_ya_zone_loca t1
    WHERE t1.zone_id = 1
      AND t1.location_id = t0.location_id
)
AND t0.location_id IN (
    SELECT location_id
    FROM t_ya_location
    WHERE type = 'DOOR'
)


-- add same zone into location id
SELECT
    z.zone_id,z.zone_name,
    l.location_id,l.location_name,
    l.area_id
FROM t_ya_location AS l
INNER JOIN t_ya_zone AS z ON z.zone_name = l.location_name
WHERE l.location_name LIKE 'D%'
  AND z.zone_name LIKE 'D%'
  AND l.location_id NOT IN (
    SELECT zl.location_id
    FROM t_ya_zone_loca AS zl
    WHERE zl.zone_id = z.zone_id
)

SELECT DISTINCT zl2.location_id as zone_id, zl.location_id,'335' as area_id
FROM t_ya_zone_loca zl INNER JOIN t_ya_location l ON l.location_id = zl.location_id WHERE NOT EXISTS (SELECT 1
FROM t_ya_zone_loca zl2 INNER JOIN t_ya_zone z ON z.zone_id = zl2.zone_id WHERE zl2.location_id = zl.location_id AND l.location_name = z.zone_name)


SELECT l.location_id
FROM t_ya_location l
WHERE l.type = 'DOOR'
  AND NOT EXISTS (
    SELECT 1
    FROM t_ya_zone_loca zl
    WHERE zl.location_id = l.location_id
      AND zl.zone_id = 1
)



SELECT DISTINCT zl.location_id,
       l.location_name
FROM t_ya_zone_loca zl
INNER JOIN t_ya_location l ON l.location_id = zl.location_id
WHERE NOT EXISTS (
    SELECT 1
    FROM t_ya_zone_loca zl2
    INNER JOIN t_ya_zone z ON z.zone_id = zl2.zone_id
    WHERE zl2.location_id = zl.location_id
      AND l.location_name = z.zone_name
)

-- location barcode query
select location_id, location_barcode, building, type, status
from t_location


SELECT top 10 * FROM t_class_loca
select top 10 *  from t_location 
select top 1000 *  from t_exception_tran_log  where exception_date > '2025-11-02' and item_number = '1850743'
select * from t_serial_active  as t where t.item_number = '1850743'	and t.serial_no_status not in ('S','O') order by t.received_date desc
select * from t_item_master where item_number = '1850743'
select top 10 *  from t_item_master 
select top 10 *  from t_location where location_id like 'A3012%'
select top 10 * from t_loc_pallet_capacity where location_id like 'A3021%'
SELECT top 10 * FROM t_location  WHERE location_id like 'A3%'

SELECT * FROM t_class_loca t where t.location_id LIKE 'A3019[CEGJLNQSUWY]%[234]'  
SELECT * FROM t_class_loca t where t.location_id LIKE 'A3019[DFHKMPRTVXZ]%[234]'  

-- Check capacity volume
SELECT * FROM t_class_loca t where t.location_id LIKE 'A302[12345][DFHKMPRTVXZ]%[1234]' and class_id like 'UPH%' and capacity_volume is null


-- update location class capacity volume
SELECT * FROM t_class_loca where location_id LIKE 'A3021[CEGJLNQSUWY]%[1234]'  

SELECT * FROM t_class_loca where location_id LIKE 'A3020[G][WXYZ][1]%'  OR location_id LIKE 'A3020[J][AB][1]%' 
SELECT * FROM t_loc_pallet_capacity where location_id LIKE 'A3020[G][WXYZ][1]%'  OR location_id LIKE 'A3020[J][AB][1]%' 
SELECT * FROM t_location where location_id LIKE 'A3020[G][WXYZ][1]%'  OR location_id LIKE 'A3020[J][AB][1]%' 


INSERT INTO your_table_name
(col1, item_code, location_id, col4, col5)
VALUES
('335','PAL5H','A3020GW1','001','0'),
('335','PAL3H','A3020GW1','001','0'),
('335','RAILS','A3020GW1','001','0'),
('335','MATT','A3020GW1','001','0'),
('335','RUGS','A3020GW1','001','0'),
('335','RUGSS','A3020GW1','001','0'),
('335','PAL5H','A3020GX1','001','0'),
('335','PAL3H','A3020GX1','001','0'),
('335','RAILS','A3020GX1','001','0'),
('335','MATT','A3020GX1','001','0'),
('335','PAL5H','A3020GY1','001','0'),
('335','PAL3H','A3020GY1','001','0'),
('335','RAILS','A3020GY1','001','0'),
('335','MATT','A3020GY1','001','0'),
('335','PAL5H','A3020GZ1','001','0'),
('335','PAL3H','A3020GZ1','001','0'),
('335','RAILS','A3020GZ1','001','0'),
('335','MATT','A3020GZ1','001','0'),
('335','PAL5H','A3020JA1','001','0'),
('335','PAL3H','A3020JA1','001','0'),
('335','RAILS','A3020JA1','001','0'),
('335','MATT','A3020JA1','001','0'),
('335','PAL5H','A3020JB1','001','0'),
('335','PAL3H','A3020JB1','001','0'),
('335','RAILS','A3020JB1','001','0'),
('335','MATT','A3020JB1','001','0');




VALUES
('335','A3020GW1',1,10),
('335','A3020GW1',3,10),
('335','A3020GW1',5,10),
('335','A3020GW1',4,10),
('335','A3020GW1',18,10),
('335','A3020GW1',16,9999),
('335','A3020GX1',1,10),
('335','A3020GX1',3,10),
('335','A3020GX1',5,10),
('335','A3020GX1',4,10),
('335','A3020GX1',18,10),
('335','A3020GX1',16,9999),
('335','A3020GY1',1,10),
('335','A3020GY1',3,10),
('335','A3020GY1',5,10),
('335','A3020GY1',4,10),
('335','A3020GY1',18,10),
('335','A3020GY1',16,9999),
('335','A3020GZ1',1,10),
('335','A3020GZ1',3,10),
('335','A3020GZ1',5,10),
('335','A3020GZ1',4,10),
('335','A3020GZ1',18,10),
('335','A3020GZ1',16,9999),
('335','A3020JA1',1,10),
('335','A3020JA1',3,10),
('335','A3020JA1',5,10),
('335','A3020JA1',4,10),
('335','A3020JA1',18,10),
('335','A3020JA1',16,9999),
('335','A3020JB1',1,10),
('335','A3020JB1',3,10),
('335','A3020JB1',5,10),
('335','A3020JB1',4,10),
('335','A3020JB1',18,10),
('335','A3020JB1',16,9999);



select top 10 * from t_loc_pallet_capacity where location_id like 'A3020[G]%[1]'  


SELECT * FROM t_class_loca t where t.location_id LIKE 'A3021[DFHKMPRTVXZ]%[1234]' 

UPDATE t_class_loca
set capacity_volume = 400000
where location_id LIKE 'A3021[CEGJLNQSUWY]%[1234]'  

UPDATE t_class_loca
set capacity_volume = 400000
where location_id LIKE  'A3025[CEGJLNQSUWY]%[1234]'  and class_id like 'UPH%'

-- update location format

SELECT t.wh_id, t.location_id, c.class_id, c.fill_seq, c.capacity_volume, t.type, p.pallet_id,  p.capacity
FROM t_location t 
JOIN t_class_loca c ON t.location_id = c.location_id
Join t_loc_pallet_capacity p ON t.location_id = p.location_id 
WHERE t.location_id LIKE 'A3015[CEGJLNQSUWY]%' and c.class_id = 'PAL3H'
order by t.location_id

select *
from t_class_loca t
where  t.class_id = 'UPH'













-- update location capacity volumn
SELECT * FROM t_class_loca t WHERE t.location_id LIKE 'A3020[DFHKM]%[234]'  
SELECT * FROM t_class_loca t WHERE t.location_id LIKE 'A3020[CEGJL]%[1234]'  
SELECT * FROM t_class_loca t WHERE t.location_id LIKE 'A3019%[1]'  
SELECT * FROM t_class_loca t where t.location_id LIKE 'A3019[CEGJLNQSUWY]%[234]'  
SELECT * FROM t_class_loca t where t.location_id LIKE 'A3019[DFHKMPRTVXZ]%[234]'  
SELECT * FROM t_class_loca t where t.location_id LIKE 'A3019%[234]'  AND t.fill_seq IS NULL

--Talked with Kim:  updated as tunnel to receiving dock use 5x7,  tunnel to Shipping dock use 3.5x7
SELECT t.wh_id, t.location_id, c.class_id, c.fill_seq, c.capacity_volume, t.type
FROM t_location t 
JOIN t_class_loca c ON t.location_id = c.location_id
WHERE t.location_id LIKE 'A3015[LNQSUWY]%' 
order by t.location_id

-- check 3.5ft
SELECT t.wh_id, t.location_id, c.class_id, c.fill_seq, c.capacity_volume, t.type, p.pallet_id,  p.capacity
FROM t_location t 
JOIN t_class_loca c ON t.location_id = c.location_id
Join t_loc_pallet_capacity p ON t.location_id = p.location_id 
WHERE t.location_id LIKE 'A3015[LNQSUWY]%' 
order by t.location_id

SELECT t.wh_id, t.location_id, c.class_id, c.fill_seq, c.capacity_volume, t.type, p.pallet_id,  p.capacity
FROM t_location t 
JOIN t_class_loca c ON t.location_id = c.location_id
Join t_loc_pallet_capacity p ON t.location_id = p.location_id 
WHERE t.location_id LIKE 'A3015J[PQRSTUVWXYZ]%' 
order by t.location_id


--A3015JG1-JN1 Tunnel is 
SELECT t.*, L.type
FROM t_class_loca t 
JOIN t_location L ON t.location_id = L.location_id
WHERE t.location_id LIKE 'A3015J[ABCDEF]%'
order by t.location_id


-- pallet capacity
SELECT t.*
FROM t_loc_pallet_capacity t 
WHERE t.location_id LIKE 'A3015[CEG]%'


--where location_id LIKE 'A3019[CEGJLNQSUWY]%[234]'   and capacity_volume is null

SELECT t.*, L.type, L.pick_area FROM t_class_loca t
JOIN t_location L ON t.location_id = L.location_id
 WHERE t.location_id LIKE 'A3%' and L.pick_area like 'UP%'



-- check putaway class UPHHV on A3% locations
SELECT * FROM t_class_loca  t
JOIN t_location L ON t.location_id = L.location_id
WHERE L.pick_area LIKE 'UPH%' AND t.class_id ='UPHHV' and t.location_id like 'A3%'

SELECT top 10 * FROM t_location  WHERE location_id like 'A3%' AND class_id ='UPHHV'


-- check putaway class not on current rules list:
SELECT * FROM t_class_loca  
WHERE location_id like 'A3%' 
and class_id NOT in ('MATT','PTEMP','UTEMP','UPHHV','UPHXH','UPHH','UPHL','UPHOT','UPHCH','UPHMHV','UPHMH','UPHML','UPHMLL','UPHMXH','PAL3H','PAL5H','RAILS','SMALL','FLOOR','RUGS','RUGSS')


select	* from t_loc_pallet_capacity as a  where a.location_id like 'A3021%' and not exists (select 1 from t_location t where t.location_id like 'A3021%' and t.location_id = a.location_id)  





WHERE location_id like 'A3%' AND class_id ='UPHHV'


SELECT * FROM t_class_loca t WHERE t.capacity_volume is null and t.location_id like 'A3018%[234]'
SELECT * FROM t_class_loca t WHERE t.fill_seq is null and t.location_id like 'A3018%'

SELECT * FROM t_class_loca  WHERE location_id like 'A3025[CG]%1'



  SELECT *
FROM t_location t
WHERE t.location_id LIKE 'A3%18%'
  AND NOT EXISTS (
        SELECT 1
        FROM t_class_loca x
        WHERE x.location_id = t.location_id
          AND x.class_id IN ('PTEMP', 'UTEMP')
  );


select  * from t_class_loca where class_id in ('UTEMP')


SELECT * FROM t_class_loca WHERE SUBSTRING(location_id, 6, 1) LIKE '[CEGJLNQSUXZ]';  -- locations with class letters in 6th position
SELECT * FROM t_class_loca WHERE PATINDEX('A3021[CEGJLNQSUXZ]%', location_id) > 0;   -- locations starting with A3021 and class letters
 
SELECT * FROM t_class_loca WHERE PATINDEX('%[CEGJLNQSUXZ]%', location_id) > 0;  -- locations with class letters
SELECT * FROM t_class_loca  WHERE location_id like 'A3021%' AND class_id NOT LIKE '%M%'
SELECT * FROM t_class_loca  WHERE location_id like 'A3021%'

SELECT * FROM t_class_loca WHERE PATINDEX('A3021[CEGJLNQSUXZ]%', location_id) > 0; 
select  *  from t_location where location_id like 'A3021%'

select  *  from t_class_loca  where PATINDEX('A3021[DFHKMPRTWY]%', location_id) > 0; -- locations starting with A3021 

select * from t_class_loca where location_id like 'A3021%' and fill_seq is null order by location_id

select * from t_class_loca where PATINDEX('A3021[CDEFGH]', location_id) > 0; 

select location_id, type  from t_location where  location_id LIKE 'A3021[GH]%'
select * from t_class_loca where location_id like 'A3021%'

select t.item_number,
	im.class_id,
	count(t.serial_number) as qty
from t_serial_active  as t
inner join t_item_master im
	on t.item_number = im.item_number
where 1=1 
	--AND t.item_number = 'R405451'
	and t.serial_no_status not in ('S','O')
	and im.pick_put_id in ('UPH')
group by t.item_number,im.class_id
having count(t.serial_number) >0

select *
from t_tran_log
where item_number = '1850743'
	and start_tran_date between '2025-10-25' and '2025-11-03'
	and tran_type = '347'
group by item_number,
start_tran_date,
	control_number,
	control_number_2



select *
from t_serial_active  as t
where t.item_number = 'R405451'
	and t.serial_no_status not in ('S','O')


select item_number,
    start_tran_date,
	control_number,
	control_number_2,
	sum(tran_qty) as tran_qty
from t_tran_log
where item_number = 'B615-31'
	and start_tran_date between '2025-10-25' and '2025-11-03'
	and tran_type = '347'
group by item_number,
start_tran_date,
	control_number,
	control_number_2



select item_number,
    start_tran_date,
	control_number,
	control_number_2,
	sum(tran_qty) as tran_qty
from t_tran_log
where item_number = 'B615-46'
	and start_tran_date between '2025-10-25' and '2025-11-03'
	and tran_type = '347'
group by item_number,
start_tran_date,
	control_number,
	control_number_2



select item_number,
    start_tran_date,
	control_number,
	control_number_2,
	sum(tran_qty) as tran_qty
from t_tran_log
where item_number = 'B615-81'
	and start_tran_date between '2025-10-25' and '2025-11-03'
	and tran_type = '347'
group by item_number,
start_tran_date,
	control_number,
	control_number_2



select item_number,
    start_tran_date,
	control_number,
	control_number_2,
	sum(tran_qty) as tran_qty
from t_tran_log
where item_number = 'B615-92'
	and start_tran_date between '2025-10-25' and '2025-11-03'
	and tran_type = '347'
group by item_number,
start_tran_date,
	control_number,
	control_number_2




select item_number,
    start_tran_date,
	control_number,
	control_number_2,
	sum(tran_qty) as tran_qty
from t_tran_log
where item_number = 'B615-97'
	and start_tran_date between '2025-10-25' and '2025-11-03'
	and tran_type = '347'
group by item_number,
start_tran_date,
	control_number,
	control_number_2



	