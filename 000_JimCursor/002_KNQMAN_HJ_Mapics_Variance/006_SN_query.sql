
-- RP received by item
SELECT t1.start_tran_date,t1.item_number,t1.control_number_2, sum(t1.tran_qty) as qty
FROM t_tran_log AS t1
WHERE t1.wh_id = '335'
	--AND t1.tran_type in ('151','951')
-- 	AND t1.control_number_2 like '0039312%'
    AND t1.item_number IN ('M004005006')
    AND t1.start_tran_date >= '2025-10-30'
GROUP by  t1.start_tran_date,t1.item_number,t1.control_number_2
order by t1.item_number, t1.start_tran_date



-- item summary received
SELECT *
FROM
   t_tran_log AS t3                   -- From the TranLog table
WHERE
    --t3.wh_id = '335'                                         -- Filter for warehouse ID 335
	--AND t3.item_number = 'A8010281'
    t3.lot_number = '661470205794'
order by t3.lot_number, t3.start_tran_date desc, t3.start_tran_time desc





select t.item_number, t.serial_number
from t_serial_active as t
where t.wh_id = '335'
  and t.item_number = 'W647-60'
  and t.serial_no_status not in ('O','S')



-- SA shipped by trips
SELECT t1.start_tran_date,t1.item_number,t1.control_number_2,  sum(t1.tran_qty) as qty
FROM t_tran_log AS t1
WHERE t1.wh_id = '335'
	AND t1.tran_type = '347'
  AND t1.item_number IN ('B779-76')
   --AND t1.control_number_2 like '%32094%'
    AND t1.start_tran_date >= '2025-10-30'
GROUP by  t1.start_tran_date,t1.item_number,t1.control_number_2
order by t1.item_number, t1.start_tran_date


-- SA shipped by trips
SELECT t1.start_tran_date,t1.item_number,t1.control_number_2, sum(t1.tran_qty) as qty
FROM t_tran_log AS t1
WHERE t1.wh_id = '335'
	AND t1.tran_type = '347'
     AND t1.item_number IN ('B779-58')
    --AND t1.control_number_2 like '%30137%'
    AND t1.start_tran_date >= '2025-10-30'
GROUP by  t1.start_tran_date,t1.item_number,t1.control_number_2
order by t1.item_number, t1.start_tran_date


-- SA shipped by trips
SELECT t1.start_tran_date,t1.item_number,t1.control_number_2, sum(t1.tran_qty) as qty
FROM t_tran_log AS t1
WHERE t1.wh_id = '335'
	AND t1.tran_type = '347'
--  AND t1.item_number IN ('5200323')
    AND t1.control_number_2 like '%32094%'
    AND t1.start_tran_date >= '2025-04-06'
GROUP by  t1.start_tran_date,t1.item_number,t1.control_number_2
order by t1.item_number, t1.start_tran_date



-- RP received by item and sn
SELECT t1.start_tran_date,t1.item_number,t1.control_number_2, t1.lot_number
FROM t_tran_log AS t1
WHERE t1.wh_id = '335'
	AND t1.tran_type in ('151','951')
-- 	AND t1.control_number_2 like '0039312%'
    AND t1.item_number IN ('W647-60')
    AND t1.start_tran_date >= '2025-10-30'
GROUP by  t1.start_tran_date,t1.item_number,t1.control_number_2,t1.lot_number
order by t1.item_number, t1.start_tran_date


-- RP received by item
SELECT t1.start_tran_date,t1.item_number,t1.control_number_2, sum(t1.tran_qty) as qty
FROM t_tran_log AS t1
WHERE t1.wh_id = '335'
	AND t1.tran_type in ('151','951')
-- 	AND t1.control_number_2 like '0039312%'
    AND t1.item_number IN ('A4000711')
    AND t1.start_tran_date >= '2025-10-30'
GROUP by  t1.start_tran_date,t1.item_number,t1.control_number_2
order by t1.item_number, t1.start_tran_date


