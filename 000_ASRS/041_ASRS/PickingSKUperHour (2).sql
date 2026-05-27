WITH

WITH base_data AS (
    SELECT 
        CAST(start_tran_date AS DATE) AS tran_date,
        DATEPART(HOUR, start_tran_time) AS tran_hour,
        DATEPART(HOUR, start_tran_time) / 2 AS tran_2hour,
        DATEPART(HOUR, start_tran_time) / 3 AS tran_3hour,
        DATEPART(HOUR, start_tran_time) / 4 AS tran_4hour,
        item_number,
        SUM(tran_qty) AS picked_qty
    FROM Distribution_Warehouse_Wholesale.TranLog
    WHERE tran_type LIKE '363' 
        AND start_tran_date >= '2025-10-01' 
        AND wh_id = '335'
    GROUP BY 
        CAST(start_tran_date AS DATE),
        DATEPART(HOUR, start_tran_time),
        item_number
)
SELECT 
    b.tran_date,
    b.tran_hour,
    b.item_number,
    CASE 
        WHEN COUNT(*) OVER (PARTITION BY b.tran_date, b.tran_hour, b.item_number) > 1 
        THEN 0 ELSE 1 
    END AS sku_count_by_hour,
    CASE 
        WHEN ROW_NUMBER() OVER (PARTITION BY b.tran_date, b.tran_2hour, b.item_number ORDER BY b.tran_hour) = 1 
        THEN 1 ELSE 0 
    END AS sku_count_2h,
    CASE 
        WHEN ROW_NUMBER() OVER (PARTITION BY b.tran_date, b.tran_3hour, b.item_number ORDER BY b.tran_hour) = 1 
        THEN 1 ELSE 0 
    END AS sku_count_3h,
    CASE 
        WHEN ROW_NUMBER() OVER (PARTITION BY b.tran_date, b.tran_4hour, b.item_number ORDER BY b.tran_hour) = 1 
        THEN 1 ELSE 0 
    END AS sku_count_4h,
    b.picked_qty
FROM base_data b
ORDER BY 
    b.tran_date,
    b.tran_hour,
    b.item_number



--SELECT 
--    CAST(start_tran_date AS DATE) AS tran_date,
--    DATEPART(HOUR, start_tran_time) AS tran_hour,
--    COUNT(DISTINCT item_number) AS sku_count
--FROM Distribution_Warehouse_Wholesale.TranLog
--WHERE tran_type LIKE '363' and start_tran_date >= '2025-10-01' and wh_id = '335'
--GROUP BY 
--    CAST(start_tran_date AS DATE),
--    DATEPART(HOUR, start_tran_time)
--ORDER BY 
--    tran_date,
--    tran_hour