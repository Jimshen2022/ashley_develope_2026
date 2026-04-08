select * from dw_developer.tabledictionary where tpktablename like '%load%master%'
select * from dw_developer.tabledictionary where tpktablename like '%WHSMST%'
select * from dw_developer.tabledictionary where tpktablename like '%WHSMST%'
select * from dw_developer.tabledictionary where tpktablename like '%breakdown%'


select * from dw_developer.tabledictionary where tpktablename like '%snapshot%'
select TOP 10 * from Distribution_Warehouse_Wholesale.LoadMaster  where wh_id = '335'
select TOP 10 * from Distribution_Warehouse_Wholesale.t_order  where wh_id = '335'
select TOP 10 * from Distribution_Warehouse_Wholesale.t_order  where wh_id = '335'



-- 查询明细数据：Trip Item 明细、已拣货数、确认状态等
SELECT 
    orb.item_number,
    SUM(orb.qty) AS trip_needed,
    SUM(ISNULL(pkd.picked_quantity, 0)) AS picked_qty
FROM Distribution_Warehouse_Wholesale.LoadMaster ldm (NOLOCK)
JOIN Distribution_Warehouse_Wholesale.t_order orm (NOLOCK)
    ON ldm.wh_id = orm.wh_id AND ldm.load_id = orm.load_id
JOIN t_order_detail_breakdown orb (NOLOCK)
    ON orb.wh_id = ldm.wh_id AND orb.order_number = orm.order_number
LEFT JOIN t_load_dispatch ldd (NOLOCK)
    ON ldd.load_id = ldm.load_id AND ldd.wh_id = ldm.wh_id
LEFT JOIN t_pick_detail pkd (NOLOCK)
    ON pkd.load_id = ldm.load_id AND pkd.wh_id = ldm.wh_id AND pkd.item_number = orb.item_number
WHERE ldm.wh_id = '335'
  AND ldm.dispatch_date + ldm.dispatch_time 
      BETWEEN CONVERT(DATETIME, '2024-01-01') AND CONVERT(DATETIME, '2024-12-31')
  AND ldm.status NOT IN ('S', 'X', 'C')
  AND ldm.load_type = 'B'
  AND (
        CASE 
            WHEN 'Y' = 'A' THEN 'Y'
            ELSE ISNULL(ldd.dispatch_confirmed, 'N')
      END = 'Y'
  )
GROUP BY orb.item_number
ORDER BY orb.item_number;
