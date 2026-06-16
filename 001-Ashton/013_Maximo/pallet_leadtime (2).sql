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
    pl.ponum,
    p.vendor,
    p.orderdate,
    r.first_receipt_date,
    DATEDIFF(day,p.orderdate,r.first_receipt_date) AS LeadTime_Days,
    pl.orderqty
FROM Manufacturing_Maximo.POLINE pl
INNER JOIN Manufacturing_Maximo.PO p
    ON pl.ponum = p.ponum
    AND pl.siteid = p.siteid
INNER JOIN receipt r
    ON pl.ponum = r.ponum
    AND pl.polinenum = r.polinenum
WHERE
    p.siteid = 'VNM.ASPM'
    AND pl.itemnum IN (
        '1000-5783',
        '1000-5795',
        '1000-5784',
        '1000-5786',
        '1000-5785'
    )
ORDER BY
    pl.itemnum,
    p.orderdate;