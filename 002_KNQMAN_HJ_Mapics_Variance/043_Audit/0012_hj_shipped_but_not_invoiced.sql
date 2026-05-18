-- Query to retrieve trip numbers, item numbers, transaction dates, and quantities
-- from the TranLog table for a specific warehouse and transaction type,
-- excluding certain trip numbers based on a subquery.
SELECT
    CAST(LEFT(t3.control_number_2, 7) AS INT) AS trip_nbr,  -- Extract the trip number from control_number_2
    CAST(t3.item_number AS VARCHAR) AS item_nbr,              -- Convert item_number to VARCHAR
    t3.start_tran_date,                                       -- Select the transaction start date
    SUM(t3.tran_qty) AS tran_qty                              -- Sum the transaction quantities
FROM
    [PowerBI_Distribution].[TranLog] AS t3                   -- From the TranLog table
WHERE
    t3.wh_id = '335'                                         -- Filter for warehouse ID 335
    AND t3.tran_type = '347'                                 -- Filter for transaction type 347
    AND t3.start_tran_date > DATEADD(DAY, -3, GETDATE())   -- Filter for transactions in the last 3 days
    AND CAST(LEFT(t3.control_number_2, 7) AS INT) NOT IN (  -- Exclude certain trip numbers
        SELECT DISTINCT
            CAST(shcTripNumber AS INT) AS trip_nbr          -- Get distinct trip numbers from the subquery
        FROM
            CostAccounting_Enh.ShippedHistoryCubeData AS t
        WHERE
            t.shcWarehouse = '335'                            -- Filter for warehouse ID 335
            AND t.shcInvoiceDate BETWEEN '2025-05-19' AND '2025-05-25'  -- Filter for invoice dates
            AND t.shcTripNumber <> 0                          -- Exclude trip numbers that are 0
    )
GROUP BY
    CAST(LEFT(t3.control_number_2, 7) AS INT),               -- Group by trip number
    t3.item_number,                                          -- Group by item number
    t3.start_tran_date                                       -- Group by transaction start date