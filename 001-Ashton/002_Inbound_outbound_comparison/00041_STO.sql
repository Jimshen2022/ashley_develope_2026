With
sto as
	(SELECT  * FROM Distribution_Warehouse_Wholesale.t_stored_item as a8  WHERE a8.wh_id in ('335')),
loc as
	(SELECT  * FROM Distribution_Warehouse_Wholesale.t_location as a9 where a9.wh_id in ('335')),
stock as (
	SELECT  sto.item_number, MIN(sto.location_id) as location_id , sum(sto.actual_qty) as Qty
	FROM  sto
	JOIN  loc
 		ON loc.location_id = sto.location_id AND loc.TypeDescription IN ('I', 'M', 'Y', 'X','P') AND loc.wh_id = sto.wh_id
	JOIN  (SELECT * FROM Distribution_Warehouse_Wholesale.t_item_master AS a2 where a2.wh_id in ('335')) AS itm
		ON sto.item_number = itm.item_number AND itm.pick_put_id LIKE '%' AND sto.wh_id = itm.wh_id
	GROUP BY sto.item_number, sto.actual_qty
)
-----------main query ---------------------
select *
from stock as s
ORDER BY s.item_number, s.location_id