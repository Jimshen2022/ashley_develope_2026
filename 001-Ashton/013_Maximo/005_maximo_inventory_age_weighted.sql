-- ============================================================
-- Inventory On-Hand + Consumption Analysis
-- Created: 2026-05-25
-- Based on: 002_maximo_inventory_report.sql + 003_maximo_transactions.sql
-- New columns:
--   ytd_issued_qty      : Year-to-date issued quantity (ISSUE transactions only)
--   last_issued_date    : Most recent issue date
--   avg_monthly_qty     : Average qty issued per month this year
--   months_of_stock     : How many months current on-hand stock can last
--   last_po_receipt_date: Most recent PO receipt date
--   inventory_age_days  : Weighted average age (days) — rolling back PO batches
--                         against current on-hand (newest batch first / FIFO)
--                         e.g. onhand=100, receipt 5/15×90pcs + 3/15×50pcs
--                         → (90×10d + 10×70d) / 100 = 16 days
--   age_bucket          : <30d / 30-90d / 90-180d / >180d
-- ============================================================

WITH

-- ① Latest unit cost per item
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
ytd_stats AS (
    SELECT
        t.itemnum,
        SUM(ABS(t.quantity))           AS ytd_issued_qty,
        MAX(CAST(t.transdate AS DATE)) AS last_issued_date
    FROM Manufacturing_Maximo.MatUseTrans AS t
    WHERE t.siteid    = 'VNM.ASPM'
      AND t.issuetype = 'ISSUE'
      AND t.quantity  < 0
      AND YEAR(t.transdate) = YEAR(GETDATE())
    GROUP BY t.itemnum
),

-- ⑤ Last PO receipt date per item
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

-- ⑥ Elapsed months in current year (denominator for avg monthly qty)
elapsed AS (
    SELECT
        CASE 
            WHEN MONTH(GETDATE()) = 1 THEN 1
            ELSE MONTH(GETDATE())
        END AS elapsed_months
),

-- ============================================================
-- ⑦  WEIGHTED AVERAGE INVENTORY AGE  (core logic)
--
-- Step A: Pull all PO receipts per item, newest first.
--         Compute cumulative received qty (running total from newest → oldest).
-- Step B: For each batch, figure out how much of that batch is still
--         "in stock" given the current on-hand (curbal).
--         - Batches fully covered by earlier (newer) receipts → 0 contribution
--         - The batch that straddles the on-hand boundary → partial qty
--         - Batches older than on-hand → not needed, excluded
-- Step C: Weighted sum = SUM(batch_qty_used × age_days) / onhand
-- ============================================================

-- Step A: all PO receipts with running cumulative qty (newest first)
po_receipts_ranked AS (
    SELECT
        r.itemnum,
        CAST(r.transdate AS DATE)                                    AS receipt_date,
        r.quantity                                                   AS batch_qty,
        -- cumulative qty from the newest receipt up to and including this row
        SUM(r.quantity) OVER (
            PARTITION BY r.itemnum
            ORDER BY r.transdate DESC
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        )                                                            AS cum_qty,
        -- age of this batch in days relative to today
        DATEDIFF(DAY, CAST(r.transdate AS DATE), CAST(GETDATE() AS DATE)) AS age_days
    FROM Manufacturing_Maximo.matrectrans AS r
    WHERE r.siteid     = 'VNM.ASPM'
      AND r.issuetype  = 'RECEIPT'
      AND r.tostoreloc LIKE 'MROSTORE%'
      AND r.ponum      IS NOT NULL
      AND r.ponum      <> ''
),

-- Step B: join to current on-hand, compute how much of each batch
--         is still represented in the current stock
--         inv.curbal = total on-hand for this item at this location
inv_onhand AS (
    SELECT
        t1.itemnum,
        t1.location,
        t1.curbal
    FROM Manufacturing_Maximo.invbalances AS t1
    JOIN LatestSnapshot ls ON t1.SnapshotDate = ls.SnapshotDate
    WHERE t1.location LIKE 'MROSTORE%'
      AND t1.curbal   > 0
      AND t1.siteid   = 'VNM.ASPM'
),

