WITH cte AS (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY lot_number
               ORDER BY start_tran_date DESC,
                        start_tran_time DESC
           ) AS rn
    FROM Distribution_Warehouse_Wholesale.tranlog 
    WHERE lot_number IN (
        '503949981748'

    )
    AND wh_id = '335'
)

SELECT *
FROM cte
WHERE rn = 1
ORDER BY lot_number;