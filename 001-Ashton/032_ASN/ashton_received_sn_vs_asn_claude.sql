WITH
-- ============================================================
-- TranLog 有效扫描 (最后一条且为 151)
-- ============================================================
tran_raw AS (
    SELECT
        LTRIM(RTRIM(CAST(item_number      AS VARCHAR(50)))) AS item_number,
        LTRIM(RTRIM(CAST(control_number_2 AS VARCHAR(50)))) AS po_number,
        LTRIM(RTRIM(CAST(lot_number       AS VARCHAR(50)))) AS lot_number,
        control_number                                      AS receiving_equipment,
        employee_id                                         AS receiving_employee,
        (start_tran_date + start_tran_time)                 AS receiving_time,
        tran_type
    FROM t_tran_log
    WHERE tran_type IN (151, 951)
      AND start_tran_date >= CAST(DATEADD(day, -7, GETDATE()) AS DATE)
      AND lot_number IS NOT NULL
      AND lot_number != ''
),
tran_last AS (
    SELECT *
    FROM (
        SELECT *,
               ROW_NUMBER() OVER (
                   PARTITION BY lot_number
                   ORDER BY receiving_time DESC
               ) AS rn
        FROM tran_raw
    ) x
    WHERE rn = 1
),

tran_valid AS (
    SELECT
        item_number,
        po_number,
        lot_number,
        receiving_equipment,
        receiving_employee,
        receiving_time
    FROM tran_last
    WHERE tran_type = 151
),
asn_base AS (
    SELECT
        t.asn_number,
        t.asn_id,
        t.status,
        t.equipment_id,
        t.trailer_type_name,
        t.expected_arrival,
        t.vendor_id,
        t.total_quantity,
        t.total_volume,
        t1.item_number,
        t1.uom,
        t1.customer_po_number,
        t1.serial_number_start,
        t1.serial_number_end,
        (t1.quantity_shipped - t1.quantity_received) AS qty_remaining,
        t1.sn_coo,
        t3.status                                    AS trailer_status,
        t3.entered_yard,
        t3.exited_yard,
        t4.location_name
    FROM t_asn AS t
    LEFT JOIN t_asn_detail  AS t1 ON t.asn_id       = t1.asn_id
    LEFT JOIN t_trailer_asn AS t2 ON t.asn_id       = t2.asn_id
    LEFT JOIN t_trailer     AS t3 ON t2.trailer_id  = t3.trailer_id
    LEFT JOIN t_ya_location AS t4 ON t3.location_id = t4.location_id
    WHERE t.[status] IN ('CHECKED IN', 'CLOSED')
      AND EXISTS (
                    SELECT 1
                    FROM tran_valid v
                    WHERE v.receiving_equipment = t.equipment_id
                      AND v.po_number = t1.customer_po_number
                )
      AND t3.entered_yard >= CAST(DATEADD(day, -90, GETDATE()) AS DATE)
      AND t1.serial_number_start IS NOT NULL
      AND t1.serial_number_end   IS NOT NULL
      AND ISNUMERIC(t1.serial_number_start) = 1
      AND ISNUMERIC(t1.serial_number_end)   = 1
),

-- ============================================================
-- 递归展开序列号范围
-- serial_number 直接保留 BIGINT，JOIN 时统一转 VARCHAR 比对
-- ============================================================
asn_expanded AS (
    SELECT
        asn_number, asn_id, status, equipment_id, trailer_type_name,
        expected_arrival, vendor_id, total_quantity, total_volume,
        item_number, uom, customer_po_number,
        serial_number_start, serial_number_end,
        qty_remaining, sn_coo,
        trailer_status, entered_yard, exited_yard, location_name,
        CAST(serial_number_start AS BIGINT) AS current_sn,
        CAST(serial_number_end   AS BIGINT) AS end_sn,
        LEN(LTRIM(RTRIM(serial_number_start))) AS sn_pad_len
    FROM asn_base
    WHERE CAST(serial_number_start AS BIGINT) <= CAST(serial_number_end AS BIGINT)

    UNION ALL

    SELECT
        asn_number, asn_id, status, equipment_id, trailer_type_name,
        expected_arrival, vendor_id, total_quantity, total_volume,
        item_number, uom, customer_po_number,
        serial_number_start, serial_number_end,
        qty_remaining, sn_coo,
        trailer_status, entered_yard, exited_yard, location_name,
        current_sn + 1,
        end_sn,
        sn_pad_len
    FROM asn_expanded
    WHERE current_sn < end_sn
),

