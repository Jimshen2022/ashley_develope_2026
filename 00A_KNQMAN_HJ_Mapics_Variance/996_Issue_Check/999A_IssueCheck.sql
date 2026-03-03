SELECT TOP 100 *  FROM INFORMATION_SCHEMA.COLUMNS WHERE COLUMN_NAME LIKE '%class%'
SELECT TOP 100 *  FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME LIKE '%capacity%'
SELECT TOP 100 *  FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME LIKE '%exception%'
SELECT TOP 100 *  FROM INFORMATION_SCHEMA.tables WHERE TABLE_NAME LIKE '%exception%'
select top 10 * from t_stored_item 
select top 1000 start_tran_date + start_tran_time , * from t_tran_log order by cast(start_tran_date + start_tran_time as datetime)   desc
select top 10 * from t_item_master where class_id = 'FLOOR'
select top 10 * from t_pick_detail 
select top 10 * from t_item_allocation_hotload  
select top 10 * from t_location where location_id like 'A3%'
select  *  from t_zone_loca WHERE zone = 'A3CGBULK'

SELECT TOP 1000 
    CAST(CAST(start_tran_date AS DATE) AS DATETIME) + 
    CAST(CAST(start_tran_time AS TIME) AS DATETIME) AS StartDateTime,
    *
FROM t_tran_log
ORDER BY CAST(CAST(start_tran_date AS DATE) AS DATETIME) + 
         CAST(CAST(start_tran_time AS TIME) AS DATETIME) DESC



--- picking by equipment
select cast(t1.start_tran_date as date) as Date, t1.location_id, t1.location_id_2, t1.equipment_zone, t1.tran_type,  
        CASE 
            --WHEN t1.tran_type IN ('151','183','951') THEN 'Unloading'
            --WHEN t1.tran_type IN ('321') THEN 'Loading'
            WHEN t1.tran_type = '363' 
                 AND (t1.location_id_2 LIKE 'VR%' OR t1.location_id_2 LIKE 'VF%')
                 AND t1.hu_id IS NOT NULL THEN 'Picking-SCOOP'
            WHEN t1.tran_type IN ('363','372') THEN 'Picking'
            --WHEN t1.tran_type = '347' THEN 'Piece shipped'
            --WHEN t1.tran_type IN ('252','262') THEN 'Replenishment'
            --WHEN t1.tran_type = '254' AND t1.location_id_2 <> 'RP998XL3' THEN 'Put away'
            --WHEN t1.control_number_2 LIKE 'RS%' AND t1.location_id_2 LIKE 'A%' THEN 'Put away'
            --WHEN t1.control_number_2 LIKE 'RS%' AND t1.location_id_2 LIKE 'DR%' THEN 'Put away'
            --WHEN t1.tran_type = '202' AND t1.control_number_2 LIKE 'CN%' AND t1.location_id_2 LIKE 'A%' THEN 'Unloading'
            --WHEN t1.tran_type = '202' AND t1.control_number_2 LIKE 'UL%' AND t1.location_id_2 LIKE 'A%' THEN 'Put away'
            ELSE 'not_pph_trx'
        END AS pph_type,
        left(t1.location_id_2,2) as equpment_type,
        right(t1.location_id,1) as picked_level,
        sum(t1.tran_qty) as tran_qty
from t_tran_log as t1
where t1.tran_type in ('363','372') 
  and t1.start_tran_date >= '2025-10-01'
group by cast(t1.start_tran_date as date), t1.location_id, t1.location_id_2, t1.equipment_zone, t1.tran_type,  
        CASE 
            --WHEN t1.tran_type IN ('151','183','951') THEN 'Unloading'
            --WHEN t1.tran_type IN ('321') THEN 'Loading'
            WHEN t1.tran_type = '363' 
                 AND (t1.location_id_2 LIKE 'VR%' OR t1.location_id_2 LIKE 'VF%')
                 AND t1.hu_id IS NOT NULL THEN 'Picking-SCOOP'
            WHEN t1.tran_type IN ('363','372') THEN 'Picking'
            --WHEN t1.tran_type = '347' THEN 'Piece shipped'
            --WHEN t1.tran_type IN ('252','262') THEN 'Replenishment'
            --WHEN t1.tran_type = '254' AND t1.location_id_2 <> 'RP998XL3' THEN 'Put away'
            --WHEN t1.control_number_2 LIKE 'RS%' AND t1.location_id_2 LIKE 'A%' THEN 'Put away'
            --WHEN t1.control_number_2 LIKE 'RS%' AND t1.location_id_2 LIKE 'DR%' THEN 'Put away'
            --WHEN t1.tran_type = '202' AND t1.control_number_2 LIKE 'CN%' AND t1.location_id_2 LIKE 'A%' THEN 'Unloading'
            --WHEN t1.tran_type = '202' AND t1.control_number_2 LIKE 'UL%' AND t1.location_id_2 LIKE 'A%' THEN 'Put away'
            ELSE 'not_pph_trx'
        END,
        left(t1.location_id_2,2),
         right(t1.location_id,1)

