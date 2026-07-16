/*
Purpose
-------
1. Pull current inventory for items whose putaway class is FLOOR
2. Resolve COO from multiple sources because t_stored_item.country_code is often blank
3. Split inventory by COO into:
   - vietnam local vendor
   - international vendor
   - unknown coo
4. Pull forecast demand for day 1 to day 60
5. Calculate average days of supply

Assumptions
-----------
1. Putaway class defaults to dbo.t_item_master.class_id.
   Local setup SQL uses class_id values such as FLOOR, RUGS, SMALL, MATT, and UPH* as
   putaway classes. Use @putaway_field = 'pick_put_id' only if the live page you are
   matching labels pick_put_id as putaway class.
2. Current available inventory = dbo.t_stored_item.actual_qty > 0 and status = 'A'.
3. COO source priority:
   a. t_stored_item.country_code
   b. t_serial_master.country_code by stored-item lot_number or serial_number
   c. t_asn_detail.sn_coo by item + PO
   d. t_asn_detail.sn_coo by serial range
   e. t_tran_log.sn_coo from recent item/lot/serial transactions
4. Vietnam local vendor = COO in ('VN', 'VNM', 'VIETNAM', 'VIET NAM').
5. Forecast day 1-60 uses dbo.t_item_forecast_daily.pick_day because pick_day is an
   integer forecast horizon bucket.
*/

DECLARE @wh_id VARCHAR(10) = '335';
DECLARE @putaway_class VARCHAR(30) = 'FLOOR';
DECLARE @putaway_field VARCHAR(20) = 'class_id'; -- valid values: class_id, pick_put_id
DECLARE @active_inventory_only BIT = 1;

IF OBJECT_ID('tempdb..#item_days') IS NOT NULL
    DROP TABLE #item_days;

/* Diagnostic result set 1: confirms which item-master field has FLOOR and whether
   there is active inventory behind it. */
SELECT
    diag.filter_field,
    diag.filter_value,
    COUNT(DISTINCT diag.item_number) AS item_count,
    COUNT(DISTINCT CASE WHEN diag.active_onhand_qty > 0 THEN diag.item_number END) AS active_inventory_item_count,
    SUM(diag.active_onhand_qty) AS active_onhand_qty,
    SUM(diag.all_onhand_qty) AS all_onhand_qty
FROM (
    SELECT
        'class_id' AS filter_field,
        itm.class_id COLLATE DATABASE_DEFAULT AS filter_value,
        itm.item_number COLLATE DATABASE_DEFAULT AS item_number,
        SUM(CASE WHEN sto.actual_qty > 0 AND sto.status = 'A' THEN sto.actual_qty ELSE 0 END) AS active_onhand_qty,
        SUM(CASE WHEN sto.actual_qty > 0 THEN sto.actual_qty ELSE 0 END) AS all_onhand_qty
    FROM dbo.t_item_master itm WITH (NOLOCK)
    LEFT JOIN dbo.t_stored_item sto WITH (NOLOCK)
        ON sto.wh_id = itm.wh_id
       AND sto.item_number = itm.item_number
    WHERE itm.wh_id = @wh_id
      AND itm.class_id = @putaway_class
    GROUP BY
        itm.class_id COLLATE DATABASE_DEFAULT,
        itm.item_number COLLATE DATABASE_DEFAULT

    UNION ALL

    SELECT
        'pick_put_id' AS filter_field,
        itm.pick_put_id COLLATE DATABASE_DEFAULT AS filter_value,
        itm.item_number COLLATE DATABASE_DEFAULT AS item_number,
        SUM(CASE WHEN sto.actual_qty > 0 AND sto.status = 'A' THEN sto.actual_qty ELSE 0 END) AS active_onhand_qty,
        SUM(CASE WHEN sto.actual_qty > 0 THEN sto.actual_qty ELSE 0 END) AS all_onhand_qty
    FROM dbo.t_item_master itm WITH (NOLOCK)
    LEFT JOIN dbo.t_stored_item sto WITH (NOLOCK)
        ON sto.wh_id = itm.wh_id
       AND sto.item_number = itm.item_number
    WHERE itm.wh_id = @wh_id
      AND itm.pick_put_id = @putaway_class
    GROUP BY
        itm.pick_put_id COLLATE DATABASE_DEFAULT,
        itm.item_number COLLATE DATABASE_DEFAULT
) diag
GROUP BY
    diag.filter_field,
    diag.filter_value
