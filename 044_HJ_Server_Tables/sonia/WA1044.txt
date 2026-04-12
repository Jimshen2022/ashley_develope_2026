~~Default~~
SELECT DISTINCT t_location.wh_id, 
    t_location.location_id,
    t_location.type, 
    t_location.status, 
    t_location.picking_flow,
    t_location.pick_area,
    t_location.cycle_count_class,
     t_location.last_count_date  AS cycle_count_date,
    t_location.capacity_volume,
    t_location.c1,
    t_location.c2,
    t_location.c3,
    t_location.building,
    t_location.cycle_count_flag,
    t_location.item_hu_indicator,
    t_location.location_aisle,
    t_location.location_tier,
    t_location.dependent_location,
    t_location.dependent_length,
    'Inventory' AS inv, 
    'License Plates' AS hu,
    'Transactions' AS trans, 
    'Exceptions' AS e,
    'Put-Away Classes' AS put,    
    'Zones' AS z,
    'Equipment Classes' AS equip,
   '%' AS tran_type, 
    getdate ()-180 AS Begin_date,
    getdate() as End_date
    FROM t_location(NOLOCK) 
LEFT OUTER JOIN t_zone_loca(NOLOCK) 
	 ON t_location.location_id=t_zone_loca.location_id
	 AND t_location.wh_id = t_zone_loca.wh_id  
LEFT OUTER JOIN t_lookup lkp (NOLOCK)
	 ON t_location.type = lkp.text
	AND t_location.wh_id = lkp.wh_id
	AND lkp.locale_id = 1033
	AND lkp.source = 't_location'
	AND lkp.lookup_type = 'TYPE'
WHERE 
       t_location.wh_id LIKE '~WH_ID~'
        AND t_location.location_id LIKE '~Location_ID~'
        AND t_location.status LIKE '~Status~'
        AND isnull(t_zone_loca.zone,'') LIKE '~zone~'
        AND UPPER(t_location.type) LIKE UPPER('~Location_Type~')
       AND ISNULL(t_location.cycle_count_flag, '') like '~cycle_count_flag~'
       AND ISNULL(t_location.pick_area, '') like '~pick_area~'
       AND ISNULL(t_location.cycle_count_class, '') like '~cycle_count_class~'
    GROUP BY t_location.wh_id, 
    t_location.location_id,
    t_location.type, 
    t_location.status, 
    t_location.picking_flow,
    t_location.pick_area,
    t_location.cycle_count_class,
    t_location.last_count_date,
    t_location.capacity_volume,
    t_location.c1,
    t_location.c2,
    t_location.c3,
    t_location.building,
    t_location.cycle_count_flag,
    t_location.item_hu_indicator,
    t_location.location_aisle,
    t_location.location_tier,
    t_location.dependent_location,
    t_location.dependent_length
    ORDER BY t_location.location_id
	