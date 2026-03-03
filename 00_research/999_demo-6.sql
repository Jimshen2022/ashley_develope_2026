WITH itm AS (
    SELECT 
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
		, case 
			when a.pallet_id = '1' then '5X5'
			when a.pallet_id = '3' then '5X7'
			when a.pallet_id = '4' then '3.5X5'
			when a.pallet_id = '5' then '3.5X5'
			when a.pallet_id = '18' then '5X8'
		ELSE 'No Skid' END as pallet_type, 
        CASE
            WHEN a.pick_put_id =  'UPH' THEN 'UPH'
            ELSE 'CG'
        END AS product
    FROM Distribution_Warehouse_Wholesale.t_item_master AS a
    WHERE a.wh_id = '335' and a.pick_put_id = 'PALLT' 
),
base_data AS (
    SELECT
        t3.wh_id,
        t3.tran_type,
        t3.description,
        CAST(t3.start_tran_date AS DATE) AS tran_date,
        t3.item_number,
        itm.product,
		itm.pallet_type,
        t3.tran_qty
    FROM [PowerBI_Distribution].[TranLog] AS t3
    LEFT JOIN itm ON itm.item_number = t3.item_number
    WHERE t3.wh_id = '335'
        AND t3.tran_type = '347'
        AND t3.start_tran_date >= CAST(GETDATE() - 91 AS DATE)
        AND t3.start_tran_date <= CAST(GETDATE() AS DATE)
)
SELECT
    wh_id,
    item_number,
	pallet_type,
    product,
    description,
    [2025-06-10], [2025-06-11], [2025-06-12]  -- 例子：列出你要展示的日期列
FROM (
    SELECT
        wh_id,
        item_number,
		pallet_type,
        product,
        description,
        tran_date,
        tran_qty
    FROM base_data
) AS src
PIVOT (
    SUM(tran_qty)
    FOR tran_date IN ([2025-06-10], [2025-06-11], [2025-06-12])  -- 指定列名
) AS p
ORDER BY wh_id, item_number;


SELECT @@VERSION;