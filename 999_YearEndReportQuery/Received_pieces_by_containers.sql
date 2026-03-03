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
)
SELECT 
	t1.[start_tran_date]
	, DATEPART(YYYY,t1.[start_tran_date])*100 +FORMAT(DATEPART(ISO_WEEK, t1.[start_tran_date]), '00') AS YearWeek
	, DATEPART(YYYY,t1.[start_tran_date])*100 + DATEPART(MONTH, t1.[start_tran_date]) AS YearMonth
	, t1.item_number
	, t2.class_id
	, t2.pick_put_id
	, t1.tran_type
	, t1.description
	, t2.commodity_code
	, t1.control_number
	, t1.control_number_2   -- receiving container unique id  
	, t1.hu_id_2
	, CASE 
		WHEN LEFT(t1.item_number, 1) IN ('A','D','E','H','K','L','M','P','Q','R','T','W') THEN 'CG'
		WHEN LEN(t1.item_number) >7 THEN 'CG'
        WHEN LEFT(t1.item_number, 1) IN ('1','2','3','4','5','6','7','8','9','U') THEN 'UPH'
		else t2.product END as product
	, SUM(CASE
		WHEN t1.tran_type IN ('151','183') THEN t1.tran_qty
		WHEN t1.tran_type IN ('951') THEN - t1.tran_qty ELSE 0 END) AS Received_Qty
	, SUM(CASE
		WHEN t1.tran_type IN ('347') THEN t1.tran_qty
		ELSE 0 END) AS Shipped_Qty
FROM Distribution_Warehouse_Wholesale.TranLog AS t1
LEFT JOIN item AS t2 ON t1.item_number = t2.item_number
WHERE t1.wh_id IN ('335')
	  AND t1.start_tran_date >= '2025-01-01'
	  AND t1.tran_type IN ('347','151','183','951')
GROUP BY
	t1.[start_tran_date]
	, DATEPART(YYYY,t1.[start_tran_date])*100 +FORMAT(DATEPART(ISO_WEEK, t1.[start_tran_date]), '00') 
	, DATEPART(YYYY,t1.[start_tran_date])*100 + DATEPART(MONTH, t1.[start_tran_date]) 
	, t1.item_number
	, t2.class_id
	, t2.pick_put_id
	, t1.tran_type
	, t1.description
	, t2.commodity_code
	, t1.control_number
	, t1.control_number_2
	, t1.hu_id_2
	, CASE 
		WHEN LEFT(t1.item_number, 1) IN ('A','D','E','H','K','L','M','P','Q','R','T','W') THEN 'CG'
		WHEN LEN(t1.item_number) >7 THEN 'CG'
        WHEN LEFT(t1.item_number, 1) IN ('1','2','3','4','5','6','7','8','9','U') THEN 'UPH'
		else t2.product END
ORDER BY DATEPART(YYYY,t1.[start_tran_date])*100 + DATEPART(MONTH, t1.[start_tran_date]) 