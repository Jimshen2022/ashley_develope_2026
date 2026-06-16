WITH SerialCTE AS (
    -- 基础查询 / Anchor member
    SELECT
        wh_id,
        item_number,
        po_number,
        date_added,
        serial_number_start,
        serial_number_end,
        CAST(serial_number_start AS BIGINT) AS current_serial,
        CAST(serial_number_end AS BIGINT) AS end_target
    FROM t_items_on_hold
    WHERE date_added >= '2026-04-22'

    UNION ALL

    -- 递归生成中间的序列号 / Recursive member
    SELECT
        wh_id,
        item_number,
        po_number,
        date_added,
        serial_number_start,
        serial_number_end,
        current_serial + 1,
        end_target
    FROM SerialCTE
    WHERE current_serial < end_target
)
SELECT
    wh_id,
    item_number,
    po_number,
    date_added,
    serial_number_start,
    serial_number_end,
    CAST(current_serial AS VARCHAR(50)) AS individual_serial_number -- 新增的列 / The newly added column
FROM SerialCTE
ORDER BY date_added DESC, current_serial ASC
OPTION (MAXRECURSION 0);