SELECT TOP 1000 *  FROM INFORMATION_SCHEMA.COLUMNS WHERE Column_name LIKE '%cube%fact%'
SELECT TOP 1000 *  FROM INFORMATION_SCHEMA.COLUMNS WHERE Column_name LIKE '%cube%fact%'


SELECT TOP 10 *  FROM t_item_uom where item_number = 'U2710518'
SELECT TOP 10 *  FROM v_item_uom_factored_cube where item_number = 'U2710518'
SELECT TOP 10 *  FROM t_stored_item where item_number = 'U2710518'


SET cube_factor = ROUND((50000.0 / nested_volume) / (8.0 / 4), 2, 1)
where class_id ='UPHMLL' and pick_put_id = 'UPH' and nested_volume >0


t_item_uom
select *
from t_item_master 
where item_number = 'U2710518'


SELECT t.*,si.actual_qty  
FROM t_item_uom as t 
JOIN (select t.item_number, sum(t.actual_qty) as actual_qty  from t_stored_item as t group by t.item_number)AS si
	ON t.item_number = si.item_number
WHERE t.pick_put_id = 'UPH'