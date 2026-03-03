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
SELECT t1.start_tran_date,t1.item_number,t1.control_number_2, sum(t1.tran_qty) as tran_qty
from t_tran_log as t1
WHERE t1.wh_id = '335'
	AND t1.tran_type in ('151','347')
 	AND t1.control_number_2 in ('P2RHQ32')
    AND t1.item_number IN ('B814-58')
    AND t1.start_tran_date >= '2025-12-06'
GROUP by  t1.start_tran_date,t1.item_number,t1.control_number_2
order by t1.item_number, t1.start_tran_date


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
    AND t1.item_number IN ('R71251')
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




