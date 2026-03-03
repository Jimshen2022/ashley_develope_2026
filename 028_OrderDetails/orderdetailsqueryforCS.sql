-- 查询已SA（已发货）的Trip基本信息
SELECT 
    ldm.wh_id,
    ldm.load_id AS trip_number,
    ldm.dispatch_date,
    ldm.dispatch_time,
    ldm.status,
    ldm.load_type,
    ldm.carrier_id,
    ISNULL(orm.carrier, ISNULL(c.carrier_name, '')) AS carrier_name
FROM t_load_master ldm WITH(NOLOCK)
LEFT JOIN t_order orm WITH(NOLOCK) 
    ON ldm.wh_id = orm.wh_id 
    AND ldm.load_id = orm.load_id
LEFT JOIN t_carrier c WITH(NOLOCK) 
    ON ldm.carrier_id = c.carrier_id
WHERE ldm.status = 'S'  -- SA状态
    AND ldm.wh_id = '335'
ORDER BY ldm.dispatch_date DESC, ldm.dispatch_time DESC
