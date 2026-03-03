-- 设置参数值
DECLARE @wh_id   VARCHAR(10) = '35',
        @load_id VARCHAR(30) = '%'

-- 查询语句
SELECT pkd.order_number,
       orm.load_id AS transfer_wh_id,
       CASE
           WHEN pkd.status = 'LOADED' THEN SUM(pkd.loaded_quantity)
           ELSE 0
       END AS pieces_loaded,
       CASE
           WHEN pkd.status IN ('RELEASED', 'CROSSDOCK', 'HOLD', 'REPLAN') THEN SUM(pkd.planned_quantity - pkd.picked_quantity)
           ELSE 0  
       END AS planned_quantity,
       CASE
           WHEN pkd.status = 'UNAVAILABL' THEN SUM(pkd.planned_quantity)
           ELSE 0
       END AS unavailable_quantity,
       CASE
           WHEN pkd.status = 'STAGED' THEN SUM(pkd.staged_quantity)
           ELSE 0
       END AS staged_quantity,
       SUM(pkd.planned_quantity) AS needed_quantity,
       pkd.status,
       pkd.pick_area,
       pkd.wh_id
FROM t_pick_detail pkd (NOLOCK)
INNER JOIN t_order orm (NOLOCK)
    ON orm.order_number = pkd.order_number
    AND orm.wh_id = pkd.wh_id
    AND orm.status NOT IN ('S', 'X', 'C')
JOIN t_lookup (NOLOCK) lup
    ON orm.type_id = lup.lookup_id
    AND orm.wh_id = lup.wh_id
    AND lup.text = 'HotLoad Orders'
    AND lup.source = 't_order'
    AND lup.locale_id = '1033'
LEFT OUTER JOIN t_item_uom itu (NOLOCK)
    ON itu.item_number = pkd.item_number
    AND itu.wh_id = pkd.wh_id
    AND itu.conversion_factor = (
        SELECT MIN(conversion_factor)
        FROM t_item_uom itu2 (NOLOCK)
        WHERE itu2.item_number = itu.item_number
              AND itu2.wh_id = itu.wh_id
    )
WHERE pkd.work_type = '35'
      AND pkd.status <> 'SHIPPED'
      AND pkd.status <> 'PICKED'
      AND pkd.wh_id = @wh_id
      AND (CASE @load_id WHEN '%' THEN orm.load_id ELSE @load_id END) = orm.load_id
GROUP BY pkd.order_number,
         orm.load_id,
         pkd.pick_area,
         pkd.status,
         pkd.wh_id
ORDER BY pkd.order_number