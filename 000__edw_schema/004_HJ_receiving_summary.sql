

-- receiving check
SELECT
    t3.control_number_2,  -- Extract the trip number from control_number_2
    CAST(t3.item_number AS VARCHAR) AS item_nbr,              -- Convert item_number to VARCHAR
    t3.start_tran_date,     -- Select the transaction start date
    case
        when t3.tran_type = '951' then SUM(-t3.tran_qty)
        else SUM(t3.tran_qty) end AS tran_qty                              -- Sum the transaction quantities
FROM
    [PowerBI_Distribution].[TranLog] AS t3                   -- From the TranLog table
WHERE
    t3.wh_id = '335'                                         -- Filter for warehouse ID 335
	AND t3.item_number = 'A2000787'
    AND t3.tran_type in ('151','951')                                 -- Filter for transaction type 347
    AND t3.start_tran_date > DATEADD(DAY, -10, GETDATE())

GROUP BY
t3.control_number_2,               -- Group by trip number
t3.item_number,                                          -- Group by item number
t3.start_tran_date,
t3.tran_type