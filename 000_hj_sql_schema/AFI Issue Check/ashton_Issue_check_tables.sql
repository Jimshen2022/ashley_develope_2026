SELECT TOP 100 *  FROM INFORMATION_SCHEMA.COLUMNS WHERE COLUMN_NAME LIKE '%serial%'
SELECT TOP 100 *  FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME LIKE '%t_order_c_number%' and COLUMN_NAME like '%email%'
SELECT TOP 100 *  FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME LIKE '%customer%'
SELECT TOP 100 *  FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME LIKE '%pal%capacity%'
SELECT TOP 100 *  FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME LIKE '%hu%'

select top 10 * from t_serial_active
select top 10 * from t_stored_item 
select top 10 * from t_item_master 
select top 10 * from t_item_uom 
select top 10 * from t_fwd_pick where item_number = 'U6600014'
select top 10 * from t_item_master where item_number = 'U6600014'
select top 10 * from t_order_detail
select top 10 * from t_order_detail_breakdown
select top 10 * from t_replenishment_task_queue
select top 10 * from t_location
select top 10 * from t_slot_rank
select top 10 * from t_exception_tran_log
select top 10 * from t_order_detail
select top 10 * from t_order_detail_breakdown
select top 10 * from t_replenishment_allocation
select top 10 * from t_work_q
select top 10 * from t_active_serial
select top 10 * from t_hu_master
select top 10 * from t_hu_detail
select top 10 * from t_battery

--ASN related tables
SELECT TOP 10 *  FROM  t_asn
SELECT TOP 10 *  FROM  t_asn_detail
SELECT TOP 10  *  FROM  t_trailer  
SELECT TOP 10 *  FROM  t_trailer_asn 
SELECT TOP 10 *  FROM  t_ya_location 
SELECT TOP 10 *  FROM  t_vendor 
SELECT TOP 10 *  FROM  t_loc_pallet_capacity 
SELECT TOP 10 *  FROM  t_item_uom 
SELECT TOP 10 *  FROM  t_fwd_pick
SELECT TOP 10 *  FROM  t_new_fwd_pick
SELECT TOP 10 *  FROM  t_serial_master
SELECT TOP 10 *  FROM  t_serial_active
 select top 10 * from t_hu_master where hu_id like '%39485305'
select top 10 * from t_hu_detail where hu_id like '%39485305'
SELECT  *  FROM  t_tran_log where employee_id = '80054' and start_tran_date >= '2026-06-04' order by start_tran_date desc, start_tran_time desc

-- uom
select top 10 * from t_item_uom where uom != 'SCOOP' AND pick_put_id = 'SCOOP'

-- check location sto
select top 10 * from t_stored_item where location_id = 'NG001SC3'
select top 10 * from t_serial_active where location_id = 'NG001SC3'
select * from t_tran_log where lot_number = '683811751449' ORDER By start_tran_date desc, start_tran_time desc


select top 10 * from t_stored_item where location_id = 'NG001RA1'
select top 10 * from t_serial_active where location_id = 'NG001RA1'
select * from t_tran_log where lot_number = '683811751449' ORDER By start_tran_date desc, start_tran_time desc




-- ASN hold
select  * from t_asn where asn_id = '1806451'
select top 10 * from t_asn_detail where customer_po_number ='P2WFX17'
select * from t_asn_detail where customer_po_number ='P2WFX17' and item_number = 'B584-81'

-- type X locations
select top 10 * from t_location 
select top 10 * from t_stored_item 

select l.location_id,l.status, l.type, sto.onhand, sto.SKUs
from t_location as l
left join (select location_id, sum(actual_qty) as onhand, count(distinct item_number) as SKUs from t_stored_item group by location_id) as sto on sto.location_id = l.location_id
where  l.type = 'X'

-- sn data error
select top 10 * from t_serial_master where serial_number = '503953786128'
select top 10 * from t_serial_active where serial_number = '503953786128'
select * from t_tran_log where lot_number = '503953786128'


-- cannot picking
select top 10 * from t_location 
select top 10 *  from t_zone_loca
select *  from t_zone

select *  from t_zone_loca where location_id like 'A3020[CEGJL]%1'
AND location_id not IN (select location_id from t_zone_loca where location_id LIKE 'A306%' and zone = 'A3CGBULK')

