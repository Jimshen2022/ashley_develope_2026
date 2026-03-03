--Ashton Inbound and outboud, by container#
SELECT
    t1.wh_id,
    t1.tran_type,
    CAST(
        CAST(
            CASE
                WHEN CHARINDEX('-', t1.control_number_2) > 0
                THEN SUBSTRING(t1.control_number_2, 1, CHARINDEX('-', t1.control_number_2) - 1)
                ELSE '0' -- 或者使用其他默认值
            END AS INT
        ) AS VARCHAR
    ) AS control_number_extracted,
    DATEPART(Month, t1.start_tran_date) as MONTH,
    CASE
        WHEN t1.tran_type IN ('151','183','951') THEN
            CONVERT(VARCHAR, FORMAT(t1.start_tran_date, 'yyyy-MM')) + '_' + CONVERT(VARCHAR, t1.control_number)
        ELSE
            CONVERT(VARCHAR, FORMAT(t1.start_tran_date, 'yyyy-MM')) + '_' +
            CAST(
                CAST(
                    CASE
                        WHEN CHARINDEX('-', t1.control_number_2) > 0
                        THEN SUBSTRING(t1.control_number_2, 1, CHARINDEX('-', t1.control_number_2) - 1)
                        ELSE '0' -- 或者使用其他默认值
                    END AS INT
                ) AS VARCHAR
            ) + '_' + t1.routing_code
    END AS container_nbr,
    CASE
        WHEN t1.tran_type in ('151', '183', '951') THEN 'INBOUND'
        ELSE 'OUTBOUND'
    END AS tran_type,
    SUM(CASE WHEN t1.tran_type IN ('951') THEN -t1.tran_qty ELSE t1.tran_qty END) as Qty
FROM
    (SELECT *
     FROM Distribution_Warehouse_Wholesale.TranLog as t0
     WHERE t0.wh_id = '335'
       AND t0.start_tran_date BETWEEN DATEADD(DAY, -60, GETDATE()) AND CAST(DATEADD(HOUR, 7, GETUTCDATE()) AS DATE)
       AND t0.tran_type IN ('151', '183', '951', '347')) AS t1
LEFT JOIN
    (SELECT *
     FROM Distribution_Warehouse_Wholesale.t_item_master as t2
     WHERE t2.wh_id = '335') as t2
ON t2.item_number = t1.item_number
GROUP BY
    t1.wh_id,
    t1.tran_type,
    CAST(
        CAST(
            CASE
                WHEN CHARINDEX('-', t1.control_number_2) > 0
                THEN SUBSTRING(t1.control_number_2, 1, CHARINDEX('-', t1.control_number_2) - 1)
                ELSE '0' -- 或者使用其他默认值
            END AS INT
        ) AS VARCHAR
    ),
    DATEPART(Month, t1.start_tran_date),
    CASE
        WHEN t1.tran_type IN ('151', '183', '951') THEN
            CONVERT(VARCHAR, FORMAT(t1.start_tran_date, 'yyyy-MM')) + '_' + CONVERT(VARCHAR, t1.control_number)
        ELSE
            CONVERT(VARCHAR, FORMAT(t1.start_tran_date, 'yyyy-MM')) + '_' +
            CAST(
                CAST(
                    CASE
                        WHEN CHARINDEX('-', t1.control_number_2) > 0
                        THEN SUBSTRING(t1.control_number_2, 1, CHARINDEX('-', t1.control_number_2) - 1)
                        ELSE '0' -- 或者使用其他默认值
                    END AS INT
                ) AS VARCHAR
            ) + '_' + t1.routing_code
    END,
    CASE
        WHEN t1.tran_type in ('151', '183', '951') THEN 'INBOUND'
        ELSE 'OUTBOUND'
    END;



-- SELECT
--     t1.wh_id,
--     t1.tran_type,
--     CAST(CAST(SUBSTRING(t1.control_number_2, 1, CHARINDEX('-', t1.control_number_2) - 1) AS INT) AS VARCHAR),
--     DATEPART(Month, t1.start_tran_date) as MONTH,
--     CASE
--         WHEN t1.tran_type IN ('151','183','951')  THEN  CONVERT(VARCHAR,FORMAT(t1.start_tran_date, 'yyyy-MM')) + '_' + CONVERT(VARCHAR,t1.control_number)
--         ELSE  CONVERT(VARCHAR,FORMAT(t1.start_tran_date, 'yyyy-MM')) + '_' + CAST(CAST(SUBSTRING(t1.control_number_2, 1, CHARINDEX('-', t1.control_number_2) - 1) AS INT) AS VARCHAR) + '_' +  t1.routing_code   END AS container_nbr,
--     CASE
--         WHEN t1.tran_type in ('151','183','951') THEN 'INBOUND'
--         ELSE 'OUTBOUND'
--     END AS tran_type,
--     SUM(CASE WHEN t1.tran_type IN ('951') THEN -t1.tran_qty ELSE t1.tran_qty END) as Qty
-- FROM
--     (SELECT *
--      FROM Distribution_Warehouse_Wholesale.TranLog as t0
--      WHERE t0.wh_id = '335'
--        AND t0.start_tran_date BETWEEN DATEADD(DAY,-120,GETDATE()) AND CAST(DATEADD(HOUR, 7, GETUTCDATE()) AS DATE)
--        AND t0.tran_type IN ('151','183','951','347')) AS t1
-- LEFT JOIN
--     (SELECT *
--      FROM Distribution_Warehouse_Wholesale.t_item_master as t2
--      WHERE t2.wh_id = '335') as t2
-- ON t2.item_number = t1.item_number
-- GROUP BY
--     t1.wh_id,
--     t1.tran_type,
--     CAST(CAST(SUBSTRING(t1.control_number_2, 1, CHARINDEX('-', t1.control_number_2) - 1) AS INT) AS VARCHAR),
--     DATEPART(Month, t1.start_tran_date),
--     CASE
--         WHEN t1.tran_type IN ('151','183','951')  THEN  CONVERT(VARCHAR,FORMAT(t1.start_tran_date, 'yyyy-MM')) + '_' + CONVERT(VARCHAR,t1.control_number)
--         ELSE  CONVERT(VARCHAR,FORMAT(t1.start_tran_date, 'yyyy-MM')) + '_' + CAST(CAST(SUBSTRING(t1.control_number_2, 1, CHARINDEX('-', t1.control_number_2) - 1) AS INT) AS VARCHAR) + '_' +  t1.routing_code   END,
--     CASE
--         WHEN t1.tran_type in ('151','183','951') THEN 'INBOUND'
--         ELSE 'OUTBOUND'
--     END