select tran_type, description, sum(tran_qty)
from t_tran_log
where start_tran_date >= '2026-01-01' and tran_type like '3%'
group by tran_type, description
order by sum(tran_qty) Desc


select *
from t_tran_log
where start_tran_date >= '2026-02-05'  and location_id = 'A3012KX4'


select *
from t_tran_log
where start_tran_date >= '2025-02-05'  and location_id = 'A3012KX4'
order by start_tran_date, start_tran_time

-- pkd, who assinged to pick
SELECT user_assigned, *
FROM t_pick_detail WITH (NOLOCK)
WHERE order_number LIKE '0085888%'
  AND pick_location IN (
        SELECT location_id
        FROM t_zone_loca WITH (NOLOCK)
        WHERE zone = 'A3CGBULK'
      );

-- employee picked 
select *  from t_tran_log where start_tran_date > '2026-02-01' and equipment_zone = 'A3CGBULK' and tran_type like '3%' order by start_tran_date, start_tran_time


--- zone loc check
select  *  from t_zone_loca WHERE zone = 'A3CGBULK' and location_id like '[SD]%' ORDER BY location_id
select  *  from t_zone_loca WHERE zone = 'A3CGNOBULK' and location_id like '[SD]%' and location_id not in (select distinct location_id  from t_zone_loca WHERE zone = 'A3CGBULK' and location_id like '[SD]%' )
select  *  from t_zone_loca WHERE zone = 'A3CGNOBULK' and location_id like '[SD]%' order by location_id
select  *  from t_zone_loca WHERE zone = 'A3CGBULK' and location_id like '[SD]%'and location_id not in (select distinct location_id  from t_zone_loca WHERE zone = 'A3CGNOBULK' and location_id like '[SD]%' ) 
select  *  from t_zone_loca WHERE zone = 'A3CGNOBULK' and location_id like '[SD]%'

-- insert locations into CG BULK zone
select  wh_id, 'A3CGNOBULK' as zone, location_id, '000' as pick_seq
from t_zone_loca WHERE zone = 'A3CGBULK' and location_id like '[SD]%'and location_id not in (select distinct location_id  from t_zone_loca WHERE zone = 'A3CGNOBULK' and location_id like '[SD]%' ) 



-- insert locations into CG NOBULK zone
select  t.wh_id,'A3CGNOBULK' as zone, t.location_id, '000' as pick_seq
from t_location as t
inner join t_zone_loca as z on t.location_id = z.location_id
WHERE t.pick_area != 'UPHOLSTERY' and t.zone != 'A3CGBULK'
group by t.wh_id, t.location_id


-- pick area check --- pallt in upholstery area
select t.item_number, sum(t.actual_qty) as qty, t.location_id, t1.pick_area, i.pick_put_id
from t_stored_item as t 
inner join t_item_master as i on t.item_number = i.item_number
inner join t_location as t1 on t.location_id = t1.location_id
where t1.pick_area = 'UPHOLSTERY' and i.pick_put_id = 'PALLT'
group by t.item_number, t.location_id, t1.pick_area, i.pick_put_id

-- each day floor item issue summary
SELECT 
    t.start_tran_date, 
    COUNT(DISTINCT LEFT(t.control_number_2, 7)) AS trips, 
    COUNT(DISTINCT t.item_number) AS bulk_skus, 
    SUM(t.tran_qty) AS total_qty,  
    SUM(t.tran_qty) / COUNT(DISTINCT LEFT(t.control_number_2, 7)) AS avg_pieces_per_trip, 
    COUNT(DISTINCT t.item_number)/COUNT(DISTINCT LEFT(t.control_number_2, 7)) AS avg_skus_per_trip
FROM t_tran_log t
INNER JOIN t_item_master AS m ON t.item_number = m.item_number
WHERE t.tran_type = '363' 
    AND m.class_id IN ('FLOOR')
GROUP BY t.start_tran_date

