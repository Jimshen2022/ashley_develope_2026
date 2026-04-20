WITH itm AS (
    SELECT t.item_number,
           t.description,
           t.commodity_code,
           t.unit_volume,
           t.unit_weight
    FROM Distribution_Warehouse_Wholesale.t_item_master AS t 
    WHERE t.wh_id = '335'
),
trx AS (
    SELECT * 
    FROM Distribution_Warehouse_Wholesale.TranLog AS t1 
    WHERE t1.wh_id = '335' 
      AND t1.start_tran_date > '2025-01-01'
      AND t1.tran_type IN ('347','340')
      AND t1.control_number_2 LIKE '0004259%'
)
SELECT t1.control_number_2,
       t1.tran_type,
       t1.description,
       t1.start_tran_date,
       t1.start_tran_time,
       CAST(CONVERT(VARCHAR(10), t1.start_tran_date, 120) + ' ' + 
            CONVERT(VARCHAR(12), t1.start_tran_time, 114) AS DATETIME) AS start_tran_datetime,
       t1.item_number,
       t1.tran_qty,
       i.unit_volume,
       t1.tran_qty * i.unit_volume AS cubes
FROM trx AS t1
LEFT JOIN itm AS i ON i.item_number = t1.item_number
ORDER BY t1.start_tran_date,
         t1.start_tran_time;
