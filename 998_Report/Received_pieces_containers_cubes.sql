-- Ashton inbound and outbound container type and avererage cubes on Feb.15 by Jim,Shen
WITH itm AS
(SELECT
     a.item_number
    ,a.description
    ,a.uom
    ,a.inventory_type
    ,a.commodity_code
    ,a.wh_id
    ,a.class_id
    ,a.unit_weight
    ,a.unit_volume
    ,a.nested_volume
    ,a.pick_put_id
    ,CASE
        WHEN a.pick_put_id ='UPH' THEN 'UPH'  -- RP
        ELSE 'CG' END AS product
FROM Distribution_Warehouse_Wholesale.t_item_master AS a
WHERE a.wh_id = '335'
),
trx AS
(
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
        WHEN t1.tran_type IN ('151', '183', '951') THEN CONCAT(t1.control_number,'_', t1.hu_id_2)
        WHEN t1.tran_type IN ('347') THEN CONCAT(LEFT(t1.control_number_2, CHARINDEX('-', t1.control_number_2 + '-') - 1), '_', t1.routing_code)
        ELSE 'CHECK'
    END AS Container_nbr,
    ROW_NUMBER() OVER (PARTITION BY t1.control_number, t1.hu_id_2
                           ORDER BY t1.start_tran_date) AS row_num_receiving,
    ROW_NUMBER() OVER (PARTITION BY CONCAT(LEFT(t1.control_number_2, CHARINDEX('-', t1.control_number_2 + '-') - 1), '_', t1.routing_code)
                           ORDER BY t1.start_tran_date) AS row_num_shipping,
    SUM(CASE
        WHEN t1.tran_type IN ('151', '183') THEN t1.tran_qty
        WHEN t1.tran_type IN ('951') THEN -t1.tran_qty ELSE 0 END) AS Received_Qty,
    SUM(CASE
        WHEN t1.tran_type IN ('151', '183') THEN t1.tran_qty*i1.unit_volume
        WHEN t1.tran_type IN ('951') THEN -t1.tran_qty*i1.unit_volume ELSE 0 END) AS Received_Cubes,
    SUM(CASE
        WHEN t1.tran_type IN ('347') THEN t1.tran_qty ELSE 0 END) AS Shipped_Qty,
    SUM(CASE
        WHEN t1.tran_type IN ('347') THEN t1.tran_qty*i1.unit_volume ELSE 0 END) AS Shipped_cubes
FROM (select t.start_tran_date,
       t.item_number,
       t.tran_type,
       t.description,
       t.control_number,
       t.control_number_2,
       t.hu_id_2,
       t.routing_code,
       t.tran_qty
      from Distribution_Warehouse_Wholesale.TranLog as t where t.wh_id IN ('335')  AND t.start_tran_date >= '2025-01-01' AND t.start_tran_date <= '2025-06-14'
      AND t.tran_type IN ('347', '151', '183', '951'))  AS t1
LEFT JOIN itm as i1 ON t1.item_number = i1.item_number
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
    i1.product,
    CASE
        WHEN t1.tran_type IN ('151', '183', '951') THEN CONCAT(t1.control_number,' - ', t1.hu_id_2)
        WHEN t1.tran_type IN ('347') THEN CONCAT(LEFT(t1.control_number_2, CHARINDEX('-', t1.control_number_2 + '-') - 1), '_', t1.routing_code)
        ELSE 'CHECK'
    END
),
ContainerType AS (
    SELECT
        t0.Container_nbr,
        CASE WHEN COUNT(DISTINCT t0.product) = 1 THEN MAX(t0.product) ELSE 'Mixed' END AS Container_Type
    FROM trx as t0
    GROUP BY t0.Container_nbr
)
/* Inbound and Outbound by container product category summary*/
SELECT
    a1.[start_tran_date],
    a1.YearMonth,
    DATEADD(DAY, 7 - DATEPART(WEEKDAY, a1.[start_tran_date]), a1.[start_tran_date]) as saturday_date,
    a2.Container_Type,
    a1.item_number,
    a1.tran_type,
    a1.description,
    a1.control_number,
    a1.control_number_2,
    a1.hu_id_2,
    a1.routing_code,
    a1.Container_nbr,
    a1.row_num_receiving,
    a1.row_num_shipping,
    a1.product,
    SUM(CASE WHEN a1.tran_type IN ('151', '183', '951') and a1.row_num_receiving = 1 then 1 else 0 end) as Received_Container_Count,
    SUM(a1.Received_Qty) as Received_Qty,
    CAST(SUM(a1.Received_Cubes) AS INT) as Received_cubes,
    SUM(CASE WHEN a1.tran_type IN ('347') and a1.row_num_shipping = 1 then 1 else 0 end) as Shipped_Container_Count,
    SUM(a1.Shipped_Qty) as Shipped_Qty,
    CAST(SUM(a1.Shipped_cubes) AS INT) as shipped_cubes
FROM trx as a1
LEFT JOIN ContainerType as a2 ON a1.Container_nbr = a2.Container_nbr
GROUP BY a1.[start_tran_date],
        a1.YearMonth,
        DATEADD(DAY, 7 - DATEPART(WEEKDAY, a1.[start_tran_date]), a1.[start_tran_date]),
        a2.Container_Type,
        a1.item_number,
        a1.tran_type,
        a1.description,
        a1.control_number,
        a1.control_number_2,
        a1.hu_id_2,
        a1.routing_code,
        a1.Container_nbr,
        a1.row_num_receiving,
        a1.row_num_shipping,
        a1.product
ORDER BY a1.[start_tran_date],
         a1.control_number


/* Inbound and Outbound by items */
-- select a1.*, a2.Container_Type
-- FROM trx as a1
-- LEFT JOIN ContainerType as a2 ON a1.Container_nbr = a2.Container_nbr
-- ORDER BY a1.start_tran_date


