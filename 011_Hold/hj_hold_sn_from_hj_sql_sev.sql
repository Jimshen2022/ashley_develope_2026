WITH SerialCTE AS (
    -- 基础查询 / Anchor member
    SELECT
        wh_id,
        item_number,
        po_number,
        date_added,
        serial_number_start,
        serial_number_end,
        -- 将字符串转换为 BIGINT 以支持大数字计算 / Cast to BIGINT for large numbers
        CAST(serial_number_start AS BIGINT) AS current_serial,
        CAST(serial_number_end AS BIGINT) AS end_target
    FROM t_items_on_hold
    WHERE date_added >= '2026-04-22'

    UNION ALL

    -- 递归生成中间的序列号 / Recursive member to generate numbers
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
-- 按原字段分组并拼接 / Group by original fields and concatenate
SELECT
    wh_id,
    item_number,
    po_number,
    date_added,
    serial_number_start,
    serial_number_end,
    STRING_AGG(CAST(current_serial AS VARCHAR(50)), ', ') WITHIN GROUP (ORDER BY current_serial) AS all_serial_numbers
FROM SerialCTE
GROUP BY
    wh_id,
    item_number,
    po_number,
    date_added,
    serial_number_start,
    serial_number_end
OPTION (MAXRECURSION 0); -- 解除递归次数限制 / Remove recursion limit