-- item shipped by trips
SELECT
CAST(LEFT(t3.control_number_2, CHARINDEX('-', t3.control_number_2) - 1) AS INT) AS trip_nbr,
t3.start_tran_date,
t3.item_number,
t3.routing_code,
SUM(t3.tran_qty) AS tran_qty
--SUM(t3.tran_qty * i.B2Z95S) AS bo_tran_cube	
FROM [PowerBI_Distribution].[TranLog] AS t3
WHERE t3.wh_id = '335'
AND t3.tran_type = '347'
AND t3.item_number ='5020655'
--AND t3.control_number_2 like '%87357%'
AND t3.start_tran_date > DATEADD(DAY, -14, GETDATE())
GROUP BY
CAST(LEFT(t3.control_number_2, CHARINDEX('-', t3.control_number_2) - 1) AS INT),
t3.start_tran_date,
t3.item_number,
t3.routing_code
ORDER BY t3.item_number, t3.start_tran_date DESC


-- HJ_SN_IN_EX001AA1_Vendor_Over_Shipment
SELECT t1.item_number, t1.location_id, CAST(t1.serial_number AS CHAR) as SN
FROM Distribution_Warehouse_Wholesale.t_serial_active  AS t1
WHERE  t1.wh_id  IN ('335')
	AND t1.item_number in ('D947-01')
  --AND t1.serial_no_status IN ('R', 'L','H')
  --AND T1.location_id LIKE 'EX001AA1%'
  AND t1.serial_no_status NOT IN ('O')
  AND t1.master_status NOT IN ('S')


-- Orphaned SN current status
 SELECT * 
 FROM Distribution_Warehouse_Wholesale.t_serial_active AS t   
 where t.wh_id = '335'
    AND t.serial_number IN ('605590369266') order by t.serial_no_status, t.status_change

-- SN trx
SELECT *
FROM Distribution_Warehouse_Wholesale.TranLog AS t1
WHERE t1.wh_id = '335'
    AND t1.lot_number IN ('618460037970')
    AND t1.start_tran_date >= '2021-01-01'
order by t1.lot_number, t1.item_number, t1.start_tran_date, t1.start_tran_time

-- Item trx
SELECT *
FROM Distribution_Warehouse_Wholesale.TranLog AS t1
WHERE t1.wh_id = '335'
    AND t1.item_number IN ('P814-838')
    AND t1.start_tran_date >= '2025-04-21'
	AND t1.tran_type ='347'
order by t1.item_number, t1.start_tran_date, t1.start_tran_time



-- SA shipped by item
SELECT t1.start_tran_date,t1.item_number,t1.control_number_2, sum(t1.tran_qty) as qty
FROM Distribution_Warehouse_Wholesale.TranLog AS t1
WHERE t1.wh_id = '335'
	AND t1.tran_type = '347'
-- 	AND t1.control_number_2 like '0039312%'
    AND t1.item_number IN ('5200323')
    AND t1.start_tran_date >= '2025-04-06'
GROUP by  t1.start_tran_date,t1.item_number,t1.control_number_2
order by t1.item_number, t1.start_tran_date





-- 820 ORPHANED DATE
SELECT t1.item_number, t1.lot_number, max(t1.start_tran_date) as date
FROM Distribution_Warehouse_Wholesale.TranLog AS t1
WHERE t1.wh_id = '335'
	AND t1.tran_type in ('820')
    AND t1.lot_number IN ('624090044488','624090044490','624090044491','833500804748','689330479071','503950023383','623820380088','503950000167','610450513593','672617734958','672617734959','625640335336','625640335531','625640336885','526403986477','526403986478','526403986479','526403986480')
    AND t1.start_tran_date >= '2025-01-01'
group by t1.item_number,t1.lot_number
order by t1.item_number,  max(t1.start_tran_date)



--  by Trip# to query transactions
SELECT
    CAST(t1.[start_tran_date] AS DATETIME) + CAST(t1.[start_tran_time] AS DATETIME) AS [combined_datetime]
    ,*
