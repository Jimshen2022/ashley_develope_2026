WITH 
-- ① Tally Table (保持不变)
tally AS (
    SELECT TOP 100000
        ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) - 1 AS n
    FROM sys.all_columns a CROSS JOIN sys.all_columns b
),

-- ② 展开 SN：新增一个 VARCHAR 类型的 SN 用于关联，避免后续 JOIN 时每行做数据转换
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
        CAST(d.serial_number_start AS BIGINT) + t.n AS serial_number,
        -- 【优化 1】提前转化为 VARCHAR，避免在最终的 JOIN 条件中频繁调用 CAST() 函数
        CAST(CAST(d.serial_number_start AS BIGINT) + t.n AS VARCHAR(50)) AS serial_number_varchar
    FROM t_asn_detail d
    JOIN tally t
        ON t.n <= CAST(d.serial_number_end AS BIGINT)
                - CAST(d.serial_number_start AS BIGINT)
    WHERE d.asn_id IN (
        SELECT asn_id FROM t_asn 
        WHERE expected_arrival >= DATEADD(DAY, -15, CAST(GETDATE() AS DATE)) 
              AND status IN ('CHECKED IN', 'CLOSED')
        )
    ),

-- ③ 最新 trailer：使用 ROW_NUMBER() 替代低效的 自连接 + MAX()
latest_trailer AS (
    SELECT asn_id, trailer_id
    FROM (
        SELECT ta.asn_id, ta.trailer_id,
               ROW_NUMBER() OVER (PARTITION BY ta.asn_id ORDER BY tr.entered_yard DESC) AS rn
        FROM t_trailer_asn ta
        INNER JOIN t_trailer tr ON ta.trailer_id = tr.trailer_id
    ) t
    WHERE rn = 1
),

-- ④ 过去30天 tran_type 151/951：移除昂贵的字符串转时间操作
tran_log_recent AS (
    SELECT
        control_number,
        control_number_2,
        item_number,
        lot_number,
        tran_type,
        -- 【优化 2】直接用原生的 date 和 time 字段排序，干掉极度消耗 CPU 的 CAST(CONVERT(...)+CONVERT(...) AS DATETIME)
        ROW_NUMBER() OVER (
            PARTITION BY control_number, control_number_2, item_number, lot_number
            ORDER BY end_tran_date DESC, end_tran_time DESC
        ) AS rn
    FROM t_tran_log
    WHERE tran_type IN ('151', '951')
      AND end_tran_date >= CAST(DATEADD(DAY, -30, GETDATE()) AS DATE)
),

-- ⑤ 实际收货过滤
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

-- ⑥ 主表：提取重复计算逻辑到 OUTER APPLY
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
        sn.serial_number_varchar, -- 用于 JOIN
        tr.trailer_id,
        tr.status               AS trailer_status,
        tr.entered_yard,
        tr.exited_yard,
        loc.location_name,
        calc.hours_in_yard,       -- 【优化 3】引用提炼出的计算结果
        CASE
            WHEN tr.entered_yard IS NULL THEN NULL
            WHEN calc.hours_in_yard <  4  THEN '[a] 0-4h'
            WHEN calc.hours_in_yard <  8  THEN '[b] 4-8h'
            WHEN calc.hours_in_yard < 24  THEN '[c] 8-24h'
            WHEN calc.hours_in_yard < 48  THEN '[d] 24-48h'
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
            WHEN tr.entered_yard IS NULL THEN CAST(a.expected_arrival AS DATE)
            WHEN DATEPART(HOUR, tr.entered_yard) BETWEEN 0 AND 6 THEN CAST(DATEADD(DAY, -1, tr.entered_yard) AS DATE)
            ELSE CAST(tr.entered_yard AS DATE)
        END AS shift_date
    FROM t_asn AS a
    JOIN sn_expanded AS sn     ON a.asn_id = sn.asn_id
    LEFT JOIN latest_trailer AS lt  ON a.asn_id = lt.asn_id
    LEFT JOIN t_trailer      AS tr  ON lt.trailer_id = tr.trailer_id
    LEFT JOIN t_ya_location  AS loc ON tr.location_id = loc.location_id
    LEFT JOIN t_vendor       AS v   ON a.vendor_id = v.vendor_id
    -- 使用 OUTER APPLY 统一计算一次时间差，避免在上面的 CASE 语句中重复计算 5 次
    OUTER APPLY (
        SELECT ROUND(DATEDIFF(MINUTE, tr.entered_yard, COALESCE(tr.exited_yard, GETDATE())) / 60.0, 1) AS hours_in_yard
    ) calc
    WHERE a.status IN ('CHECKED IN', 'CLOSED') 
      AND a.expected_arrival >= DATEADD(DAY, -15, CAST(GETDATE() AS DATE))
)

