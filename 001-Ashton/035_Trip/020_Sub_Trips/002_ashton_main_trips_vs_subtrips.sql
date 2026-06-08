WITH fill_trips AS (
    SELECT LEFT(t1.control_number_2, 7) * 1 AS trip_nbr
    FROM Distribution_Warehouse_Wholesale.TranLog AS t1
    WHERE t1.wh_id = '335'
      AND t1.start_tran_date > '2025-01-01'
      AND t1.tran_type = '347'
      AND t1.control_number_2 NOT LIKE '%-00'
      AND ISNUMERIC(LEFT(t1.control_number_2, 7)) = 1
),
i AS (
    SELECT
        t0.ITNBR,
        t0.STID,
        t0.ITCLS,
        t0.B2Z95S,
        t0.ITDSC
    FROM MasterData_ItemMaster_AFI.ITMRVA AS t0
    WHERE t0.STID = '335'
)
SELECT
    t1.start_tran_date,
    t1.tran_type,
    t1.description,
    t1.control_number_2,
    TRY_CONVERT(INT, LEFT(t1.control_number_2, 7)) AS trip_nbr,
    t1.item_number,
    ROW_NUMBER() OVER (
        PARTITION BY TRY_CONVERT(INT, LEFT(t1.control_number_2, 7))
        ORDER BY t1.start_tran_date
    ) AS rn,
    CASE
        WHEN ROW_NUMBER() OVER (
            PARTITION BY TRY_CONVERT(INT, LEFT(t1.control_number_2, 7))
            ORDER BY t1.start_tran_date
        ) = 1 THEN 1
        ELSE 0
    END AS trips_count,
CASE
    WHEN t1.control_number_2 LIKE '%-00' THEN 0 -- 如果以 '-00' 结尾
    WHEN ROW_NUMBER() OVER (
            PARTITION BY t1.control_number_2
            ORDER BY t1.control_number_2
        ) = 1 THEN 1 -- 第一行
    ELSE 0 -- 其他情况
    END AS sub_trips_count,
    CASE
        WHEN t1.control_number_2 NOT LIKE '%-00' THEN 'sub-trip'
        ELSE 'main_trip'
    END AS trip_type,
    SUM(t1.tran_qty) AS tran_qty,
    SUM(t1.tran_qty) * i.B2Z95S AS Cubes
FROM Distribution_Warehouse_Wholesale.TranLog AS t1
LEFT JOIN i ON i.ITNBR = t1.item_number
INNER JOIN fill_trips AS trips ON TRY_CONVERT(INT, LEFT(t1.control_number_2, 7)) = trips.trip_nbr
WHERE t1.wh_id = '335'
  AND t1.start_tran_date > '2025-01-01'
  AND t1.tran_type = '347'
  AND ISNUMERIC(LEFT(t1.control_number_2, 7)) = 1
GROUP BY
    t1.start_tran_date,
    t1.tran_type,
    t1.description,
    t1.control_number_2,
    TRY_CONVERT(INT, LEFT(t1.control_number_2, 7)),
    t1.item_number,
    i.B2Z95S,
    CASE
        WHEN t1.control_number_2 NOT LIKE '%-00' THEN 'sub-trip'
        ELSE 'main_trip'
    END
ORDER BY TRY_CONVERT(INT, LEFT(t1.control_number_2, 7)), t1.start_tran_date;