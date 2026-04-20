select top 1000 *  from t_exception_tran_log  where exception_date > '2025-11-02' and item_number = '1850743'
select * from t_serial_active  as t where t.item_number = '1850743'	and t.serial_no_status not in ('S','O') order by t.received_date desc
select * from t_item_master where item_number = '1850743'
select top 10 *  from t_item_master 
select top 10 *  from t_location where location_id like 'A3012%'
select top 10 * from t_loc_pallet_capacity where location_id like 'A3021%'
SELECT top 10 * FROM t_location  WHERE location_id like 'A3%'
SELECT * FROM t_class_loca t where t.location_id LIKE 'A3019[CEGJLNQSUWY]%[234]'  
SELECT * FROM t_class_loca t where t.location_id LIKE 'A3019[DFHKMPRTVXZ]%[234]'  

-- update location format

SELECT t.wh_id, t.location_id, c.class_id, c.fill_seq, c.capacity_volume, t.type, p.pallet_id,  p.capacity
FROM t_location t 
LEFT JOIN t_class_loca c ON t.location_id = c.location_id
LEFT JOIN t_loc_pallet_capacity p ON t.location_id = p.location_id 
WHERE t.location_id LIKE 'A3022[DFHKMPRTVXZ]%' and t.pick_area like 'U%' AND class_id like '%HM%'
order by t.location_id


SELECT t.wh_id, t.location_id, c.class_id, c.fill_seq, c.capacity_volume, t.type, p.pallet_id,  p.capacity
FROM t_location t 
LEFT JOIN t_class_loca c ON t.location_id = c.location_id
LEFT JOIN t_loc_pallet_capacity p ON t.location_id = p.location_id 
WHERE t.location_id LIKE 'A3022[CD][A]%[1234]' and t.pick_area like 'U%'
order by t.location_id

SELECT 
    t.wh_id, 
    t.location_id,
    STRING_AGG(CAST(c.class_id AS NVARCHAR(MAX)), ', ') AS class_ids,
    STRING_AGG(CAST(c.fill_seq AS NVARCHAR(MAX)), ', ') AS fill_seqs,
    STRING_AGG(CAST(c.capacity_volume AS NVARCHAR(MAX)), ', ') AS capacity_volumes,
    STRING_AGG(CAST(t.type AS NVARCHAR(MAX)), ', ') AS types,
    STRING_AGG(CAST(p.pallet_id AS NVARCHAR(MAX)), ', ') AS pallet_ids,
    STRING_AGG(CAST(p.capacity AS NVARCHAR(MAX)), ', ') AS capacities
FROM t_location t 
LEFT JOIN t_class_loca c ON t.location_id = c.location_id
LEFT JOIN t_loc_pallet_capacity p ON t.location_id = p.location_id 
WHERE t.location_id LIKE 'A3015J[N-Z][5]' OR  t.location_id LIKE 'A3015[LN]%[5]' OR t.location_id LIKE 'A3015Q[A-W][5]'
GROUP BY t.wh_id, t.location_id
ORDER BY t.location_id









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



	