-- =============================================
-- Part 1: 主表行 + actual_received_sn + received_judged
-- =============================================
SELECT
    m.asn_id, m.asn_number, m.asn_status, m.equipment_id, m.trailer_type_name,
    m.expected_arrival, m.vendor_id, m.total_quantity, m.total_volume, m.vendor_name,
    m.asn_detail_id, m.item_number, m.lot_number, m.line_number, m.uom,
    m.customer_po_number, m.quantity_shipped, m.quantity_received, m.born_on_date,
    m.carb_compliance_level, m.sn_coo, m.transfer_number, m.serial_number,
    m.trailer_id, m.trailer_status, m.entered_yard, m.exited_yard, m.location_name,
    m.hours_in_yard, m.hours_in_yard_bucket, m.container_status, m.shift, m.shift_date,
    ar.actual_received_sn,
    CASE
        WHEN m.serial_number_varchar = ar.actual_received_sn THEN 'Completed'
        ELSE 'Un-Received'
    END AS received_judged
FROM asn_main m
LEFT JOIN actual_received ar
    ON  m.equipment_id           = ar.control_number
    AND m.customer_po_number     = ar.control_number_2
    AND m.item_number            = ar.item_number
    -- 使用预处理好的 VARCHAR 列进行 JOIN，避免全表扫描时类型转换
    AND m.serial_number_varchar  = ar.actual_received_sn

UNION ALL

-- =============================================
-- Part 2: 提取多余收货 (Not on ASN)
-- =============================================
SELECT
    a.asn_id, a.asn_number, a.status AS asn_status, a.equipment_id, a.trailer_type_name,
    a.expected_arrival, a.vendor_id, a.total_quantity, a.total_volume, v.vendor_name,
    NULL, ar.item_number, NULL, NULL, NULL, ar.control_number_2, NULL, NULL, NULL, NULL,
    NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
    ar.actual_received_sn,
    'Not on ASN' AS received_judged
FROM actual_received ar
JOIN t_asn a
    ON  a.equipment_id = ar.control_number
    AND a.status       IN ('CHECKED IN', 'CLOSED')
LEFT JOIN t_vendor v ON a.vendor_id = v.vendor_id
WHERE
    -- 【优化 4】不要去 EXISTS (asn_main)。asn_main 是一个被展开了可能几十万行的庞大 CTE。
    -- 直接查底表 t_asn 和 t_asn_detail 效率会提升数十倍！
    EXISTS (
        SELECT 1 FROM t_asn a_sub
        JOIN t_asn_detail d_sub ON a_sub.asn_id = d_sub.asn_id
        WHERE a_sub.equipment_id = ar.control_number
          AND d_sub.customer_po_number = ar.control_number_2
          AND a_sub.status IN ('CHECKED IN', 'CLOSED')
          AND a_sub.expected_arrival >= DATEADD(DAY, -15, CAST(GETDATE() AS DATE))
    )
    AND NOT EXISTS (
        SELECT 1 FROM t_asn a_sub2
        JOIN t_asn_detail d_sub2 ON a_sub2.asn_id = d_sub2.asn_id
        WHERE a_sub2.equipment_id = ar.control_number
          AND d_sub2.customer_po_number = ar.control_number_2
          AND d_sub2.item_number = ar.item_number
          -- 核心：直接判断 收货SN 是否落在起始-截止范围内，而不需要依赖前面展开了几十万行的主表去比对
          AND TRY_CAST(ar.actual_received_sn AS BIGINT) BETWEEN CAST(d_sub2.serial_number_start AS BIGINT) AND CAST(d_sub2.serial_number_end AS BIGINT)
          AND a_sub2.status IN ('CHECKED IN', 'CLOSED')
          AND a_sub2.expected_arrival >= DATEADD(DAY, -15, CAST(GETDATE() AS DATE))
    )
ORDER BY
    asn_id,
    customer_po_number,
    item_number,
    serial_number,
    actual_received_sn;