select *  from t_zone_loca where location_id like 'A306%' AND location_id not IN (select location_id from t_zone_loca where location_id LIKE 'A306%' and zone = 'A3CGBULK')
select *  from t_zone_loca where location_id like 'A3020[CEGJL]%1' AND location_id not IN (select location_id from t_zone_loca where location_id LIKE 'A3020[CEGJL]%1' and zone = 'A3CGBULK')



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


-- tran
select * from t_stored_item where item_number = 'D824-05'
select start_tran_date,item_number, control_number, control_number_2, sum(case when tran_type = '951' then -tran_qty else tran_qty end) as tran_qty 
from t_tran_log
where start_tran_date > '2026-01-01' and tran_type = '151' and item_number = 'D824-05'
group by start_tran_date,item_number, control_number, control_number_2

select start_tran_date,item_number, control_number, control_number_2, sum(case when tran_type = '951' then -tran_qty else tran_qty end) as tran_qty 
from t_tran_log
where start_tran_date > '2026-05-01' and tran_type = '347' and item_number = 'D824-05'
group by start_tran_date,item_number, control_number, control_number_2

select top 10 * from t_stored_item 

select sum(actual_qty) as onhand
from t_stored_item 
where location_id like 'A3019%1'


select item_number, location_id, sum(actual_qty) as onhand
from t_stored_item 
where location_id like 'A3019%1'
group by item_number, location_id

-- select top 100 * from t_tran_log WITH (NOLOCK) where tran_type in ('151','951') order by start_tran_date desc, start_tran_time desc

WITH
-- ① Tally Table
tally AS (
    SELECT TOP 100000
        ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) - 1 AS n
    FROM sys.all_columns a WITH (NOLOCK) 
    CROSS JOIN sys.all_columns b WITH (NOLOCK)
),

-- ② 展开 SN：每个 serial_number 单独一行
sn_expanded AS (
    SELECT
        d.asn_detail_id,
        d.asn_id,
        d.item_number,
        d.lot_number,
        d.line_number,
        d.uom,
        d.customer_po_number,
        d.quantity_shipped,
        d.quantity_received,
        d.born_on_date,
        d.carb_compliance_level,
        d.sn_coo,
        d.transfer_number,
        CAST(d.serial_number_start AS BIGINT) + t.n AS serial_number
    FROM t_asn_detail d WITH (NOLOCK)
    JOIN tally t
        ON t.n <= CAST(d.serial_number_end AS BIGINT)
                - CAST(d.serial_number_start AS BIGINT)
    WHERE d.asn_id IN (
        SELECT asn_id FROM t_asn WITH (NOLOCK) 
        WHERE expected_arrival >= DATEADD(DAY, -7, CAST(GETDATE() AS DATE))
        --WHERE vendor_id IN ('6135', '6580', '6548')
    )
),

-- ③ 每个 asn_id 只取 entered_yard 最新的一条 trailer
latest_trailer AS (
    SELECT
        ta.asn_id,
        ta.trailer_id
    FROM t_trailer_asn ta WITH (NOLOCK)
    INNER JOIN (
        SELECT
            ta2.asn_id,
            MAX(tr.entered_yard) AS max_entered_yard
        FROM t_trailer_asn ta2 WITH (NOLOCK)
        INNER JOIN t_trailer tr WITH (NOLOCK) ON ta2.trailer_id = tr.trailer_id
        GROUP BY ta2.asn_id
    ) mx ON ta.asn_id = mx.asn_id
    INNER JOIN t_trailer tr WITH (NOLOCK) ON ta.trailer_id = tr.trailer_id
                            AND tr.entered_yard = mx.max_entered_yard
)

