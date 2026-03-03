With sto as
	(SELECT  * FROM Distribution_Warehouse_Wholesale.t_stored_item as a8  WHERE a8.wh_id in ('335')),
loc as
	(SELECT  * FROM Distribution_Warehouse_Wholesale.t_location as a9 where a9.wh_id in ('335'))

-----------main query ---------------------
SELECT sto.item_number, sto.location_id, sto.[type],loc.TypeDescription,
               Sum(sto.actual_qty) AS qty
        FROM  sto
               JOIN  loc
                 ON sto.location_id = loc.location_id
				 AND sto.wh_id = loc.wh_id
        WHERE  sto.[type] <> 'STORAGE'
               AND sto.actual_qty > 0
               AND loc.TypeDescription = 'S'
			   AND sto.wh_id = '335'
        GROUP  BY  sto.item_number, sto.location_id, sto.[type],loc.TypeDescription