WITH OnHandData AS (
    SELECT T1.ITNBR, T1.HOUSE, T1.ITCLS, T1.MOHTQ, T2.ITDSC
    FROM AMFLIBL.ITEMBL T1
    JOIN AMFLIBL.ITMRVA T2 ON T2.ITCLS = T1.ITCLS AND T2.ITNBR = T1.ITNBR
    JOIN AMFLIBL.WHSMST T3 ON T3.STID = T2.STID AND T1.HOUSE = T3.WHID
    WHERE T1.HOUSE = '51' AND T1.MOHTQ <> 0
),
UnitPriceData AS (
    SELECT b1.RPAITX, MAX(b1.RPAMVA) as RPAMVA
    FROM (
        SELECT x.RPAITX, x.ITCLS, x.RPAMVA, x.RPBLDT, x.RPZ0D7
        FROM (
            (
                (SELECT a.RPAITX, (CASE WHEN a.RPBRCD IN ('VND') THEN a.RPAMVA/23090 ELSE a.RPAMVA END) AS RPAMVA, a.RPBLDT, a.RPZ0D7, T2.ITCLS
                FROM AMFLIBL.ITMFPR a
                LEFT JOIN AMFLIBL.ITMRVA T2 ON a.RPAITX = T2.ITNBR AND a.RPZ0D7 = T2.STID
                WHERE a.RPZ0D7 = '51' AND a.RPAITX || a.RPZ0D7 || a.RPBLDT IN (
                    SELECT a.RPAITX || a.RPZ0D7 || MAX(a.RPBLDT) RPBLDT
                    FROM AMFLIBL.ITMFPR a
                    WHERE a.RPZ0D7 = '51'
                    GROUP BY a.RPAITX, a.RPZ0D7
                ))
                UNION ALL
                (SELECT t1.ITNO1G, t1.UCCT1G/23090 AS RPAMVA, t1.CCDT1G, t1.STID1G, t1.STID1G
                FROM AMFLIBL.ITMPRB t1)
            )
            UNION ALL
            (SELECT t1.ITNBR, t1.LCOST/23090 AS RPAMVA, t1.LDQOH, t1.HOUSE, t1.ITCLS
            FROM AMFLIBL.ITEMBL t1)
        ) AS x
    ) b1
    GROUP BY b1.RPAITX
)
SELECT a.ITNBR, a.HOUSE, a.ITCLS, a.MOHTQ, b.RPAMVA AS "UP($USD)",
        (CASE WHEN a.ITCLS IN ('WPLS','PLST') THEN 'PLASTIC'   
            WHEN a.ITCLS IN ('PVN2','QA','QB') THEN 'RAW'  
            WHEN a.ITCLS LIKE 'CH%' THEN 'RAW'  
            WHEN a.ITCLS LIKE 'CR%' THEN 'RAW'              
            WHEN a.ITCLS IN ('TAF') THEN 'RP' 
            WHEN a.ITCLS IN ('CTA','MTA','HTA') THEN 'RP CGs' 
            WHEN a.ITCLS IN ('FFR') THEN 'FFR'   
            WHEN a.ITCLS IN ('BBFR') THEN 'FR SOCK'   
            WHEN a.ITCLS IN ('ZDTP') THEN 'PILLOW'   
            WHEN a.ITCLS IN ('MVN') THEN 'QUILTING'   
            WHEN a.ITCLS IN ('ZKIZ') THEN 'ZIPPER COVER'   
            WHEN a.ITCLS IN ('WVHC','WVVG') THEN 'VERONA'    
            WHEN a.ITCLS IN ('PVN') THEN 'FABRIC'   
            WHEN a.ITCLS IN ('WVCS') THEN 'FOUNDATION'   
            WHEN a.ITCLS IN ('ZABC','ZECD','ZDAA','ZECD','ZDWC','ZDAB','ZDAE','ZDAW','ZDBC','ZDWC','ZDAY','ZEBR','ZVTY') THEN 'CASEGOODS'   
            WHEN a.ITCLS IN ('ZAIS','ZKIS','ZNFR','ZKBP','ZKBA','ZBMA','TAB') THEN 'BEDDING'   
            WHEN a.ITCLS LIKE  'Z%K' THEN 'UNKITS'   
            ELSE 'Check' END) AS Product, 
    CASE
        WHEN b.RPAMVA IS NULL AND a.ITCLS NOT LIKE 'Z%' THEN 0
        WHEN b.RPAMVA IS NULL AND a.ITCLS LIKE 'Z%' THEN DECIMAL(a.MOHTQ) * 50
        ELSE DECIMAL(a.MOHTQ) * COALESCE(b.RPAMVA, 0)
    END AS "AMT($USD)"
FROM OnHandData a
LEFT JOIN UnitPriceData b ON a.ITNBR = b.RPAITX