SELECT
    -- t_asn 所有列
    a.asn_id,
    a.asn_number,
    a.status                AS asn_status,
    a.equipment_id,
    a.trailer_type_name,
    a.expected_arrival,
    a.vendor_id,
    a.total_quantity,
    a.total_volume,

    -- t_vendor
    v.vendor_name,

    -- t_asn_detail 所有列（已展开 SN）
    sn.asn_detail_id,
    sn.item_number,
    sn.lot_number,
    sn.line_number,
    sn.uom,
    sn.customer_po_number,
    sn.quantity_shipped,
    sn.quantity_received,
    sn.born_on_date,
    sn.carb_compliance_level,
    sn.sn_coo,
    sn.transfer_number,
    cast(sn.serial_number as varchar(50)) AS serial_number,

    -- t_trailer 所有列
    tr.trailer_id,
    tr.status               AS trailer_status,
    tr.entered_yard,
    tr.exited_yard,

    -- t_ya_location 所有列
    loc.location_name,

    -- 计算列
    ROUND(
        DATEDIFF(MINUTE,
            tr.entered_yard,
            COALESCE(tr.exited_yard, GETDATE())
        ) / 60.0, 1
    ) AS hours_in_yard,

    CASE
        WHEN tr.entered_yard IS NULL THEN NULL
        WHEN ROUND(DATEDIFF(MINUTE, tr.entered_yard, COALESCE(tr.exited_yard, GETDATE())) / 60.0, 1) <  4  THEN '[a] 0-4h'
        WHEN ROUND(DATEDIFF(MINUTE, tr.entered_yard, COALESCE(tr.exited_yard, GETDATE())) / 60.0, 1) <  8  THEN '[b] 4-8h'
        WHEN ROUND(DATEDIFF(MINUTE, tr.entered_yard, COALESCE(tr.exited_yard, GETDATE())) / 60.0, 1) < 24  THEN '[c] 8-24h'
        WHEN ROUND(DATEDIFF(MINUTE, tr.entered_yard, COALESCE(tr.exited_yard, GETDATE())) / 60.0, 1) < 48  THEN '[d] 24-48h'
        ELSE '[e] 48h+'
    END AS hours_in_yard_bucket,

    CASE
        WHEN loc.location_name IS NULL      THEN 'In_Transit'
        WHEN tr.exited_yard    IS NOT NULL  THEN 'Completed'
        WHEN loc.location_name LIKE 'D%'    THEN 'On_Door'
        WHEN loc.location_name LIKE '%YARD' THEN 'In_Yard'
        ELSE 'CHECK'
    END AS container_status,

    CASE
        WHEN tr.entered_yard IS NULL THEN NULL
        WHEN DATEPART(HOUR, tr.entered_yard) BETWEEN 7 AND 19 THEN 'D'
        ELSE 'N'
    END AS shift,

    CASE
        WHEN tr.entered_yard IS NULL
            THEN CAST(a.expected_arrival AS DATE)
        WHEN DATEPART(HOUR, tr.entered_yard) BETWEEN 0 AND 6
            THEN CAST(DATEADD(DAY, -1, tr.entered_yard) AS DATE)
        ELSE
            CAST(tr.entered_yard AS DATE)
    END AS shift_date

FROM t_asn AS a WITH (NOLOCK)
JOIN sn_expanded AS sn
    ON a.asn_id = sn.asn_id
LEFT JOIN latest_trailer AS lt
    ON a.asn_id = lt.asn_id
LEFT JOIN t_trailer AS tr WITH (NOLOCK)
    ON lt.trailer_id = tr.trailer_id
LEFT JOIN t_ya_location AS loc WITH (NOLOCK)
    ON tr.location_id = loc.location_id
LEFT JOIN t_vendor AS v WITH (NOLOCK)
    ON a.vendor_id = v.vendor_id
WHERE
    a.status IN ('NEW', 'CHECKED IN', 'CLOSED')
   -- AND a.vendor_id IN ('6135', '6580', '6548')
ORDER BY
    a.asn_id,
    sn.customer_po_number,
    sn.serial_number;




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


-- sto
select  * from t_stored_item where item_number = 'A3000202'
select * from t_item_master where item_number = 'T789-2'
select * from t_order_detail where item_number = 'T789-2'
select * from t_order_detail_breakdown where item_number = 'T789-2'



select top 100 * from t_hu_master where hu_id like '%39916747'
select top 100 * from t_hu_detail where hu_id like '%39916747'

-- sn
select * from t_serial_active where location_id = 'FOOT51014'
select top 10 * from t_stored_item 


-- tranlog
select top 10 * from t_tran_log order by lot_number, start_tran_date desc, start_tran_time desc


-- consolidation
select * from t_fwd_pick where item_number ='D824-50T'
select * from t_location where location_id ='A3012FU1'


-- replenishment check for item
select * from t_fwd_pick where capacity_qty >400

select * from t_loc_pallet_capacity where capacity >4 and location_id like 'A30%' and pallet_id != 16 

select top 10 * from t_item_master where item_number = 'A2000665'
select top 10 * from t_item_uom where item_number = 'A2000665'
select top 10 * from t_fwd_pick where item_number = 'A2000665'
select top 10 * from t_loc_pallet_capacity where location_id = 'A3012EA1'
select top 1000 * from t_work_q where item_number = 'A2000665'


-- item in whse
select * from t_stored_item WHERE item_number in ('T236-13','T247-13','T251-13') 
select * from t_serial_active WHERE item_number in ('T236-13','T247-13','T251-13') 

