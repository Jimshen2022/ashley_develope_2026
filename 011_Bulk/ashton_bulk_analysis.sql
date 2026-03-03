-- BULK item issue summary
WITH base_data AS (
    SELECT 
        cast(t.start_tran_date as date) start_tran_date, 
        t.item_number, 
        LEFT(t.control_number_2, 7) AS trips, 
        SUM(t.tran_qty) AS total_qty,
        CASE 
            WHEN SUM(t.tran_qty) >= 0 AND SUM(t.tran_qty) < 4 THEN '0-3 pcs'
            WHEN SUM(t.tran_qty) >= 4 AND SUM(t.tran_qty) < 7 THEN '4-6 pcs'
            WHEN SUM(t.tran_qty) >= 7 AND SUM(t.tran_qty) < 10 THEN '7-9 pcs'
            WHEN SUM(t.tran_qty) >= 10 THEN '10+ pcs'
            ELSE 'Unknown'
        END AS bucket
    FROM t_tran_log t
    INNER JOIN t_item_master AS m ON t.item_number = m.item_number
    WHERE t.tran_type = '363' 
        AND m.class_id IN ('FLOOR')
    GROUP BY t.start_tran_date, t.item_number, LEFT(t.control_number_2, 7)
)
SELECT 
    bucket,
    SUM(total_qty) AS total_qty,
    COUNT(DISTINCT trips) AS trips_count,
    COUNT(DISTINCT item_number) AS SKUs,
    ROUND(SUM(total_qty) * 1.0 / COUNT(DISTINCT trips), 2) AS avg_pieces_per_trip,
    ROUND(COUNT(DISTINCT item_number) * 1.0 / COUNT(DISTINCT trips), 2) AS avg_skus_per_trip
FROM base_data
GROUP BY bucket
ORDER BY 
    CASE bucket
        WHEN '0-3 pcs' THEN 1
        WHEN '4-6 pcs' THEN 2
        WHEN '7-9 pcs' THEN 3
        WHEN '10+ pcs' THEN 4
        ELSE 5
    END