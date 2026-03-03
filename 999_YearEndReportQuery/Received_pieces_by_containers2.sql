WITH item AS
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
        WHEN a.commodity_code NOT LIKE 'Z%' THEN 'CG'  -- RP
        WHEN a.class_id IN ('SMALL','PAL3H','PAL5H','RAILS','FLOOR','RPFG','FLOOROP','PAL5L','RUGS') THEN 'CG'
        WHEN a.class_id LIKE 'UPH%' THEN 'UPH'
        WHEN a.class_id IS NULL AND a.pick_put_id = 'UPH' THEN 'UPH'
        WHEN a.class_id IS NULL AND a.pick_put_id = 'PALLT' THEN 'CG'
		WHEN LEFT(a.item_number, 1) IN ('A','D','E','H','K','L','M','P','Q','R','T','W') THEN 'CG'
		WHEN LEN(a.item_number) >7 THEN 'CG'
        WHEN LEFT(a.item_number, 1) IN ('1','2','3','4','5','6','7','8','9','U') THEN 'UPH'
		ELSE 'CG'
    END AS product
FROM Distribution_Warehouse_Wholesale.t_item_master AS a
WHERE a.wh_id = '335' 
),
cte_shipped AS (
    SELECT 
        t1.*,
        ROW_NUMBER() OVER (PARTITION BY LEFT(t1.control_number_2, CHARINDEX('-', t1.control_number_2 + '-') - 1) 
                           ORDER BY t1.start_tran_date) AS row_num_shipped
    FROM Distribution_Warehouse_Wholesale.TranLog AS t1
   WHERE t1.tran_type = '347' and t1.wh_id = '335' and t1.start_tran_date > '2023-12-20'
),
cte_received AS (
    SELECT 
        t1.*,
        ROW_NUMBER() OVER (PARTITION BY t1.control_number, t1.hu_id_2 
                           ORDER BY t1.start_tran_date) AS row_num_received
    FROM Distribution_Warehouse_Wholesale.TranLog AS t1 
    WHERE t1.tran_type IN ('151', '183', '951') and t1.wh_id = '335'  and t1.start_tran_date > '2023-12-20'
)
SELECT 
	t1.[start_tran_date],
	DATEPART(YYYY, t1.[start_tran_date]) * 100 + FORMAT(DATEPART(ISO_WEEK, t1.[start_tran_date]), '00') AS YearWeek,
	DATEPART(YYYY, t1.[start_tran_date]) * 100 + DATEPART(MONTH, t1.[start_tran_date]) AS YearMonth,
	t1.item_number,
	t2.class_id,
	t2.pick_put_id,
	t1.tran_type,
	t1.description,
	t2.commodity_code,
	t1.control_number,
	t1.control_number_2,
	t1.hu_id_2,
	CASE 
		WHEN LEFT(t1.item_number, 1) IN ('A','D','E','H','K','L','M','P','Q','R','T','W') THEN 'CG'
		WHEN LEN(t1.item_number) > 7 THEN 'CG'
        WHEN LEFT(t1.item_number, 1) IN ('1','2','3','4','5','6','7','8','9','U') THEN 'UPH'
		ELSE t2.product 
    END AS product,
	SUM(CASE
		WHEN t1.tran_type IN ('151', '183') THEN t1.tran_qty
		WHEN t1.tran_type IN ('951') THEN -t1.tran_qty ELSE 0 END) AS Received_Qty,
	SUM(CASE
		WHEN t1.tran_type IN ('347') THEN t1.tran_qty ELSE 0 END) AS Shipped_Qty,
	MAX(CASE WHEN cte_shipped.row_num_shipped = 1 THEN 1 ELSE 0 END) AS shipped_container_qty,
	MAX(CASE WHEN cte_received.row_num_received = 1 THEN 1 ELSE 0 END) AS received_container_qty
FROM (select * from Distribution_Warehouse_Wholesale.TranLog as t where t.wh_id IN ('335')  AND t.start_tran_date >= '2024-01-01'
	  AND t.tran_type IN ('347', '151', '183', '951'))  AS t1
LEFT JOIN item AS t2 ON t1.item_number = t2.item_number
LEFT JOIN cte_shipped ON t1.control_number_2 = cte_shipped.control_number_2
LEFT JOIN cte_received ON t1.control_number = cte_received.control_number AND t1.hu_id_2 = cte_received.hu_id_2

GROUP BY
	t1.[start_tran_date],
	DATEPART(YYYY, t1.[start_tran_date]) * 100 + FORMAT(DATEPART(ISO_WEEK, t1.[start_tran_date]), '00'),
	DATEPART(YYYY, t1.[start_tran_date]) * 100 + DATEPART(MONTH, t1.[start_tran_date]),
	t1.item_number,
	t2.class_id,
	t2.pick_put_id,
	t1.tran_type,
	t1.description,
	t2.commodity_code,
	t1.control_number,
	t1.control_number_2,
	t1.hu_id_2,
	CASE 
		WHEN LEFT(t1.item_number, 1) IN ('A','D','E','H','K','L','M','P','Q','R','T','W') THEN 'CG'
		WHEN LEN(t1.item_number) > 7 THEN 'CG'
        WHEN LEFT(t1.item_number, 1) IN ('1','2','3','4','5','6','7','8','9','U') THEN 'UPH'
		ELSE t2.product 
    END
ORDER BY DATEPART(YYYY, t1.[start_tran_date]) * 100 + DATEPART(MONTH, t1.[start_tran_date]);