select * from t_stored_item WHERE item_number in ('T236-13','T247-13','T251-13')
select * from t_serial_active WHERE item_number in ('T236-13','T247-13','T251-13') 

-- by item and location
select * from t_stored_item WHERE item_number in ('T236-13','T247-13','T251-13') order by item_number, location_id
select item_number, location_id, po_number, count(serial_number) as on_hand_sn_qty
from t_serial_active
where wh_id = '335' and item_number in ('T236-13','T247-13','T251-13')
    and (serial_no_status != 'S' and serial_no_status != 'O')
GROUP BY item_number, location_id, po_number
order by item_number, po_number, location_id



-- item location on hand 
select * from t_stored_item where item_number like '86140%' and location_id not like 'RP%' order by location_id

-- sn master status change 
select * from t_serial_active where serial_number in ('666158390262')
select * from t_serial_master where serial_number = '666158390262'
select * from t_stored_item where item_number = 'U6600014'
select * from t_serial_master where item_number = 'U6600014'
select * from t_serial_active where item_number = 'H743-70'
select * from t_serial_active where serial_number in ('666158390262')
select * from t_serial_active where serial_number in ('666158324114')
select * from t_serial_master where serial_number in ('688076032457','688076032459')
select * from t_tran_log where lot_number in ('503953598356') order by start_tran_date desc, start_tran_time desc
select * from t_tran_log where employee_id = '1001787' and start_tran_date >= '2026-06-04' order by start_tran_date desc, start_tran_time desc


 select top 10 * from t_tran_log  order by lot_number, start_tran_date desc, start_tran_time desc

 -- sn check
 select top 1000 * from t_tran_log  order by start_tran_date desc, start_tran_time desc
 select * from t_tran_log where item_number in ('A2000686') order by lot_number, start_tran_date desc, start_tran_time desc
 select * from t_tran_log where lot_number in ('666158390262') order by lot_number, start_tran_date desc, start_tran_time desc
 select * from t_tran_log where lot_number in ('605590374873') order by lot_number, start_tran_date desc, start_tran_time desc
 select * from t_tran_log where lot_number in ('661420010313') order by lot_number, start_tran_date desc, start_tran_time desc
 select * from t_tran_log where lot_number in ('503952904749') order by lot_number, start_tran_date desc, start_tran_time desc
 select * from t_tran_log where lot_number in ('618268972022','618268972023') order by lot_number, start_tran_date desc, start_tran_time desc
 select * from t_tran_log where item_number in ('L243354') and location_id = 'EX001AA1' order by lot_number, end_tran_date desc, end_tran_time desc


  select * from t_tran_log where lot_number in ('672617679245','672617679250','672617679487','672617679488') order by lot_number, start_tran_date desc, start_tran_time desc
  select * from t_tran_log where lot_number in ('630570017309') order by lot_number, end_tran_date desc, end_tran_time desc
  select * from t_tran_log where lot_number in ('503952252218') order by lot_number, end_tran_date desc, end_tran_time desc
  select * from t_tran_log where lot_number in ('503953040405') order by lot_number, end_tran_date desc, end_tran_time desc
  select * from t_tran_log where lot_number in ('503953598356') order by lot_number, end_tran_date desc, end_tran_time desc
  select * from t_tran_log where lot_number in ('670110189207') order by lot_number, end_tran_date desc, end_tran_time desc
  select * from t_tran_log where lot_number in ('623820604873') order by lot_number, end_tran_date desc, end_tran_time desc
  select * from t_tran_log where lot_number in ('667048056058') order by lot_number, end_tran_date desc, end_tran_time desc
  select * from t_tran_log where lot_number in ('692229400527') order by lot_number, end_tran_date desc, end_tran_time desc
  select * from t_tran_log where lot_number in ('688806078375') order by lot_number, end_tran_date desc, end_tran_time desc
  select * from t_tran_log where lot_number in ('688806159289') order by lot_number, end_tran_date desc, end_tran_time desc
  select * from t_tran_log where lot_number in ('833500838401') order by lot_number, end_tran_date desc, end_tran_time desc


  688806159289
833500838401

  select *
  from t_tran_log 
  where item_number = '6690677'      and tran_type in ('165','855','161')
  order by start_tran_date, start_tran_time

  select * from t_tran_log where lot_number IN ('603953822942','503953822942') order by item_number, lot_number, start_tran_date desc, start_tran_time desc

     select start_tran_date, item_number,   tran_type, sum(tran_qty) as qty
    from t_tran_log
    where item_number like 'B685-92%' and tran_type = '347'
    group by  start_tran_date, item_number,   tran_type
    order by start_tran_date 


    select item_number,  control_number_2, tran_type, sum(tran_qty) as qty
    from t_tran_log
    where control_number_2 like '%59961%' and tran_type = '347'
    group by  item_number,  control_number_2,tran_type

