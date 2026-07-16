-- FLOOR inventory days of supply

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

coo AS
(
    SELECT DISTINCT
        wh_id,
        item_number,
        serial_number,
        CASE
            WHEN country_code IS NULL
                THEN 'vietnam local vendor'

            WHEN country_code COLLATE DATABASE_DEFAULT
                 IN ('VN', 'VNM', 'VIETNAM', 'VIET NAM')
                THEN 'vietnam local vendor'

            ELSE 'international vendor'
        END AS vendor_coo
    FROM dbo.t_serial_master WITH (NOLOCK)
    WHERE wh_id = '335'
      AND serial_no_status NOT IN ('S', 'O')
),

sn_oh AS
(
    SELECT
        s.wh_id,
        s.item_number,
        s.serial_number,
        1 AS qty,
        s.serial_no_status,
        s.location_id,
        c.vendor_coo
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

onhand AS
(
    SELECT
        wh_id,
        item_number,

        SUM(qty) AS onhand_qty,

        CASE
            ---------------------------------------------------
            -- No active SN can find COO information
            ---------------------------------------------------
            WHEN SUM(
                    CASE
                        WHEN vendor_coo IS NOT NULL THEN 1
                        ELSE 0
                    END
                 ) = 0
                THEN 'no coo found'

            ---------------------------------------------------
            -- Both local and international inventory exist
            ---------------------------------------------------
            WHEN SUM(
                    CASE
                        WHEN vendor_coo = 'vietnam local vendor'
                            THEN 1
                        ELSE 0
                    END
                 ) > 0
             AND SUM(
                    CASE
                        WHEN vendor_coo = 'international vendor'
                            THEN 1
                        ELSE 0
                    END
                 ) > 0
                THEN 'mixed coo'

            ---------------------------------------------------
            -- International only
            ---------------------------------------------------
            WHEN SUM(
                    CASE
                        WHEN vendor_coo = 'international vendor'
                            THEN 1
                        ELSE 0
                    END
                 ) > 0
                THEN 'international vendor'

            ---------------------------------------------------
            -- Vietnam local only
            ---------------------------------------------------
            WHEN SUM(
                    CASE
                        WHEN vendor_coo = 'vietnam local vendor'
                            THEN 1
                        ELSE 0
                    END
                 ) > 0
                THEN 'vietnam local vendor'

            ELSE 'no coo found'
        END AS coo

    FROM sn_oh
    GROUP BY
        wh_id,
        item_number
),

forecast_1_60 AS
(
    SELECT
        f.wh_id,
        f.item_number,
        SUM(COALESCE(f.forecast_demand, 0)) AS forecast_qty_1_60

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

final_data AS
(
    SELECT
        oh.wh_id,
        oh.item_number,
        i.class_id,
        oh.coo,
        oh.onhand_qty,

        COALESCE(fc.forecast_qty_1_60, 0)
            AS forecast_qty_1_60,

        -------------------------------------------------------
        -- Average daily forecast = 60-day forecast / 60
        -------------------------------------------------------
        CAST(
            ROUND(
                COALESCE(fc.forecast_qty_1_60, 0) / 60.0,
                4
            )
            AS DECIMAL(18,4)
        ) AS avg_daily_forecast_1_60,

        -------------------------------------------------------
        -- Days of Supply
        -- = On Hand / Average Daily Forecast
        -- = On Hand * 60 / 60-day Forecast
        -------------------------------------------------------
        CASE
            WHEN COALESCE(fc.forecast_qty_1_60, 0) = 0
                THEN NULL

            ELSE
                CAST(
                    ROUND(
                        oh.onhand_qty * 60.0
                        / NULLIF(fc.forecast_qty_1_60, 0),
                        2
                    )
                    AS DECIMAL(18,2)
                )
        END AS days_of_supply

    FROM onhand AS oh

    INNER JOIN itm AS i
        ON oh.wh_id = i.wh_id
       AND oh.item_number = i.item_number

    LEFT JOIN forecast_1_60 AS fc
        ON oh.wh_id = fc.wh_id
       AND oh.item_number = fc.item_number
)

SELECT
    wh_id,
    item_number,
    class_id,
    coo,
    onhand_qty,
    forecast_qty_1_60,
    avg_daily_forecast_1_60,
    days_of_supply

FROM final_data

ORDER BY
    -----------------------------------------------------------
    -- Forecast = 0 / Days of Supply NULL first
    -----------------------------------------------------------
    CASE
        WHEN days_of_supply IS NULL THEN 0
        ELSE 1
    END,

    -----------------------------------------------------------
    -- Then highest Days of Supply first
    -----------------------------------------------------------
    days_of_supply DESC,

    item_number;