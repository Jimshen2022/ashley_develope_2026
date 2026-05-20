WITH Lot151 AS (
    -- Get all unique lot_numbers with tran_type = '151' from 2026-01-01
    SELECT DISTINCT lot_number
    FROM Distribution_Warehouse_Wholesale.tranlog
    WHERE wh_id = '335'
      AND tran_type = '151'
      AND start_tran_date >= '2026-01-01'
      AND lot_number IS NOT NULL
),
Tran152 AS (
    -- Get finish datetime for tran_type = '152'
    SELECT 
        lot_number,
        CONVERT(DATETIME, 
            CONVERT(VARCHAR(10), end_tran_date, 120) + ' ' + 
            CONVERT(VARCHAR(8), end_tran_time, 108)
        ) AS finish_datetime_152
    FROM Distribution_Warehouse_Wholesale.tranlog
    WHERE wh_id = '335'
      AND tran_type = '152'
      AND lot_number IN (SELECT lot_number FROM Lot151)
),
Tran202 AS (
    -- Get start move datetime for tran_type = '202'
    SELECT 
        lot_number,
        CONVERT(DATETIME, 
            CONVERT(VARCHAR(10), start_tran_date, 120) + ' ' + 
            CONVERT(VARCHAR(8), start_tran_time, 108)
        ) AS start_move_datetime_202
    FROM Distribution_Warehouse_Wholesale.tranlog
    WHERE wh_id = '335'
      AND tran_type = '202'
      AND lot_number IN (SELECT lot_number FROM Lot151)
),
Tran855 AS (
    -- Check if tran_type = '855' exists for each lot_number
    SELECT DISTINCT
        lot_number,
        'Y' AS has_855
    FROM Distribution_Warehouse_Wholesale.tranlog
    WHERE wh_id = '335'
      AND tran_type = '855'
      AND lot_number IN (SELECT lot_number FROM Lot151)
)
SELECT 
    l.lot_number,
    t152.finish_datetime_152 AS [152_finish_datetime],
    t202.start_move_datetime_202 AS [202_start_move_datetime],
    DATEDIFF(SECOND, t152.finish_datetime_152, t202.start_move_datetime_202) AS Time_seconds,
    CASE 
        WHEN DATEDIFF(SECOND, t152.finish_datetime_152, t202.start_move_datetime_202) IS NULL THEN NULL
        WHEN DATEDIFF(SECOND, t152.finish_datetime_152, t202.start_move_datetime_202) < 0 THEN 'Negative Time'
        WHEN DATEDIFF(SECOND, t152.finish_datetime_152, t202.start_move_datetime_202) <= 60 THEN '0~1min'
        WHEN DATEDIFF(SECOND, t152.finish_datetime_152, t202.start_move_datetime_202) <= 120 THEN '1~2mins'
        WHEN DATEDIFF(SECOND, t152.finish_datetime_152, t202.start_move_datetime_202) <= 180 THEN '2~3mins'
        WHEN DATEDIFF(SECOND, t152.finish_datetime_152, t202.start_move_datetime_202) <= 240 THEN '3~4mins'
        WHEN DATEDIFF(SECOND, t152.finish_datetime_152, t202.start_move_datetime_202) <= 300 THEN '4~5mins'
        WHEN DATEDIFF(SECOND, t152.finish_datetime_152, t202.start_move_datetime_202) <= 600 THEN '5~10mins'
        WHEN DATEDIFF(SECOND, t152.finish_datetime_152, t202.start_move_datetime_202) <= 900 THEN '10~15mins'
        WHEN DATEDIFF(SECOND, t152.finish_datetime_152, t202.start_move_datetime_202) <= 1800 THEN '15~30mins'
        WHEN DATEDIFF(SECOND, t152.finish_datetime_152, t202.start_move_datetime_202) <= 3600 THEN '30~60mins'
        WHEN DATEDIFF(SECOND, t152.finish_datetime_152, t202.start_move_datetime_202) <= 7200 THEN '1~2hours'
        WHEN DATEDIFF(SECOND, t152.finish_datetime_152, t202.start_move_datetime_202) <= 10800 THEN '2~3hours'
        WHEN DATEDIFF(SECOND, t152.finish_datetime_152, t202.start_move_datetime_202) <= 14400 THEN '3~4hours'
        WHEN DATEDIFF(SECOND, t152.finish_datetime_152, t202.start_move_datetime_202) <= 21600 THEN '4~6hours'
        WHEN DATEDIFF(SECOND, t152.finish_datetime_152, t202.start_move_datetime_202) <= 28800 THEN '6~8hours'
        WHEN DATEDIFF(SECOND, t152.finish_datetime_152, t202.start_move_datetime_202) <= 43200 THEN '8~12hours'
        WHEN DATEDIFF(SECOND, t152.finish_datetime_152, t202.start_move_datetime_202) <= 86400 THEN '12~24hours'
        ELSE '>24hours'
    END AS Time_seconds_intervals,
    ISNULL(t855.has_855, 'N') AS exists_855
FROM Lot151 l
LEFT JOIN Tran152 t152 ON l.lot_number = t152.lot_number
LEFT JOIN Tran202 t202 ON l.lot_number = t202.lot_number
LEFT JOIN Tran855 t855 ON l.lot_number = t855.lot_number
WHERE t152.finish_datetime_152 IS NOT NULL 
   OR t202.start_move_datetime_202 IS NOT NULL
ORDER BY l.lot_number;