ORDER BY
    CASE diag.filter_field WHEN @putaway_field THEN 1 ELSE 2 END,
    diag.filter_field;

;WITH inventory_base AS (
    SELECT
        sto.wh_id COLLATE DATABASE_DEFAULT AS wh_id,
        sto.item_number COLLATE DATABASE_DEFAULT AS item_number,
        itm.class_id COLLATE DATABASE_DEFAULT AS class_id,
        itm.pick_put_id COLLATE DATABASE_DEFAULT AS pick_put_id,
        sto.location_id COLLATE DATABASE_DEFAULT AS location_id,
        sto.lot_number COLLATE DATABASE_DEFAULT AS lot_number,
        sto.serial_number COLLATE DATABASE_DEFAULT AS serial_number,
        sto.po_number COLLATE DATABASE_DEFAULT AS po_number,
        sto.country_code COLLATE DATABASE_DEFAULT AS stored_country_code,
        sto.actual_qty
    FROM dbo.t_stored_item sto WITH (NOLOCK)
    INNER JOIN dbo.t_item_master itm WITH (NOLOCK)
        ON sto.wh_id = itm.wh_id
       AND sto.item_number = itm.item_number
    WHERE sto.wh_id = @wh_id
      AND (
            (@putaway_field = 'class_id' AND itm.class_id = @putaway_class)
         OR (@putaway_field = 'pick_put_id' AND itm.pick_put_id = @putaway_class)
      )
      AND sto.actual_qty > 0
      AND (@active_inventory_only = 0 OR sto.status = 'A')
),
inventory_with_coo AS (
    SELECT
        inv.wh_id,
        inv.item_number,
        inv.class_id,
        inv.pick_put_id,
        inv.location_id,
        inv.lot_number,
        inv.serial_number,
        inv.po_number,
        inv.actual_qty,
        coo.coo_country_code,
        coo.coo_source,
        CASE
            WHEN coo.coo_country_code IS NULL THEN 'unknown coo'
            WHEN coo.coo_country_code COLLATE DATABASE_DEFAULT IN ('VN', 'VNM', 'VIETNAM', 'VIET NAM') THEN 'vietnam local vendor'
            ELSE 'international vendor'
        END AS vendor_origin_bucket
    FROM inventory_base inv
    OUTER APPLY (
        SELECT TOP 1
            NULLIF(UPPER(LTRIM(RTRIM(snm.country_code COLLATE DATABASE_DEFAULT))), '') AS country_code
        FROM dbo.t_serial_master snm WITH (NOLOCK)
        WHERE snm.wh_id COLLATE DATABASE_DEFAULT = inv.wh_id COLLATE DATABASE_DEFAULT
          AND snm.item_number COLLATE DATABASE_DEFAULT = inv.item_number COLLATE DATABASE_DEFAULT
          AND snm.country_code IS NOT NULL
          AND LTRIM(RTRIM(snm.country_code)) <> ''
          AND snm.serial_number COLLATE DATABASE_DEFAULT IN (inv.lot_number COLLATE DATABASE_DEFAULT, inv.serial_number COLLATE DATABASE_DEFAULT)
        ORDER BY
            snm.status_change DESC
    ) serial_coo
    OUTER APPLY (
        SELECT TOP 1
            NULLIF(UPPER(LTRIM(RTRIM(asd.sn_coo COLLATE DATABASE_DEFAULT))), '') AS sn_coo
        FROM dbo.t_asn_detail asd WITH (NOLOCK)
        WHERE asd.item_number COLLATE DATABASE_DEFAULT = inv.item_number COLLATE DATABASE_DEFAULT
          AND asd.sn_coo IS NOT NULL
          AND LTRIM(RTRIM(asd.sn_coo)) <> ''
          AND inv.po_number IS NOT NULL
          AND LTRIM(RTRIM(inv.po_number)) <> ''
          AND asd.customer_po_number COLLATE DATABASE_DEFAULT = inv.po_number COLLATE DATABASE_DEFAULT
        ORDER BY
            asd.born_on_date DESC,
            asd.asn_detail_id DESC
    ) asn_po_coo
    OUTER APPLY (
        SELECT TOP 1
            NULLIF(UPPER(LTRIM(RTRIM(asd.sn_coo COLLATE DATABASE_DEFAULT))), '') AS sn_coo
        FROM dbo.t_asn_detail asd WITH (NOLOCK)
        WHERE asd.item_number COLLATE DATABASE_DEFAULT = inv.item_number COLLATE DATABASE_DEFAULT
          AND asd.sn_coo IS NOT NULL
          AND LTRIM(RTRIM(asd.sn_coo)) <> ''
          AND TRY_CONVERT(BIGINT, COALESCE(NULLIF(inv.serial_number, ''), NULLIF(inv.lot_number, ''))) IS NOT NULL
          AND TRY_CONVERT(BIGINT, asd.serial_number_start) IS NOT NULL
          AND TRY_CONVERT(BIGINT, asd.serial_number_end) IS NOT NULL
          AND TRY_CONVERT(BIGINT, COALESCE(NULLIF(inv.serial_number, ''), NULLIF(inv.lot_number, '')))
              BETWEEN TRY_CONVERT(BIGINT, asd.serial_number_start) AND TRY_CONVERT(BIGINT, asd.serial_number_end)
        ORDER BY
            asd.born_on_date DESC,
            asd.asn_detail_id DESC
    ) asn_serial_coo
    OUTER APPLY (
        SELECT TOP 1
            NULLIF(UPPER(LTRIM(RTRIM(tl.sn_coo COLLATE DATABASE_DEFAULT))), '') AS sn_coo
        FROM dbo.t_tran_log tl WITH (NOLOCK)
        WHERE tl.wh_id COLLATE DATABASE_DEFAULT = inv.wh_id COLLATE DATABASE_DEFAULT
          AND tl.item_number COLLATE DATABASE_DEFAULT = inv.item_number COLLATE DATABASE_DEFAULT
          AND tl.sn_coo IS NOT NULL
          AND LTRIM(RTRIM(tl.sn_coo)) <> ''
          AND (
                tl.lot_number COLLATE DATABASE_DEFAULT IN (inv.lot_number COLLATE DATABASE_DEFAULT, inv.serial_number COLLATE DATABASE_DEFAULT)
             OR tl.control_number COLLATE DATABASE_DEFAULT = inv.po_number COLLATE DATABASE_DEFAULT
             OR tl.control_number_2 COLLATE DATABASE_DEFAULT = inv.po_number COLLATE DATABASE_DEFAULT
          )
        ORDER BY
            tl.start_tran_date DESC,
            tl.start_tran_time DESC,
            tl.log_id DESC
    ) tran_coo
    CROSS APPLY (
        SELECT
            COALESCE(
                NULLIF(UPPER(LTRIM(RTRIM(inv.stored_country_code COLLATE DATABASE_DEFAULT))), ''),
                serial_coo.country_code,
                asn_po_coo.sn_coo,
                asn_serial_coo.sn_coo,
                tran_coo.sn_coo
            ) AS coo_country_code,
            CASE
                WHEN NULLIF(UPPER(LTRIM(RTRIM(inv.stored_country_code COLLATE DATABASE_DEFAULT))), '') IS NOT NULL THEN 't_stored_item.country_code'
                WHEN serial_coo.country_code IS NOT NULL THEN 't_serial_master.country_code'
                WHEN asn_po_coo.sn_coo IS NOT NULL THEN 't_asn_detail.sn_coo_by_po'
                WHEN asn_serial_coo.sn_coo IS NOT NULL THEN 't_asn_detail.sn_coo_by_serial_range'
                WHEN tran_coo.sn_coo IS NOT NULL THEN 't_tran_log.sn_coo'
                ELSE 'no coo found'
            END AS coo_source
    ) coo
),
floor_inventory AS (
    SELECT
        wh_id,
        item_number,
        class_id,
        pick_put_id,
        coo_country_code,
        coo_source,
        vendor_origin_bucket,
        SUM(actual_qty) AS onhand_qty
    FROM inventory_with_coo
    GROUP BY
        wh_id,
        item_number,
        class_id,
        pick_put_id,
        coo_country_code,
        coo_source,
        vendor_origin_bucket
),
forecast_1_60 AS (
    SELECT
        f.wh_id,
        f.item_number,
        SUM(f.forecast_demand) AS forecast_qty_1_60
    FROM dbo.t_item_forecast_daily f WITH (NOLOCK)
    INNER JOIN dbo.t_item_master itm WITH (NOLOCK)
        ON f.wh_id = itm.wh_id
       AND f.item_number = itm.item_number
    WHERE f.wh_id = @wh_id
      AND (
            (@putaway_field = 'class_id' AND itm.class_id = @putaway_class)
         OR (@putaway_field = 'pick_put_id' AND itm.pick_put_id = @putaway_class)
      )
      AND f.pick_day BETWEEN 1 AND 60
    GROUP BY
        f.wh_id,
        f.item_number
)
SELECT
    inv.wh_id,
    inv.item_number,
    inv.class_id,
    inv.pick_put_id,
    inv.coo_country_code,
    inv.coo_source,
    inv.vendor_origin_bucket,
    inv.onhand_qty,
    ISNULL(fc.forecast_qty_1_60, 0) AS forecast_qty_1_60,
    CAST(ISNULL(fc.forecast_qty_1_60, 0) / 60.0 AS DECIMAL(18, 4)) AS avg_daily_forecast_1_60,
    CAST(
        CASE
            WHEN ISNULL(fc.forecast_qty_1_60, 0) <= 0 THEN NULL
            ELSE inv.onhand_qty * 60.0 / fc.forecast_qty_1_60
        END
        AS DECIMAL(18, 2)
    ) AS days_of_supply
