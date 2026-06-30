SELECT
    l.location_id,
    l.status,
    l.type,
    sto.onhand,
    sto.SKUs
FROM t_location AS l
LEFT JOIN (
    SELECT
        location_id,
        SUM(actual_qty) AS onhand,
        COUNT(DISTINCT item_number) AS SKUs
    FROM t_stored_item
    GROUP BY location_id
) AS sto
    ON sto.location_id = l.location_id
WHERE l.type = 'X'
  AND (sto.SKUs = 1 OR sto.SKUs IS NULL)
  AND l.location_id LIKE 'A3%'
ORDER BY l.location_id;