-- sn status check
select * from t_serial_master where serial_number = '688806159289'
 
 
select top 10 * from t_serial_active where serial_number = '667048056058'
select top 10 * from t_serial_active where serial_number = '667048056058'
select top 10 * from t_serial_master where serial_number = '667048056058'
select * from t_tran_log where lot_number IN ('667048056058') order by item_number, lot_number, start_tran_date desc, start_tran_time desc

select distinct serial_no_status from t_serial_master where serial_number = '688075633760'

select t.*, m.serial_no_status
from t_serial_active(nolock) as t 
left join t_serial_master(nolock) as m on t.serial_number = m.serial_number
where t.serial_no_status != m.serial_no_status and t.serial_no_status in ('R')


select * from t_tran_log where control_number_2 = 'P2VJ976'
select start_tran_date, control_number,control_number_2, sum(tran_qty) as qty  from t_tran_log where item_number = 'U2710513' and tran_type in ('151')  group by start_tran_date, control_number,control_number_2 order by start_tran_date,control_number,control_number_2
select start_tran_date, control_number,control_number_2, sum(tran_qty) as qty  from t_tran_log where item_number = 'B100-14' and tran_type in ('347')  group by start_tran_date, control_number,control_number_2 order by start_tran_date,control_number,control_number_2


-- 340 Back order check


select top 10 * from t_tran_log as t1 WHERE t1.wh_id = '335' 	AND t1.tran_type in ('340')
select top 10 * from t_tran_log as t1 WHERE t1.wh_id = '335' 	AND t1.tran_type in ('347')
select * from t_reason where type = 'BACKORDER'
SELECT t1.start_tran_date,t1.item_number,t1.control_number_2,t1.control_number, t1.tran_type, sum(case when t1.tran_type = '951' then -t1.tran_qty else t1.tran_qty end) as tran_qty
from t_tran_log as t1
WHERE t1.wh_id = '335'
	AND t1.tran_type in ('350')
   -- AND t1.item_number IN ('D947-81')
    AND t1.control_number_2 like '%38131%'
    AND t1.start_tran_date >= '2026-05-01'
GROUP by  t1.start_tran_date,t1.item_number,t1.control_number_2,t1.control_number,t1.tran_type
order by t1.item_number, t1.start_tran_date


-- 347 abnormal transactions by item
SELECT t1.start_tran_date,t1.item_number,t1.control_number_2,t1.control_number, t1.tran_type, sum(case when t1.tran_type = '951' then -t1.tran_qty else t1.tran_qty end) as tran_qty
from t_tran_log as t1
WHERE t1.wh_id = '335'
	AND t1.tran_type in ('347')
   AND t1.item_number IN ('5590335')
    --AND t1.control_number_2 like '%39537%'
    AND t1.start_tran_date >= '2026-5-01'
GROUP by  t1.start_tran_date,t1.item_number,t1.control_number_2,t1.control_number,t1.tran_type
order by t1.item_number, t1.start_tran_date

select * from t_tran_log where control_number_2 like '%36618%' and item_number = 'RP ORDER' order by lot_number, start_tran_date desc, start_tran_time desc



-- no 152 trx check, get the last transaction for each lot, and filter by tran_type and location_id_2
WITH last_tran AS (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY lot_number
               ORDER BY start_tran_date DESC, 
                        CONVERT(TIME, start_tran_time) DESC  -- 只取時間部分排序
           ) AS rn
    FROM t_tran_log
    WHERE wh_id = '335'
      AND start_tran_date >= '2026-04-19'
)
--SELECT item_number,
--       control_number_2,
--       tran_type,
--       lot_number,
--       location_id_2,
--       start_tran_date,
--       start_tran_time
SELECT *
FROM last_tran
WHERE rn = 1
  AND tran_type = '151'
  AND (location_id_2 LIKE 'F%' OR location_id_2 LIKE 'V%')
ORDER BY item_number, start_tran_date;



