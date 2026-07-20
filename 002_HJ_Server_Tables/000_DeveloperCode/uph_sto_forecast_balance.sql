/*
UPH STO / forecast demand balance by item.

Rules:
- item scope: dbo.t_item_master.pick_put_id = @pick_put_id
- sto_qty comes from dbo.t_stored_item where type = 'STORAGE', excluding location_id LIKE 'EX%', 'SH%', 'NG%', and 'DM%'
- shipping_stage_qty comes from dbo.t_stored_item where location_id starts with S or D, excluding exception locations EX%, SH%, NG%, and DM%
- exception locations are not counted as shippable inventory or shipping stage
- demand buckets come from dbo.t_item_forecast_daily.pick_day / forecast_demand
- no-demand bucket quantity = sto_qty - MAX(demand_qty - shipping_stage_qty, 0), floored at zero
- allocated location strings use non-shipping-stage storage inventory only
*/

DECLARE @wh_id VARCHAR(10) = '335';
DECLARE @pick_put_id VARCHAR(15) = 'UPH';

;WITH item_scope AS (
    SELECT
        itm.wh_id,
        itm.item_number
    FROM dbo.t_item_master itm WITH (NOLOCK)
    WHERE itm.wh_id = @wh_id
      AND itm.pick_put_id = @pick_put_id
),
storage_inventory AS (
    SELECT
        sto.wh_id,
        sto.item_number,
        SUM(sto.actual_qty) AS sto_qty
    FROM dbo.t_stored_item sto WITH (NOLOCK)
    INNER JOIN item_scope item
        ON item.wh_id = sto.wh_id
       AND item.item_number = sto.item_number
    WHERE sto.wh_id = @wh_id
      AND sto.type = 'STORAGE'
      AND sto.status = 'A'
      AND sto.actual_qty > 0
      AND sto.location_id NOT LIKE 'EX%'
      AND sto.location_id NOT LIKE 'SH%'
      AND sto.location_id NOT LIKE 'NG%'
      AND sto.location_id NOT LIKE 'DM%'
    GROUP BY
        sto.wh_id,
        sto.item_number
),
shipping_stage AS (
    SELECT
        sto.wh_id,
        sto.item_number,
        SUM(sto.actual_qty) AS shipping_stage_qty
    FROM dbo.t_stored_item sto WITH (NOLOCK)
    INNER JOIN item_scope item
        ON item.wh_id = sto.wh_id
       AND item.item_number = sto.item_number
    WHERE sto.wh_id = @wh_id
      AND sto.status = 'A'
      AND sto.actual_qty > 0
      AND sto.location_id NOT LIKE 'EX%'
      AND sto.location_id NOT LIKE 'SH%'
      AND sto.location_id NOT LIKE 'NG%'
      AND sto.location_id NOT LIKE 'DM%'
      AND (sto.location_id LIKE 'S%' OR sto.location_id LIKE 'D%')
    GROUP BY
        sto.wh_id,
        sto.item_number
),
inventory_location AS (
    SELECT
        sto.wh_id,
        sto.item_number,
        sto.location_id,
        SUM(sto.actual_qty) AS location_qty
    FROM dbo.t_stored_item sto WITH (NOLOCK)
    INNER JOIN item_scope item
        ON item.wh_id = sto.wh_id
       AND item.item_number = sto.item_number
    WHERE sto.wh_id = @wh_id
      AND sto.type = 'STORAGE'
      AND sto.status = 'A'
      AND sto.actual_qty > 0
      AND sto.location_id NOT LIKE 'EX%'
      AND sto.location_id NOT LIKE 'SH%'
      AND sto.location_id NOT LIKE 'NG%'
      AND sto.location_id NOT LIKE 'DM%'
      AND sto.location_id NOT LIKE 'S%'
      AND sto.location_id NOT LIKE 'D%'
    GROUP BY
        sto.wh_id,
        sto.item_number,
        sto.location_id
),
location_ranked AS (
    SELECT
        wh_id,
        item_number,
        location_id,
        location_qty,
        SUM(location_qty) OVER (
            PARTITION BY wh_id, item_number
            ORDER BY location_id
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS running_qty,
        ISNULL(
            SUM(location_qty) OVER (
                PARTITION BY wh_id, item_number
                ORDER BY location_id
                ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
            ),
            0
        ) AS previous_running_qty
    FROM inventory_location
),
forecast AS (
    SELECT
        f.wh_id,
        f.item_number,
        SUM(CASE WHEN f.pick_day >= 1 THEN f.forecast_demand ELSE 0 END) AS all_demand_qty,
        SUM(CASE WHEN f.pick_day BETWEEN 1 AND 30 THEN f.forecast_demand ELSE 0 END) AS demand_30_days,
        SUM(CASE WHEN f.pick_day BETWEEN 1 AND 60 THEN f.forecast_demand ELSE 0 END) AS demand_60_days,
        SUM(CASE WHEN f.pick_day BETWEEN 1 AND 90 THEN f.forecast_demand ELSE 0 END) AS demand_90_days,
        SUM(CASE WHEN f.pick_day BETWEEN 1 AND 180 THEN f.forecast_demand ELSE 0 END) AS demand_180_days,
        SUM(CASE WHEN f.pick_day BETWEEN 1 AND 360 THEN f.forecast_demand ELSE 0 END) AS demand_360_days
    FROM dbo.t_item_forecast_daily f WITH (NOLOCK)
    INNER JOIN item_scope item
        ON item.wh_id = f.wh_id
       AND item.item_number = f.item_number
    WHERE f.wh_id = @wh_id
      AND f.pick_day >= 1
    GROUP BY
        f.wh_id,
        f.item_number
),
combined AS (
    SELECT
        item.wh_id,
        item.item_number,
        ISNULL(inv.sto_qty, 0) AS sto_qty,
        ISNULL(stage.shipping_stage_qty, 0) AS shipping_stage_qty,
        ISNULL(fc.all_demand_qty, 0) AS all_demand_qty,
        ISNULL(fc.demand_30_days, 0) AS demand_30_days,
        ISNULL(fc.demand_60_days, 0) AS demand_60_days,
        ISNULL(fc.demand_90_days, 0) AS demand_90_days,
        ISNULL(fc.demand_180_days, 0) AS demand_180_days,
        ISNULL(fc.demand_360_days, 0) AS demand_360_days
    FROM item_scope item
    LEFT JOIN storage_inventory inv
        ON inv.wh_id = item.wh_id
       AND inv.item_number = item.item_number
    LEFT JOIN shipping_stage stage
        ON stage.wh_id = item.wh_id
       AND stage.item_number = item.item_number
    LEFT JOIN forecast fc
        ON fc.wh_id = item.wh_id
       AND fc.item_number = item.item_number
),
balances AS (
    SELECT
        wh_id,
        item_number,
        sto_qty,
        shipping_stage_qty,
        all_demand_qty,
        CASE
            WHEN all_demand_qty - shipping_stage_qty <= 0 THEN sto_qty
            WHEN sto_qty - (all_demand_qty - shipping_stage_qty) < 0 THEN 0
            ELSE sto_qty - (all_demand_qty - shipping_stage_qty)
        END AS no_demand_qty,
        demand_30_days,
        CASE
            WHEN demand_30_days - shipping_stage_qty <= 0 THEN sto_qty
            WHEN sto_qty - (demand_30_days - shipping_stage_qty) < 0 THEN 0
            ELSE sto_qty - (demand_30_days - shipping_stage_qty)
        END AS over_30_days_no_demand_qty,
        demand_60_days,
        CASE
            WHEN demand_60_days - shipping_stage_qty <= 0 THEN sto_qty
            WHEN sto_qty - (demand_60_days - shipping_stage_qty) < 0 THEN 0
            ELSE sto_qty - (demand_60_days - shipping_stage_qty)
        END AS over_60_days_no_demand_qty,
        demand_90_days,
        CASE
            WHEN demand_90_days - shipping_stage_qty <= 0 THEN sto_qty
            WHEN sto_qty - (demand_90_days - shipping_stage_qty) < 0 THEN 0
            ELSE sto_qty - (demand_90_days - shipping_stage_qty)
        END AS over_90_days_no_demand_qty,
        demand_180_days,
        CASE
            WHEN demand_180_days - shipping_stage_qty <= 0 THEN sto_qty
            WHEN sto_qty - (demand_180_days - shipping_stage_qty) < 0 THEN 0
            ELSE sto_qty - (demand_180_days - shipping_stage_qty)
        END AS over_180_days_no_demand_qty,
        demand_360_days,
        CASE
            WHEN demand_360_days - shipping_stage_qty <= 0 THEN sto_qty
            WHEN sto_qty - (demand_360_days - shipping_stage_qty) < 0 THEN 0
            ELSE sto_qty - (demand_360_days - shipping_stage_qty)
        END AS over_360_days_no_demand_qty
    FROM combined
),
balance_buckets AS (
    SELECT wh_id, item_number, 'all' AS bucket_name, no_demand_qty AS bucket_qty FROM balances
    UNION ALL
    SELECT wh_id, item_number, '30', over_30_days_no_demand_qty FROM balances
    UNION ALL
    SELECT wh_id, item_number, '60', over_60_days_no_demand_qty FROM balances
    UNION ALL
    SELECT wh_id, item_number, '90', over_90_days_no_demand_qty FROM balances
    UNION ALL
    SELECT wh_id, item_number, '180', over_180_days_no_demand_qty FROM balances
    UNION ALL
    SELECT wh_id, item_number, '360', over_360_days_no_demand_qty FROM balances
),
allocated_detail AS (
    SELECT
        bucket.wh_id,
        bucket.item_number,
        bucket.bucket_name,
        loc.location_id,
        CASE
            WHEN loc.running_qty <= bucket.bucket_qty THEN loc.location_qty
            WHEN loc.previous_running_qty < bucket.bucket_qty THEN bucket.bucket_qty - loc.previous_running_qty
            ELSE 0
        END AS allocated_qty
    FROM balance_buckets bucket
    INNER JOIN location_ranked loc
        ON loc.wh_id = bucket.wh_id
       AND loc.item_number = bucket.item_number
    WHERE bucket.bucket_qty > 0
),
allocated_strings AS (
    SELECT
        alloc.wh_id,
        alloc.item_number,
        alloc.bucket_name,
        STRING_AGG(
            CONVERT(NVARCHAR(MAX), CONCAT(alloc.location_id, ' * ', CONVERT(VARCHAR(30), CAST(alloc.allocated_qty AS DECIMAL(18, 0))))),
            '; '
        ) WITHIN GROUP (ORDER BY alloc.location_id) AS allocated_location_qty
    FROM allocated_detail alloc
    WHERE alloc.allocated_qty > 0
    GROUP BY
        alloc.wh_id,
        alloc.item_number,
        alloc.bucket_name
)
SELECT
    bal.item_number AS item,
    bal.sto_qty,
    bal.shipping_stage_qty,
    bal.all_demand_qty,
    bal.no_demand_qty,
    ISNULL(loc_all.allocated_location_qty, '') AS no_demand_allocated_location_qty,
    bal.demand_30_days,
    bal.over_30_days_no_demand_qty,
    ISNULL(loc_30.allocated_location_qty, '') AS over_30_days_allocated_location_qty,
    bal.demand_60_days,
    bal.over_60_days_no_demand_qty,
    ISNULL(loc_60.allocated_location_qty, '') AS over_60_days_allocated_location_qty,
    bal.demand_90_days,
    bal.over_90_days_no_demand_qty,
    ISNULL(loc_90.allocated_location_qty, '') AS over_90_days_allocated_location_qty,
    bal.demand_180_days,
    bal.over_180_days_no_demand_qty,
    ISNULL(loc_180.allocated_location_qty, '') AS over_180_days_allocated_location_qty,
    bal.demand_360_days,
    bal.over_360_days_no_demand_qty,
    ISNULL(loc_360.allocated_location_qty, '') AS over_360_days_allocated_location_qty
FROM balances bal
LEFT JOIN allocated_strings loc_all
    ON loc_all.wh_id = bal.wh_id
   AND loc_all.item_number = bal.item_number
   AND loc_all.bucket_name = 'all'
LEFT JOIN allocated_strings loc_30
    ON loc_30.wh_id = bal.wh_id
   AND loc_30.item_number = bal.item_number
   AND loc_30.bucket_name = '30'
LEFT JOIN allocated_strings loc_60
    ON loc_60.wh_id = bal.wh_id
   AND loc_60.item_number = bal.item_number
   AND loc_60.bucket_name = '60'
LEFT JOIN allocated_strings loc_90
    ON loc_90.wh_id = bal.wh_id
   AND loc_90.item_number = bal.item_number
   AND loc_90.bucket_name = '90'
LEFT JOIN allocated_strings loc_180
    ON loc_180.wh_id = bal.wh_id
   AND loc_180.item_number = bal.item_number
   AND loc_180.bucket_name = '180'
LEFT JOIN allocated_strings loc_360
    ON loc_360.wh_id = bal.wh_id
   AND loc_360.item_number = bal.item_number
   AND loc_360.bucket_name = '360'
WHERE bal.sto_qty <> 0
   OR bal.shipping_stage_qty <> 0
   OR bal.all_demand_qty <> 0
ORDER BY bal.item_number;