-- Step C: for each receipt batch, clip qty to what is still in stock
--   cum_qty         = running total up to this batch (newest → oldest)
--   cum_qty_before  = cum_qty of the row above (i.e. before this batch)
--   
--   qty still in stock from this batch =
--       GREATEST(0,  MIN(cum_qty, onhand) - MAX(cum_qty_before, 0) )
--   → simplified with CASE because SQL Server has no GREATEST/LEAST before 2022
weighted_age AS (
    SELECT
        pr.itemnum,
        SUM(
            -- qty from this batch that is still in stock
            CASE
                WHEN (pr.cum_qty - pr.batch_qty) >= ih.curbal
                    THEN 0   -- this batch is entirely beyond the on-hand boundary
                WHEN pr.cum_qty <= ih.curbal
                    THEN pr.batch_qty * pr.age_days   -- whole batch still in stock
                ELSE
                    -- partial: only (onhand - qty_already_covered) pcs from this batch
                    (ih.curbal - (pr.cum_qty - pr.batch_qty)) * pr.age_days
            END
        ) * 1.0 / NULLIF(ih.curbal, 0)              AS inventory_age_days
    FROM po_receipts_ranked  AS pr
    JOIN inv_onhand          AS ih  ON ih.itemnum = pr.itemnum
    -- only process batches that are at least partially within on-hand
    WHERE (pr.cum_qty - pr.batch_qty) < ih.curbal
    GROUP BY pr.itemnum, ih.curbal
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
    c.description                                    AS commodity_desc,
    t0.itemtype,
    t0.status,
    t1.location,
    t1.binnum,
    t1.curbal                                        AS onhand,
    t1.curbal * uc.unitcost                          AS [amount($VND)],
    -- USD amount: VND ÷ exchange rate (1 USD ≈ 26,360 VND, update as needed)
    ROUND(t1.curbal * uc.unitcost / 26360.0, 2)     AS [amount($USD)],
    t1.orgid,
    t1.siteid,
    t1.itemsetid,
    DATEADD(HOUR, 12, t1.SnapshotDate)               AS SnapshotDate,

    -- ── Consumption analysis columns ────────────────────────────
    ISNULL(ys.ytd_issued_qty, 0)                     AS ytd_issued_qty,
    ys.last_issued_date,

    CASE 
        WHEN ISNULL(ys.ytd_issued_qty, 0) = 0 THEN 0
        ELSE ROUND(CAST(ys.ytd_issued_qty AS FLOAT) / e.elapsed_months, 2)
    END                                              AS avg_monthly_qty,

    CASE 
        WHEN ISNULL(ys.ytd_issued_qty, 0) = 0 THEN NULL
        ELSE ROUND(
                t1.curbal
                / (CAST(ys.ytd_issued_qty AS FLOAT) / e.elapsed_months),
             1)
    END                                              AS months_of_stock,

    pr.last_po_receipt_date,

    -- ── Inventory Age (weighted average, days) ──────────────────
    -- NULL when no PO receipt history exists for this item
    ROUND(wa.inventory_age_days, 1)                  AS inventory_age_days,

    -- ── Age Bucket ───────────────────────────────────────────────
    CASE
        WHEN wa.inventory_age_days IS NULL            THEN '[e] No Receipt Data'
        WHEN wa.inventory_age_days <  30              THEN '[a] <30d'
        WHEN wa.inventory_age_days <  90              THEN '[b] 30-90d'
        WHEN wa.inventory_age_days < 180              THEN '[c] 90-180d'
        ELSE                                               '[d] >180d'
    END                                              AS age_bucket

FROM Manufacturing_Maximo.invbalances AS t1

JOIN LatestSnapshot ls 
    ON t1.SnapshotDate = ls.SnapshotDate

LEFT JOIN Manufacturing_Maximo.item AS t0
    ON t0.itemsetid = 'VNMSET' AND t1.itemnum = t0.itemnum

LEFT JOIN commodity AS c
    ON c.commodity = t0.commoditygroup

LEFT JOIN uc
    ON uc.itemnum = t1.itemnum

LEFT JOIN ytd_stats AS ys
    ON ys.itemnum = t1.itemnum

LEFT JOIN last_po_receipt AS pr
    ON pr.itemnum = t1.itemnum

LEFT JOIN weighted_age AS wa
    ON wa.itemnum = t1.itemnum

CROSS JOIN elapsed AS e

WHERE t1.location LIKE 'MROSTORE%'
  AND t1.curbal   > 0
  AND t1.siteid   = 'VNM.ASPM'

ORDER BY t1.itemnum;