-- 151， 951 abnormal transactions by item
SELECT t1.start_tran_date,t1.item_number,t1.control_number_2, t1.tran_type, sum(case when t1.tran_type = '951' then -t1.tran_qty else t1.tran_qty end) as tran_qty
from t_tran_log as t1
WHERE t1.wh_id = '335'
	AND t1.tran_type in ('151','951')
    AND t1.control_number IN ('P2VSH22')
    AND t1.start_tran_date >= '2026-01-01'
GROUP by  t1.start_tran_date,t1.item_number,t1.control_number_2,t1.tran_type
order by t1.item_number, t1.start_tran_date




-- 151， 951 abnormal transactions by item
SELECT t1.start_tran_date,t1.item_number,t1.control_number_2, t1.tran_type, sum(case when t1.tran_type = '951' then -t1.tran_qty else t1.tran_qty end) as tran_qty
from t_tran_log as t1
WHERE t1.wh_id = '335'
	AND t1.tran_type in ('151','951')
    AND t1.item_number IN ('B974-97S')
    AND t1.start_tran_date >= '2026-06-01'
GROUP by  t1.start_tran_date,t1.item_number,t1.control_number_2,t1.tran_type
order by t1.item_number, t1.start_tran_date



-- 161,165, 851, 855 abnormal transactions by item
SELECT t1.start_tran_date,t1.item_number,t1.control_number_2, t1.tran_type, t1.lot_number, sum(t1.tran_qty) as tran_qty
from t_tran_log as t1
WHERE t1.wh_id = '335'
	AND t1.tran_type in ('161','165','851','855')
    AND t1.item_number IN ('R407300')
    AND t1.start_tran_date >= '2026-05-01'
GROUP by  t1.start_tran_date,t1.item_number,t1.control_number_2,t1.tran_type, t1.lot_number
order by t1.item_number, t1.start_tran_date

 select * from t_tran_log where lot_number in ('833500814427') order by lot_number, start_tran_date desc, start_tran_time desc


-- by sn
SELECT t1.start_tran_date,t1.item_number,t1.control_number_2, t1.tran_type, t1.lot_number, sum(t1.tran_qty) as tran_qty
from t_tran_log as t1
WHERE t1.wh_id = '335'
	AND t1.tran_type in ('855','165')
    AND t1.item_number IN ('6730564')
    AND t1.start_tran_date >= '2026-04-19'
GROUP by  t1.start_tran_date,t1.item_number,t1.control_number_2,t1.tran_type, t1.lot_number
order by t1.item_number, t1.start_tran_date


-- sn history
select * from t_tran_log where lot_number in ('833500835252','630570021844') order by lot_number, start_tran_date desc, start_tran_time desc
select * from t_tran_log where lot_number in ('683811716878') order by lot_number, start_tran_date desc, start_tran_time desc
select * from t_tran_log where lot_number in ('688075633760') order by lot_number, start_tran_date desc, start_tran_time desc
select * from t_tran_log where lot_number in ('548800123580') order by lot_number, start_tran_date desc, start_tran_time desc
select * from t_tran_log where lot_number in ('548800122340') order by lot_number, start_tran_date desc, start_tran_time desc
select * from t_tran_log where lot_number in ('692963453510') order by lot_number, start_tran_date desc, start_tran_time desc


-- trx
select top 10 * from t_tran_log where start_tran_date = cast(getdate() as date)  order by start_tran_date desc, start_tran_time desc




-- serial number active
select top 10 * from t_serial_active where po_number = '8379393' 


SELECT * 
FROM t_tran_log AS t3                  
WHERE
    t3.item_number = 'R407051'
    AND t3.location_id in ('NG001OP3')
order by t3.lot_number, t3.start_tran_date desc, t3.start_tran_time desc


-- trip shipped infor
select start_tran_date,start_tran_time, tran_type, description, item_number, left(control_number_2,7) as trip_nbr,sum(tran_qty ) as trip_qty
from t_tran_log
where tran_type = '347' 
and control_number_2 like '%57351%' 
group by start_tran_date,start_tran_time, tran_type, description, item_number, left(control_number_2,7)


-- trip shipped infor
select start_tran_date,start_tran_time, tran_type, description, item_number, left(control_number_2,7) as trip_nbr,sum(tran_qty ) as trip_qty
from t_tran_log
where tran_type = '347' 
and control_number_2 like '%1746%'
group by start_tran_date,start_tran_time, tran_type, description, item_number, left(control_number_2,7)






