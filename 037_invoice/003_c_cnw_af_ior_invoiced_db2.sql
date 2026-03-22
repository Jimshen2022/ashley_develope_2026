--Created on Oct.02.2024 by Jim,Shen
WITH BaseData AS (
    SELECT
        t4.INIVDT, t6.ITITNO, t4.INWHSE, t6.ITITCL, t6.ITSHQT, t2.UUCCIM, t7.XCUS#,
        t6.ITWHSE, t6.ITCSNO, t6.ITSPNO, T5.XNTRPN, T5.XNINVR, T5.XNORNO, t1.STACD,
        t2.CUBES AS Unit_CubicFeet,
        t2.CUBES * t6.ITSHQT as CUBES,
        t4.INPONO, t1.CUSNM, t7.XFRGHT, t7.XTCONF, t7.XDSCNT, t6.ITPRIC, t1.CCTYN as CountryCode,
        t4.INIVDT || '_' || CHAR(t5.XNTRPN) AS Container#,
    CASE
        WHEN t6.ITITCL NOT LIKE 'Z%' THEN 'RP'
        WHEN t6.ITITNO LIKE '100-%' THEN 'CG'
        WHEN REGEXP_LIKE(TRIM(t6.ITITNO), '^[1-9U]') THEN 'UPH'
        --WHEN SUBSTR(TRIM(T1.ITNBR),1,1) IN ('1','2','3','4','5','6','7','8','9','U') THEN 'UPH'
        WHEN SUBSTR(TRIM(t6.ITITNO),1,1) IN ('A') AND t2.CUBES >= 0.3 THEN 'CG'
        WHEN REGEXP_LIKE(TRIM(t6.ITITNO), '^[ALRQ]') THEN 'ACCESSORY'
        --WHEN SUBSTR(TRIM(t6.ITITNO),1,1) IN ('A','L','R','Q') THEN 'ACCESSORY'
        WHEN LENGTH(TRIM(t6.ITITNO)) = 6 AND SUBSTR(TRIM(t6.ITITNO),1,1) ='M' THEN 'ACCESSORY'
    ELSE 'CG' END AS Sub_Product,
    CASE
        WHEN t6.ITITCL NOT LIKE 'Z%' THEN 'RP'
        WHEN t6.ITITNO LIKE '100-%' THEN 'CG'
        WHEN REGEXP_LIKE(TRIM(t6.ITITNO), '^[1-9U]') THEN 'UPH'
        ELSE 'CG'
    END AS Product,
    t8.SSSPA1 as shipt_to_address1,
    t8.SSSPA2 as shipt_to_address2,
    t8.SSSPA3 as shipt_to_address3,
    t8.SSSPST as shipt_to_state_code,
    t8.SSSPCN as shipt_to_country_code,
    t5.XOCRDT as org_cust_req_date,
    t4.INORDT as order_date,
    t4.INRQDT as request_date,
    t4.INRODT as reversed_order_date

    FROM
        (SELECT * FROM AFILELIB.TSITIN AS a WHERE a.ITWHSE IN ('C','CNW','AF','IRO')) AS t6
        LEFT JOIN  AFILELIB.TSITXN AS t7 ON t6.ITORNO = t7.XTORNO AND t6.ITITNO = t7.XTITNO AND t6.ITINVR = t7.XTINVR AND t6.ITITSQ = t7.XTITSQ
        LEFT JOIN  (SELECT * FROM AFILELIB.TSININ AS c WHERE c.INWHSE IN ('C','CNW','AF','IRO')) AS t4 ON t6.ITORNO = t4.INORNO AND t6.ITWHSE = t4.INWHSE AND t6.ITINVR = t4.ININVR
        LEFT JOIN AFILELIB.TSINXN t5 ON t6.ITORNO = t5.XNORNO AND t6.ITINVR = t5.XNINVR
        LEFT JOIN AFILELIB.ACUSMASJ t1 ON t6.ITCSNO = t1.CUSNO
        --LEFT JOIN AMFLIBA.MBBZRES1 t3 ON t6.ITITNO = t3.BZAITX
        LEFT JOIN AFILELIB.ITMEXT t2 ON t6.ITITNO = t2.ITNBR
        LEFT JOIN AFILELIB.TSSSIN t8 ON t6.ITINVR = t8.SSINVR AND t6.ITORNO = t8.SSORNO and t6.ITCSNO = t8.SSCSNO AND t6.ITSPNO = t8.SSSPNO
    WHERE
        t4.INWHSE IN ('C','CNW','AF','IRO')
       -- AND t5.XNTRPN <> 0
        --AND t4.INIVDT BETWEEN INTEGER(REPLACE(CHAR(CURRENT DATE - 360 DAYS), '-', '')) AND INTEGER(REPLACE(CHAR(CURRENT DATE), '-', ''))
        AND t4.INIVDT BETWEEN 20240101 AND INTEGER(REPLACE(CHAR(CURRENT DATE), '-', ''))
        AND t6.ITSHQT > 0
),
ContainerTypes AS (
    SELECT
        Container#,
        CASE WHEN COUNT(DISTINCT Product) = 1 THEN 'None-Mixed' ELSE 'Mixed' END AS ContainerType
    FROM
        BaseData
    GROUP BY
        Container#
)
SELECT  bd.INIVDT, bd.ITITNO, bd.INWHSE, bd.ITITCL, bd.ITSHQT, bd.UUCCIM, bd.XCUS#,
    bd.ITWHSE, bd.ITCSNO, bd.ITSPNO, bd.XNTRPN, bd.XNINVR, bd.XNORNO, bd.STACD,
    bd.Unit_CubicFeet, bd.CUBES,
    bd.INPONO, bd.CUSNM, bd.XFRGHT, bd.XTCONF, bd.XDSCNT, bd.ITPRIC,bd.CountryCode,
    bd.Container#, bd.Sub_product, bd.Product,
    CASE
        WHEN ct.ContainerType = 'None-Mixed' THEN bd.Product
        ELSE ct.ContainerType
    END AS Cont_Categories,
    bd.shipt_to_address1,
    bd.shipt_to_address2,
    bd.shipt_to_address3,
    bd.shipt_to_state_code,
    bd.shipt_to_country_code,
    bd.org_cust_req_date,
    bd.order_date,
    bd.request_date,
    bd.reversed_order_date
FROM
    BaseData bd
    LEFT JOIN ContainerTypes ct ON bd.Container# = ct.Container#
ORDER BY
    bd.INIVDT, bd.XNTRPN 
