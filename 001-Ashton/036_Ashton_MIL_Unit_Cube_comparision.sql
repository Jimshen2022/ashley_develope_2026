WITH ClassifiedData AS (
    SELECT 
        t2.HOUSE,
        TRIM(t4.ITNBR) AS Item_Number,
        t2.ITCLS,
        t4.B2Z95S AS Master_Unit_Cube,
        t2.MOHTQ AS On_Hand,
        CASE
            WHEN t4.ITNBR LIKE 'M%' AND LENGTH(T4.ITNBR)>6 THEN 'MATT'
            WHEN t4.ITNBR LIKE '[A-Z]%' THEN 'CG'
            ELSE 'UPH'
        END AS Product
    FROM
        AFILELIB.ITBEXT t1
        JOIN AMFLIBA.ITEMBL t2 ON t2.HOUSE = t1.HOUSE AND t2.ITNBR = t1.ITNBR
        JOIN AFILELIB.ITMEXT t3 ON t3.ITNBR = t1.ITNBR
        JOIN AMFLIBA.ITMRVA t4 ON t4.ITNBR = t1.ITNBR AND t4.ITCLS = t2.ITCLS
    WHERE
        t1.HOUSE = '335'
        AND t2.ITCLS LIKE 'Z%'
        AND t2.ITCLS NOT LIKE '%K'
),
OpenPOData AS (
    SELECT
        TRIM(t1.ITNBR) AS Item_Number,
        SUM(t1.QTYOR) AS Open_PO
    FROM
        AMFLIBA.POITEM t1
        JOIN AMFLIBA.POMAST t2 ON t1.ORDNO = t2.ORDNO AND t1.HOUSE = t2.HOUSE
    WHERE
        t1.HOUSE = '335'
        AND t2.PSTTS IN ('10', '20', '30')
    GROUP BY
        t1.ITNBR
)
SELECT
    a.HOUSE,
    a.Item_Number,
    a.ITCLS,
    a.Master_Unit_Cube,
    a.On_Hand,
    b.Open_PO,
    a.Product
FROM
    ClassifiedData a
    LEFT JOIN OpenPOData b ON a.Item_Number = b.Item_Number
WHERE
    a.Product = 'MATT'
