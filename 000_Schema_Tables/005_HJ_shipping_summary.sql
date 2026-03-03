
-- shipped check
SELECT
    CAST(LEFT(t3.control_number_2, 7) AS INT) AS trip_nbr,  -- Extract the trip number from control_number_2
    CAST(t3.item_number AS VARCHAR) AS item_nbr,              -- Convert item_number to VARCHAR
    t3.start_tran_date,                                       -- Select the transaction start date
    SUM(t3.tran_qty) AS tran_qty                              -- Sum the transaction quantities
FROM
    [PowerBI_Distribution].[TranLog] AS t3                   -- From the TranLog table
WHERE
    t3.wh_id = '335'                                         -- Filter for warehouse ID 335
	AND t3.item_number = 'A2000787'
    AND t3.tran_type = '347'                                 -- Filter for transaction type 347
    AND t3.start_tran_date > DATEADD(DAY, -20, GETDATE()) 

GROUP BY
CAST(LEFT(t3.control_number_2, 7) AS INT),               -- Group by trip number
t3.item_number,                                          -- Group by item number
t3.start_tran_date    

