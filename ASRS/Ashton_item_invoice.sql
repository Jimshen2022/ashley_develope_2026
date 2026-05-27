WITH
-- 1) Base filter reference (must be defined first as ONHAND depends on it)
ITMRVA_CTE AS (
    SELECT d.ITNBR, d.B2Z95S, d.ITDSC, d.STID
    FROM MasterData_ItemMaster_AFI.ITMRVA d
    WHERE d.STID IN ('335')
),

-- 2) On-hand quantity (primary table): locations A3% or RS% in warehouse 335, filtered by ITMRVA items
ONHAND_CTE AS (
    SELECT
        oh.wh_id,
        oh.item_number,
        SUM(oh.actual_qty) AS onhand_qty
    FROM Distribution_Warehouse_Wholesale.t_stored_item AS oh
    WHERE oh.wh_id IN ('335')
      AND (oh.location_id LIKE 'A3%' OR oh.location_id LIKE 'RS%')
      AND oh.item_number IN (SELECT ITNBR FROM ITMRVA_CTE)
    GROUP BY oh.wh_id, oh.item_number
),

-- 3) Remaining base tables
ITEMBL_CTE AS (
    SELECT a.ITNBR, a.HOUSE, a.MOHTQ, a.WHSLC, a.ITCLS, a.QTSYR, a.MPUPQ, a.USEYR, a.LDQOH, a.DOFLS, a.PLREQ, a.RECPL, a.SAFTY
    FROM MasterData_ItemMaster_AFI.ITEMBL a
    WHERE a.MOHTQ > 0
      AND a.HOUSE IN ('335')
),
ITBEXT_CTE AS (
    SELECT b.ITNBR, b.HOUSE, b.TIHIUNLD, b.PICKPUT, b.ITMCLSID,
           b.UNITSWIDE, b.UNITLAYERS, b.UNITSDEEP, b.SCOOPQTY, b.SKIDSIZE, b.MFPUS, b.OVRFLWBLDG, b.TOHLD, b.ATPQT
    FROM MasterData_ItemMaster_AFI.ITBEXT b
    WHERE b.HOUSE IN ('335')
),
ITMEXT_CTE AS (
    SELECT c.ITNBR, c.QTYCR, c.NBSEAT, c.CRTWIN, c.CRTLIN, c.CRTHIN,
           c.PRDWIN, c.PRDHIN, c.PRDLIN, c.ITMWEGHT, c.MFPUS, c.SERIES, c.UUCCIM, c.PRDDDES
    FROM MasterData_ItemMaster_AFI.ITMEXT c
),

-- 4) Latest invoice per item (filtered to items present in ITMRVA_CTE)
RankedInvoices AS (
    SELECT
        shcItemNumber,
        shcInvoiceDate,
        shcInvoiceNumber,
        shcOrderNumber,
        shcWarehouse,
        shcTripNumber,
        shcCustomerNumber,
        shcBusinessType,
        shcHomestoreFlag,
        shcBillToName,
        shcGrossQuantityShipped,
        shcGrossAmountShipped,
        shcExtStandardUnitCost,
        (shcGrossAmountShipped / NULLIF(shcGrossQuantityShipped, 0)) AS UnitPrice,
        ROW_NUMBER() OVER(
            PARTITION BY shcItemNumber
            ORDER BY shcInvoiceDate DESC
        ) AS rn
    FROM CostAccounting_Enh.ShippedHistoryCubeData
    WHERE shcItemNumber IN (SELECT ITNBR FROM ITMRVA_CTE)
),
LatestInvoice AS (
    SELECT * FROM RankedInvoices WHERE rn = 1
),

