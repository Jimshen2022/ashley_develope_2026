/* SELECT orm.wh_id,
       orm.order_number,
       orm.arrive_date,
       hts.stage_loc,
       ldm.door_loc,
       ldm.load_id,
       ldm.equipment_id,
       orm.customer_id AS destination,
       '~arrive_date~' AS scr_etd,
       '~destination~' AS scr_destination,
	   isnull(ldm.status,'R') as status
FROM   t_order(nolock) orm
       JOIN t_lookup (nolock) lkp
         ON orm.wh_id = lkp.wh_id
            AND orm.load_id = lkp.text
            AND lkp.source = 'HotLoad_ATP_SKIP'
            AND lkp.lookup_type = 'TRSFWHID'
            AND lkp.locale_id = '1033'
       JOIN t_lookup (nolock) tup
         ON orm.wh_id = tup.wh_id
            AND orm.type_id = tup.lookup_id
            AND tup.source = 't_order'
            AND tup.lookup_type = 'TYPE'
            AND tup.locale_id = '1033'
            AND tup.text = 'HotLoad Orders'
       LEFT JOIN t_hotloading_stage (nolock)hts
              ON hts.wh_id = orm.wh_id
                 AND hts.order_number = orm.order_number
       LEFT JOIN t_load_master(nolock) ldm
              ON orm.wh_id = ldm.wh_id
                 AND orm.customer_id = ldm.transfer_wh_id
                 AND ldm.load_id = hts.load_id
WHERE  orm.wh_id = '~wh_id~'
       AND orm.arrive_date >= '~arrive_date~'
       AND orm.load_id LIKE '~destination~'
       AND Isnull(ldm.status, '') <> 'S'
       AND orm.status NOT IN ( 'C', 'X' )
ORDER  BY orm.wh_id,
          orm.order_number,
          orm.arrive_date */


SELECT orm.wh_id,
       orm.order_number,
       orm.arrive_date,
       hts.stage_loc,
       ldm.door_loc,
       ldm.load_id,
       ldm.equipment_id,
       orm.customer_id AS destination,
       '~arrive_date~' AS scr_etd,
       '~destination~' AS scr_destination,
	   isnull(ldm.status,'R') as status
	   ,case when orm.customer_id in (select text from t_lookup where source ='HotLoad_ATP_SKIP'and lookup_type='TRSFWHID'
and locale_id ='1033')
	    then '' 
		else 'Add' end as 'action'

FROM   t_order(nolock) orm
       JOIN t_lookup (nolock) lkp
         ON orm.wh_id = lkp.wh_id
            AND orm.load_id = lkp.text
            AND lkp.source ='t_load_master'-- 'HotLoad_ATP_SKIP'
            AND lkp.lookup_type = 'TRSFWHID'
            AND lkp.locale_id = '1033'
       JOIN t_lookup (nolock) tup
         ON orm.wh_id = tup.wh_id
            AND orm.type_id = tup.lookup_id
            AND tup.source = 't_order'
            AND tup.lookup_type = 'TYPE'
            AND tup.locale_id = '1033'
            AND tup.text = 'HotLoad Orders'
       LEFT JOIN t_hotloading_stage (nolock)hts
              ON hts.wh_id = orm.wh_id
                 AND hts.order_number = orm.order_number
       LEFT JOIN t_load_master(nolock) ldm
              ON orm.wh_id = ldm.wh_id
                 AND orm.customer_id = ldm.transfer_wh_id
                 AND ldm.load_id = hts.load_id
WHERE  orm.wh_id = '~wh_id~'
       AND orm.arrive_date >= '~arrive_date~'
       AND orm.load_id LIKE '~destination~'
       AND Isnull(ldm.status, '') <> 'S'
       AND orm.status NOT IN ( 'C', 'X' )
ORDER  BY orm.wh_id,
          orm.order_number,
          orm.arrive_date
