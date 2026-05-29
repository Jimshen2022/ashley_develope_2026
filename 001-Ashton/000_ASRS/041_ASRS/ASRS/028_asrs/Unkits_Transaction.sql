WITH itm AS (
    SELECT
        t.ITNBR AS item_number,
        t.ITDSC AS description,
        t.BZCQCD AS uom,
        'FG' AS inventory_type,
        t.ITCLS AS commodity_code,
        t.STID AS wh_id,
        'PAL5H' AS class_id,
        t.WEGHT AS unit_weight,
        t.B2Z95S AS unit_volume,
        t.B2Z95S AS nested_volume,
        'PALLT' AS pick_put_id,
        '5x5' AS pallet_id,
        CASE
            WHEN t.B2Z95S = 0 THEN ROUND(131.355 / 2.167, 2)
            ELSE ROUND(131.355 / t.B2Z95S, 2)
        END AS std_hand_qty,
        'CG' AS product
    FROM MasterData_ItemMaster_MIL.ITMRVA AS t
    WHERE STID = '51' AND (ITCLS LIKE 'Z%K' OR ITCLS = 'WVVG')
)

SELECT
    t0.HOUSE AS wh_id,
    t0.TCODE AS tran_type,
    'Shipment' AS description,
    CAST('20'+RIGHT(t0.UPDDT,6) AS DATE) AS start_tran_date,
    t0.ITNBR AS item_number,
    'CG' AS product,
    1 AS pallet_id,
    SUM(t0.TRQTY) AS qty
FROM Manufacturing_Inventory_MIL.IMHIST AS t0
LEFT JOIN itm ON itm.item_number = t0.ITNBR
WHERE t0.HOUSE = '51'
  AND t0.TCODE = 'SA'
  AND CAST('20' + RIGHT(t0.UPDDT, 6) AS DATE) >= CAST(GETDATE() - 90 AS DATE)
  AND
GROUP BY
    t0.HOUSE,
    t0.TCODE,
    t0.UPDDT,
    t0.ITNBR
