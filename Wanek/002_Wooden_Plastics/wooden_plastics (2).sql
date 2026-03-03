-- 1) 准备位置列表
DROP TABLE IF EXISTS #wh_list;
CREATE TABLE #wh_list (wh_id NVARCHAR(20));

INSERT INTO #wh_list (wh_id)
SELECT DISTINCT wh_id
FROM (
    VALUES
        ('S001'), ('S005'), ('S0102'), ('S012'), ('S015'),
        ('S017'), ('S018'), ('S020'), ('S021'), ('S0232'),
        ('S028'), ('S0335'), ('S042'), ('S049'), ('S050'),
        ('S060'), ('S070'), ('S101'), ('S0102'),
        ('S101'), ('S105'), ('S1102'), ('S112'), ('S115'),
        ('S117'), ('S118'), ('S120'), ('S121'), ('S1232'),
        ('S128'), ('S1335'), ('S142'), ('S149'), ('S150'),
        ('S160'), ('S170'), ('S101'), ('S1102'),
        ('S105'), ('S1102'), ('S115'), ('S117'), ('S118'),
        ('S120'), ('S121'), ('S1213'), ('S1215'), ('S1232'),
        ('S1242'), ('S128'), ('S1335'), ('S142')
) AS all_data(wh_id);

CREATE UNIQUE CLUSTERED INDEX IX_wh_list ON #wh_list(wh_id);

-- 2) 物化 itm 并加索引（基表用 NOLOCK）
IF OBJECT_ID('tempdb..#itm') IS NOT NULL DROP TABLE #itm;

SELECT
    item_number,
    MIN(unit_volume) AS unit_volume
INTO #itm
FROM t_item_master WITH (NOLOCK)
WHERE wh_id = '35'
  AND inventory_type <> 'RM'
GROUP BY item_number;

CREATE UNIQUE CLUSTERED INDEX IX_itm_item ON #itm(item_number);

-- 3) 主查询：把 IN (SELECT …) 改为 JOIN，并在基表加 NOLOCK
WITH sn AS (
    SELECT t.*
    FROM t_serial_active AS t WITH (NOLOCK)
    JOIN #wh_list AS wl
      ON wl.wh_id = t.location_id         -- ← 用 JOIN 代替 IN (SELECT …)
    WHERE t.serial_no_status NOT IN ('O','S')
      AND t.wh_id IN ('35','31','33')
),
sn_sum AS (
    SELECT
        t.wh_id,
        t.item_number,
        t.po_number AS mo_nbr,
        t.location_id,
        COUNT_BIG(t.serial_number) AS qty,
        COUNT_BIG(t.serial_number) * COALESCE(i.unit_volume, 0) AS cubes
    FROM sn AS t
    LEFT JOIN #itm AS i
      ON i.item_number = t.item_number
    GROUP BY
        t.wh_id,
        t.item_number,
        i.unit_volume,
        t.po_number,
        t.location_id
)
SELECT
    wh_id, item_number, mo_nbr, location_id, qty, cubes
FROM sn_sum
ORDER BY location_id
OPTION (RECOMPILE);