-- by sn
SELECT tran_type,description,start_tran_date,start_tran_time,employee_id,control_number,control_number_2,wh_id,location_id,hu_id,item_number,lot_number,tran_qty,location_id_2,employee_id_2,
sn_coo,process,equipment_zone
from t_tran_log as t1
WHERE t1.wh_id = '335'
    AND t1.lot_number IN ('645850002909')
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
	AND t1.tran_type in ('151')
 	AND t1.control_number_2 in ('P2W4V07')
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
    t3.lot_number in ('503952911404')
order by t3.lot_number, t3.start_tran_date desc, t3.start_tran_time desc
 --   t3.lot_number in ('698075460913','688075534443','688075534444','688075534442')


-- ITEM MASTER
select top 100 * from t_item_master 
select top 100 * from t_item_uom




-- CHECK STO
WITH itm as 
(select distinct i.item_number ,
    case 
        when i.pick_put_id = 'UPH' THEN 'UPH'
        when i.pick_put_id = 'PALLT' AND i.class_id = 'FLOOR' THEN 'BULK'
        when i.pick_put_id = 'PALLT' AND i.class_id = 'RUGS' THEN 'RUGS'
        when i.pick_put_id = 'PALLT' THEN 'CG'
        else 'RP' end as product
from t_item_master as i
where i.wh_id = '335'
)
select SUBSTRING(t.location_id, 6, 2) as section, right(t.location_id,1) as level,  i.product, sum(t.actual_qty) as actual_qty        
from t_stored_item as t
left join itm as i  on t.item_number = i.item_number
where t.wh_id = '335' and t.location_id like 'A30[25]%[12345]' and i.product in ('BULK')
group by SUBSTRING(t.location_id, 6,2) , right(t.location_id,1) , i.product
order by SUBSTRING(t.location_id, 6, 2) , right(t.location_id,1)

-- STO ITEM in A3025
WITH itm as 
(select distinct i.item_number ,
    case 
        when i.pick_put_id = 'UPH' THEN 'UPH'
        when i.pick_put_id = 'PALLT' AND i.class_id = 'FLOOR' THEN 'BULK'
        when i.pick_put_id = 'PALLT' AND i.class_id = 'RUGS' THEN 'RUGS'
        when i.pick_put_id = 'PALLT' THEN 'CG'
        else 'RP' end as product
from t_item_master as i
where i.wh_id = '335'
)
select t.location_id, i.product, sum(t.actual_qty) as actual_qty        
from t_stored_item as t
left join itm as i  on t.item_number = i.item_number
where t.wh_id = '335' and t.location_id like 'A3025%' and i.product in ('BULK')
group by t.location_id, i.product
order by t.location_id


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





select top 10 * from t_customer where customer_number like '%888800%'
select top 10 * from t_order
select load_id, customer_id, customer_name from t_order group by load_id, customer_id, customer_name 
select customer_number, customer_name from t_customer group by customer_number, customer_name 

select top 10 * from t_order_c_number
select * from t_order_c_number

select top 10 * from t_order where load_id like '%57978%' 
select top 10 * from t_order_c_number where order_number like '%57978%' 
select top 10 * from t_order_detail_breakdown where order_number like '%57978%'
select top 10 * from t_tran_log where tran_type like '347%' and control_number_2 like '%57978%'
select top 10 * from t_tran_log where tran_type like '345%' and control_number_2 like '%57978%'

-- 关键：同一个订单前缀下有多个不同客户
SELECT 
    LEFT(order_number, 7) AS trip_nbr, 
    customer_number, 
    bill_to_name,
    order_number -- 包含原始单号以便区分
FROM t_order_c_number
WHERE LEFT(order_number, 7) IN (
    SELECT LEFT(order_number, 7)
    FROM t_order_c_number
    GROUP BY LEFT(order_number, 7)
    HAVING COUNT(DISTINCT customer_number) > 1 
)
ORDER BY trip_nbr;

-- 关键：同一个Trip对应的客户ID去重后大于1
SELECT 
    LEFT(order_number, 7) AS trip_nbr,
    COUNT(DISTINCT customer_number) AS customer_count,
    COUNT(DISTINCT bill_to_name) AS name_count
FROM t_order_c_number
GROUP BY LEFT(order_number, 7)
HAVING COUNT(DISTINCT customer_number) > 1; 


