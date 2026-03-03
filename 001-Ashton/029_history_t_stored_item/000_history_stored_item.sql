--select * from dw_developer.tabledictionary where tpktablename like '%stored%'
--select * from dw_developer.tabledictionary where tpkSchemaName like '%whole%' ORDER BY tpkRowCount DESC


WITH ranked_snapshots AS (
    SELECT  
        t.wh_id,
        t.item_number,
        CAST(t.snapshotDatetime AS DATE) AS snapshot_date,
        t.snapshotDatetime,
        t.actual_qty,
        ROW_NUMBER() OVER (
            PARTITION BY t.wh_id, t.item_number, CAST(t.snapshotDatetime AS DATE)
            ORDER BY t.snapshotDatetime DESC
        ) AS rn
    FROM Distribution_Warehouse_Wholesale_History.t_stored_item AS t 
    WHERE t.wh_id = '335' AND t.snapshotDatetime >= '2025-01-01'
)
SELECT  
    wh_id,
    item_number,
    snapshot_date,
    snapshotDatetime,
    SUM(actual_qty) AS actual_qty
FROM ranked_snapshots
WHERE rn = 1
GROUP BY wh_id, item_number, snapshot_date, snapshotDatetime
ORDER BY snapshot_date ASC;