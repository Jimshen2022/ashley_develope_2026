SELECT t.location_id, t.status, t.type,
       e.tran_type, e.description, e.exception_date, e.exception_time, e.employee_id,
       SUM(s.actual_qty) AS onhand
FROM t_location AS t
LEFT JOIN t_stored_item AS s 
       ON t.location_id = s.location_id
LEFT JOIN (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY location_id 
               ORDER BY exception_date DESC, exception_time DESC
           ) AS rn
    FROM t_exception_tran_log
    WHERE tran_type IN ('202F2','252F2')
) AS e 
       ON t.location_id = e.location_id 
       AND e.rn = 1
WHERE t.status = 'F' 
  AND t.location_id LIKE 'A3%'
GROUP BY t.location_id, t.status, t.type,
         e.tran_type, e.description, e.exception_date, e.exception_time, e.employee_id
HAVING SUM(s.actual_qty) IS NULL;