FROM Distribution_Warehouse_Wholesale.TranLog AS t1
WHERE t1.wh_id = '335'
    AND t1.start_tran_date > '2024-01-01'
    AND t1.lot_number in ('639721157638')
ORDER BY  CAST(t1.[start_tran_date] AS DATETIME) + CAST(t1.[start_tran_time] AS DATETIME)


-- by item transactions all
SELECT CAST(t1.[start_tran_date] AS DATE) AS Transaction_Date
	, t1.control_number_2
	, t1.control_number as Reference
	, t1.item_number
	, t1.tran_type
	, t1.description
    , t1.tran_qty
	, t1.lot_number
FROM (SELECT * FROM Distribution_Warehouse_Wholesale.TranLog AS a WHERE a.wh_id = '335') AS t1
WHERE t1.start_tran_date > '2024-09-01'
AND t1.item_number IN ('H821-17')
ORDER BY  CAST(t1.[start_tran_date] AS DATE)


-- HJ_SN_IN_WAREHOUSE+LOADED+HOLD
SELECT *
FROM Distribution_Warehouse_Wholesale.t_serial_active AS t1
WHERE t1.wh_id = '335'
 --   AND t1.item_number = 'H821-44'
     AND t1.serial_no_status IN ('R', 'L','H')


-- HJ_SN_IN_EX001AA1_Vendor_Over_Shipment
SELECT t1.item_number, t1.location_id, CAST(t1.serial_number AS CHAR) as SN
FROM Distribution_Warehouse_Wholesale.t_serial_active  AS t1
WHERE  t1.wh_id  IN ('335')
  AND t1.serial_no_status IN ('R', 'L','H')
  AND T1.location_id LIKE 'EX001AA1%'
  AND t1.serial_no_status NOT IN ('O')
  AND t1.master_status NOT IN ('S')



-- HJ_SN_IN_WAREHOUSE+LOADED+HOLD ORIGINAL ONE -------???????
SELECT *
FROM Distribution_Warehouse_Wholesale.t_serial_active AS t2
WHERE t2.wh_id = '335'
  AND t2.serial_no_status IN ('R', 'L','H')
  AND t2.serial_no_status NOT IN ('O')
  AND t2.master_status NOT IN ('S')

-- HJ SN ORPHANED
SELECT *
FROM Distribution_Warehouse_Wholesale.t_serial_active AS t2
WHERE t2.wh_id = '335'
     AND t2.serial_no_status IN ('O')

-- Ashton SN InWarehouse
SELECT t1.item_number, t1.location_id, CAST(t1.serial_number AS CHAR) as SN
FROM Distribution_Warehouse_Wholesale.t_serial_active  AS t1
WHERE  t1.wh_id  IN ('335')
  AND t1.serial_no_status NOT IN ('O')
  AND t1.master_status NOT IN ('S')

-- 两表差异 NOT EXISTS 可以用来找到在 t1 中没有出现在 t2 中的记录

SELECT *
FROM Distribution_Warehouse_Wholesale.t_serial_active AS t1
WHERE t1.wh_id = '335'
  AND t1.serial_no_status NOT IN ('O')
  AND t1.master_status NOT IN ('S')
  AND NOT EXISTS (
    SELECT 1
    FROM Distribution_Warehouse_Wholesale.t_serial_active AS t2
    WHERE t2.wh_id = '335'
      AND t2.serial_no_status IN ('R', 'L','H')
      AND t1.serial_number = t2.serial_number -- 假设serial_no是唯一标识字段
  );


-- NOT EXISTS 可以用来找到在 t2 中没有出现在 t1 中的记录
SELECT *
FROM Distribution_Warehouse_Wholesale.t_serial_active AS t2
WHERE t2.wh_id = '335'
  AND t2.serial_no_status IN ('R', 'L','H')
  AND NOT EXISTS (
    SELECT 1
    FROM Distribution_Warehouse_Wholesale.t_serial_active AS t1
    WHERE t1.wh_id = '335'
      AND t1.serial_no_status NOT IN ('O')
      AND t1.master_status NOT IN ('S')
      AND t2.serial_number = t1.serial_number -- 假设serial_no是唯一标识字段
  );


