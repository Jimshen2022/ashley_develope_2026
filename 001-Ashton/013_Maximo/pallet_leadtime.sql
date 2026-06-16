WITH receipt AS (
    SELECT
        m.ponum,
        m.polinenum,
        MIN(m.transdate) AS first_receipt_date
    FROM Manufacturing_Maximo.MATRECTRANS m
    WHERE m.issuetype = 'RECEIPT'
    GROUP BY
        m.ponum,
        m.polinenum
)

SELECT
    pl.itemnum,
    COUNT(*) AS PO_Lines,
    AVG(DATEDIFF(day,p.orderdate,r.first_receipt_date)*1.0) AS Avg_LeadTime_Days,
    MIN(DATEDIFF(day,p.orderdate,r.first_receipt_date)) AS Min_LeadTime,
    MAX(DATEDIFF(day,p.orderdate,r.first_receipt_date)) AS Max_LeadTime
FROM Manufacturing_Maximo.POLINE pl
INNER JOIN Manufacturing_Maximo.PO p
    ON pl.ponum = p.ponum
    AND pl.siteid = p.siteid
INNER JOIN receipt r
    ON pl.ponum = r.ponum
    AND pl.polinenum = r.polinenum
WHERE
    p.siteid = 'VNM.ASPM'
    AND p.status IN ('CLOSE','COMP')
    AND pl.itemnum IN (
        '1000-5783',
        '1000-5795',
        '1000-5784',
        '1000-5786',
        '1000-5785'
    )
GROUP BY
    pl.itemnum
ORDER BY
    pl.itemnum;