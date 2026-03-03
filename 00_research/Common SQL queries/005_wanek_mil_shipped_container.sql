with itm AS (
--( SELECT CAST(trim(STID) AS VARCHAR) + '_' + cast(trim(ITNBR) as varchar) AS wh_item, itnbr, WEGHT, B2Z95S   
--    FROM MasterData_ItemMaster_AFI.ITMRVA
--    WHERE STID = '335'
--UNION ALL
--    SELECT CAST(trim(STID) AS VARCHAR) + '_' + cast(trim(ITNBR) as varchar) AS wh_item, itnbr, WEGHT, B2Z95S   
--    FROM MasterData_ItemMaster_WNK.ITMRVA
--    WHERE STID = '35' 
--UNION ALL
--    SELECT CAST(trim(STID) AS VARCHAR) + '_' + cast(trim(ITNBR) as varchar) AS wh_item, itnbr, WEGHT, B2Z95S   
--    FROM MasterData_ItemMaster_MIL.ITMRVA
--    WHERE STID = '51' 

 SELECT CAST('335' AS VARCHAR) + '_' + cast(trim(ITNBR) as varchar) AS wh_item,  
	t.ITNBR, 
	t.CUBES AS B2Z95S,
	t.CRTLIN,
	t.CRTWIN,
	t.CRTHIN,
	t.ITMWEGHT AS WEGHT
    FROM MasterData_ItemMaster_AFI.ITMEXT as t
UNION ALL
 SELECT CAST('35' AS VARCHAR) + '_' + cast(trim(ITNBR) as varchar) AS wh_item,  
	t.ITNBR, 
	t.CUBES AS B2Z95S,
	t.CRTLIN,
	t.CRTWIN,
	t.CRTHIN,
	t.ITMWEGHT AS WEGHT
    FROM MasterData_ItemMaster_WNK.ITMEXT as t
UNION ALL
 SELECT CAST('51' AS VARCHAR) + '_' + cast(trim(ITNBR) as varchar) AS wh_item,  
	t.ITNBR, 
	t.CUBES AS B2Z95S,
	t.CRTLIN,
	t.CRTWIN,
	t.CRTHIN,
	t.ITMWEGHT AS WEGHT
    FROM MasterData_ItemMaster_MIL.ITMEXT as t
),
RankedRoutes as (
    select
        t.wh_id,
        t.routing_code,
        t.start_tran_date,
        ROW_NUMBER() over (
            partition by t.wh_id, t.routing_code
            order by t.start_tran_date desc
        ) as rn_per_code
    from Distribution_Warehouse_Wholesale.TranLog as t
    where t.wh_id in ('51', '35')
        and t.start_tran_date >= '2025-06-01'
        and t.tran_type = '361'
        and t.wh_id_2 = '17'
),
DistinctRoutes as (
    select *
    from RankedRoutes
    where rn_per_code = 1  -- 每个 routing_code 只取最新一条
),
Top10PerWh as (
    select *,
        ROW_NUMBER() over (
            partition by wh_id
            order by start_tran_date desc
        ) as rn
    from DistinctRoutes
),
container_nbr as
(
select cast(wh_id as varchar) + '_' + routing_code as container_nbr
from Top10PerWh
where rn <= 10
--order by wh_id, start_tran_date desc
),
RankedRoutes2 as (
    select
        t.Warehouse,
        t.[Trip Number],
        t.[Invoice date],
        ROW_NUMBER() over (
            partition by t.Warehouse, t.[Trip Number]
            order by t.[Invoice date] desc
        ) as rn_per_code
    from AFISales_DW.FactShippedHistory as t
	where t.Warehouse = '335' and t.[invoice date] >= '2025-05-01' 
	and t.[Account And ShipTo Number] = '3824800-17' 
),
DistinctRoutes2 as (
    select *
    from RankedRoutes2
    where rn_per_code = 1  -- 每个 routing_code 只取最新一条
),
Top10PerWh2 as (
    select *,
        ROW_NUMBER() over (
            partition by Warehouse
            order by [Invoice date] desc
        ) as rn
    from DistinctRoutes2
),
container_nbr2 as
(
select cast(Warehouse as varchar) + '_' + cast([Trip Number] as varchar) as container_nbr
from Top10PerWh2
where rn <= 10
--order by wh_id, start_tran_date desc
),
trx as (
--mil and wanek
select cast(trim(t.wh_id) as varchar) + '_' + cast(trim(t.item_number) as varchar) as wh_item, *
from Distribution_Warehouse_Wholesale.TranLog as t
where t.wh_id in ('51','35')
    and t.start_tran_date >= '2025-06-01'
    and t.tran_type = '361'
    and t.wh_id_2 = '17'
    and cast(t.wh_id as varchar) + '_' + t.routing_code in (select * from container_nbr)
union all
--ashton
select cast(trim(t.wh_id) as varchar) + '_' + cast(trim(t.item_number) as varchar) as wh_item, *
from Distribution_Warehouse_Wholesale.TranLog as t
where t.wh_id in ('335')
    and t.start_tran_date >= '2025-06-01'
    and t.tran_type = '347'
    and cast(t.wh_id as varchar) + '_' + CAST(LEFT(t.control_number_2,7) * 1  AS VARCHAR) in (select * from container_nbr2)
)
select 
    t1.start_tran_date,
    t1.wh_id,
    t1.wh_item, 
    t1.item_number, 
    t1.tran_qty, 
    t1.tran_qty * i.WEGHT as [Weight(lbs)],
    t1.tran_qty * i.B2Z95S  as cubes,
    t1.routing_code as container_number,
    t1.wh_id_2 as destination,
    cast(t1.lot_number as varchar) as serial_number,
    t1.control_number as order_number,
	i.CRTLIN,
	i.CRTWIN,
	i.CRTHIN
from trx as t1
-- 尝试更彻底的字符串清理
left join itm as i on i.wh_item = t1.wh_item
order by t1.wh_id 