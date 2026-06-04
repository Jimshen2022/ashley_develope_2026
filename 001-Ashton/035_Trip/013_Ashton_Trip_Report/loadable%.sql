SELECT odb.item_number,
       Isnull((SELECT Sum(planned_quantity)
               FROM   t_pick_detail P (nolock)
                      JOIN t_load_master M (nolock)
                        ON P.load_id = M.load_id
                           AND M.status <> 'S'
               WHERE  P.item_number = odb.item_number
                      AND P.status = 'RELEASED'
                      AND P.wh_id = M.wh_id
                      AND P.wh_id = '~wh_id~'), 0) AS planned_quantity
INTO   #Temp
FROM   t_order_detail_breakdown odb (nolock)
join   t_order (nolock) orm on odb.wh_id=orm.wh_id and odb.order_number=orm.order_number
WHERE  odb.wh_id = '~wh_id~'
     /*  AND LEFT(odb.order_number, 10) LIKE '~load_id~' */
	 and orm.load_id like '~load_id~'
GROUP  BY odb.item_number
ORDER  BY item_number

SELECT T1.wh_id,
       T1.trip,
       T1.order_number,
       T1.c_number,
       T1.sequence_number,
       T1.item_number,
       T1.set_group,
       T1.planned_qty,
       T1.bo_qty,
       T1.remove_line_goto,
       T1.remove_set_goto,
       T1.remove_c_number_goto,
       T1.warehouse_inventory,
       T1.allocated_inventory,
       T1.hold_quantity,
       ( T1.warehouse_inventory - T1.allocated_inventory ) AS total_available,
       T1.flag,
       T1.line_number,
       T1.lot_number,
       T1.ship_status
FROM   (SELECT odb.wh_id,
             /*  Substring(odb.order_number, 1, 10)             AS trip, */
			   orm.load_id							as trip,
               odb.order_number,
               odb.c_number,
               odb.sequence_number,
               odb.item_number,
               odb.line_number,
               odb.lot_number,
               odb.set_group,
               Sum(odb.qty)                                   AS planned_qty,
               Isnull((SELECT Sum(sto.actual_qty)
                       FROM   t_stored_item sto (nolock),
                              t_location loc (nolock),
                              t_building bld (nolock)
                       WHERE  sto.item_number = odb.item_number
                              AND sto.wh_id = odb.wh_id
                              AND sto.wh_id = loc.wh_id
                              AND sto.location_id = loc.location_id
                              AND loc.building = bld.building
                              AND loc.type IN ( 'M', 'I', 'P', 'A', 'X' )
                              AND sto.status = 'A'
                              AND sto.actual_qty > 0
                              AND bld.offsite_flag = 'N'
                              AND sto.wh_id = bld.wh_id
                              AND sto.wh_id = '~wh_id~'), 0)  AS warehouse_inventory,
               (SELECT #Temp.planned_quantity
                FROM   #Temp
                WHERE  odb.item_number = #Temp.item_number)   AS allocated_inventory,
               (SELECT Sum(actual_qty)
                FROM   t_stored_item sto (nolock)
                WHERE  status = 'H'
                       AND sto.item_number = odb.item_number
                       AND sto.wh_id = '~wh_id~')             AS hold_quantity,
               (SELECT Count(*)
                FROM   t_order_detail_breakdown (nolock)
                WHERE  order_number = odb.order_number
                       AND wh_id = odb.wh_id
                       AND item_number = odb.item_number
                       AND c_number = odb.c_number
                       AND line_number = odb.line_number
                       AND ( ship_status = 'B'
                              OR ship_status = 'BACKORDER' )) AS bo_qty,
               CASE
                 WHEN (SELECT Count(status)
                       FROM   t_load_master (nolock)
                       WHERE  load_id = '~load_id~'
                              AND wh_id = '~wh_id~'
                              AND status IN( 'R', 'H', 'N' )) > 0 THEN 'BO Line'
                 ELSE ''
               END                                            AS remove_line_goto,
               CASE
                 WHEN (SELECT Count(status)
                       FROM   t_load_master (nolock)
                       WHERE  load_id = '~load_id~'
                              AND wh_id = '~wh_id~'
                              AND status IN( 'H', 'N', 'R' )) > 0 THEN 'BO Set'
                 ELSE ''
               END                                            AS remove_set_goto,
               CASE
                 WHEN (SELECT Count(status)
                       FROM   t_load_master (nolock)
                       WHERE  load_id = '~load_id~'
                              AND wh_id = '~wh_id~'
                              AND status IN( 'H', 'N', 'R' )) > 0 THEN 'BO C#'
                 ELSE ''
               END                                            AS remove_c_number_goto,
               'N'                                            AS flag,
               odb.ship_status
        FROM   t_order_detail_breakdown odb (nolock)
		join  t_order (nolock) orm on odb.wh_id=orm.wh_id and odb.order_number=orm.order_number
        WHERE  odb.wh_id = '~wh_id~'
               AND (  /*LEFT(odb.order_number, 10) LIKE '~load_id~'   */
					 orm.load_id like '~load_id~'
                     AND odb.order_number IN (SELECT odb.order_number
                                              FROM   t_order_detail_breakdown odb (nolock)
											  join t_order (nolock) orm on odb.wh_id=orm.wh_id and odb.order_number=orm.order_number
                                              WHERE /* LEFT(odb.order_number, 10) LIKE '~load_id~' */
													  orm.load_id LIKE '~load_id~'
                                                     AND item_number = '~item_number~') )
        GROUP  BY odb.wh_id,
                /*  Substring(odb.order_number, 1, 10), */
				  orm.load_id,
                  odb.order_number,
                  odb.c_number,
                  odb.sequence_number,
                  odb.item_number,
                  odb.line_number,
                  odb.lot_number,
                  odb.set_group,
                  ship_status) T1
ORDER  BY T1.wh_id,
          T1.trip,
          T1.order_number,
          T1.c_number,
          T1.sequence_number,
          T1.item_number,
          T1.set_group

DROP TABLE #Temp