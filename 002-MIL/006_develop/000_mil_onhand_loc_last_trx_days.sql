WITH oh1 AS (
    SELECT
        a1.ITNBR,
        t2.ITDSC,
        t2.ITCLS,
        a1.HOUSE,
        a1.LLOCN,
        SUM(a1.LQNTY) AS ONHAND
    FROM Manufacturing_ProductionPlanning_MIL.SLQNTY AS a1
    LEFT JOIN (
        SELECT a.ITNBR, a.ITCLS, a.ITDSC
        FROM MasterData_ItemMaster_MIL.ITMRVA AS a
        WHERE a.STID IN ('51')
    ) AS t2 ON a1.ITNBR = t2.ITNBR
    WHERE a1.HOUSE IN ('51')
      AND a1.LLOCN NOT IN ('RS001','S01ST1','PIC01','LMF001')
    GROUP BY a1.ITNBR, t2.ITDSC, t2.ITCLS, a1.HOUSE, a1.LLOCN
),

last_trx AS (
    SELECT
        ITNBR,
        LAST_UPDDT,
        TCODE AS LAST_TCODE
    FROM (
        SELECT
            T1.ITNBR,
            T1.UPDDT  AS LAST_UPDDT,
            T1.TCODE,
            ROW_NUMBER() OVER (PARTITION BY T1.ITNBR ORDER BY T1.UPDDT DESC) AS RN
        FROM Manufacturing_Inventory_MIL.IMHIST AS T1
        WHERE T1.HOUSE = '51'
          AND T1.TRQTY <> 0
          AND EXISTS (
              SELECT 1
              FROM (
                  SELECT i.ITNBR
                  FROM Manufacturing_ProductionPlanning_MIL.SLQNTY AS i
                  WHERE i.LQNTY <> 0
                    AND i.HOUSE IN ('51')
                    AND i.LLOCN NOT IN ('RS001','S01ST1','PIC01','LMF001')
                  GROUP BY i.ITNBR
              ) AS b1
              WHERE b1.ITNBR = T1.ITNBR
          )
    ) AS ranked
    WHERE RN = 1
)

SELECT
    oh1.ITNBR                                               AS "Item",
    oh1.ITDSC                                               AS "Description",
    oh1.ITCLS                                               AS "Category",
    oh1.ONHAND                                              AS "Qty",
    'EA'                                                    AS "Unit",
    oh1.LLOCN                                               AS "Location",
    CAST(CONCAT('20',
        SUBSTRING(CAST(lt.LAST_UPDDT AS VARCHAR(8)), 2, 2), '-',
        SUBSTRING(CAST(lt.LAST_UPDDT AS VARCHAR(8)), 4, 2), '-',
        SUBSTRING(CAST(lt.LAST_UPDDT AS VARCHAR(8)), 6, 2)
    ) AS DATE)                                              AS "Last Transaction Date",
    lt.LAST_TCODE                                           AS "Last Transaction Type",
    CASE
        WHEN lt.LAST_UPDDT IS NULL THEN NULL
        ELSE DATEDIFF(DAY,
            CAST(CONCAT('20',
                SUBSTRING(CAST(lt.LAST_UPDDT AS VARCHAR(8)), 2, 2), '-',
                SUBSTRING(CAST(lt.LAST_UPDDT AS VARCHAR(8)), 4, 2), '-',
                SUBSTRING(CAST(lt.LAST_UPDDT AS VARCHAR(8)), 6, 2)
            ) AS DATE),
            CAST(GETDATE() AS DATE))
    END                                                     AS "Days Since Last Movement"

FROM oh1
LEFT JOIN last_trx lt ON oh1.ITNBR = lt.ITNBR

ORDER BY "Days Since Last Movement" DESC