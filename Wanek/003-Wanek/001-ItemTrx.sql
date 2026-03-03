
/* found serialn umber ship 361 > 1 */
SELECT CAST(t1.[start_tran_date] AS DATE) AS Transaction_Date
    , t1.tran_type
	, t1.description
	, t1.item_number
    , cast(t1.lot_number as char(50)) as SN
    , t1.wh_id
    , count(t1.lot_number) as Qty
 FROM (SELECT * FROM Distribution_Warehouse_Wholesale.TranLog AS a where a.wh_id  IN ('35','31','33')) AS t1
WHERE t1.start_tran_date > '2024-01-01'
    AND t1.item_number in ('9810366') AND t1.tran_type in ('361')
group by CAST(t1.[start_tran_date] AS DATE)
    , t1.tran_type
	, t1.description
	, t1.item_number
    , cast(t1.lot_number as char(50))
    , t1.wh_id
having count(t1.lot_number)>1
ORDER BY CAST(t1.[start_tran_date] AS DATE)

/* found serial number not be received  */
SELECT DISTINCT CAST(t1.lot_number AS CHAR(50)) AS SN
FROM Distribution_Warehouse_Wholesale.TranLog AS t1
WHERE t1.wh_id IN ('35', '31', '33')
    AND t1.start_tran_date > '2024-01-01'
    AND t1.item_number IN ('9810366')
    AND NOT EXISTS (
        SELECT 1
        FROM (
            SELECT a.lot_number
            FROM Distribution_Warehouse_Wholesale.TranLog AS a
            WHERE a.wh_id IN ('35', '31', '33')
                AND a.start_tran_date > '2024-01-01'
                AND a.item_number IN ('9810366')
                AND a.tran_type IN ('111', '112')
            GROUP BY a.lot_number
        ) AS b
        WHERE t1.lot_number = b.lot_number
    );