-- 5) Unified join of item master tables (ITMRVA as primary)
MERGED AS (
    SELECT
        t4.ITNBR,
        t4.STID AS HOUSE,
        t2.MOHTQ,
        t2.WHSLC,
        t2.ITCLS,
        t2.QTSYR,
        t2.MPUPQ AS OPEN_PO,
        t2.USEYR AS [Quantity used this year],
        t2.LDQOH AS [Last date affecting quantity on hand],
        t2.DOFLS AS [Date of last sale],
        t2.PLREQ AS [Pick list requirements],
        t2.RECPL AS [Quantity received since last plan],
        t2.SAFTY AS [Safety stock],
        t4.B2Z95S,
        t4.ITDSC,
        t1.TIHIUNLD,
        t1.PICKPUT,
        t1.ITMCLSID,
        t1.UNITSWIDE,
        t1.UNITLAYERS,
        t1.UNITSDEEP,
        t1.SCOOPQTY,
        t1.SKIDSIZE,
        t1.MFPUS AS [Manu. Status Code],
        t1.OVRFLWBLDG,
        t1.TOHLD AS [Total_Hold_Qty],
        t1.ATPQT,
        t3.QTYCR,
        t3.NBSEAT,
        t3.CRTWIN AS [CRTWIN(inch)],
        t3.CRTLIN AS [CRTLIN(inch)],
        t3.CRTHIN AS [CRTHIN(inch)],
        t3.PRDWIN AS [PRDWIN(inch)],
        t3.PRDHIN AS [PRDHIN(inch)],
        t3.PRDLIN AS [PRDLIN(inch)],
        t3.ITMWEGHT,
        t3.MFPUS,
        t3.SERIES,
        t3.UUCCIM AS [Financial Division],
        t3.PRDDDES AS [Dimension Description],
        -- Invoice fields (latest record per item)
        inv.shcInvoiceDate                                                                           AS LatestInvoiceDate,
        inv.shcGrossAmountShipped                                                                    AS GrossSaleAmount,
        inv.shcGrossQuantityShipped                                                                  AS GrossSaleQty,
        CAST(inv.UnitPrice AS DECIMAL(18, 2))                                                        AS LatestUnitPrice,
        CAST(inv.shcExtStandardUnitCost AS DECIMAL(18, 2))                                           AS ExtStandardUnitCost,
        CAST(inv.shcExtStandardUnitCost / NULLIF(inv.shcGrossQuantityShipped, 0) AS DECIMAL(18, 2))  AS SingleUnitCost,
        inv.shcInvoiceNumber,
        inv.shcOrderNumber,
        inv.shcWarehouse         AS InvoiceWarehouse,
        inv.shcTripNumber,
        inv.shcCustomerNumber,
        inv.shcBusinessType,
        inv.shcHomestoreFlag,
        inv.shcBillToName
    FROM ITMRVA_CTE t4
    LEFT JOIN ITEMBL_CTE t2
        ON t2.ITNBR = t4.ITNBR
       AND t2.HOUSE = t4.STID
    LEFT JOIN ITBEXT_CTE t1
        ON t1.ITNBR = t4.ITNBR
       AND t1.HOUSE = t4.STID
    LEFT JOIN ITMEXT_CTE t3
        ON t3.ITNBR = t4.ITNBR
    LEFT JOIN LatestInvoice inv
        ON inv.shcItemNumber = t4.ITNBR
),

-- 6) Unified calculations (all weights converted to KG)
METRICS AS (
    SELECT
        m.*,

        -- Unit weight (KG)
        CAST(m.ITMWEGHT * 0.453592 AS DECIMAL(18, 6)) AS UNIT_WEIGHT_KG,

        -- Scoop weight (KG)
        CAST(CASE
            WHEN m.SCOOPQTY IS NOT NULL AND m.ITMWEGHT IS NOT NULL
                 THEN m.SCOOPQTY * m.ITMWEGHT * 0.453592
            ELSE NULL
        END AS DECIMAL(18, 6)) AS SCOOP_WEIGHT_KG,

        -- Carton dimensions (inch → mm, 1 inch = 25.4 mm)
        CAST([CRTWIN(inch)] * 25.4 AS DECIMAL(10, 2)) AS [CRTWIN(mm)],
        CAST([CRTLIN(inch)] * 25.4 AS DECIMAL(10, 2)) AS [CRTLIN(mm)],
        CAST([CRTHIN(inch)] * 25.4 AS DECIMAL(10, 2)) AS [CRTHIN(mm)],

        -- Pallet count (minimum 1 pallet)
        CASE
            WHEN m.SCOOPQTY IS NULL OR m.SCOOPQTY = 0 THEN NULL
            WHEN m.MOHTQ IS NULL THEN NULL
            WHEN m.MOHTQ <= m.SCOOPQTY THEN 1
            ELSE CEILING(m.MOHTQ / NULLIF(m.SCOOPQTY, 0))
        END AS PALLETS
    FROM MERGED m
)

