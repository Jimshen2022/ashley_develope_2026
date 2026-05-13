SELECT pkd.order_number,
       orm.load_id AS transfer_wh_id,
       CASE
         WHEN pkd.status = 'LOADED' THEN Sum(pkd.loaded_quantity)
         ELSE 0
       END         AS pieces_loaded,
       CASE
         WHEN pkd.status IN( 'RELEASED', 'CROSSDOCK' ,'HOLD','REPLAN') THEN Sum(pkd.planned_quantity - pkd.picked_quantity)    ---2015/04/20 Grace Liu change add hold and replan status
         ELSE 0  
       END         AS planned_quantity,
	    CASE
         WHEN pkd.status ='UNAVAILABL' THEN Sum(pkd.planned_quantity)
         ELSE 0
       END         AS unavailable_quantity,
	   ----2014/08/13 Grace Liu Create
	   CASE
	    WHEN pkd.status='STAGED' then Sum(pkd.staged_quantity)
		ELSE 0
	   END		AS staged_quantity,
	   sum(pkd.planned_quantity) as needed_quantity,
	   ---2014/08/13 Grace liu end 
       pkd.status,
       pkd.pick_area,
       pkd.wh_id
FROM   t_pick_detail pkd (nolock)
       INNER JOIN t_order orm (nolock)
               ON orm.order_number = pkd.order_number
                  AND orm.wh_id = pkd.wh_id
                  AND orm.status NOT IN( 'S', 'X', 'C' )
       JOIN t_lookup(nolock)lup
         ON orm.type_id = lup.lookup_id
		    AND orm.wh_id = lup.wh_id
            AND lup.text = 'HotLoad Orders'
            AND source = 't_order'
            and lup.locale_id='1033'
       LEFT OUTER JOIN t_item_uom itu (nolock)
                    ON itu.item_number = pkd.item_number
                       AND itu.wh_id = pkd.wh_id
                       AND itu.conversion_factor = (SELECT Min(conversion_factor)
                                                    FROM   t_item_uom itu2 (nolock)
                                                    WHERE  itu2.item_number = itu.item_number
                                                           AND itu2.wh_id = itu.wh_id)
WHERE  pkd.work_type = '35'
       AND pkd.status <> 'SHIPPED'
       --AND pkd.status <> 'UNAVAILABL'
       AND pkd.status <> 'PICKED'
	   AND pkd.wh_id= '~wh_id~'
AND (case '~load_id~' when '%' then orm.load_id else  '~load_id~' end)= orm.load_id
GROUP  BY pkd.order_number,
          orm.load_id,
          pkd.pick_area,
          pkd.status,
          pkd.wh_id
ORDER  BY pkd.order_number 

