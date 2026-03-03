SELECT orm.wh_id,
       orm.order_number,
       orm.load_id,
       orm.arrive_date,
       pkd.item_number,
       Isnull(Sum(pkd.planned_quantity), 0)                                          AS order_qty,
       ( Isnull(Sum(pkd.planned_quantity), 0) - Isnull(Sum(pkd.picked_quantity), 0) )AS remains_qty,
	   pkd.status,
       pkd.pick_location,
       pkd.pick_area,
       'Replan'                                                                      AS 'Action'
FROM   t_order (nolock) orm
       JOIN t_pick_detail (nolock) pkd
         ON orm.wh_id = pkd.wh_id
            AND orm.order_number = pkd.order_number
            AND orm.load_id = pkd.load_id
WHERE  orm.status <> 'C'
       AND orm.load_id = '~load_id~'
       AND orm.order_number = '~order_number~'
       AND orm.wh_id = '~wh_id~'
GROUP  BY orm.wh_id,
          orm.order_number,
          orm.load_id,
          orm.arrive_date,
          pkd.item_number,
		  pkd.status,
          pkd.pick_location,
          pkd.pick_area
HAVING( Isnull(Sum(pkd.planned_quantity), 0) - Isnull(Sum(pkd.picked_quantity), 0) > 0 )
ORDER  BY orm.order_number,
          orm.load_id,
          orm.arrive_date,
          pkd.item_number 
