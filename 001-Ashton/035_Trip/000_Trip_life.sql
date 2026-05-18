select top 10 * from Distribution_Warehouse_Wholesale.LoadMaster t where t.wh_id = '335'


with lm as 
(
select
    -- 格式 112 代表 yyyyMMdd，结果如：003443120251027
    LEFT(t.load_id, 7) + '_' + LEFT(CONVERT(VARCHAR(20), t.trip_create_date, 112),6) as trip_nbr,    
    STRING_AGG(t.load_id, ', ') as combined_load_id,   
    max(t.door_loc) as door_loc,
    t.status as trip_status,
    t.shipment_status,
    max(t.equipment_id) as container_number,
    max(t.trailer_number) as container_size,
    t.trip_create_date + t.trip_create_time as trip_create_datetime,
    t.dispatch_date + t.dispatch_time as dispatch_datetime,
    max(t.actual_ship_date) as actual_ship_date,
    t.trip_type_id
from Distribution_Warehouse_Wholesale.LoadMaster t
where t.wh_id = '335' 
    and t.status = 'S' 
group by
    LEFT(t.load_id, 7) + '_' + LEFT(CONVERT(VARCHAR(20), t.trip_create_date, 112),6),    
    t.status,
    t.shipment_status,
    t.trip_create_date + t.trip_create_time, 
    t.dispatch_date + t.dispatch_time,
    t.trip_type_id
),
odt as (
    select 
        LEFT(t.order_number, 7) as trip_nbr,
        SUM(t.qty) as total_ordered_quantity
    from t_order_detail t
    group by LEFT(t.order_number, 7)
),
itm as (
    select t.item_number, t.pick_put_id,
    case 
        when t.commodity_code not like 'Z%' then 'RP'
        when t.pick_put_id = 'UPH' then 'UPH'
        else 'CG' end as product
    from t_item_master as t
),
pkd as (
select 
    LEFT(t.order_number, 7) as trip_nbr,
    SUM(t.planned_quantity) as planned_quantity,
    SUM(t.picked_quantity) as picked_quantity,
    SUM(t.staged_quantity) as staged_quantity,
    SUM(t.loaded_quantity) as loaded_quantity
from t_pick_detail t
join itm on t.item_number = itm.item_number
group by 
    LEFT(t.order_number, 7)
) 
select l.*, 
       o.total_ordered_quantity,
       p.planned_quantity,
       p.picked_quantity,
       p.staged_quantity,
       p.loaded_quantity,
       
       -- 【新增列 1】Dispatch Date (仅日期，去掉时间)
       CAST(l.dispatch_datetime AS DATE) as dispatch_date_only,

       -- 【新增列 2】对应周六的日期 (Week Ending Saturday)
       -- 逻辑：以1900-01-06(周六)为基准，计算过了多少周，强制对齐到周六
       DATEADD(week, DATEDIFF(week, '1900-01-06', l.dispatch_datetime), '1900-01-06') as week_ending_date,

       -- 【新增列 3】年月 (格式: YYYY-MM)
       FORMAT(l.dispatch_datetime, 'yyyyMM') as dispatch_year_month

from lm as l
left join pkd as p on l.trip_nbr = p.trip_nbr
left join odt as o on l.trip_nbr = o.trip_nbr
