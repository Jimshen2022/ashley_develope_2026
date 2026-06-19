SELECT 
    m.itemnum AS Item_Number,
    i.description AS Item_Description,
    m.assetnum AS Equipment_Number,
    m.refwo AS Work_Order_Number,
    m.actualdate AS Issue_Date,                      -- Original timestamp column
    CAST(m.actualdate AS DATE) AS Issue_Date_Only,    -- 👈 New Column: Clean date format for Excel
    m.quantity AS Issue_Qty,
    m.issueunit AS Issue_Unit,
    m.linecost AS Issue_Cost,                        -- Original cost in system transaction currency
    
    -- 👈 New Column: Calculated USD Cost using a fixed exchange rate (25000)
    CASE 
        WHEN UPPER(RTRIM(m.currencycode)) = 'USD' THEN m.linecost
        WHEN UPPER(RTRIM(m.currencycode)) = 'VND' THEN ROUND(m.linecost / 26326.0, 2)
        ELSE m.linecost -- Fallback default
    END AS Issue_Cost_USD,
    
    m.currencycode AS Currency,
    m.assetnum AS Asset_Number,
    m.memo AS Issue_Memo,
    m.refwo AS Work_Order_Reference,
    m.location AS department,
    m.storeloc AS From_Storehouse,
    m.siteid AS Site_ID
FROM 
    Manufacturing_Maximo.matusetrans m
LEFT JOIN 
    Manufacturing_Maximo.item i 
    ON m.itemnum = i.itemnum 
    AND m.itemsetid = i.itemsetid
WHERE 
    m.siteid = 'VNM.ASPM'
    AND m.issuetype = 'ISSUE'
    AND m.actualdate >= '2025-01-01'
    AND (
        m.itemnum LIKE '106%' OR
        m.itemnum LIKE '992%'
    )
ORDER BY 
    m.actualdate DESC;