/*
select top 10 * from t_pick_detail
select top 10 * from t_load_master where status not in ('S', 'X', 'C')
select top 10 * from t_load_master where status not in ('S', 'X', 'C')
select top 10 * from t_order
select top 10 * from t_order_detail_breakdown
select top 10 * from t_pick_detail

*/

WITH TripDemand AS (
    SELECT
        DATEADD(SECOND, DATEDIFF(SECOND, 0, ldm.dispatch_time), ldm.dispatch_date) AS dispatch_date,
        orb.item_number,
        ldm.load_id AS trip_number,
        ldm.status AS ldm_status,
        SUM(orb.qty) AS trip_needed,
        ISNULL(pkd.picked_qty, 0) AS trip_picked
    FROM t_load_master ldm WITH (NOLOCK)
    JOIN t_order orm WITH (NOLOCK)
        ON ldm.load_id = orm.load_id
        AND ldm.wh_id = orm.wh_id
    JOIN t_order_detail_breakdown orb WITH (NOLOCK)
        ON orm.order_number = orb.order_number
        AND orm.wh_id = orb.wh_id
    LEFT JOIN (
        SELECT
            load_id,
            item_number,
            SUM(picked_quantity) AS picked_qty
        FROM t_pick_detail WITH (NOLOCK)
        WHERE picked_quantity > 0
          AND load_id IS NOT NULL
        GROUP BY
            load_id,
            item_number
    ) pkd
        ON ldm.load_id = pkd.load_id
        AND orb.item_number = pkd.item_number
    WHERE ldm.wh_id = '335'
      AND DATEADD(SECOND, DATEDIFF(SECOND, 0, ldm.dispatch_time), ldm.dispatch_date)
            >= DATEADD(MONTH, -1, GETDATE())
      AND DATEADD(SECOND, DATEDIFF(SECOND, 0, ldm.dispatch_time), ldm.dispatch_date)
            < DATEADD(DAY, 1, CAST(DATEADD(MONTH, 1, GETDATE()) AS DATE))
      AND ldm.status NOT IN ('S', 'X', 'C')
      AND ldm.load_type = 'B'
    GROUP BY
        DATEADD(SECOND, DATEDIFF(SECOND, 0, ldm.dispatch_time), ldm.dispatch_date),
        orb.item_number,
        ldm.load_id,
        ldm.status,
        pkd.picked_qty
)

SELECT
    dispatch_date,
    item_number,
    trip_number,
    ldm_status,
    trip_needed,
    trip_picked,
    (trip_needed - trip_picked) AS trip_demand_qty
FROM TripDemand
WHERE (trip_needed - trip_picked) > 0
ORDER BY
    item_number,
    dispatch_date,
    trip_number;