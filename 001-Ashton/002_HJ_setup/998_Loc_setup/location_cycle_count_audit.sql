--select top 10 * from t_location as t
--select top 10 * from t_stored_item as t


SELECT 
    s.wh_id,
    s.item_number,
    s.location_id,
    l.last_count_date,
    l.last_physical_date,
    l.cycle_count_class,
    l.c2,
    l.cycle_count_flag,
    l.type,
SUM(s.actual_qty) AS on_hand_qty
FROM t_stored_item AS s
INNER JOIN t_location AS l
    ON s.location_id = l.location_id
WHERE 1=1
  AND SUBSTRING(s.location_id,1,2) NOT IN ('NG','DM','SH','EX','RP')  
  AND l.type NOT IN ('D','S','F','V')
  --AND (l.cycle_count_class not in ('1','2') or l.c2 is null)   
  AND l.cycle_count_flag = 'N'
GROUP BY 
    s.wh_id,
    s.item_number,
    s.location_id,
    l.last_count_date,
    l.last_physical_date,
    l.cycle_count_class,
    l.c2,
    l.cycle_count_flag,
    l.type;
