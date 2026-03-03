select top 10 * from t_order_detail_breakdown






-- 查询已SA的Trip，包含C Number和Item明细
-- 查询已SA的Trip，使用orb表中的c_number
SELECT 
    ldm.wh_id,
    ldm.load_id AS trip_number,
    ldm.dispatch_date,
    ldm.dispatch_time,
    ldm.status,
    ISNULL(orm.carrier, ISNULL(c.carrier_name, '')) AS carrier_name,
    orb.c_number,  -- 直接从orb表获取c_number
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
    ON orb.wh_id = ldm.wh_id
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
ORDER BY ldm.dispatch_date DESC, ldm.dispatch_time DESC, orb.c_number, orb.item_number