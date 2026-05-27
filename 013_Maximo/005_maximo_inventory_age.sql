-- ============================================================
-- Inventory On-Hand + Consumption Analysis
-- Created: 2026-05-25
-- Based on: 002_maximo_inventory_report.sql + 003_maximo_transactions.sql
-- New columns:
--   ytd_issued_qty      : Year-to-date issued quantity (ISSUE transactions only)
--   last_issued_date    : Most recent issue date
--   avg_monthly_qty     : Average qty issued per month this year
--                         (based on elapsed months from Jan 1 to today)
--   months_of_stock     : How many months current on-hand stock can last
--   last_po_receipt_date: Most recent PO receipt date (from matrectrans, issuetype=RECEIPT, ponum IS NOT NULL)
-- ============================================================

WITH

-- ① Latest unit cost per item (from most recent transaction with cost)
unit_cost AS (
    SELECT 
        t0.itemnum, 
        t0.unitcost,
        ROW_NUMBER() OVER (PARTITION BY t0.itemnum ORDER BY t0.transdate DESC) AS rn
    FROM Manufacturing_Maximo.MatUseTrans AS t0
    WHERE t0.siteid   = 'VNM.ASPM' 
      AND t0.unitcost <> 0
),
uc AS (
    SELECT itemnum, unitcost
    FROM unit_cost
    WHERE rn = 1
),

-- ② Latest inventory snapshot date
LatestSnapshot AS (
    SELECT MAX(SnapshotDate) AS SnapshotDate 
    FROM Manufacturing_Maximo.invbalances 
    WHERE location = 'MROSTORE'
),

-- ③ Commodity descriptions
commodity AS (
    SELECT *
    FROM Manufacturing_Maximo.Commodities AS t
    WHERE t.itemsetid = 'VNMSET'
),

-- ④ YTD issued qty & last issued date per item
--    Only count ISSUE transactions (quantity < 0 = outbound)
--    for the current calendar year
ytd_stats AS (
    SELECT
        t.itemnum,
        SUM(ABS(t.quantity))            AS ytd_issued_qty,
        MAX(CAST(t.transdate AS DATE))  AS last_issued_date
    FROM Manufacturing_Maximo.MatUseTrans AS t
    WHERE t.siteid    = 'VNM.ASPM'
      AND t.issuetype = 'ISSUE'          -- ISSUE transactions only
      AND t.quantity  < 0               -- outbound (defensive filter)
      AND YEAR(t.transdate) = YEAR(GETDATE())
    GROUP BY t.itemnum
),

-- ⑤ Last PO receipt date per item
--    Source: Manufacturing_Maximo.matrectrans
--    Key fields confirmed from data:
--      issuetype = 'RECEIPT'  → PO goods receipt
--      tostoreloc             → destination store (filter MROSTORE%)
--      ponum                  → PO number, e.g. 'PF001542'
--      siteid = 'VNM.ASPM'   → mandatory site filter
last_po_receipt AS (
    SELECT
        r.itemnum,
        MAX(CAST(r.transdate AS DATE)) AS last_po_receipt_date
    FROM Manufacturing_Maximo.matrectrans AS r
    WHERE r.siteid     = 'VNM.ASPM'
      AND r.issuetype  = 'RECEIPT'
      AND r.tostoreloc LIKE 'MROSTORE%'
      AND r.ponum      IS NOT NULL
      AND r.ponum      <> ''
    GROUP BY r.itemnum
),

-- ⑥ Number of elapsed months in the current year up to today
--    e.g. if today is 25-May-2026, elapsed = 5 (Jan–May inclusive)
--    We use this as the denominator for monthly average
elapsed AS (
    SELECT
        CASE 
            WHEN MONTH(GETDATE()) = 1 THEN 1   -- avoid divide-by-zero in January
            ELSE MONTH(GETDATE())
        END AS elapsed_months
)

-- ================================================================
-- MAIN SELECT
-- ================================================================
SELECT
    -- ── Original inventory columns ──────────────────────────────
    t1.itemnum,
    t0.description,
    t0.orderunit,
    t0.issueunit,
    t0.commoditygroup,
    c.description                                   AS commodity_desc,
    t0.itemtype,
    t0.status,
    t1.location,
    t1.binnum,
    t1.curbal                                       AS onhand,
    t1.curbal * uc.unitcost                         AS [amount($VND)],
    t1.orgid,
    t1.siteid,
    t1.itemsetid,
    DATEADD(HOUR, 12, t1.SnapshotDate)              AS SnapshotDate,

    -- ── NEW: Consumption analysis columns ───────────────────────

    -- Year-to-date issued quantity (NULL → 0 if never issued this year)
    ISNULL(ys.ytd_issued_qty, 0)                    AS ytd_issued_qty,

    -- Last date the item was issued (NULL if never issued)
    ys.last_issued_date,

    -- Average qty issued per month this year
    -- Formula: YTD qty ÷ elapsed months in current year
    CASE 
        WHEN ISNULL(ys.ytd_issued_qty, 0) = 0 THEN 0
        ELSE ROUND(
                CAST(ys.ytd_issued_qty AS FLOAT) / e.elapsed_months,
             2)
    END                                             AS avg_monthly_qty,

    -- How many months the current on-hand stock can last
    -- Formula: onhand ÷ avg_monthly_qty
    -- Shows NULL when avg_monthly_qty = 0 (no consumption this year → cannot estimate)
    CASE 
        WHEN ISNULL(ys.ytd_issued_qty, 0) = 0 THEN NULL
        ELSE ROUND(
                t1.curbal
                / (CAST(ys.ytd_issued_qty AS FLOAT) / e.elapsed_months),
             1)
    END                                             AS months_of_stock,

    -- Last PO receipt date (NULL if no PO receipt on record)
    pr.last_po_receipt_date

FROM Manufacturing_Maximo.invbalances AS t1

-- Filter to latest snapshot only
JOIN LatestSnapshot ls 
    ON t1.SnapshotDate = ls.SnapshotDate

-- Item master
LEFT JOIN Manufacturing_Maximo.item AS t0
    ON t0.itemsetid = 'VNMSET' AND t1.itemnum = t0.itemnum

-- Commodity description
LEFT JOIN commodity AS c
    ON c.commodity = t0.commoditygroup

-- Unit cost
LEFT JOIN uc
    ON uc.itemnum = t1.itemnum

-- YTD consumption stats
LEFT JOIN ytd_stats AS ys
    ON ys.itemnum = t1.itemnum

-- Last PO receipt date
LEFT JOIN last_po_receipt AS pr
    ON pr.itemnum = t1.itemnum

-- Elapsed-months constant (cross join = single row)
CROSS JOIN elapsed AS e

WHERE t1.location LIKE 'MROSTORE%'
  AND t1.curbal   > 0
  AND t1.siteid   = 'VNM.ASPM'

ORDER BY t1.itemnum;