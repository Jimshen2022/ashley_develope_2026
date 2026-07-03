/*
Derived from:
  D:\GitHub\ashley_develope_2026\998_Report\Inbound_and_outbound_qty_by_product.sql

Output columns:
  wh_id, start_tran_date, tran_piece, container_count, yearmonth, year, inbound_or_outbound

Notes:
  - No date range filter is applied.
  - Inbound uses tran_type 151/183 as positive and 951 as negative.
  - Outbound uses tran_type 347 as positive.
*/

WITH trx_base AS (
    SELECT
        t.wh_id,
        CAST(t.start_tran_date AS date) AS start_tran_date,
        CAST(t.start_tran_time AS time) AS start_tran_time,
        t.tran_type,
        t.tran_qty,
        NULLIF(LTRIM(RTRIM(CAST(t.control_number AS varchar(100)))), '') AS control_number,
        NULLIF(LTRIM(RTRIM(CAST(t.control_number_2 AS varchar(100)))), '') AS control_number_2,
        NULLIF(LTRIM(RTRIM(CAST(t.routing_code AS varchar(100)))), '') AS routing_code,
        COALESCE(
            NULLIF(LTRIM(RTRIM(CAST(t.control_number AS varchar(100)))), ''),
            NULLIF(LTRIM(RTRIM(CAST(t.control_number_2 AS varchar(100)))), ''),
            NULLIF(LTRIM(RTRIM(CAST(t.routing_code AS varchar(100)))), ''),
            'NO_CONTROL'
        ) AS receiving_reference
    FROM Distribution_Warehouse_Wholesale.TranLog AS t
    WHERE t.wh_id = '335'
      AND t.tran_type IN ('151', '183', '951', '347')
),
inbound_ordered AS (
    SELECT
        b.*,
        LAG(b.start_tran_date) OVER (
            PARTITION BY b.wh_id, b.receiving_reference
            ORDER BY b.start_tran_date, b.start_tran_time, b.control_number_2, b.routing_code
        ) AS previous_receiving_date
    FROM trx_base AS b
    WHERE b.tran_type IN ('151', '183', '951')
),
inbound_grouped AS (
    SELECT
        i.*,
        SUM(
            CASE
                WHEN i.previous_receiving_date IS NULL THEN 1
                WHEN DATEDIFF(DAY, i.previous_receiving_date, i.start_tran_date) > 2 THEN 1
                ELSE 0
            END
        ) OVER (
            PARTITION BY i.wh_id, i.receiving_reference
            ORDER BY i.start_tran_date, i.start_tran_time, i.control_number_2, i.routing_code
            ROWS UNBOUNDED PRECEDING
        ) AS receiving_group_id
    FROM inbound_ordered AS i
),
inbound_with_key AS (
    SELECT
        i.wh_id,
        i.start_tran_date,
        i.start_tran_time,
        i.tran_type,
        CASE
            WHEN i.tran_type IN ('151', '183') THEN i.tran_qty
            WHEN i.tran_type = '951' THEN -i.tran_qty
            ELSE 0
        END AS tran_piece,
        CONCAT(i.receiving_reference, '_', CAST(i.receiving_group_id AS varchar(20))) AS container_key
    FROM inbound_grouped AS i
),
inbound_normalized AS (
    SELECT
        i.wh_id,
        i.start_tran_date,
        i.tran_piece,
        i.container_key,
        'Inbound' AS inbound_or_outbound,
        ROW_NUMBER() OVER (
            PARTITION BY i.wh_id, i.container_key
            ORDER BY i.start_tran_date, i.start_tran_time, i.tran_type
        ) AS container_row_num
    FROM inbound_with_key AS i
),
outbound_with_key AS (
    SELECT
        b.wh_id,
        b.start_tran_date,
        b.start_tran_time,
        b.tran_qty AS tran_piece,
        CONCAT(
            COALESCE(
                NULLIF(
                    LEFT(
                        COALESCE(b.control_number_2, '') + '-',
                        CHARINDEX('-', COALESCE(b.control_number_2, '') + '-') - 1
                    ),
                    ''
                ),
                b.control_number,
                'NO_TRIP'
            ),
            '_',
            COALESCE(b.routing_code, b.control_number_2, b.control_number, 'NO_ROUTING')
        ) AS container_key
    FROM trx_base AS b
    WHERE b.tran_type = '347'
),
outbound_normalized AS (
    SELECT
        o.wh_id,
        o.start_tran_date,
        o.tran_piece,
        o.container_key,
        'Outbound' AS inbound_or_outbound,
        ROW_NUMBER() OVER (
            PARTITION BY o.wh_id, o.container_key
            ORDER BY o.start_tran_date, o.start_tran_time
        ) AS container_row_num
    FROM outbound_with_key AS o
),
normalized AS (
    SELECT * FROM inbound_normalized
    UNION ALL
    SELECT * FROM outbound_normalized
),
aggregated AS (
    SELECT
        wh_id,
        start_tran_date,
        SUM(tran_piece) AS tran_piece,
        SUM(CASE WHEN container_row_num = 1 THEN 1 ELSE 0 END) AS container_count,
        DATEPART(YEAR, start_tran_date) * 100 + DATEPART(MONTH, start_tran_date) AS yearmonth,
        DATEPART(YEAR, start_tran_date) AS [year],
        inbound_or_outbound
    FROM normalized
    WHERE tran_piece <> 0
    GROUP BY
        wh_id,
        start_tran_date,
        inbound_or_outbound
)
SELECT
    wh_id,
    start_tran_date,
    tran_piece,
    container_count,
    yearmonth,
    [year],
    inbound_or_outbound
FROM aggregated
ORDER BY start_tran_date, inbound_or_outbound;
