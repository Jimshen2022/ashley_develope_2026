WITH itm AS (
    SELECT 
         a.item_number
        ,a.description
        ,a.wh_id
		, CASE 
			WHEN a.pallet_id = '1' THEN '5X5'
			WHEN a.pallet_id = '3' THEN '5X7'
			WHEN a.pallet_id = '4' THEN '3.5X5'
			WHEN a.pallet_id = '5' THEN '3.5X5'
			WHEN a.pallet_id = '18' THEN '5X8'
		ELSE 'No Skid' END AS pallet_type, 
        CASE
            WHEN a.commodity_code NOT LIKE 'Z%' THEN 'RP'
            WHEN a.pick_put_id = 'UPH' THEN 'UPH'
            WHEN a.pick_put_id = 'PALLT' THEN 'CG'
            ELSE 'CHECK'
        END AS product
    FROM Distribution_Warehouse_Wholesale.t_item_master AS a
    WHERE a.wh_id = '335' 
      AND a.pick_put_id = 'PALLT' 
),
base_data AS (
    SELECT
        t3.wh_id,
        t3.item_number,
        itm.description,
        itm.product,
		itm.pallet_type,
        CAST(t3.start_tran_date AS DATE) AS tran_date,
        t3.tran_qty
    FROM [PowerBI_Distribution].[TranLog] AS t3
    INNER JOIN itm ON itm.item_number = t3.item_number AND itm.wh_id = t3.wh_id
    WHERE t3.wh_id = '335'
        AND t3.tran_type = '347'
        AND t3.start_tran_date >= CAST(DATEADD(DAY, -91, GETDATE()) AS DATE)
        AND t3.start_tran_date <= CAST(GETDATE() AS DATE)
)
SELECT
    wh_id,
    item_number,
    description,
	pallet_type,
    product,
    [2025-06-10], [2025-06-11], [2025-06-12]
FROM (
    SELECT
        wh_id,
        item_number,
        description,
		pallet_type,
        product,
        tran_date,
        tran_qty
    FROM base_data
) AS src
PIVOT (
    SUM(tran_qty)
    FOR tran_date IN ([2025-06-10], [2025-06-11], [2025-06-12])
) AS p
ORDER BY wh_id, item_number;

SELECT @@VERSION;