-- BULK item issue summary
WITH base_data AS (
    SELECT 
        t.start_tran_date, 
        t.item_number, 
        LEFT(t.control_number_2, 7) AS trips, 
        SUM(t.tran_qty) AS total_qty,
        CASE 
            WHEN SUM(t.tran_qty) >= 0 AND SUM(t.tran_qty) < 4 THEN '0-3 pcs'
            WHEN SUM(t.tran_qty) >= 4 AND SUM(t.tran_qty) < 7 THEN '4-6 pcs'
            WHEN SUM(t.tran_qty) >= 7 AND SUM(t.tran_qty) < 10 THEN '7-9 pcs'
            WHEN SUM(t.tran_qty) >= 10 THEN '10+ pcs'
            ELSE 'Unknown'
        END AS bucket
    FROM t_tran_log t
    INNER JOIN t_item_master AS m ON t.item_number = m.item_number
    WHERE t.tran_type = '363' 
        AND m.class_id IN ('FLOOR')
    GROUP BY t.start_tran_date, t.item_number, LEFT(t.control_number_2, 7)
)
SELECT 
    bucket,
    SUM(total_qty) AS total_qty,
    COUNT(DISTINCT trips) AS trips_count,
    COUNT(DISTINCT item_number) AS SKUs,
    ROUND(SUM(total_qty) * 1.0 / COUNT(DISTINCT trips), 2) AS avg_pieces_per_trip,
    ROUND(COUNT(DISTINCT item_number) * 1.0 / COUNT(DISTINCT trips), 2) AS avg_skus_per_trip
FROM base_data
GROUP BY bucket
ORDER BY 
    CASE bucket
        WHEN '0-3 pcs' THEN 1
        WHEN '4-6 pcs' THEN 2
        WHEN '7-9 pcs' THEN 3
        WHEN '10+ pcs' THEN 4
        ELSE 5
    END



-- 
WITH trip_details AS (
    -- Step 1: CTE出基础数据
    SELECT 
        t.start_tran_date AS date,
        LEFT(t.control_number_2, 7) AS trip,
        t.item_number AS item,
        t.tran_qty AS qty
    FROM t_tran_log t
    INNER JOIN t_item_master AS m ON t.item_number = m.item_number
    WHERE t.tran_type = '363' 
        AND m.class_id IN ('FLOOR')
),
trips_with_qty_gt_3 AS (
    -- Step 2: 找出qty > 3的记录，按trip去重
    SELECT DISTINCT 
        date,
        trip
    FROM trip_details
    WHERE qty > 3
)
-- Step 3: 汇总
SELECT 
    td.date,
    COUNT(DISTINCT td.trip) AS trip_count,
    COUNT(DISTINCT td.item) AS skus_count,
    SUM(td.qty) AS total_qty,
    COUNT(DISTINCT tq.trip) AS trip_count_with_qty_gt_3
FROM trip_details td
LEFT JOIN trips_with_qty_gt_3 tq 
    ON td.date = tq.date AND td.trip = tq.trip
GROUP BY td.date
ORDER BY td.date

--  LOC
select location_id, status, type, capacity_volume from t_location  where location_id like 'A3%' order by location_id



-- ON HAND IN racking
select item_number, sum(actual_qty) as qty, location_id from t_stored_item where location_id like 'A3%' group by item_number, location_id  order by location_id
-- ONHAND IN STAGING
select item_number, sum(actual_qty) as qty, location_id from t_stored_item where location_id like 'RS%' group by item_number, location_id  order by location_id
-- ONHAND IN YARD
select item_number, sum(actual_qty) as qty, location_id from t_stored_item where location_id like 'RS%' group by item_number, location_id  order by location_id



-- trx

select start_tran_date,tran_type,  control_number,control_number_2,  item_number, sum(case when tran_type = '951' then -tran_qty else tran_qty end ) as qty 
from t_tran_log 
where tran_type in ('151','951') and item_number = 'R81234'
group by start_tran_date, tran_type,  control_number,control_number_2,  item_number
order by start_tran_date, item_number

-- trx 347 BY TRIPS

select start_tran_date,tran_type,  control_number,control_number_2,  item_number, sum(case when tran_type = '951' then -tran_qty else tran_qty end ) as qty 
from t_tran_log 
where  tran_type in ('347') and control_number_2 like '%89713%'
group by start_tran_date, tran_type,  control_number,control_number_2,  item_number
order by start_tran_date, item_number


-- stock
select  * from t_stored_item where location_id like 'A3018[DFHKM]%[1]'  order by location_id
select location_id, sum(actual_qty) as qty from t_stored_item where location_id like 'A3018[DFHKM]%[1]' group by location_id  order by location_id
select  avg(actual_qty) as qty from t_stored_item where location_id like 'A3018[DFHKM]%[1]'  
select  * from t_stored_item where location_id like 'A3018[CEFGJL]%[1]'  order by location_id
select  * from t_stored_item where location_id like 'A3018[CEFGJL]%[1]'  order by location_id