INTO #item_days
FROM floor_inventory inv
LEFT JOIN forecast_1_60 fc
    ON inv.wh_id = fc.wh_id
   AND inv.item_number = fc.item_number;

/* Diagnostic result set 2: shows where COO was resolved from. */
SELECT
    coo_source,
    coo_country_code,
    vendor_origin_bucket,
    COUNT(DISTINCT item_number) AS item_count,
    SUM(onhand_qty) AS total_onhand_qty
FROM #item_days
GROUP BY
    coo_source,
    coo_country_code,
    vendor_origin_bucket
ORDER BY
    CASE WHEN coo_source = 'no coo found' THEN 2 ELSE 1 END,
    coo_source,
    coo_country_code;

SELECT
    wh_id,
    item_number,
    class_id,
    pick_put_id,
    coo_country_code,
    coo_source,
    vendor_origin_bucket,
    onhand_qty,
    forecast_qty_1_60,
    avg_daily_forecast_1_60,
    days_of_supply
FROM #item_days
ORDER BY
    vendor_origin_bucket,
    coo_country_code,
    item_number;

SELECT
    vendor_origin_bucket,
    COUNT(DISTINCT item_number) AS item_count,
    SUM(onhand_qty) AS total_onhand_qty,
    SUM(forecast_qty_1_60) AS total_forecast_qty_1_60,
    CAST(SUM(forecast_qty_1_60) / 60.0 AS DECIMAL(18, 4)) AS avg_daily_forecast_1_60,
    CAST(
        CASE
            WHEN SUM(forecast_qty_1_60) <= 0 THEN NULL
            ELSE SUM(onhand_qty) * 60.0 / SUM(forecast_qty_1_60)
        END
        AS DECIMAL(18, 2)
    ) AS avg_days_of_supply
FROM #item_days
GROUP BY
    vendor_origin_bucket
ORDER BY
    CASE vendor_origin_bucket
        WHEN 'vietnam local vendor' THEN 1
        WHEN 'international vendor' THEN 2
        ELSE 3
    END;

DROP TABLE #item_days;