-- 综合查询：订单、客户信息、345和347的数量
with customer_info as (
select customer_number, customer_name 
from t_customer 
group by customer_number, customer_name 
),
cc_nbr as (
select 
        left(order_number,7) as trip_nbr, 
        MAX(customer_number) as customer_number, -- 强制取一个
        MAX(bill_to_name) as bill_to_name
    from t_order_c_number 
    group by left(order_number,7)
),
trip_qty_345 as (
select start_tran_date,start_tran_time, tran_type, description, left(control_number_2,7) as trip_nbr,sum(num_items ) as trip_qty
from t_tran_log
where tran_type = '345' 
group by start_tran_date ,start_tran_time, tran_type, description, left(control_number_2,7)
),
trip_qty_347 as (
select start_tran_date,start_tran_time, tran_type, description, left(control_number_2,7) as trip_nbr,sum(tran_qty ) as trip_qty
from t_tran_log
where tran_type = '347' 
group by start_tran_date ,start_tran_time, tran_type, description, left(control_number_2,7)
)
select t.*, t1.trip_qty as trip_qty_347, c.customer_number, ci.customer_name, c.bill_to_name
from trip_qty_345 as t
left join trip_qty_347 as t1 on t.trip_nbr = t1.trip_nbr
left join cc_nbr as c on t.trip_nbr = c.trip_nbr
left join customer_info as ci on c.customer_number = ci.customer_number



select start_tran_date,start_tran_time, tran_type, description, left(control_number,7) as trip_nbr, routing_code, sum(tran_qty ) as qty
from t_tran_log
where tran_type = '340'
group by start_tran_date ,start_tran_time, tran_type, description, left(control_number,7), routing_code

-- trx type 340 back order
select *
from t_tran_log 
where tran_type like '340%' and start_tran_date = '2026-02-26' and control_number_2 like '%92556%'
-- trx type

select start_tran_date, tran_type, description, left(control_number,7) as trip,sum(case when tran_type = '951' then -tran_qty else tran_qty end ) as qty 
from t_tran_log 
where tran_type like '3%' and start_tran_date >= '2025-01-26' and control_number like '%55573%'
group by start_tran_date ,tran_type, description, left(control_number,7)
order by start_tran_date ,tran_type, description,left(control_number,7)

-- trx type

select start_tran_date, tran_type, description, left(control_number_2,7) as trip,sum(case when tran_type = '951' then -tran_qty else tran_qty end ) as qty 
from t_tran_log 
where tran_type like '3%' and start_tran_date = '2026-02-26' and control_number_2 like '%92556%'
group by start_tran_date ,tran_type, description, left(control_number_2,7)
order by start_tran_date ,tran_type, description,left(control_number_2,7)




-- trx type 345

select *
from t_tran_log 
where tran_type like '345%' and start_tran_date = '2026-02-26' and control_number_2 like '%92556%'

-- trx type 347

select *
from t_tran_log 
where tran_type like '3%' and start_tran_date = '2026-03-22' order by start_tran_date, start_tran_time



--  LOC
select location_id, status, type, capacity_volume from t_location  where location_id like 'A3%' order by location_id



-- ON HAND IN racking
select item_number, sum(actual_qty) as qty, location_id from t_stored_item where location_id like 'A3%' group by item_number, location_id  order by location_id
-- ONHAND IN STAGING
select item_number, sum(actual_qty) as qty, location_id from t_stored_item where location_id like 'RS%' group by item_number, location_id  order by location_id
-- ONHAND IN YARD
select item_number, sum(actual_qty) as qty, location_id from t_stored_item where location_id like 'RS%' group by item_number, location_id  order by location_id


-- trx by item and transaction type

select start_tran_date, item_number, sum(case when tran_type = '951' then -tran_qty else tran_qty end ) as qty 
from t_tran_log 
where tran_type in ('151','951') and item_number = '1700338'
group by start_tran_date, item_number  
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


-- KNQMAN variance verify on Mar.22.2026
select *  from t_tran_log  where lot_number = '503948691983' order by start_tran_date desc, start_tran_time desc
select *  from t_tran_log  where lot_number = '503952183811' order by start_tran_date desc, start_tran_time desc
select *  from t_tran_log  where lot_number = '503951714438' order by start_tran_date desc, start_tran_time desc
select *  from t_tran_log  where lot_number = '503952704823' order by start_tran_date desc, start_tran_time desc

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
    AND t1.item_number IN ('D631-01')
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
	AND t1.control_number_2 IN ('P2RQ088')
    AND t1.start_tran_date >= '2026-01-01'
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
WHERE pallet_id = 16 AND PATINDEX('A3011[' + 'CEGJLNQSUXZ' + ']%', location_id) > 0
where location_id like 'A3021%' and substring(location_id,6,1) in  ('C','E','G','J','L') and class_id in ('UPHH','UPHL','UPHOT','UPHXH','UPHCH')



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