-- location, item, cubes
select  sum(t.actual_qty * i.nested_volume)/sum(t.actual_qty) as avg_cft_per_pieces,
sum(t.actual_qty * i.nested_volume)/sum(t.actual_qty)*0.0283168 as avg_cbm_per_pieces
from t_stored_item t
left join t_item_master i on i.item_number = t.item_number 
where location_id like 'A3018[CEFGJL]%[1]'  and t.item_number not like '[RD]%'  AND  t.item_number not like '1000699%'
group by  t.item_number

-- aisle 20
select  item_number, location_id,  sum(t.actual_qty )as actual_qty
from t_stored_item t
where location_id like 'A3020[DFHKM]%[1]' 
--where location_id like 'A3020[CEGJL]%[1]' 
group by item_number, location_id
order by  t.location_id

-- aisle 21
select  item_number, location_id,  sum(t.actual_qty )as actual_qty
from t_stored_item t
--where location_id like 'A3021[DFHKM]%[1]' 
where location_id like 'A3021[CEGJL]%[1]' 
group by item_number, location_id
order by  t.location_id


-- aisle 21
select  item_number, location_id,  sum(t.actual_qty )as actual_qty
from t_stored_item t
where location_id like 'A3021[DFHKM]%[1]' 
--where location_id like 'A3021[CEGJL]%[1]' 
group by item_number, location_id
order by  t.location_id

-- aisle 25
select  item_number, location_id,  sum(t.actual_qty )as actual_qty
from t_stored_item t
where location_id like 'A3025[CEGJL]%[1]' 
group by item_number, location_id
order by  t.location_id

-- aisle 25
select  item_number, location_id,  sum(t.actual_qty )as actual_qty
from t_stored_item t
where location_id like 'A3025[DFHKM]%[1]' 
--where location_id like 'A3021[CEGJL]%[1]' 
group by item_number, location_id
order by  t.location_id

-- location
select location_id, status, type,  capacity_volume  from t_location where location_id like 'A306%' 

-- by sn
select t.tran_type, t.description, t.start_tran_date, t.start_tran_time, t.employee_id, t.control_number_2, t.wh_id, t.location_id, t.item_number, t.tran_qty, t.location_id_2, t.routing_code, t.hu_id,  
from Distribution_Warehouse_Wholesale.TranLog as t  
where  lot_number = '618268701622' 
order by start_tran_date desc, start_tran_time desc

select t.tran_type, t.description, t.start_tran_date, t.start_tran_time, t.employee_id, t.control_number_2, t.wh_id, t.location_id, t.item_number, t.tran_qty, t.location_id_2, t.routing_code, t.hu_id
from Distribution_Warehouse_Wholesale.TranLog as t  
where  lot_number = '618268701624' 
order by start_tran_date desc, start_tran_time desc

-- by sn
select *  from Distribution_Warehouse_Wholesale.TranLog  where  lot_number = '503951145940' order by start_tran_date desc, start_tran_time desc
select *  from Distribution_Warehouse_Wholesale.TranLog  where  lot_number = '618268701624' order by start_tran_date desc, start_tran_time desc
select *  from Distribution_Warehouse_Wholesale.TranLog where wh_id = '335' and item_number = 'A2000629' AND lot_number like '606%28' 
select *  from Distribution_Warehouse_Wholesale.TranLog where wh_id = '335' and item_number = 'A2000629' AND lot_number like '606%28' 
select *  from t_tran_log  where lot_number = '803952452209' order by start_tran_date desc, start_tran_time desc
select *  from t_tran_log  where lot_number = '503952452433' order by start_tran_date desc, start_tran_time desc
select *  from t_tran_log  where lot_number = '503951145940' order by start_tran_date desc, start_tran_time desc

-- by serial number status
select  *  from t_serial_active  where serial_number = '688806115244' 
select  *  from t_serial_active  where serial_no_status not in ('O','S') AND  item_number = 'L204194' 
select  *  from t_serial_active  where serial_no_status  in ('O','S') AND  item_number = 'L204194' 
select  *  from t_serial_active  where item_number = 'L204194' and serial_no_status = 'O' and location_id is null

select top 10 *  from t_item_master  where item_number = 'L204194' 
select top 10 *  from t_hu_master  where serial_number = '803952452444' 
select top 10 *  from t_hu_detail  where serial_number = '803952452444' 


