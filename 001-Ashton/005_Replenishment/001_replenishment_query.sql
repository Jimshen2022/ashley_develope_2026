DECLARE @wh_id       varchar(10) = '335';
DECLARE @item_number varchar(30) = 'T247-13';
DECLARE @location_id varchar(50) = 'A3017NX1';

WITH target_loc AS (
    SELECT
        l.wh_id,
        l.location_id,
        l.status AS location_status,
        l.type   AS location_type,
        l.zone,
        l.building
    FROM dbo.t_location l WITH (NOLOCK)
    WHERE l.wh_id = @wh_id
      AND l.location_id = @location_id
),
fwd_cfg AS (
    SELECT
        f.wh_id,
        f.location_id,
        f.item_number,
        f.replen_level,
        f.replen_qty,
        f.capacity_qty,
        CASE
            WHEN ISNULL(f.capacity_qty, 0) > 0 THEN f.capacity_qty
            WHEN ISNULL(f.replen_level, 0) + ISNULL(f.replen_qty, 0) > 0
                THEN ISNULL(f.replen_level, 0) + ISNULL(f.replen_qty, 0)
            ELSE NULL
        END AS target_capacity_qty
    FROM dbo.t_fwd_pick f WITH (NOLOCK)
    WHERE f.wh_id = @wh_id
      AND f.location_id = @location_id
      AND f.item_number = @item_number
),
pick_inv AS (
    SELECT
        s.wh_id,
        s.location_id,
        s.item_number,
        SUM(ISNULL(s.actual_qty, 0)) AS current_pick_qty
    FROM dbo.t_stored_item s WITH (NOLOCK)
    WHERE s.wh_id = @wh_id
      AND s.location_id = @location_id
      AND s.item_number = @item_number
      AND s.type = 'STORAGE'
      AND s.status = 'A'
    GROUP BY s.wh_id, s.location_id, s.item_number
),
open_replen_wkq AS (
    SELECT
        w.wh_id,
        w.item_number,
        w.location_id,
        COUNT(*) AS open_wkq_count,
        SUM(ISNULL(w.qty, 0)) AS open_wkq_qty,
        STRING_AGG(CONVERT(varchar(30), w.work_q_id), ', ') AS work_q_ids
    FROM dbo.t_work_q w WITH (NOLOCK)
    WHERE w.wh_id = @wh_id
      AND w.item_number = @item_number
      AND w.work_type = '07'
      AND w.work_status <> 'C'
      AND w.pick_ref_number IN ('INTERBUILDING', 'REPLENISH', 'LTCREPLENISH')
      AND (w.location_id = @location_id OR w.from_location_id = @location_id)
    GROUP BY w.wh_id, w.item_number, w.location_id
),
same_building_stock AS (
    SELECT
        loc.building,
        s.item_number,
        SUM(CASE WHEN loc.type IN ('I','M','P') THEN ISNULL(s.actual_qty, 0) ELSE 0 END) AS qty_in_I_M_P,
        SUM(CASE WHEN loc.type IN ('IG','F','SL') AND s.status <> 'U' THEN ISNULL(s.actual_qty, 0) ELSE 0 END) AS qty_in_IG_F_SL,
        SUM(CASE
                WHEN loc.location_id <> @location_id
                 AND loc.type IN ('I','M','P','IG','F','SL')
                THEN ISNULL(s.actual_qty, 0)
                ELSE 0
            END) AS qty_other_locations_same_building
    FROM dbo.t_stored_item s WITH (NOLOCK)
    JOIN dbo.t_location loc WITH (NOLOCK)
      ON loc.wh_id = s.wh_id
     AND loc.location_id = s.location_id
    JOIN target_loc tgt
      ON tgt.building = loc.building
     AND tgt.wh_id = loc.wh_id
    WHERE s.wh_id = @wh_id
      AND s.item_number = @item_number
      AND s.type = 'STORAGE'
    GROUP BY loc.building, s.item_number
)
SELECT
    @wh_id AS wh_id,
    @item_number AS item_number,
    @location_id AS location_id,
    tgt.location_type,
    tgt.location_status,
    CASE WHEN tgt.location_status IN ('E','F','P') THEN 'Yes' ELSE 'No' END AS location_is_active_proxy,
    tgt.building,
    fwd.replen_level,
    fwd.replen_qty,
    fwd.capacity_qty,
    fwd.target_capacity_qty,
    ISNULL(pick.current_pick_qty, 0) AS current_pick_qty,
    CASE
        WHEN ISNULL(fwd.target_capacity_qty, 0) > 0
        THEN CAST(ISNULL(pick.current_pick_qty, 0) * 100.0 / fwd.target_capacity_qty AS decimal(18,2))
        ELSE NULL
    END AS current_percent_full,
    CASE
        WHEN ISNULL(fwd.replen_level, 0) > ISNULL(pick.current_pick_qty, 0)
        THEN ISNULL(fwd.replen_level, 0) - ISNULL(pick.current_pick_qty, 0)
        ELSE 0
    END AS shortage_to_replen_level,
    CASE
        WHEN ISNULL(fwd.target_capacity_qty, 0) > ISNULL(pick.current_pick_qty, 0)
        THEN ISNULL(fwd.target_capacity_qty, 0) - ISNULL(pick.current_pick_qty, 0)
        ELSE 0
    END AS shortage_to_target_capacity,
    ISNULL(wkq.open_wkq_count, 0) AS open_replen_wkq_count,
    ISNULL(wkq.open_wkq_qty, 0) AS open_replen_wkq_qty,
    wkq.work_q_ids,
    ISNULL(src.qty_in_I_M_P, 0) AS same_building_qty_in_I_M_P,
    ISNULL(src.qty_in_IG_F_SL, 0) AS same_building_qty_in_IG_F_SL,
    ISNULL(src.qty_other_locations_same_building, 0) AS same_building_qty_other_locations,
    CASE
        WHEN fwd.item_number IS NULL THEN 'No forward-pick setup found for this item/location'
        WHEN ISNULL(pick.current_pick_qty, 0) >= ISNULL(fwd.replen_level, 0)
             THEN 'Pick qty is already at/above replen_level'
        WHEN ISNULL(wkq.open_wkq_count, 0) > 0
             THEN 'Already has open replenishment WKQ'
        WHEN ISNULL(src.qty_other_locations_same_building, 0) <= 0
             THEN 'Target location is short, but no same-building source stock is visible'
        ELSE 'Pick qty is below replen_level, no open replen WKQ, and same-building stock exists'
    END AS diagnosis_summary
FROM target_loc tgt
LEFT JOIN fwd_cfg fwd
  ON fwd.wh_id = tgt.wh_id
 AND fwd.location_id = tgt.location_id
LEFT JOIN pick_inv pick
  ON pick.wh_id = tgt.wh_id
 AND pick.location_id = tgt.location_id
 AND pick.item_number = fwd.item_number
LEFT JOIN open_replen_wkq wkq
  ON wkq.wh_id = tgt.wh_id
 AND wkq.location_id = tgt.location_id
 AND wkq.item_number = @item_number
LEFT JOIN same_building_stock src
  ON src.building = tgt.building
 AND src.item_number = @item_number;