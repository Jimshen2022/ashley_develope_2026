-- select top 100 * from t_tran_log WITH (NOLOCK) where tran_type in ('151','951') order by start_tran_date desc, start_tran_time desc

WITH
-- ① Tally Table
tally AS (
    SELECT TOP 100000
        ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) - 1 AS n
    FROM sys.all_columns a WITH (NOLOCK) 
    CROSS JOIN sys.all_columns b WITH (NOLOCK)
),

-- ② 展开 SN：每个 serial_number 单独一行
sn_expanded AS (
    SELECT
        d.asn_detail_id,
        d.asn_id,
        d.item_number,
        d.lot_number,
        d.line_number,
        d.uom,
        d.customer_po_number,
        d.quantity_shipped,
        d.quantity_received,
        d.born_on_date,
        d.carb_compliance_level,
        d.sn_coo,
        d.transfer_number,
        CAST(d.serial_number_start AS BIGINT) + t.n AS serial_number
    FROM t_asn_detail d WITH (NOLOCK)
    JOIN tally t
        ON t.n <= CAST(d.serial_number_end AS BIGINT)
                - CAST(d.serial_number_start AS BIGINT)
    WHERE d.asn_id IN (
        SELECT asn_id FROM t_asn WITH (NOLOCK) 
        WHERE expected_arrival >= DATEADD(DAY, -7, CAST(GETDATE() AS DATE))
        --WHERE vendor_id IN ('6135', '6580', '6548')
    )
),

-- ③ 每个 asn_id 只取 entered_yard 最新的一条 trailer
latest_trailer AS (
    SELECT
        ta.asn_id,
        ta.trailer_id
    FROM t_trailer_asn ta WITH (NOLOCK)
    INNER JOIN (
        SELECT
            ta2.asn_id,
            MAX(tr.entered_yard) AS max_entered_yard
        FROM t_trailer_asn ta2 WITH (NOLOCK)
        INNER JOIN t_trailer tr WITH (NOLOCK) ON ta2.trailer_id = tr.trailer_id
        GROUP BY ta2.asn_id
    ) mx ON ta.asn_id = mx.asn_id
    INNER JOIN t_trailer tr WITH (NOLOCK) ON ta.trailer_id = tr.trailer_id
                            AND tr.entered_yard = mx.max_entered_yard
)

SELECT
    -- t_asn 所有列
    a.asn_id,
    a.asn_number,
    a.status                AS asn_status,
    a.equipment_id,
    a.trailer_type_name,
    a.expected_arrival,
    a.vendor_id,
    a.total_quantity,
    a.total_volume,

    -- t_vendor
    v.vendor_name,

    -- t_asn_detail 所有列（已展开 SN）
    sn.asn_detail_id,
    sn.item_number,
    sn.lot_number,
    sn.line_number,
    sn.uom,
    sn.customer_po_number,
    sn.quantity_shipped,
    sn.quantity_received,
    sn.born_on_date,
    sn.carb_compliance_level,
    sn.sn_coo,
    sn.transfer_number,
    cast(sn.serial_number as varchar(50)) AS serial_number,

    -- t_trailer 所有列
    tr.trailer_id,
    tr.status               AS trailer_status,
    tr.entered_yard,
    tr.exited_yard,

    -- t_ya_location 所有列
    loc.location_name,

    -- 计算列
    ROUND(
        DATEDIFF(MINUTE,
            tr.entered_yard,
            COALESCE(tr.exited_yard, GETDATE())
        ) / 60.0, 1
    ) AS hours_in_yard,

    CASE
        WHEN tr.entered_yard IS NULL THEN NULL
        WHEN ROUND(DATEDIFF(MINUTE, tr.entered_yard, COALESCE(tr.exited_yard, GETDATE())) / 60.0, 1) <  4  THEN '[a] 0-4h'
        WHEN ROUND(DATEDIFF(MINUTE, tr.entered_yard, COALESCE(tr.exited_yard, GETDATE())) / 60.0, 1) <  8  THEN '[b] 4-8h'
        WHEN ROUND(DATEDIFF(MINUTE, tr.entered_yard, COALESCE(tr.exited_yard, GETDATE())) / 60.0, 1) < 24  THEN '[c] 8-24h'
        WHEN ROUND(DATEDIFF(MINUTE, tr.entered_yard, COALESCE(tr.exited_yard, GETDATE())) / 60.0, 1) < 48  THEN '[d] 24-48h'
        ELSE '[e] 48h+'
    END AS hours_in_yard_bucket,

    CASE
        WHEN loc.location_name IS NULL      THEN 'In_Transit'
        WHEN tr.exited_yard    IS NOT NULL  THEN 'Completed'
        WHEN loc.location_name LIKE 'D%'    THEN 'On_Door'
        WHEN loc.location_name LIKE '%YARD' THEN 'In_Yard'
        ELSE 'CHECK'
    END AS container_status,

    CASE
        WHEN tr.entered_yard IS NULL THEN NULL
        WHEN DATEPART(HOUR, tr.entered_yard) BETWEEN 7 AND 19 THEN 'D'
        ELSE 'N'
    END AS shift,

    CASE
        WHEN tr.entered_yard IS NULL
            THEN CAST(a.expected_arrival AS DATE)
        WHEN DATEPART(HOUR, tr.entered_yard) BETWEEN 0 AND 6
            THEN CAST(DATEADD(DAY, -1, tr.entered_yard) AS DATE)
        ELSE
            CAST(tr.entered_yard AS DATE)
    END AS shift_date

FROM t_asn AS a WITH (NOLOCK)
JOIN sn_expanded AS sn
    ON a.asn_id = sn.asn_id
LEFT JOIN latest_trailer AS lt
    ON a.asn_id = lt.asn_id
LEFT JOIN t_trailer AS tr WITH (NOLOCK)
    ON lt.trailer_id = tr.trailer_id
LEFT JOIN t_ya_location AS loc WITH (NOLOCK)
    ON tr.location_id = loc.location_id
LEFT JOIN t_vendor AS v WITH (NOLOCK)
    ON a.vendor_id = v.vendor_id
WHERE
    a.status IN ('NEW', 'CHECKED IN', 'CLOSED')
   -- AND a.vendor_id IN ('6135', '6580', '6548')
ORDER BY
    a.asn_id,
    sn.customer_po_number,
    sn.serial_number;