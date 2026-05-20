/*
SELECT TOP 10 *  FROM  t_asn
SELECT TOP 10 *  FROM  t_asn_detail
SELECT TOP 10  *  FROM  t_trailer  
SELECT TOP 10 *  FROM  t_trailer_asn 
SELECT TOP 10 *  FROM  t_ya_location 

SELECT TOP 10 *  FROM  t_asn where asn_id = '1725692'
SELECT TOP 10 *  FROM  t_asn_detail where asn_id = '1725692'
SELECT TOP 10  *  FROM  t_trailer   where trailer_id = '355197'
SELECT TOP 10 *  FROM  t_trailer_asn  where asn_id = '1725692'
*/

-- asn and detail
WITH asn_cte AS (
    SELECT
        t.asn_id,
        STRING_AGG(t.customer_po_number, ', ') AS customer_po_number,
        SUM(t.quantity_shipped)                AS quantity_shipped,
        SUM(t.quantity_received)               AS quantity_received
    FROM (
        SELECT
            asn_id,
            customer_po_number,
            SUM(quantity_shipped)  AS quantity_shipped,
            SUM(quantity_received) AS quantity_received
        FROM t_asn_detail
        WHERE asn_id IN (
            SELECT asn_id FROM t_asn WHERE vendor_id IN ('6135', '6580', '6548')
        )
        GROUP BY asn_id, customer_po_number
    ) AS t
    GROUP BY t.asn_id
),
-- 每个 asn_id 只取 entered_yard 最新的一条 trailer
latest_trailer AS (
    SELECT
        ta.asn_id,
        ta.trailer_id
    FROM t_trailer_asn ta
    INNER JOIN (
        SELECT
            ta2.asn_id,
            MAX(tr.entered_yard) AS max_entered_yard
        FROM t_trailer_asn ta2
        INNER JOIN t_trailer tr ON ta2.trailer_id = tr.trailer_id
        GROUP BY ta2.asn_id
    ) mx ON ta.asn_id = mx.asn_id
    INNER JOIN t_trailer tr ON ta.trailer_id = tr.trailer_id
                            AND tr.entered_yard = mx.max_entered_yard
)
SELECT
    t.asn_number,
    t.asn_id,
    t.status,
    t.equipment_id,
    t.trailer_type_name,
    t.expected_arrival,
    t.vendor_id,
    t5.vendor_name,
    t.total_quantity,
    t.total_volume,
    t1.customer_po_number,
    t1.quantity_shipped,
    t1.quantity_received,
    t3.status          AS trailer_status,
    t3.entered_yard,
    t3.exited_yard,
    t4.location_name,
    ROUND(
        DATEDIFF(MINUTE,
            t3.entered_yard,
            COALESCE(t3.exited_yard, GETDATE())
        ) / 60.0, 1
    ) AS hours_in_yard,
    CASE
        WHEN t3.entered_yard IS NULL THEN NULL
        WHEN ROUND(DATEDIFF(MINUTE, t3.entered_yard, COALESCE(t3.exited_yard, GETDATE())) / 60.0, 1) <  4  THEN '[a] 0-4h'
        WHEN ROUND(DATEDIFF(MINUTE, t3.entered_yard, COALESCE(t3.exited_yard, GETDATE())) / 60.0, 1) <  8  THEN '[b] 4-8h'
        WHEN ROUND(DATEDIFF(MINUTE, t3.entered_yard, COALESCE(t3.exited_yard, GETDATE())) / 60.0, 1) < 24  THEN '[c] 8-24h'
        WHEN ROUND(DATEDIFF(MINUTE, t3.entered_yard, COALESCE(t3.exited_yard, GETDATE())) / 60.0, 1) < 48  THEN '[d] 24-48h'
        ELSE '[e] 48h+'
    END AS hours_in_yard_bucket,
    CASE
        WHEN t4.location_name IS NULL      THEN 'In_Transit'
        WHEN t3.exited_yard   IS NOT NULL  THEN 'Completed'
        WHEN t4.location_name LIKE 'D%'    THEN 'On_Door'
        WHEN t4.location_name LIKE '%YARD' THEN 'In_Yard'
        ELSE 'CHECK'
    END AS container_status,
    CASE
        WHEN t3.entered_yard IS NULL THEN NULL
        WHEN DATEPART(HOUR, t3.entered_yard) >= 7
         AND DATEPART(HOUR, t3.entered_yard) <= 19 THEN 'D'
        ELSE 'N'
    END AS shift,
    CASE
        WHEN t3.entered_yard IS NULL
            THEN CAST(t.expected_arrival AS DATE)
        WHEN DATEPART(HOUR, t3.entered_yard) BETWEEN 0 AND 6
            THEN CAST(DATEADD(DAY, -1, t3.entered_yard) AS DATE)
        ELSE
            CAST(t3.entered_yard AS DATE)
    END AS shift_date
FROM t_asn AS t
LEFT JOIN asn_cte        AS t1 ON t.asn_id = t1.asn_id
LEFT JOIN latest_trailer AS t2 ON t.asn_id = t2.asn_id
LEFT JOIN t_trailer      AS t3 ON t2.trailer_id = t3.trailer_id
LEFT JOIN t_ya_location  AS t4 ON t3.location_id = t4.location_id
LEFT JOIN t_vendor       AS t5 ON t.vendor_id = t5.vendor_id
WHERE 1=1
    AND t.[status] IN ('NEW', 'CHECKED IN', 'CLOSED')
    AND t.vendor_id  IN ('6135', '6580', '6548')