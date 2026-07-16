-- FLOOR inventory age summary by vendor origin

;WITH itm AS
(
    SELECT DISTINCT
        wh_id,
        item_number,
        class_id
    FROM dbo.t_item_master WITH (NOLOCK)
    WHERE wh_id = '335'
      AND class_id = 'FLOOR'
),

------------------------------------------------------------
-- Get COO information by serial number
------------------------------------------------------------
coo AS
(
    SELECT DISTINCT
        sm.wh_id,
        sm.item_number,
        sm.serial_number,

        CASE
            WHEN sm.country_code IS NULL
                THEN 'Vietnam'

            WHEN UPPER(LTRIM(RTRIM(sm.country_code)))
                 COLLATE DATABASE_DEFAULT
                 IN ('VN', 'VNM', 'VIETNAM', 'VIET NAM')
                THEN 'Vietnam'

            ELSE 'International'
        END AS vendor_origin

    FROM dbo.t_serial_master AS sm WITH (NOLOCK)

    WHERE sm.wh_id = '335'
      AND sm.serial_no_status NOT IN ('S', 'O')
),

------------------------------------------------------------
-- Active on-hand serial numbers
------------------------------------------------------------
sn_oh AS
(
    SELECT
        s.wh_id,
        s.item_number,
        s.serial_number,
        s.location_id,
        c.vendor_origin

    FROM dbo.t_serial_active AS s WITH (NOLOCK)

    INNER JOIN itm AS i
        ON s.wh_id = i.wh_id
       AND s.item_number = i.item_number

    LEFT JOIN coo AS c
        ON s.wh_id = c.wh_id
       AND s.item_number = c.item_number
       AND s.serial_number = c.serial_number

    WHERE s.wh_id = '335'
      AND s.serial_no_status NOT IN ('S', 'O')
),

------------------------------------------------------------
-- Aggregate on-hand to ITEM level first
--
-- Determine item vendor bucket:
-- 1. Vietnam
-- 2. International
-- 3. Mixed
-- 4. No COO Found
------------------------------------------------------------
item_onhand AS
(
    SELECT
        wh_id,
        item_number,

        COUNT(*) AS onhand_qty,

        CASE
            ------------------------------------------------
            -- No COO matched for any active SN
            ------------------------------------------------
            WHEN SUM(
                    CASE
                        WHEN vendor_origin IS NOT NULL
                            THEN 1
                        ELSE 0
                    END
                 ) = 0
                THEN 'No COO Found'

            ------------------------------------------------
            -- Both Vietnam and International exist
            ------------------------------------------------
            WHEN SUM(
                    CASE
                        WHEN vendor_origin = 'Vietnam'
                            THEN 1
                        ELSE 0
                    END
                 ) > 0

             AND SUM(
                    CASE
                        WHEN vendor_origin = 'International'
                            THEN 1
                        ELSE 0
                    END
                 ) > 0
                THEN 'Mixed'

            ------------------------------------------------
            -- Vietnam only
            ------------------------------------------------
            WHEN SUM(
                    CASE
                        WHEN vendor_origin = 'Vietnam'
                            THEN 1
                        ELSE 0
                    END
                 ) > 0
                THEN 'Vietnam'

            ------------------------------------------------
            -- International only
            ------------------------------------------------
            WHEN SUM(
                    CASE
                        WHEN vendor_origin = 'International'
                            THEN 1
                        ELSE 0
                    END
                 ) > 0
                THEN 'International'

            ELSE 'No COO Found'

        END AS vendor_origin_bucket

    FROM sn_oh

    GROUP BY
        wh_id,
        item_number
),

------------------------------------------------------------
-- 60-day forecast by ITEM
------------------------------------------------------------
forecast_1_60 AS
(
    SELECT
        f.wh_id,
        f.item_number,

        SUM(
            COALESCE(f.forecast_demand, 0)
        ) AS forecast_qty_1_60

    FROM dbo.t_item_forecast_daily AS f WITH (NOLOCK)

    INNER JOIN itm AS i
        ON f.wh_id = i.wh_id
       AND f.item_number = i.item_number

    WHERE f.wh_id = '335'
      AND f.pick_day BETWEEN 1 AND 60

    GROUP BY
        f.wh_id,
        f.item_number
),

------------------------------------------------------------
-- Combine inventory and forecast at ITEM level
------------------------------------------------------------
item_data AS
(
    SELECT
        oh.wh_id,
        oh.item_number,
        oh.vendor_origin_bucket,
        oh.onhand_qty,

        COALESCE(
            fc.forecast_qty_1_60,
            0
        ) AS forecast_qty_1_60

    FROM item_onhand AS oh

    LEFT JOIN forecast_1_60 AS fc
        ON oh.wh_id = fc.wh_id
       AND oh.item_number = fc.item_number
)

------------------------------------------------------------
-- Final summary by Vendor Origin Bucket
------------------------------------------------------------
SELECT
    vendor_origin_bucket,

    --------------------------------------------------------
    -- Number of distinct FLOOR items
    --------------------------------------------------------
    COUNT(DISTINCT item_number)
        AS item_count,

    --------------------------------------------------------
    -- Total on-hand pieces
    --------------------------------------------------------
    SUM(onhand_qty)
        AS total_onhand_qty,

    --------------------------------------------------------
    -- Total 60-day forecast
    --------------------------------------------------------
    SUM(forecast_qty_1_60)
        AS total_forecast_qty_1_60,

    --------------------------------------------------------
    -- Average daily forecast
    -- = Total 60-day Forecast / 60
    --------------------------------------------------------
    CAST(
        ROUND(
            SUM(forecast_qty_1_60) / 60.0,
            4
        )
        AS DECIMAL(18,4)
    ) AS avg_daily_forecast_1_60,

    --------------------------------------------------------
    -- Average Days of Supply
    --
    -- = Total On Hand / Aggregate Daily Forecast
    -- = Total On Hand * 60 / Total 60-day Forecast
    --------------------------------------------------------
    CASE
        WHEN SUM(forecast_qty_1_60) = 0
            THEN NULL

        ELSE
            CAST(
                ROUND(
                    SUM(onhand_qty) * 60.0
                    / NULLIF(
                        SUM(forecast_qty_1_60),
                        0
                    ),
                    2
                )
                AS DECIMAL(18,2)
            )
    END AS avg_days_of_supply

FROM item_data

GROUP BY
    vendor_origin_bucket

ORDER BY
    CASE vendor_origin_bucket
        WHEN 'Vietnam'       THEN 1
        WHEN 'International' THEN 2
        WHEN 'Mixed'         THEN 3
        WHEN 'No COO Found'  THEN 4
        ELSE 5
    END;