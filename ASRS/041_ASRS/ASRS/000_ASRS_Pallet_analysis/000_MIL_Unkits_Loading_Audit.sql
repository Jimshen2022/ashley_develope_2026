WITH HeaderDetails AS (
    SELECT
        ContainerNumber,
        WCHCONTAINERSIZE,
        WCHDOORNUMBER,
        WCHBUILDING,
        WCHPOSTEDTIMESTAMP,
        WCHDESTINATION,
        Container#,
        H_Cubes
    FROM (
        SELECT
            TRIM(a.WCHCONTAINERNUMBER) AS ContainerNumber,
            a.WCHCONTAINERSIZE,
            a.WCHDOORNUMBER,
            a.WCHBUILDING,
            a.WCHPOSTEDTIMESTAMP,
            a.WCHDESTINATION,
            TRIM(a.WCHORIGIN) || '-' || TRIM(a.WCHCONTAINERNUMBER) || '-' || TRIM(a.WCHDESTINATION) AS Container#,
            a.WCHTOTALCUBES AS H_Cubes,
            ROW_NUMBER() OVER (PARTITION BY TRIM(a.WCHCONTAINERNUMBER) ORDER BY a.WCHPOSTEDTIMESTAMP DESC) AS rn
        FROM DISTLIBL.TBL_WVCONTAINER_HDR a
        WHERE a.WCHCONTAINERSTATUS IN ('P', 'T')
          AND a.WCHORIGIN = '51'
          AND TRIM(a.WCHCONTAINERNUMBER) NOT LIKE '%AIR%'
          AND a.WCHDESTINATION NOT IN ('001')
        UNION ALL
        SELECT
            TRIM(a.WCHCONTAINERNUMBER) AS ContainerNumber,
            a.WCHCONTAINERSIZE,
            a.WCHDOORNUMBER,
            a.WCHBUILDING,
            a.WCHPOSTEDTIMESTAMP,
            a.WCHDESTINATION,
            TRIM(a.WCHORIGIN) || '-' || TRIM(a.WCHCONTAINERNUMBER) || '-' || TRIM(a.WCHDESTINATION) || '-' || SUBSTR(CHAR(a.WCHARCHIVETIMESTAMP), 1, 13) AS Container#,
            a.WCHTOTALCUBES AS H_Cubes,
            ROW_NUMBER() OVER (PARTITION BY TRIM(a.WCHCONTAINERNUMBER) ORDER BY a.WCHPOSTEDTIMESTAMP DESC) AS rn
        FROM ASHLEYARCL.WVCNTHDA a
        WHERE a.WCHCONTAINERSTATUS IN ('P', 'T')
          AND a.WCHPOSTEDTIMESTAMP BETWEEN CURRENT DATE - 180 DAYS AND CURRENT DATE
          AND a.WCHORIGIN = '51'
          AND TRIM(a.WCHCONTAINERNUMBER) NOT LIKE '%AIR%'
          AND a.WCHDESTINATION NOT IN ('001')
    ) ranked_data
    WHERE rn = 1
),
i AS (
    SELECT
        a.ITNBR,
        MAX(a.ITMCQTY) AS ITMCQTY
    FROM AFILELIBL.ITMEXT a
    GROUP BY a.ITNBR
),
ctn AS (
    SELECT
        a.WCHCONTAINERNUMBER,
        a.WCHWEEKPO
    FROM DISTLIBL.TBL_WVCONTAINER_HDR a
    WHERE a.WCHCONTAINERSTATUS IN ('P', 'T')
      AND a.WCHORIGIN IN ('51')
    UNION ALL
    SELECT
        a1.WCHCONTAINERNUMBER,
        a1.WCHWEEKPO
    FROM ASHLEYARCL.WVCNTHDA a1
    WHERE a1.WCHCONTAINERSTATUS IN ('P', 'T')
      AND a1.WCHPOSTEDTIMESTAMP BETWEEN CURRENT DATE - 180 DAYS AND CURRENT DATE
      AND a1.WCHORIGIN IN ('51')
),
grouped_data AS (
    SELECT
        t1.DWFDOORNUMBER as Loading_Door_Number,
        t1.DWFCONTAINERNUMBER as Container_Number,
        t1.DWFROWNUMBER as Loading_ROW_Number,
        t1.DWFFINISHITEM as Item_Number,
        hd.WCHDESTINATION as Destination,
        ctn.WCHWEEKPO as CO_Number,
        SUM(t1.DWFQUANTITY) / NULLIF(i.ITMCQTY, 0) AS cartons,
        SUM(t1.DWFQUANTITY) AS Qty,
        VARCHAR_FORMAT(MAX(t1.DWFAUDITTIME), 'YYYY-MM-DD HH24:MI:SS') AS last_scan_time
    FROM RGNFILL.TBL_CONTAINER_AUDIT_DW120RF t1
    LEFT JOIN i ON t1.DWFFINISHITEM = i.ITNBR
    LEFT JOIN HeaderDetails as hd ON t1.DWFCONTAINERNUMBER = hd.ContainerNumber
    LEFT JOIN ctn ON t1.DWFCONTAINERNUMBER = ctn.WCHCONTAINERNUMBER
    WHERE t1.DWFCONTAINERNUMBER IN (SELECT WCHCONTAINERNUMBER FROM ctn)
      AND t1.DWFAUDITTIME >= CURRENT_TIMESTAMP - 180 DAYS
    GROUP BY
        t1.DWFDOORNUMBER,
        t1.DWFCONTAINERNUMBER,
        t1.DWFROWNUMBER,
        t1.DWFFINISHITEM,
        i.ITMCQTY,
        hd.WCHDESTINATION,
        ctn.WCHWEEKPO
)
SELECT
    Loading_Door_Number,
    Container_Number,
    Loading_ROW_Number,
    Item_Number,
    Destination,
    CO_Number,
    cartons,
    Qty,
    last_scan_time,
    CASE
        WHEN ROW_NUMBER() OVER (
            PARTITION BY Container_Number, Item_Number
            ORDER BY Loading_ROW_Number, last_scan_time
        ) = 1 THEN 1
        ELSE 0
    END AS SKU_count
FROM grouped_data
ORDER BY
    Container_Number,
    Loading_ROW_Number,
    last_scan_time