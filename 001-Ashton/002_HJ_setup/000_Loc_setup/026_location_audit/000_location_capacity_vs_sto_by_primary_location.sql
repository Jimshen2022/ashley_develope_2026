WITH itm AS (
SELECT * 
FROM Distribution_Warehouse_Wholesale.t_item_master as  itm 
WHERE itm.wh_id = '335'
),
fp AS (
SELECT *
FROM Distribution_Warehouse_Wholesale.t_forward_pick as t1
WHERE t1.wh_id = '335'
),
loc as 
(SELECT * 
FROM Distribution_Warehouse_Wholesale.t_location as t 
WHERE t.wh_id='335'
	and t.location_id like 'A3%'),
sto AS (
SELECT  sto.item_number,
        SUM(sto.actual_qty) AS actual_qty
    SELECT TOP 10 *
    FROM Distribution_Warehouse_Wholesale.t_stored_item sto
    WHERE sto.wh_id = '335'
		AND sto.type = 'STORAGE'
		AND sto.location_id LIKE 'A3%'
	GROUP BY sto.item_number
)
SELECT t1.location_id, 
	t1.status,
	t1.TypeDescription,
	t1.cycle_count_class,
	t1.capacity_qty,
	t1.stored_qty,
	t1.pick_area,
	t1.c2,
	t1.item_hu_indicator,
	t1.location_aisle,
	t1.location_tier,
	t1.length,
	t1.width,
	t1.height,
	f.Itemnumber,
	f.ReplenLevel,
	f.ReplenQty,
	f.CapacityQty,
	f.IsNewItem
FROM  loc as t1
LEFT JOIN fp as f ON f.LocationId = t1.location_id
ORDER BY t1.location_id


SELECT * from Distribution_Warehouse_Wholesale.t_forward_pick as t1 WHERE t1.wh_id = '335' 