asn_final AS (
    SELECT
        asn_number, asn_id, status, equipment_id, trailer_type_name,
        expected_arrival, vendor_id, total_quantity, total_volume,
        item_number, uom,
        LTRIM(RTRIM(CAST(customer_po_number AS VARCHAR(50)))) AS customer_po_number,
        serial_number_start,
        serial_number_end,
        qty_remaining, sn_coo,
        trailer_status, entered_yard, exited_yard, location_name,
        LTRIM(RTRIM(CAST(current_sn AS VARCHAR(20))))         AS serial_number,
        sn_pad_len
    FROM asn_expanded
)
-- ============================================================
-- FULL OUTER JOIN
-- ★ JOIN key 与诊断 6c 完全一致: LTRIM+RTRIM+CAST VARCHAR
-- ============================================================
SELECT
    -- ASN 列
    a.asn_number,
    a.asn_id,
    a.status,
    a.equipment_id,
    a.trailer_type_name,
    a.expected_arrival,
    a.vendor_id,
    a.total_quantity,
    a.total_volume,
    COALESCE(a.item_number,        t.item_number)  AS item_number,
    a.uom,
    a.customer_po_number,
    a.serial_number_start,
    a.serial_number_end,
    a.qty_remaining,
    a.sn_coo,
    a.trailer_status,
    a.entered_yard,
    a.exited_yard,
    a.location_name,
    COALESCE(a.serial_number,      t.lot_number)   AS serial_number,

    -- TranLog 列 (拼接在 ASN 右边)
    t.po_number             AS tl_po_number,
    t.item_number           as tl_item_number,
    t.lot_number            AS tl_lot_number,
    t.receiving_equipment,
    t.receiving_employee,
    t.receiving_time,

    -- 比对结果
    CASE
        WHEN a.serial_number IS NOT NULL AND t.lot_number IS NOT NULL THEN 'Matched'
        WHEN a.serial_number IS NOT NULL AND t.lot_number IS NULL     THEN 'ASN Only'
        ELSE                                                               'TranLog Only'
    END AS Match_Status,

    -- ★ 新增: po_nbr 取两表 PO 的最大值
    CASE
        WHEN a.customer_po_number IS NULL THEN t.po_number
        WHEN t.po_number          IS NULL THEN a.customer_po_number
        WHEN a.customer_po_number >= t.po_number THEN a.customer_po_number
        ELSE t.po_number
    END AS po_nbr,
    -- ★ 新增: item_nbr 取两表 PO 的最大值
    CASE
        WHEN a.item_number IS NULL THEN t.item_number
        WHEN t.item_number IS NULL THEN a.item_number
        ELSE t.item_number
    END AS itm_number,
    -- ★ 新增: con_nbr 取两表 PO 的最大值
    CASE
        WHEN a.equipment_id IS NULL THEN t.receiving_equipment
        WHEN t.receiving_equipment IS NULL THEN a.equipment_id
        ELSE t.receiving_equipment
    END AS con_nbr

FROM asn_final AS a
FULL OUTER JOIN tran_valid AS t
    ON  a.customer_po_number = t.po_number
    AND a.item_number        = t.item_number
    AND a.serial_number      = t.lot_number

ORDER BY
    Match_Status,
    COALESCE(a.customer_po_number, t.po_number),
    COALESCE(a.item_number,        t.item_number),
    COALESCE(a.serial_number,      t.lot_number)

OPTION (MAXRECURSION 0);