with itm AS
( SELECT CAST('335' AS VARCHAR) + '_' + cast(trim(ITNBR) as varchar) AS wh_item,  
	t.ITNBR, 
	t.CUBES AS B2Z95S,
	t.CRTLIN,
	t.CRTWIN,
	t.CRTHIN,
	t.ITMWEGHT AS WEGHT
    FROM MasterData_ItemMaster_AFI.ITMEXT as t),
RankedRoutes as (
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
DistinctRoutes as (
    select *
    from RankedRoutes
    where rn_per_code = 1  -- 每个 routing_code 只取最新一条
),
Top10PerWh as (
    select *,
        ROW_NUMBER() over (
            partition by Warehouse
            order by [Invoice date] desc
        ) as rn
    from DistinctRoutes
),
container_nbr as
(
select cast(Warehouse as varchar) + '_' + cast([Trip Number] as varchar) as container_nbr
from Top10PerWh
where rn <= 10
--order by wh_id, start_tran_date desc
),
trx as (
select cast(trim(t.Warehouse) as varchar) + '_' + cast(trim(t.[Item SKU]) as varchar) as wh_item, *
FROM AFISales_DW.FactShippedHistory as t 
WHERE t.Warehouse = '335' and t.[invoice date] >= '2025-05-01' 
	and t.[Account And ShipTo Number] = '3824800-17' 
    and cast(t.Warehouse as varchar) + '_' + cast(t.[Trip Number] as varchar) in (select * from container_nbr)
)
select 
    t1.[Invoice date] as start_tran_date,
    t1.Warehouse as wh_id,
    t1.wh_item, 
    t1.[Item SKU] as item_number, 
    t1.[Bonded Warehouse Transfer Quantity] as tran_qty,
    t1.[Bonded Warehouse Transfer Quantity] * i.WEGHT as [Weight(lbs)],
    t1.[Bonded Warehouse Transfer Quantity] * i.B2Z95S  as cubes,
    t1.[Trip Number] as container_number,
    t1.[Account And ShipTo Number] as destination,
    '' as serial_number,
    t1.[Order Number] as order_number,
	i.CRTLIN,
	i.CRTWIN,
	i.CRTHIN
from trx as t1
-- 尝试更彻底的字符串清理
left join itm as i on i.wh_item = t1.wh_item
order by t1.[Invoice date] 




