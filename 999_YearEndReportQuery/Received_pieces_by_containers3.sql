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
        WHEN a.pick_put_id ='UPH' THEN 'UPH'
		ELSE 'CG'
    END AS product
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
	i1.product,
	CASE
	    WHEN t1.tran_type IN ('151', '183', '951') THEN CONCAT(t1.control_number,'_', t1.hu_id_2)
	    WHEN t1.tran_type IN ('347') THEN LEFT(t1.control_number_2, CHARINDEX('-', t1.control_number_2 + '-') - 1)
	    ELSE 'CHECK'
	END AS Container_nbr,
	ROW_NUMBER() OVER (PARTITION BY t1.control_number, t1.hu_id_2 
                           ORDER BY t1.start_tran_date) AS row_num_receiving,
	ROW_NUMBER() OVER (PARTITION BY LEFT(t1.control_number_2, CHARINDEX('-', t1.control_number_2 + '-') - 1) 
                           ORDER BY t1.start_tran_date) AS row_num_shipping,
	SUM(CASE
		WHEN t1.tran_type IN ('151', '183') THEN t1.tran_qty
		WHEN t1.tran_type IN ('951') THEN -t1.tran_qty ELSE 0 END) AS Received_Qty,
	SUM(CASE
		WHEN t1.tran_type IN ('347') THEN t1.tran_qty ELSE 0 END) AS Shipped_Qty
FROM (select t.start_tran_date,
       t.item_number,
       t.tran_type,
       t.description,
       t.control_number,
       t.control_number_2,
       t.hu_id_2,
       t.tran_qty
      from Distribution_Warehouse_Wholesale.TranLog as t where t.wh_id IN ('335')  AND t.start_tran_date >= '2025-01-01'
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
	i1.product,
	CASE
	    WHEN t1.tran_type IN ('151', '183', '951') THEN CONCAT(t1.control_number,' - ', t1.hu_id_2)
	    WHEN t1.tran_type IN ('347') THEN LEFT(t1.control_number_2, CHARINDEX('-', t1.control_number_2 + '-') - 1)
	    ELSE 'CHECK'
	END
),
ContainerType AS (
    SELECT
        t0.Container_nbr,
        CASE WHEN COUNT(DISTINCT t0.product) = 1 THEN t0.product ELSE 'Mixed' END AS Container_Type
    FROM trx as t0
    GROUP BY t0.Container_nbr,t0.product
)
SELECT  a1.YearMonth
     , DATEADD(DAY, 7 - DATEPART(WEEKDAY, a1.[start_tran_date]), a1.[start_tran_date]) as saturday_date
     , a2.Container_Type
	, SUM(a1.Received_Qty) as Received_Qty
	, SUM(a1.Shipped_Qty) as Shipped_Qty
	, SUM(CASE WHEN a1.tran_type = '347' AND a1.row_num_shipping = 1 THEN 1 ELSE 0 END) AS Shipped_Containers_Qty
	, SUM(CASE WHEN a1.tran_type IN ('151','951','183') AND a1.row_num_receiving = 1 THEN 1 ELSE 0 END) AS Received_Containers_Qty
FROM trx as a1
LEFT JOIN ContainerType as a2 ON a1.Container_nbr = a2.Container_nbr
GROUP BY a1.YearMonth,DATEADD(DAY, 7 - DATEPART(WEEKDAY, a1.[start_tran_date]), a1.[start_tran_date]), a2.Container_Type
ORDER BY a1.YearMonth