select *  from t_tran_log  where lot_number = '688806115244' order by start_tran_date desc, start_tran_time desc
select *  from t_active_serial  where lot_number = '688806115244' order by start_tran_date desc, start_tran_time desc



-- by item receiving by LP
SELECT t1.start_tran_date,t1.start_tran_time,t1.item_number,t1.control_number, t1.control_number_2, t1.employee_id,t1.hu_id,t1.location_id, t1.location_id_2,
    sum (CASE when  t1.tran_type = '151' then t1.tran_qty else 0 end) as tran_151_qty,
    sum (CASE when  t1.tran_type = '951' then -t1.tran_qty else 0 end) as tran_951_qty,
    sum (CASE when  t1.tran_type = '151' then t1.tran_qty else 0 end) +  sum (CASE when  t1.tran_type = '951' then -t1.tran_qty else 0 end) as total_received_qty
from t_tran_log as t1
WHERE t1.wh_id = '335'
	AND t1.tran_type in ('151','951')
    AND t1.item_number IN ('L204194')
	--AND t1.control_number_2 IN ('P2RNP16','P2RNS50','P2RRC24','P2RMR77','P2RMQ29')
    AND t1.start_tran_date >= '2025-12-28'
GROUP by  t1.start_tran_date,t1.start_tran_time,t1.item_number,t1.control_number,  t1.control_number_2, t1.employee_id, t1.hu_id,t1.location_id, t1.location_id_2
order by t1.start_tran_date,  t1.start_tran_time, t1.control_number

-- by item receiving by PO
SELECT t1.start_tran_date,t1.item_number,t1.control_number, t1.control_number_2, 
    sum (CASE when  t1.tran_type = '151' then t1.tran_qty else 0 end) as tran_151_qty,
    sum (CASE when  t1.tran_type = '951' then -t1.tran_qty else 0 end) as tran_951_qty,
    sum (CASE when  t1.tran_type = '151' then t1.tran_qty else 0 end) +  sum (CASE when  t1.tran_type = '951' then -t1.tran_qty else 0 end) as total_received_qty
from t_tran_log as t1
WHERE t1.wh_id = '335'
	AND t1.tran_type in ('151','951')
    --AND t1.item_number IN ('L204194')
	AND t1.control_number_2 IN ('P2S6P97')
    AND t1.start_tran_date >= '2025-01-01'
GROUP by  t1.start_tran_date,t1.item_number,t1.control_number,  t1.control_number_2
order by t1.start_tran_date,  t1.control_number_2

-- by item inbound 
SELECT t1.start_tran_date,t1.item_number,t1.control_number,t1.control_number_2, t1.tran_type, t1.lot_number, sum(t1.tran_qty) as tran_qty
from t_tran_log as t1
WHERE t1.wh_id = '335'
	AND t1.tran_type in ('165','851','855')
    AND t1.item_number IN ('L204194')
	AND t1.control_number_2 IN ('P2RNT74','P2RSC61','P2RSC85','P2RSD96')
    AND t1.start_tran_date >= '2025-12-28'
GROUP by  t1.start_tran_date,t1.item_number,t1.control_number, t1.control_number_2,t1.tran_type, t1.lot_number
order by t1.item_number, t1.start_tran_date


select * from t_tran_log where item_number = 'L329104' and control_number = '688806136469' order by start_tran_date, start_tran_time
select * from t_tran_log where item_number = 'L329104' and control_number = 'P2RFJ51' order by start_tran_date, start_tran_time
select * from t_stored_item where item_number = 'L329104'
select * from t_serial_active where item_number = 'L329104' and location_id = 'EX001AA1'



-- pallet capacity
select  * from t_loc_pallet_capacity where location_id in ('A3020GC1','A3020GL','A3020GN1') 
select  * from t_class_loca where location_id in ('A3020GC1','A3020GL','A3020GN1') 


	Update
	t_class_loca
	SET capacity_volume = 400000
	WHERE PATINDEX('A3021[CEGJLNQSUXZ]%', location_id) > 0;
	
	
	
	Update
	t_class_loca
	SET capacity_volume = 500000
	WHERE PATINDEX('A3021[DFHKMPRTWY]%', location_id) > 0;
	
	Update
	t_class_loca
	SET fill_seq = '001' 
	Where location_id LIKE 'A3021[CDEF]%'
	
	
	Delete
	t_class_loca
	WHERE location_id like 'A3021%' AND class_id NOT LIKE '%M%'
	
	
	Delete
	t_class_loca
	WHERE location_id like 'A3018[G][ABCDEFGH]%1' and class_id = 'UPHMH'
	
	Delete
	t_class_loca
