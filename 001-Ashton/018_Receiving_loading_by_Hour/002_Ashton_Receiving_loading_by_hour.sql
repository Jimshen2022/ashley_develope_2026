WITH LatestBookings AS (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY BokTripNumBer ORDER BY BokTripCreateDate DESC) AS rn
    FROM [Wholesale_ProductSourcing_AFI].[Bookings]
    WHERE BokWarehouse = '335'
),
container_nbr as (
    SELECT t.*, d.tpkModified
    FROM LatestBookings AS t
    CROSS JOIN (
        SELECT tpkModified
        FROM dw_developer.tabledictionary
        WHERE tpktablename LIKE 'Bookings'
    ) AS d
    WHERE t.rn = 1
      AND t.BokTripCreateDate > '2024-12-01'
),
itm AS (
    SELECT
         a.item_number,
         a.uom,
         a.pick_put_id,
         a.wh_id,
         a.class_id,
         a.uom_weight,
         a.unit_volume,
         a.nested_volume,
         CASE
		     WHEN a.class_id LIKE 'UPH%' THEN 'UPH'
             WHEN a.class_id NOT LIKE 'Z%' THEN 'CG'
             WHEN a.pick_put_id IN ('SMALL','PAL3H','PAL5H','RAILS','FLOOR','RPFG','FLOOROP','PAL5L','RUGS') THEN 'CG'
             WHEN a.class_id IS NULL AND a.pick_put_id = 'UPH' THEN 'UPH'
             WHEN a.class_id IS NULL AND a.pick_put_id = 'PALLT' THEN 'CG'
             WHEN LEFT(a.item_number, 1) IN ('A','D','E','H','K','L','M','P','Q','R','T','W') THEN 'CG'
             WHEN LEN(a.item_number) > 7 THEN 'CG'
             WHEN LEFT(a.item_number, 1) IN ('1','2','3','4','5','6','7','8','9','U') THEN 'UPH'
             ELSE 'CG'
         END AS product
    FROM Distribution_Warehouse_Wholesale.t_item_uom AS a
WHERE a.wh_id = '335' AND a.uom NOT IN ('SCOOP')
),
trx AS (
    SELECT
        t1.[start_tran_date],
        DATEPART(YYYY, t1.[start_tran_date]) * 100 + FORMAT(DATEPART(ISO_WEEK, t1.[start_tran_date]), '00') AS YearWeek,
        DATEPART(YYYY, t1.[start_tran_date]) * 100 + DATEPART(MONTH, t1.[start_tran_date]) AS YearMonth,
        t1.item_number,
        t1.tran_type,
        t1.description,
        t1.control_number,
        t1.control_number_2,
        t1.hu_id_2,
        t1.routing_code,
        i1.product,
        CASE
            WHEN t1.tran_type IN ('151', '183', '951') THEN CONCAT(t1.control_number, '_', t1.hu_id_2)
            WHEN t1.tran_type = '322' THEN (
                SELECT TOP 1 b.BokContainerNumBer
                FROM container_nbr AS b
                WHERE TRY_CAST(b.BokTripNumBer AS INT) = TRY_CAST(LEFT(t1.control_number_2, 7) AS INT)
            )
            ELSE 'CHECK'
        END AS Container_nbr,
        ROW_NUMBER() OVER (PARTITION BY t1.control_number, t1.hu_id_2 ORDER BY t1.start_tran_date) AS row_num_receiving,
        ROW_NUMBER() OVER (PARTITION BY CONCAT(LEFT(t1.control_number_2, CHARINDEX('-', t1.control_number_2 + '-') - 1), '_', t1.routing_code)
                           ORDER BY t1.start_tran_date) AS row_num_shipping,
        SUM(CASE
            WHEN t1.tran_type IN ('151', '183') THEN t1.tran_qty
            WHEN t1.tran_type IN ('951') THEN -t1.tran_qty ELSE 0 END) AS Received_Qty,
        SUM(CASE
            WHEN t1.tran_type IN ('151', '183') THEN t1.tran_qty * i1.unit_volume
            WHEN t1.tran_type IN ('951') THEN -t1.tran_qty * i1.unit_volume ELSE 0 END) AS Received_Cubes,
        SUM(CASE WHEN t1.tran_type = '322' THEN t1.tran_qty ELSE 0 END) AS Loaded_Qty,
        SUM(CASE WHEN t1.tran_type = '322' THEN t1.tran_qty * i1.unit_volume ELSE 0 END) AS Loaded_cubes
    FROM (
        SELECT t.start_tran_date,
               t.item_number,
               t.tran_type,
               t.description,
               t.control_number,
               t.control_number_2,
               t.hu_id_2,
               t.routing_code,
               t.tran_qty
        FROM Distribution_Warehouse_Wholesale.TranLog AS t
        WHERE t.wh_id = '335'
          AND t.start_tran_date >= '2025-01-01'
          AND t.tran_type IN ('322', '151', '183', '951')
    ) AS t1
    LEFT JOIN itm AS i1 ON t1.item_number = i1.item_number
    GROUP BY
        t1.[start_tran_date],
        DATEPART(YYYY, t1.[start_tran_date]) * 100 + FORMAT(DATEPART(ISO_WEEK, t1.[start_tran_date]), '00'),
        DATEPART(YYYY, t1.[start_tran_date]) * 100 + DATEPART(MONTH, t1.[start_tran_date]),
        t1.item_number,
        t1.tran_type,
        t1.description,
        t1.control_number,
        t1.control_number_2,
        t1.hu_id_2,
        t1.routing_code,
        i1.product
)
SELECT
    a1.[start_tran_date],
    a1.product,
    SUM(CASE WHEN a1.tran_type IN ('151', '183', '951') AND a1.row_num_receiving = 1 THEN 1 ELSE 0 END) AS Received_Container_Count,
    SUM(a1.Received_Qty) AS Received_Qty,
    CAST(SUM(a1.Received_Cubes) AS INT) AS Received_cubes,
    SUM(CASE WHEN a1.tran_type = '322' AND a1.row_num_shipping = 1 THEN 1 ELSE 0 END) AS Loaded_Container_Count,
    SUM(a1.Loaded_Qty) AS Loaded_Qty,
    CAST(SUM(a1.Loaded_cubes) AS INT) AS Loaded_cubes
FROM trx AS a1
GROUP BY
    a1.[start_tran_date],
     a1.product
ORDER BY a1.[start_tran_date];
