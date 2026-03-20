WITH ss as (
    select t.SSINVR,
        t.SSORNO,
        t.SSCONO,
        t.SSCSNO as "Customer Number",
        trim(t.SSSTNM) || '(' || TRIM(t.SSCSNO) || '/' ||  TRIM(t.SSSPNO) || ')' as "Sold to Name",
        trim(t.SSSTA1) || '' || TRIM(t.SSSTA2) as "Sold to Address",
         TRIM(t.SSSTA3) || ',' || TRIM(t.SSSTST) || '  ' || TRIM(t.SSSTZC) as "sold to CITY/STATE/ZIP",
         t.SSSPNO,
         TRIM(t.SSSPNM) || '(' || TRIM(t.SSCSNO) || '/' ||  TRIM(t.SSSPNO) || ')'  as "Ship to Name",
         trim(t.SSSPA1) || ' ' || TRIM(t.SSSPA2) as "Ship to Address",
         TRIM(t.SSSPA3) || ',' || TRIM(t.SSSPST) || ' ' || TRIM(t.SSSPZC) as "Ship to CITY/STATE/ZIP",
         t.SSSCTY,
         t.SSSPCN
            FROM AFILELIB.TSSSIN as t
),
po AS (
    SELECT
        t.HOUSE,
        t.ORDNO,
        t.VNDNR,
        t.PSTTS,
        t.UU25PM
    FROM AMFLIBA.POMAST AS t
    WHERE t.HOUSE IN ('C','C35','CNW','AF','IOR') AND t.PSTTS IN ('10','20','30')
),
trip as (
    SELECT t.XNINVR,
           t.XNORNO,
           t.XNTRPN
    FROM AFILELIB.TSINXN AS t
    WHERE t.XNTRPN IS NOT NULL
)
    SELECT
        t.ININVR as "Invoice Number",
        t.INORNO as "Order Number",
        t.INIVDT as "Invoice Date",
        t.INIVAM as "Inv Val",
        t.INIDAM as "Inv Dsc",
        t.ININSL as "Ord Val",
        t.INCONO as "Company Number",
        t.INCSNO as "Customer Number",
        t.INPONO as "Customer PO",
        t.INTMDS as "Terms Des" ,
        t.INORDT as "Order Date",
        t.INRQDT as "Request Date",
        t.INSHIN as "Shipping Inst",
        t.INWHSE as "Warehouse",
        t.INORVL as "OrderValue" ,
        t1.XNTRPN as "Trip#",
        t2."Sold to Name",
        t2."Sold to Address",
        t2."sold to CITY/STATE/ZIP",
        t2."Ship to Name",
        t2."Ship to Address",
        t2."Ship to CITY/STATE/ZIP",
        t2.SSSCTY,
        t2.SSSPCN,
        CASE
            WHEN t.INWHSE = 'C' THEN
                CASE
                    WHEN t.INSHIN IS NULL THEN 'NULL_INSHIN'
                    ELSE TRIM(CAST(t.INSHIN AS CHAR(50)))
                END
            WHEN t.INWHSE = '335' THEN
                CASE
                    WHEN t1.XNTRPN IS NULL THEN 'NULL_XNTRPN'
                    ELSE TRIM(CAST(t1.XNTRPN AS CHAR(50)))
                END
            ELSE 'Unknown'
        END AS ShippingIntr_Trips
    FROM AFILELIB.TSININ AS t
    left join trip as t1 on t.ININVR = t1.XNINVR and t.INORNO = t1.XNORNO
    left join ss as t2 on t.ININVR = t2.SSINVR and t.INORNO = t2.SSORNO
    WHERE t.INWHSE in ('C','CNW','AF','IOR')
-- AND t.INIVDT >= TO_CHAR(CURRENT DATE - 120 DAYS, 'YYYYMMDD')
AND t.INIVDT >= '20260101' AND t.INIVDT <= '20281231'