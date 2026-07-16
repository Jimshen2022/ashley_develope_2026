DECLARE @wh_id         varchar(10) = '335';
DECLARE @item_number   varchar(30) = '%';
DECLARE @location_like varchar(50) = '%';   -- 例如 'A301%'，不限制就用 '%'

WITH inv AS (
    SELECT
        s.wh_id,
        s.item_number,
        s.location_id,
        s.status AS inventory_status,
        SUM(ISNULL(s.actual_qty, 0)) AS actual_quantity,
        SUM(ISNULL(s.unavailable_qty, 0)) AS unavailable_qty,
        MIN(s.fifo_date) AS born_on_date
    FROM dbo.t_stored_item s WITH (NOLOCK)
    WHERE s.wh_id = @wh_id
      AND s.item_number = @item_number
      AND s.location_id LIKE @location_like
      AND s.type = 'STORAGE'
    GROUP BY
        s.wh_id,
        s.item_number,
        s.location_id,
        s.status
),
fp_detail AS (
    SELECT
        f.wh_id,
        f.item_number,
        f.location_id,
        f.replen_level,
        f.replen_qty,
        f.capacity_qty AS fwd_pick_capacity,
        CASE
            WHEN ISNULL(f.capacity_qty, 0) > 0 THEN f.capacity_qty
            WHEN ISNULL(f.replen_level, 0) + ISNULL(f.replen_qty, 0) > 0
                THEN ISNULL(f.replen_level, 0) + ISNULL(f.replen_qty, 0)
            ELSE NULL
        END AS target_capacity_qty
    FROM dbo.t_fwd_pick f WITH (NOLOCK)
    WHERE f.wh_id = @wh_id
      AND f.item_number = @item_number
),
fp_item AS (
    SELECT
        f.wh_id,
        f.item_number,
        STRING_AGG(f.location_id, ', ') AS fwp_location_id,
        MAX(f.replen_level) AS replen_level,
        MAX(f.replen_qty) AS replen_qty,
        MAX(f.capacity_qty) AS fwd_pick_capacity
    FROM dbo.t_fwd_pick f WITH (NOLOCK)
    WHERE f.wh_id = @wh_id
      AND f.item_number = @item_number
    GROUP BY
        f.wh_id,
        f.item_number
),
fp_loc_info AS (
    SELECT
        f.wh_id,
        f.item_number,
        STRING_AGG(
            CONCAT(
                f.location_id,
                ' | InvStatus:', ISNULL(i.inventory_status, '-'),
                ' | LocStatus:', ISNULL(l.status, '-'),
                ' | LocType:', ISNULL(l.type, '-')
            ),
            ' ; '
        ) AS fwp_location_detail,
        STRING_AGG(f.location_id, ', ') AS fwp_location_id,
        STRING_AGG(ISNULL(i.inventory_status, '-'), ', ') AS fwp_inventory_status,
        STRING_AGG(ISNULL(l.status, '-'), ', ') AS fwp_location_status,
        STRING_AGG(ISNULL(l.type, '-'), ', ') AS fwp_location_type
    FROM fp_detail f
    LEFT JOIN dbo.t_location l WITH (NOLOCK)
        ON l.wh_id = f.wh_id
       AND l.location_id = f.location_id
    LEFT JOIN (
        SELECT
            s.wh_id,
            s.item_number,
            s.location_id,
            STRING_AGG(s.status, '/') AS inventory_status
        FROM dbo.t_stored_item s WITH (NOLOCK)
        WHERE s.wh_id = @wh_id
          AND s.item_number = @item_number
          AND s.type = 'STORAGE'
        GROUP BY
            s.wh_id,
            s.item_number,
            s.location_id
    ) i
        ON i.wh_id = f.wh_id
       AND i.item_number = f.item_number
       AND i.location_id = f.location_id
    GROUP BY
        f.wh_id,
        f.item_number
),
wkq_by_loc AS (
    SELECT
        w.wh_id,
        w.item_number,
        w.location_id,
        COUNT(*) AS wkq_count,
        STRING_AGG(CONVERT(varchar(20), w.priority), ', ') AS wkq_priority,
        STRING_AGG(CONVERT(varchar(30), w.work_q_id), ', ') AS wkq_ids
    FROM dbo.t_work_q w WITH (NOLOCK)
    WHERE w.wh_id = @wh_id
      AND w.item_number = @item_number
      AND w.work_type = '07'
      AND w.work_status <> 'C'
      AND w.pick_ref_number IN ('INTERBUILDING', 'REPLENISH', 'LTCREPLENISH')
    GROUP BY
        w.wh_id,
        w.item_number,
        w.location_id
),
wkq_item AS (
    SELECT
        w.wh_id,
        w.item_number,
        COUNT(*) AS wkq_count,
        STRING_AGG(CONVERT(varchar(20), w.priority), ', ') AS wkq_priority,
        STRING_AGG(CONVERT(varchar(30), w.location_id), ', ') AS wkq_to_location,
        STRING_AGG(CONVERT(varchar(30), w.work_q_id), ', ') AS wkq_ids
    FROM dbo.t_work_q w WITH (NOLOCK)
    WHERE w.wh_id = @wh_id
      AND w.item_number = @item_number
      AND w.work_type = '07'
      AND w.work_status <> 'C'
      AND w.pick_ref_number IN ('INTERBUILDING', 'REPLENISH', 'LTCREPLENISH')
    GROUP BY
        w.wh_id,
        w.item_number
),
scoop AS (
    SELECT
        u.wh_id,
        u.item_number,
        MAX(CASE WHEN u.uom = 'SCOOP' THEN u.conversion_factor END) AS scoop_qty,
        MAX(CASE WHEN u.uom = 'SCOOP' THEN u.units_per_grab END) AS scoop_units_per_grab,
        MAX(CASE WHEN u.uom = 'SCOOP' THEN u.std_hand_qty END) AS scoop_std_hand_qty
    FROM dbo.t_item_uom u WITH (NOLOCK)
    WHERE u.wh_id = @wh_id
      AND u.item_number = @item_number
    GROUP BY
        u.wh_id,
        u.item_number
)
SELECT
    ROW_NUMBER() OVER (
        ORDER BY
            CASE WHEN fpd.location_id IS NOT NULL THEN 0 ELSE 1 END,
            inv.location_id
    ) AS [#],
    inv.item_number AS [Item Number],
    CASE WHEN fpd.location_id IS NOT NULL THEN 'FP' ELSE '' END AS [FWD PICK],
    ISNULL(wkq_loc.wkq_count, 0) AS [Current Loc Replen WKQ Count],
    CASE WHEN ISNULL(wkq_loc.wkq_count, 0) > 0 THEN 'Y' ELSE 'N' END AS [Current Loc Has Replen WKQ],
    ISNULL(wkq_loc.wkq_priority, '') AS [Current Loc WKQ Priority],
    inv.location_id AS [Location],
    fpinfo.fwp_location_id AS [FWP Location Id],
    fpinfo.fwp_inventory_status AS [FWP Inventory Status],
    fpinfo.fwp_location_status AS [FWP Location Status],
    fpinfo.fwp_location_type AS [FWP Location Type],
    fpinfo.fwp_location_detail AS [FWP Location Detail],
    inv.actual_quantity AS [Actual Quantity],
    NULL AS [Kits Location],
    inv.inventory_status AS [Inventory Status],
    CASE
        WHEN ISNULL(inv.unavailable_qty, 0) > 0 THEN 'SOME Qtys Held'
        ELSE 'ALL GOOD'
    END AS [Hold Status],
    inv.born_on_date AS [Born On Date],
    l.status AS [Location Status],
    l.type AS [Location Type],
    l.building AS [Building],
    l.zone AS [Zone],
    scoop.scoop_qty AS [SCOOP Qty],
    scoop.scoop_units_per_grab AS [SCOOP Units/Grab],
    scoop.scoop_std_hand_qty AS [SCOOP Std Hand Qty],
    fpd.replen_level AS [Loc Replen Level],
    fpd.replen_qty AS [Loc Replen Qty],
    fpd.fwd_pick_capacity AS [Loc FWP Capacity],
    l.capacity_qty AS [Location Capacity],
    fpd.target_capacity_qty AS [Loc Target Capacity],
    CASE
        WHEN ISNULL(fpd.target_capacity_qty, 0) > 0
            THEN CAST(inv.actual_quantity * 100.0 / fpd.target_capacity_qty AS decimal(18,2))
        ELSE NULL
    END AS [Current Utilized %],
    CASE
        WHEN ISNULL(fpd.replen_level, 0) > inv.actual_quantity
            THEN fpd.replen_level - inv.actual_quantity
        ELSE 0
    END AS [Short To Replen Level],
    CASE
        WHEN ISNULL(fpd.target_capacity_qty, 0) > inv.actual_quantity
            THEN fpd.target_capacity_qty - inv.actual_quantity
        ELSE 0
    END AS [Short To Target Capacity],
    CASE WHEN ISNULL(wkq_item.wkq_count, 0) > 0 THEN 'Y' ELSE 'N' END AS [Item Has Any Replen WKQ],
    ISNULL(wkq_item.wkq_priority, '') AS [Item Replen WKQ Priority],
    ISNULL(wkq_item.wkq_to_location, '') AS [Item Replen WKQ To Location],
    ISNULL(wkq_item.wkq_ids, '') AS [Item Replen WKQ Ids]
FROM inv
LEFT JOIN dbo.t_location l WITH (NOLOCK)
    ON l.wh_id = inv.wh_id
   AND l.location_id = inv.location_id
LEFT JOIN fp_detail fpd
    ON fpd.wh_id = inv.wh_id
   AND fpd.item_number = inv.item_number
   AND fpd.location_id = inv.location_id
LEFT JOIN fp_item
    ON fp_item.wh_id = inv.wh_id
   AND fp_item.item_number = inv.item_number
LEFT JOIN fp_loc_info fpinfo
    ON fpinfo.wh_id = inv.wh_id
   AND fpinfo.item_number = inv.item_number
LEFT JOIN wkq_by_loc wkq_loc
    ON wkq_loc.wh_id = inv.wh_id
   AND wkq_loc.item_number = inv.item_number
   AND wkq_loc.location_id = inv.location_id
LEFT JOIN wkq_item
    ON wkq_item.wh_id = inv.wh_id
   AND wkq_item.item_number = inv.item_number
LEFT JOIN scoop
    ON scoop.wh_id = inv.wh_id
   AND scoop.item_number = inv.item_number
ORDER BY
    CASE WHEN fpd.location_id IS NOT NULL THEN 0 ELSE 1 END,
    inv.location_id;