WHERE location_id like 'A3018[G][ABCDEFGH]%1' and class_id = 'UPHMH'


t_loc_pallet_capacity
WHERE pallet_id = 16 AND PATINDEX('A3011[' + 'CEGJLNQSUXZ' + ']%', location_id) > 0



delete
where location_id like 'A3021%' and substring(location_id,6,1) in  ('C','E','G','J','L') and class_id in ('UPHH','UPHL','UPHOT','UPHXH','UPHCH')
('335','UPHL','A3021LP3','005','400000'),
('335','UPHOT','A3021LP3','001','400000'),
('335','UPHL','A3021LP4','005','400000'),
('335','UPHOT','A3021LP4','001','400000');


-- container and po 
select  * from t_tran_log where control_number in ('HLXU651205','FFAU3648068') and start_tran_date >= '2026-01-01' and item_number in ('T743-6') order by start_tran_date, start_tran_time
select  * from t_tran_log where control_number_2 in  ('P2RJP89','P2RKC60') and start_tran_date >= '2026-01-01' and item_number in ('T743-6')  order by start_tran_date, start_tran_time
select  * from t_tran_log where control_number_2 in  ('P2RJP89','P2RKC60') and start_tran_date >= '2026-01-01' order by start_tran_date, start_tran_time


-- exception
SELECT TOP 100 *  FROM t_exception_log where item_number = 'A'


select top 10 * from t_item_master where item_number= '1067034'

-- loaded cubes for trip# 
select  t.order_number, t.status, t.item_number,t.loaded_quantity, i.unit_volume, nested_volume, t.loaded_quantity *i.nested_volume as cubes, i.length, i.width, i.height
from t_pick_detail as t
join t_item_master as i on t.item_number = i.item_number
where t.order_number like '%74812%' and t.picked_quantity>0
order by t.item_number

-- back order
select  * from t_tran_log where tran_type = '340' and control_number_2 like '%74812%'


SELECT top 10 * FROM t_tran_log where tran_type = '347' and routing_code LIKE 'BMOU649055%'
SELECT  tran_type,description, sum(tran_qty) as qty FROM t_tran_log group by tran_type, description order by tran_type 

SELECT * FROM t_location where location_id like 'A3020D[A-H]1'
SELECT * FROM t_class_loca where location_id like 'A3020D[A-H]1'
SELECT * FROM t_class_loca where location_id like 'A3020D[A-H]1'

select top 100 *  FROM t_tran_log  order by start_tran_date desc, start_tran_time desc
select top 10 *  FROM t_tran_log  WHERE tran_type in ('151') and item_number like 'R%'  and start_tran_date > '2025-12-01' order by start_tran_date, start_tran_time



select top 10 *  FROM t_capacity_by_hour 
select *  FROM t_tran_log  WHERE lot_number = '503952343763' order by start_tran_date, start_tran_time
select top 1000 *  FROM t_tran_log  WHERE lot_number = '503952261116' order by start_tran_date, start_tran_time


select top 10 *  FROM t_asn


select top 10 *  FROM Distribution_Warehouse_Wholesale.t_serial_active AS t1 WHERE t1.wh_id IN ('335') AND t1.serial_no_status NOT IN ('O') AND t1.master_status NOT IN ('S')
select top 10 *  FROM Distribution_Warehouse_Wholesale.t_serial_active AS t1 WHERE t1.po_number = '8247931'

select top 10 * from t_item_uom where item_number like '1000646%' 
select top 10 * from t_item_master where item_number like '1000646%' 
select top 10 * from t_stored_item
select top 10 * from t_location where location_id like 'M3%' AND type = 'I'

with sto AS (select location_id, sum(actual_qty) as loc_qty, count(distinct item_number) as distinct_item_count
			 from t_stored_item where wh_id = '35'
			 group by location_id, item_number)

select t1.wh_id, t1.location_id, ISNULL(t2.loc_qty,0) as loc_qty, ISNULL(t2.distinct_item_count,0) as distinct_item_count 
from t_location as t1 
LEFT JOIN (select location_id, sum(actual_qty) as loc_qty, count(distinct item_number) as distinct_item_count
			 from t_stored_item where wh_id = '35'
			 group by location_id, item_number) AS t2 ON t1.location_id = t2.location_id
where t1.location_id like 'M3%' AND type = 'I'

-- by item
SELECT t1.start_tran_date,t1.item_number,t1.control_number_2, t1.tran_type, t1.lot_number, sum(t1.tran_qty) as tran_qty
from t_tran_log as t1
WHERE t1.wh_id = '335'
	AND t1.tran_type in ('165','851','855')
    AND t1.item_number IN ('L317044')
    AND t1.start_tran_date >= '2025-12-14'
