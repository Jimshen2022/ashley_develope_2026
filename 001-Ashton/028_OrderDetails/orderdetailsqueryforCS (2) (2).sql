
select top 100 * from t_order_detail_breakdown
select top 100 * from t_tran_log where tran_type in ('347')

select left(t.control_number_2,7) as trip_number,t.item_number, obd.c_number, sum(t.tran_qty) as total_tran_qty, sum(obd.qty) as obd_qty, max(t.end_tran_date + t.end_tran_time) as last_tran_datetime
from t_tran_log as t
left join t_order_detail_breakdown as obd
    on t.wh_id = obd.wh_id
    and left(t.control_number_2,7) = left(obd.order_number,7) and t.item_number = obd.item_number
where t.tran_type = '347'
group by left(t.control_number_2,7), t.item_number, obd.c_number

select top 100 * from t_order_detail_breakdown where order_number like '%7555%'

-- 查询最近2周（14天）已SA的Trip，包含c_number和item明细
SELECT 
    ldm.wh_id,
    ldm.load_id AS trip_number,
    ldm.dispatch_date,
    ldm.dispatch_time,
    ldm.status,
    ISNULL(orm.carrier, ISNULL(c.carrier_name, '')) AS carrier_name,
    orb.c_number,
    orb.item_number,
    orb.qty AS order_qty,
    ISNULL(pkd.picked_quantity, 0) AS picked_qty
FROM t_load_master ldm WITH(NOLOCK)
LEFT JOIN t_order orm WITH(NOLOCK) 
    ON ldm.wh_id = orm.wh_id 
    AND ldm.load_id = orm.load_id
LEFT JOIN t_carrier c WITH(NOLOCK) 
    ON ldm.carrier_id = c.carrier_id
INNER JOIN t_order_detail_breakdown orb WITH(NOLOCK)
    ON orb.wh_id = orm.wh_id
    AND orb.order_number = orm.order_number
LEFT JOIN (
    SELECT wh_id, load_id, item_number, SUM(picked_quantity) AS picked_quantity
    FROM t_pick_detail WITH(NOLOCK)
    GROUP BY wh_id, load_id, item_number
) pkd
    ON pkd.wh_id = ldm.wh_id
    AND pkd.load_id = ldm.load_id
    AND pkd.item_number = orb.item_number
WHERE ldm.status = 'S'
    AND ldm.wh_id = '335'
    AND ldm.dispatch_date >= DATEADD(DAY, -14, GETDATE())  -- 最近14天
ORDER BY ldm.dispatch_date DESC, ldm.dispatch_time DESC, orb.c_number, orb.item_number