-- 7) Final select: ONHAND as primary, item master + invoice fields left joined
SELECT
    -- On-hand fields (primary table)
    oh.wh_id,
    oh.item_number,
    oh.onhand_qty,

    -- Basic item master info
   -- mx.HOUSE,
    mx.MOHTQ,
   -- mx.WHSLC,
    mx.ITCLS,
   -- mx.QTSYR,
    mx.OPEN_PO,

    -- Additional ITEMBL fields
    mx.[Quantity used this year],
    mx.[Last date affecting quantity on hand],
    mx.[Date of last sale],
    mx.[Pick list requirements],
    mx.[Quantity received since last plan],
   -- mx.[Safety stock],

    -- ITMRVA fields
    mx.B2Z95S,
    mx.ITDSC,

    -- ITBEXT fields
    mx.TIHIUNLD,
    mx.PICKPUT,
    mx.ITMCLSID,
    mx.UNITSWIDE,
    mx.UNITLAYERS,
    mx.UNITSDEEP,
    mx.SCOOPQTY,
    mx.SKIDSIZE,
    mx.[Manu. Status Code],
    mx.OVRFLWBLDG,
    mx.[Total_Hold_Qty],
   -- mx.ATPQT,

    -- ITMEXT fields
   -- mx.QTYCR,
   -- mx.NBSEAT,
    mx.[CRTWIN(inch)],
    mx.[CRTLIN(inch)],
    mx.[CRTHIN(inch)],
    mx.[CRTWIN(mm)],
    mx.[CRTLIN(mm)],
    mx.[CRTHIN(mm)],
    mx.[PRDWIN(inch)],
    mx.[PRDHIN(inch)],
    mx.[PRDLIN(inch)],
    mx.ITMWEGHT,
    mx.SERIES,
    mx.[Financial Division],
    mx.[Dimension Description],

    -- Product category logic
    CASE
        WHEN mx.ITCLS NOT LIKE 'Z%' THEN 'RP'
        WHEN mx.PICKPUT = 'UPH' THEN 'UPH'
        ELSE 'CG'
    END AS PRODUCT_CATEGORY,

    -- Sub-category logic
    CASE
        WHEN mx.ITMCLSID IN ('FLOOR') THEN 'BULK'
        WHEN mx.ITMCLSID IN ('RUGS')  THEN 'RUG'
        WHEN mx.PICKPUT = 'UPH'       THEN 'UPH'
        ELSE 'CG'
    END AS SUB_CATEGORY,

    -- Calculated weight / pallet fields
    mx.UNIT_WEIGHT_KG,
    mx.PALLETS,
    mx.SCOOP_WEIGHT_KG,

    -- Unit weight range (KG)
    CASE
        WHEN mx.UNIT_WEIGHT_KG < 10   THEN 'A. 0-10'
        WHEN mx.UNIT_WEIGHT_KG < 20   THEN 'B. 10-20'
        WHEN mx.UNIT_WEIGHT_KG < 30   THEN 'C. 20-30'
        WHEN mx.UNIT_WEIGHT_KG < 40   THEN 'D. 30-40'
        WHEN mx.UNIT_WEIGHT_KG < 50   THEN 'E. 40-50'
        WHEN mx.UNIT_WEIGHT_KG < 60   THEN 'F. 50-60'
        WHEN mx.UNIT_WEIGHT_KG < 70   THEN 'G. 60-70'
        WHEN mx.UNIT_WEIGHT_KG < 80   THEN 'H. 70-80'
        WHEN mx.UNIT_WEIGHT_KG < 90   THEN 'I. 80-90'
        WHEN mx.UNIT_WEIGHT_KG < 100  THEN 'K. 90-100'
        WHEN mx.UNIT_WEIGHT_KG < 110  THEN 'L. 100-110'
        WHEN mx.UNIT_WEIGHT_KG < 120  THEN 'M. 110-120'
        WHEN mx.UNIT_WEIGHT_KG < 130  THEN 'N. 120-130'
        WHEN mx.UNIT_WEIGHT_KG < 140  THEN 'O. 130-140'
        WHEN mx.UNIT_WEIGHT_KG < 150  THEN 'P. 140-150'
        WHEN mx.UNIT_WEIGHT_KG < 160  THEN 'Q. 150-160'
        WHEN mx.UNIT_WEIGHT_KG < 170  THEN 'R. 160-170'
        WHEN mx.UNIT_WEIGHT_KG < 180  THEN 'S. 170-180'
        ELSE 'T. Over 180'
    END AS UNIT_WEIGHT_RANGE_KG,

    -- Scoop total weight range (KG)
    CASE
        WHEN mx.SCOOP_WEIGHT_KG < 100   THEN 'A. 0-100'
        WHEN mx.SCOOP_WEIGHT_KG < 200   THEN 'B. 100-200'
        WHEN mx.SCOOP_WEIGHT_KG < 300   THEN 'C. 200-300'
        WHEN mx.SCOOP_WEIGHT_KG < 400   THEN 'D. 300-400'
        WHEN mx.SCOOP_WEIGHT_KG < 500   THEN 'E. 400-500'
        WHEN mx.SCOOP_WEIGHT_KG < 600   THEN 'F. 500-600'
        WHEN mx.SCOOP_WEIGHT_KG < 700   THEN 'G. 600-700'
        WHEN mx.SCOOP_WEIGHT_KG < 800   THEN 'H. 700-800'
        WHEN mx.SCOOP_WEIGHT_KG < 900   THEN 'I. 800-900'
        WHEN mx.SCOOP_WEIGHT_KG < 1000  THEN 'K. 900-1000'
        WHEN mx.SCOOP_WEIGHT_KG < 1100  THEN 'L. 1000-1100'
        WHEN mx.SCOOP_WEIGHT_KG < 1200  THEN 'M. 1100-1200'
        WHEN mx.SCOOP_WEIGHT_KG < 1300  THEN 'N. 1200-1300'
        WHEN mx.SCOOP_WEIGHT_KG < 1400  THEN 'O. 1300-1400'
        WHEN mx.SCOOP_WEIGHT_KG < 1500  THEN 'P. 1400-1500'
        WHEN mx.SCOOP_WEIGHT_KG < 1600  THEN 'Q. 1500-1600'
        WHEN mx.SCOOP_WEIGHT_KG < 1700  THEN 'R. 1600-1700'
        WHEN mx.SCOOP_WEIGHT_KG < 1800  THEN 'S. 1700-1800'
        WHEN mx.SCOOP_WEIGHT_KG < 1900  THEN 'T. 1800-1900'
        WHEN mx.SCOOP_WEIGHT_KG < 2000  THEN 'U. 1900-2000'
        WHEN mx.SCOOP_WEIGHT_KG < 2100  THEN 'V. 2000-2100'
        ELSE 'W. Over 2100'
    END AS SCOOP_WEIGHT_RANGE_KG,

    -- Invoice fields (latest record per item)
    mx.LatestInvoiceDate,
    mx.GrossSaleAmount,
    mx.GrossSaleQty,
    mx.LatestUnitPrice,
    mx.ExtStandardUnitCost,
    mx.SingleUnitCost,
    mx.shcInvoiceNumber,
    mx.shcOrderNumber,
    mx.InvoiceWarehouse,
    mx.shcTripNumber,
    mx.shcCustomerNumber,
    mx.shcBusinessType,
    mx.shcHomestoreFlag,
    mx.shcBillToName

FROM ONHAND_CTE AS oh
LEFT JOIN METRICS AS mx
    ON mx.ITNBR = oh.item_number
--WHERE mx.PICKPUT = 'PALLT';