GROUP by  t1.start_tran_date,t1.item_number,t1.control_number_2,t1.tran_type, t1.lot_number
order by t1.item_number, t1.start_tran_date

-- by sn
SELECT tran_type,description,start_tran_date,start_tran_time,employee_id,control_number,control_number_2,wh_id,location_id,hu_id,item_number,lot_number,tran_qty,location_id_2,employee_id_2,
sn_coo,process,equipment_zone
from t_tran_log as t1
WHERE t1.wh_id = '335'
    AND t1.lot_number IN ('547720003921')
    AND t1.start_tran_date >= '2025-12-14'
order by t1.item_number, t1.start_tran_date, t1.start_tran_time



-- check transactions
SELECT tran_type,description,start_tran_date,start_tran_time,employee_id,control_number,control_number_2,wh_id,location_id,hu_id,item_number,lot_number,tran_qty,location_id_2,employee_id_2,
sn_coo,process,equipment_zone
from t_tran_log as t1
WHERE t1.wh_id = '335'
	AND t1.tran_type in ('151','951')
-- 	AND t1.control_number_2 like '0039312%'
    AND t1.item_number IN ('833500825192')
    AND t1.start_tran_date >= '2025-11-30'
order by t1.item_number, t1.start_tran_date


-- RP received by PO
SELECT t1.start_tran_date,t1.start_tran_time, t1.item_number,t1.control_number_2, sum(t1.tran_qty) as tran_qty
from t_tran_log as t1
WHERE t1.wh_id = '335'
	AND t1.tran_type in ('151','347')
 	AND t1.control_number_2 in ('P2R7Q66','P2R8L70')
   -- AND t1.item_number IN ('B814-58')
    AND t1.start_tran_date >= '2025-11-01'
GROUP by  t1.start_tran_date,t1.item_number,t1.control_number_2, t1.start_tran_time
order by t1.item_number, t1.start_tran_date, t1.start_tran_time


--- yard trailer log
SELECT *  FROM t_ya_tran_log 
where carrier_trailer_number = '50E-545.10'
order by started,ended

-- item summary received
SELECT *
FROM t_tran_log AS t3                   -- From the TranLog table
WHERE
    --t3.wh_id = '335'                                         -- Filter for warehouse ID 335
	--AND t3.item_number = 'A8010281'
    t3.lot_number in ('688075534442')
order by t3.lot_number, t3.start_tran_date desc, t3.start_tran_time desc
 --   t3.lot_number in ('698075460913','688075534443','688075534444','688075534442')




select top 10 *
from t_tran_log
where wh_id = '335'
order by start_tran_date desc, start_tran_time desc




-- RP received by PO
SELECT t1.start_tran_date,t1.item_number,t1.control_number_2, sum(t1.tran_qty) as tran_qty
from t_tran_log as t1
WHERE t1.wh_id = '335'
	AND t1.tran_type in ('151','951')
 	AND t1.control_number_2 in ('P2QM971')
    --AND t1.item_number IN ('P798-838')
    AND t1.start_tran_date >= '2025-11-16'
GROUP by  t1.start_tran_date,t1.item_number,t1.control_number_2
order by t1.item_number, t1.start_tran_date

-- RP received by item and sn
SELECT t1.start_tran_date,t1.item_number,t1.control_number_2, sum(t1.tran_qty) as tran_qty
from t_tran_log as t1
WHERE t1.wh_id = '335'
	AND t1.tran_type in ('151','951')
 	--AND t1.control_number_2 in ('P2QSP73','P2QTZ51','P2QQ739')
    AND t1.item_number IN ('5020577')
    AND t1.start_tran_date >= '2025-11-16'
GROUP by  t1.start_tran_date,t1.item_number,t1.control_number_2
order by t1.item_number, t1.start_tran_date


-- RP received by item and sn
SELECT t1.start_tran_date,t1.item_number,t1.control_number_2, sum(t1.tran_qty) as tran_qty
from t_tran_log as t1
WHERE t1.wh_id = '335'
	AND t1.tran_type in ('151','951')
 	AND t1.control_number_2 in ('P2QSP73','P2QTZ51','P2QQ739','P2QSW23')
    --AND t1.item_number IN ('D631-01')
    AND t1.start_tran_date >= '2025-11-16'
GROUP by  t1.start_tran_date,t1.item_number,t1.control_number_2
order by t1.item_number, t1.start_tran_date



