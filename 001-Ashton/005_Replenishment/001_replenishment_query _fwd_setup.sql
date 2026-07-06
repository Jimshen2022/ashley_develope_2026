DECLARE @wh_id       varchar(10) = '335';
DECLARE @item_number varchar(30) = 'T247-13';

WITH fp AS (
    SELECT
        f.wh_id,
        f.item_number,
        f.location_id,
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
      AND f.item_number = @item_number
),
fp_inv AS (
    SELECT
        s.wh_id,
        s.item_number,
        s.location_id,
        STRING_AGG(s.status, '/') AS inventory_status,
        SUM(ISNULL(s.actual_qty, 0)) AS actual_quantity
    FROM dbo.t_stored_item s WITH (NOLOCK)
    WHERE s.wh_id = @wh_id
      AND s.item_number = @item_number
      AND s.type = 'STORAGE'
    GROUP BY
        s.wh_id,
        s.item_number,
        s.location_id
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
)
SELECT
    ROW_NUMBER() OVER (ORDER BY fp.location_id) AS [#],
    fp.item_number AS [Item Number],
    fp.location_id AS [FWP Location Id],
    ISNULL(fp_inv.actual_quantity, 0) AS [FWP Actual Quantity],
    ISNULL(fp_inv.inventory_status, '') AS [FWP Inventory Status],
    l.status AS [FWP Location Status],
    l.type AS [FWP Location Type],
    l.building AS [FWP Building],
    l.zone AS [FWP Zone],
    fp.replen_level,
    fp.replen_qty,
    fp.capacity_qty AS [fwp_capacity_qty],
    l.capacity_qty AS [location_capacity],
    fp.target_capacity_qty,
    CASE WHEN ISNULL(wkq.replen_wkq_count, 0) > 0 THEN 'Y' ELSE 'N' END AS [Has Replen WKQ],
    ISNULL(wkq.replen_wkq_count, 0) AS [Replen WKQ Count],
    ISNULL(wkq.replen_wkq_priority, '') AS [Replen WKQ Priority],
    ISNULL(wkq.replen_wkq_ids, '') AS [Replen WKQ Ids]
FROM fp
LEFT JOIN dbo.t_location l WITH (NOLOCK)
    ON l.wh_id = fp.wh_id
   AND l.location_id = fp.location_id
LEFT JOIN fp_inv
    ON fp_inv.wh_id = fp.wh_id
   AND fp_inv.item_number = fp.item_number
   AND fp_inv.location_id = fp.location_id
LEFT JOIN wkq
    ON wkq.wh_id = fp.wh_id
   AND wkq.item_number = fp.item_number
   AND wkq.location_id = fp.location_id
ORDER BY fp.location_id;