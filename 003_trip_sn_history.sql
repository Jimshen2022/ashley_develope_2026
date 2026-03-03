

-- item summary received
SELECT *
FROM
    [PowerBI_Distribution].[TranLog] AS t3                   -- From the TranLog table
WHERE
    --t3.wh_id = '335'                                         -- Filter for warehouse ID 335
	--AND t3.item_number = 'A8010281'
    t3.lot_number = '503951329235'
order by t3.lot_number, t3.start_tran_date desc, t3.start_tran_time desc



SELECT top 10 
    wh_id,
    emp_number,
    name,
    dept,
    group_nbr,
    supervisor_nbr,
    supervisor
FROM Distribution_Warehouse_Wholesale.t_employee
WHERE wh_id IN ('33') and emp_number in ('74621');













SELECT t1.item_number,    t1.control_number AS received_container_nbr,
    t1.control_number_2 as [reference_trip_po_nbr],t1.start_tran_date,
    CASE WHEN t1.tran_type = '951' THEN SUM(-t1.tran_qty)
    ELSE SUM(t1.tran_qty) END   as tran_qty
FROM
    Distribution_Warehouse_Wholesale.TranLog AS t1
WHERE
    t1.wh_id IN ('335')
    AND t1.tran_type IN ('151', '183','951')
    AND t1.start_tran_date BETWEEN
        DATEADD(WEEK, -4, DATEADD(DAY, 1 - DATEPART(WEEKDAY, GETDATE()), CAST(GETDATE() AS DATE)))
        AND CAST(GETDATE() AS DATE)
GROUP BY t1.item_number, t1.control_number,t1.control_number_2, t1.start_tran_date, t1.tran_type


-- item summary shipped
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
    AND t3.start_tran_date > DATEADD(DAY, -4, GETDATE())

GROUP BY
CAST(LEFT(t3.control_number_2, 7) AS INT),               -- Group by trip number
t3.item_number,                                          -- Group by item number
t3.start_tran_date



-- item summary received
SELECT
    CAST(LEFT(t3.control_number_2, 7) AS INT) AS trip_nbr,  -- Extract the trip number from control_number_2
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
    AND t3.start_tran_date > DATEADD(DAY, -4, GETDATE())

GROUP BY
CAST(LEFT(t3.control_number_2, 7) AS INT),               -- Group by trip number
t3.item_number,                                          -- Group by item number
t3.start_tran_date,
t3.tran_type