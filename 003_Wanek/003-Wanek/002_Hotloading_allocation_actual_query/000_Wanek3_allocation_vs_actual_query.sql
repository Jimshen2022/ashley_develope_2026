-- by item and order type
SELECT
    t3.tran_type,
    t3.description,
    t3.start_tran_date,
    t3.item_number,
    t3.control_number_2,
    DATEPART(HOUR, t3.start_tran_time) AS TRAN_HOUR,
    SUM(t3.tran_qty) AS qty
FROM [PowerBI_Distribution].[TranLog] AS t3
WHERE t3.wh_id = '35'
    AND t3.item_number = '9140689'
    AND t3.tran_type = '374'    -- crossdock Crossdock Transfer SN (put)
    AND t3.control_number_2 = '17'
    AND t3.start_tran_date = '2025-05-21'
GROUP BY
    t3.tran_type,
    t3.description,
    t3.start_tran_date,
    t3.item_number,
    t3.control_number_2,
    DATEPART(HOUR, t3.start_tran_time)
ORDER BY
    TRAN_HOUR


-- by item to query whole week tran qty summary
SELECT
    t3.control_number_2 as trip_nbr,
    t3.item_number,
    t3.control_number,
    SUM(CASE WHEN t3.start_tran_date = '2025-05-18' THEN t3.tran_qty ELSE 0 END) AS [2025-05-18],
    SUM(CASE WHEN t3.start_tran_date = '2025-05-19' THEN t3.tran_qty ELSE 0 END) AS [2025-05-19],
    SUM(CASE WHEN t3.start_tran_date = '2025-05-20' THEN t3.tran_qty ELSE 0 END) AS [2025-05-20],
    SUM(CASE WHEN t3.start_tran_date = '2025-05-21' THEN t3.tran_qty ELSE 0 END) AS [2025-05-21],
    SUM(CASE WHEN t3.start_tran_date = '2025-05-22' THEN t3.tran_qty ELSE 0 END) AS [2025-05-22],
    SUM(CASE WHEN t3.start_tran_date = '2025-05-23' THEN t3.tran_qty ELSE 0 END) AS [2025-05-23]
FROM [PowerBI_Distribution].[TranLog] AS t3
WHERE t3.wh_id = '35'
  AND t3.item_number = '9140689'
  AND t3.tran_type = '374'
  AND t3.start_tran_date BETWEEN '2025-05-18' AND '2025-05-23'
GROUP BY
    t3.control_number_2,
    t3.item_number,
    t3.control_number
ORDER BY
    t3.item_number, trip_nbr, control_number;