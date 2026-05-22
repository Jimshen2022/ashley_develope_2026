WITH
-- ① Tally Table
tally AS (
    SELECT TOP 100000
        ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) - 1 AS n
    FROM sys.all_columns a CROSS JOIN sys.all_columns b
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
    FROM t_asn_detail d
    JOIN tally t
        ON t.n <= CAST(d.serial_number_end AS BIGINT)
                - CAST(d.serial_number_start AS BIGINT)
    WHERE d.asn_id IN (
        SELECT asn_id FROM t_asn where expected_arrival >= DATEADD(DAY, -15, CAST(GETDATE() AS DATE))
       -- WHERE vendor_id IN ('6135', '6580', '6548')
    )
),

-- ③ 最新 trailer
latest_trailer AS (
    SELECT ta.asn_id, ta.trailer_id
    FROM t_trailer_asn ta
    INNER JOIN (
        SELECT ta2.asn_id, MAX(tr.entered_yard) AS max_entered_yard
        FROM t_trailer_asn ta2
        INNER JOIN t_trailer tr ON ta2.trailer_id = tr.trailer_id
        GROUP BY ta2.asn_id
    ) mx ON ta.asn_id = mx.asn_id
    INNER JOIN t_trailer tr ON ta.trailer_id = tr.trailer_id
                            AND tr.entered_yard = mx.max_entered_yard
),

-- ④ 过去30天 tran_type 151/951，每个 lot 取最后一笔交易
tran_log_recent AS (
    SELECT
        control_number,
        control_number_2,
        item_number,
        lot_number,
        tran_type,
        CAST(
            CONVERT(VARCHAR, end_tran_date, 23) + ' ' +
            CONVERT(VARCHAR, end_tran_time, 108)
        AS DATETIME) AS end_tran_dt,
        ROW_NUMBER() OVER (
            PARTITION BY control_number, control_number_2, item_number, lot_number
            ORDER BY
                CAST(
                    CONVERT(VARCHAR, end_tran_date, 23) + ' ' +
                    CONVERT(VARCHAR, end_tran_time, 108)
                AS DATETIME) DESC
        ) AS rn
    FROM t_tran_log
    WHERE tran_type IN ('151', '951')
      AND end_tran_date >= CAST(DATEADD(DAY, -30, GETDATE()) AS DATE)
),

-- ⑤ 最后一笔是151才算真正收货（951=undo）
actual_received AS (
    SELECT
        control_number,
        control_number_2,
        item_number,
        lot_number AS actual_received_sn
    FROM tran_log_recent
    WHERE rn = 1
      AND tran_type = '151'
),