-- racking onhand
SELECT t1.item_number, t1.location_id, COUNT(t1.serial_number) as OnHand
FROM Distribution_Warehouse_Wholesale.t_serial_active  AS T1
WHERE  t1.wh_id  IN ('335') AND T1.location_id LIKE 'A3%' AND t1.serial_no_status NOT IN ('O') and t1.master_status NOT IN ('S')
GROUP BY t1.item_number, t1.location_id


--- HJ Transactions main
SELECT CAST(t1.[start_tran_date] AS DATETIME) as start_tran_date,
       t1.lot_number,
       t1.item_number,
       CASE
           WHEN t1.lot_number not in (select distinct  a.lot_number
                                  from Distribution_Warehouse_Wholesale.TranLog as a
                                  where a.wh_id = '335'
                                    and a.tran_type = '151'
                                    and a.start_tran_date > '2024-01-01'
                                    ) Then 'No_151_trx'
           ELSE  '151 received' END as received_check
FROM Distribution_Warehouse_Wholesale.TranLog AS t1
WHERE t1.wh_id = '335'
  AND t1.item_number IN ('B980-93')
  AND t1.start_tran_date > '2024-01-01'
  AND t1.tran_type IN ('165')
ORDER BY  CAST(t1.[start_tran_date] AS DATETIME) + CAST(t1.[start_tran_time] AS DATETIME)





--  by serial number to query transactions
SELECT
    CAST(t1.[start_tran_date] AS DATETIME) + CAST(t1.[start_tran_time] AS DATETIME) AS [combined_datetime]
    ,*
FROM Distribution_Warehouse_Wholesale.TranLog AS t1
WHERE t1.wh_id = '335'
    AND t1.start_tran_date > '2024-01-01'
    AND t1.lot_number in ('639721157638')
ORDER BY  CAST(t1.[start_tran_date] AS DATETIME) + CAST(t1.[start_tran_time] AS DATETIME)


-- item without 151 received transaction
SELECT CAST(t1.[start_tran_date] AS DATETIME) as start_tran_date,
       t1.lot_number,
       t1.item_number,
       CASE
           WHEN t1.lot_number not in (select distinct  a.lot_number
                                  from Distribution_Warehouse_Wholesale.TranLog as a
                                  where a.wh_id = '335'
                                    and a.tran_type = '151'
                                    and a.start_tran_date > '2024-10-06') Then 'No_151_trx'
           ELSE  '151 received' END as received_check
FROM Distribution_Warehouse_Wholesale.TranLog AS t1
WHERE t1.wh_id = '335'
  AND t1.item_number IN ('A4000325')
  AND t1.start_tran_date > '2024-10-01'
  --AND t1.tran_type IN ('165')
ORDER BY  CAST(t1.[start_tran_date] AS DATETIME) + CAST(t1.[start_tran_time] AS DATETIME)


-- undo lp transaction
SELECT
      CAST(t1.[start_tran_date] AS DATETIME) as start_tran_date, *
FROM Distribution_Warehouse_Wholesale.TranLog AS t1
WHERE t1.wh_id = '335'
  AND t1.item_number IN ('4480228')
  AND t1.start_tran_date > '2024-09-06'
  AND t1.tran_type IN ('151','951')
  AND t1.control_number_2 IN ('P2GX272')
ORDER BY  CAST(t1.[start_tran_date] AS DATETIME) + CAST(t1.[start_tran_time] AS DATETIME)


-- EX001AA1
SELECT top 10 *,
              CAST(t1.[start_tran_date] AS DATETIME) as start_tran_date
FROM Distribution_Warehouse_Wholesale.TranLog AS t1
WHERE t1.wh_id = '335'
    and t1.item_number = 'A4000325'
    and t1.location_id = 'EX001AA1'