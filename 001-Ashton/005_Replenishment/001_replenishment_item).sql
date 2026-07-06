DECLARE @wh_id         varchar(10) = '335';
DECLARE @item_number   varchar(30) = 'T247-13';
DECLARE @location_like varchar(50) = '%';

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
fp AS (
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
wkq AS (
    SELECT
        w.wh_id,
        w.item_number,
        w.location_id,
        COUNT(*) AS replen_wkq_count,
        STRING_AGG(CONVERT(varchar(20), w.priority), ', ') AS replen_wkq_priority,
        STRING_AGG(CONVERT(varchar(30), w.work_q_id), ', ') AS replen_wkq_ids
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
    ROW_NUMBER() OVER (ORDER BY inv.location_id, inv.inventory_status) AS [#],
    inv.item_number AS [Item Number],
    inv.location_id AS [Location],
    CASE WHEN fp.location_id IS NOT NULL THEN 'FP' ELSE '' END AS [FWD PICK],
    inv.actual_quantity AS [Actual Quantity],
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

    CASE WHEN fp.location_id IS NOT NULL THEN 'Y' ELSE 'N' END AS [Is This FWP Location],
    fp.location_id AS [FWP Location Id],
    fp.replen_level AS [replen_level],
    fp.replen_qty AS [replen_qty],
    fp.fwd_pick_capacity AS [fwp_capacity_qty],
    l.capacity_qty AS [location_capacity],
    fp.target_capacity_qty AS [target_capacity_qty],

    scoop.scoop_qty AS [SCOOP Qty],
    scoop.scoop_units_per_grab AS [SCOOP Units/Grab],
    scoop.scoop_std_hand_qty AS [SCOOP Std Hand Qty],

    CASE WHEN ISNULL(wkq.replen_wkq_count, 0) > 0 THEN 'Y' ELSE 'N' END AS [Has Replen WKQ],
    ISNULL(wkq.replen_wkq_count, 0) AS [Replen WKQ Count],
    ISNULL(wkq.replen_wkq_priority, '') AS [Replen WKQ Priority],
    ISNULL(wkq.replen_wkq_ids, '') AS [Replen WKQ Ids],

    CASE
        WHEN ISNULL(fp.target_capacity_qty, 0) > 0
            THEN CAST(inv.actual_quantity * 100.0 / fp.target_capacity_qty AS decimal(18,2))
        ELSE NULL
    END AS [Current Utilized %],
    CASE
        WHEN ISNULL(fp.replen_level, 0) > inv.actual_quantity
            THEN fp.replen_level - inv.actual_quantity
        ELSE 0
    END AS [Short To Replen Level]
FROM inv
LEFT JOIN dbo.t_location l WITH (NOLOCK)
    ON l.wh_id = inv.wh_id
   AND l.location_id = inv.location_id
LEFT JOIN fp
    ON fp.wh_id = inv.wh_id
   AND fp.item_number = inv.item_number
   AND fp.location_id = inv.location_id
LEFT JOIN wkq
    ON wkq.wh_id = inv.wh_id
   AND wkq.item_number = inv.item_number
   AND wkq.location_id = inv.location_id
LEFT JOIN scoop
    ON scoop.wh_id = inv.wh_id
   AND scoop.item_number = inv.item_number
ORDER BY inv.location_id, inv.inventory_status;