-- ⑥ 主表：ASN + SN展开 + trailer + vendor
asn_main AS (
    SELECT
        a.asn_id,
        a.asn_number,
        a.status                AS asn_status,
        a.equipment_id,
        a.trailer_type_name,
        a.expected_arrival,
        a.vendor_id,
        a.total_quantity,
        a.total_volume,
        v.vendor_name,
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
        sn.serial_number,
        tr.trailer_id,
        tr.status               AS trailer_status,
        tr.entered_yard,
        tr.exited_yard,
        loc.location_name,
        ROUND(
            DATEDIFF(MINUTE, tr.entered_yard, COALESCE(tr.exited_yard, GETDATE())) / 60.0, 1
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
            ELSE CAST(tr.entered_yard AS DATE)
        END AS shift_date
    FROM t_asn AS a
    JOIN sn_expanded AS sn     ON a.asn_id = sn.asn_id
    LEFT JOIN latest_trailer AS lt  ON a.asn_id = lt.asn_id
    LEFT JOIN t_trailer      AS tr  ON lt.trailer_id = tr.trailer_id
    LEFT JOIN t_ya_location  AS loc ON tr.location_id = loc.location_id
    LEFT JOIN t_vendor       AS v   ON a.vendor_id = v.vendor_id
    WHERE a.status IN ('NEW', 'CHECKED IN', 'CLOSED') 
        and a.expected_arrival >= DATEADD(DAY, -15, CAST(GETDATE() AS DATE))
      --AND a.vendor_id IN ('6135', '6580', '6548')
)

-- =============================================
-- Part 1: 主表行 + actual_received_sn + received_judged
-- =============================================
SELECT
    m.asn_id,
    m.asn_number,
    m.asn_status,
    m.equipment_id,
    m.trailer_type_name,
    m.expected_arrival,
    m.vendor_id,
    m.total_quantity,
    m.total_volume,
    m.vendor_name,
    m.asn_detail_id,
    m.item_number,
    m.lot_number,
    m.line_number,
    m.uom,
    m.customer_po_number,
    m.quantity_shipped,
    m.quantity_received,
    m.born_on_date,
    m.carb_compliance_level,
    m.sn_coo,
    m.transfer_number,
    m.serial_number,
    m.trailer_id,
    m.trailer_status,
    m.entered_yard,
    m.exited_yard,
    m.location_name,
    m.hours_in_yard,
    m.hours_in_yard_bucket,
    m.container_status,
    m.shift,
    m.shift_date,
    ar.actual_received_sn,
    CASE
        WHEN CAST(m.serial_number AS VARCHAR) = ar.actual_received_sn
            THEN 'Completed'
        ELSE
            'Un-Received'
    END AS received_judged
FROM asn_main m
LEFT JOIN actual_received ar
    ON  m.equipment_id           = ar.control_number
    AND m.customer_po_number     = ar.control_number_2
    AND m.item_number            = ar.item_number
    AND CAST(m.serial_number AS VARCHAR) = ar.actual_received_sn

UNION ALL

-- =============================================
-- Part 2: tran_log 收货了，equipment_id+PO 匹配，
--         但 item 或 SN 对不上主表 → Not on ASN
-- =============================================
SELECT
    a.asn_id,
    a.asn_number,
    a.status                AS asn_status,
    a.equipment_id,
    a.trailer_type_name,
    a.expected_arrival,
    a.vendor_id,
    a.total_quantity,
    a.total_volume,
    v.vendor_name,
    NULL                    AS asn_detail_id,
    ar.item_number,
    NULL                    AS lot_number,
    NULL                    AS line_number,
    NULL                    AS uom,
    ar.control_number_2     AS customer_po_number,
    NULL                    AS quantity_shipped,
    NULL                    AS quantity_received,
    NULL                    AS bom_on_date,
    NULL                    AS carb_compliance_level,
    NULL                    AS sn_coo,
    NULL                    AS transfer_number,
    NULL                    AS serial_number,
    NULL                    AS trailer_id,
    NULL                    AS trailer_status,
    NULL                    AS entered_yard,
    NULL                    AS exited_yard,
    NULL                    AS location_name,
    NULL                    AS hours_in_yard,
    NULL                    AS hours_in_yard_bucket,
    NULL                    AS container_status,
    NULL                    AS shift,
    NULL                    AS shift_date,
    ar.actual_received_sn,
    'Not on ASN'            AS received_judged
FROM actual_received ar
JOIN t_asn a
    ON  a.equipment_id = ar.control_number
    AND a.status       IN ('NEW', 'CHECKED IN', 'CLOSED')
LEFT JOIN t_vendor v ON a.vendor_id = v.vendor_id
WHERE
    -- equipment_id + PO 能匹配上主表
    EXISTS (
        SELECT 1 FROM asn_main m
        WHERE m.equipment_id       = ar.control_number
          AND m.customer_po_number = ar.control_number_2
    )
    -- 但 item + SN 组合在主表里找不到
    AND NOT EXISTS (
        SELECT 1 FROM asn_main m
        WHERE m.equipment_id                     = ar.control_number
          AND m.customer_po_number               = ar.control_number_2
          AND m.item_number                      = ar.item_number
          AND CAST(m.serial_number AS VARCHAR)   = ar.actual_received_sn
    )

ORDER BY
    asn_id,
    customer_po_number,
    item_number,
    serial_number,
    actual_received_sn;