-- RP received by item and sn
SELECT t1.start_tran_date,t1.item_number,t1.control_number_2, sum(t1.tran_qty) as tran_qty
from t_tran_log as t1
WHERE t1.wh_id = '335'
	AND t1.tran_type in ('151','951')
 	AND t1.control_number_2 in ('P2QSP73','P2QTZ51','P2QQ739')
    --AND t1.item_number IN ('D631-01')
    AND t1.start_tran_date >= '2025-11-16'
GROUP by  t1.start_tran_date,t1.item_number,t1.control_number_2
order by t1.item_number, t1.start_tran_date


-- RP received by item and sn
SELECT t1.start_tran_date,t1.item_number,t1.control_number_2, sum(t1.tran_qty) as tran_qty
from t_tran_log as t1
WHERE t1.wh_id = '335'
	AND t1.tran_type in ('151','951')
-- 	AND t1.control_number_2 like '0039312%'
    AND t1.item_number IN ('B633-36')
    AND t1.start_tran_date >= '2025-11-16'
GROUP by  t1.start_tran_date,t1.item_number,t1.control_number_2
order by t1.item_number, t1.start_tran_date


-- RP received by item and sn
SELECT t1.start_tran_date,t1.item_number,t1.control_number_2, sum(t1.tran_qty) as tran_qty
from t_tran_log as t1
WHERE t1.wh_id = '335'
	AND t1.tran_type in ('347')
-- 	AND t1.control_number_2 like '0039312%'
    AND t1.item_number IN ('B633-36')
    AND t1.start_tran_date >= '2025-11-16'
GROUP by  t1.start_tran_date,t1.item_number,t1.control_number_2
order by t1.item_number, t1.start_tran_date

SELECT *
FROM
    t_tran_log AS t3                   -- From the TranLog table
WHERE
    --t3.wh_id = '335'                                         -- Filter for warehouse ID 335
	--AND t3.item_number = 'A8010281'
    t3.lot_number = '606580128579'
order by t3.lot_number, t3.start_tran_date desc, t3.start_tran_time desc


-- RP received by item and sn
SELECT t1.start_tran_date,t1.item_number,t1.control_number_2, sum(t1.tran_qty) as tran_qty
from t_tran_log as t1
WHERE t1.wh_id = '335'
	AND t1.tran_type in ('347')
-- 	AND t1.control_number_2 like '0039312%'
    AND t1.item_number IN ('U1070031')
    AND t1.start_tran_date >= '2025-12-10'
GROUP by  t1.start_tran_date,t1.item_number,t1.control_number_2
order by t1.item_number, t1.start_tran_date

-- RP received by item and sn
SELECT t1.start_tran_date,t1.item_number,t1.control_number_2, sum(t1.tran_qty) as tran_qty
from t_tran_log as t1
WHERE t1.wh_id = '335'
	AND t1.tran_type in ('347')
 	AND t1.control_number_2 like '0058662-%'
--    AND t1.item_number IN ('U1070031')
    AND t1.start_tran_date >= '2025-12-10'
GROUP by  t1.start_tran_date,t1.item_number,t1.control_number_2
order by t1.item_number, t1.start_tran_date




-- RP received by item and sn
SELECT t1.start_tran_date,t1.item_number,t1.control_number_2, sum(t1.tran_qty) as tran_qty
from t_tran_log as t1
WHERE t1.wh_id = '335'
	AND t1.tran_type in ('151','951')
-- 	AND t1.control_number_2 like '0039312%'
    AND t1.item_number IN ('B974-74')
    AND t1.start_tran_date >= '2025-11-16'
GROUP by  t1.start_tran_date,t1.item_number,t1.control_number_2
order by t1.item_number, t1.start_tran_date




-- RP received by item and sn
SELECT t1.start_tran_date,t1.item_number,t1.control_number_2, sum(t1.tran_qty) as tran_qty
from t_tran_log as t1
WHERE t1.wh_id = '335'
	AND t1.tran_type in ('151','951')
-- 	AND t1.control_number_2 like '0039312%'
    AND t1.item_number IN ('D631-01')
    AND t1.start_tran_date >= '2025-11-16'
GROUP by  t1.start_tran_date,t1.item_number,t1.control_number_2
order by t1.item_number, t1.start_tran_date

-- item summary received

SELECT *
FROM
    t_tran_log AS t3                   -- From the TranLog table
WHERE
    --t3.wh_id = '335'                                         -- Filter for warehouse ID 335
	--AND t3.item_number = 'A8010281'
    t3.lot_number = '803952074398'
order by t3.lot_number, t3.start_tran_date desc, t3.start_tran_time desc




