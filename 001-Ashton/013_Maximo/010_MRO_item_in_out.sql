SELECT 
    t.Item_Number,
    i.description AS Item_Description,
    t.Transaction_Type,                              -- 交易类型：ISSUE(领用) / RECEIPT(PO采购入库)
    t.Transaction_Date,                              -- 实际交易执行日期 (YYYY-MM-DD)
    t.Quantity,                                      -- 交易数量 (领用为负数，入库为正数)
    t.Unit_Cost,                                     -- 交易单价
    t.Total_Cost,                                    -- 交易总金额
    t.Currency,                                      -- 币种 (USD / VND)
    t.Storehouse,                                    -- 关联库房 (如 MROSTORE)
    t.Work_Order_Number,                             -- 关联工单号 (仅ISSUE有)
    t.PO_Number,                                     -- 关联PO采购单号 (仅RECEIPT有)
    t.Asset_Number,                                  -- 关联设备号
    t.Entered_By,                                    -- 操作员
    t.Memo_Description,                              -- 交易备注/描述
    t.Site_ID
FROM 
(
    -- 1. 抓取 MATUSETRANS 表中的 ISSUE (领用) 交易记录
    SELECT 
        m.itemnum AS Item_Number,
        m.itemsetid,
        m.issuetype AS Transaction_Type,
        CAST(m.actualdate AS DATE) AS Transaction_Date,
        m.quantity AS Quantity,
        m.unitcost AS Unit_Cost,
        m.linecost AS Total_Cost,
        m.currencycode AS Currency,
        m.storeloc AS Storehouse,
        m.refwo AS Work_Order_Number,
        NULL AS PO_Number,
        m.assetnum AS Asset_Number,
        m.enterby AS Entered_By,
        m.memo AS Memo_Description,                  
        m.siteid AS Site_ID
    FROM 
        Manufacturing_Maximo.matusetrans m
    WHERE 
        m.siteid = 'VNM.ASPM'
        AND m.issuetype = 'ISSUE'
        AND m.itemnum IN ('1000-1055', '1000-1034','990-7995','990-9877')

    UNION ALL

    -- 2. 抓取 MATRECTRANS 表中的 RECEIPT (PO收货入库) 交易记录 (根据报错彻底对齐列名)
    SELECT 
        r.itemnum AS Item_Number,
        r.itemsetid,
        'RECEIPT' AS Transaction_Type,                -- 👈 修正：直接硬编码交易类型，防止底表列名不一致
        CAST(r.actualdate AS DATE) AS Transaction_Date,
        r.quantity AS Quantity,
        r.unitcost AS Unit_Cost,
        r.linecost AS Total_Cost,
        r.currencycode AS Currency,
        r.location AS Storehouse,                     -- 👈 修正：如果是数仓拉平表，目标库房字段可能叫 location
        NULL AS Work_Order_Number,
        r.ponum AS PO_Number,
        r.assetnum AS Asset_Number,
        r.enterby AS Entered_By,
        r.description AS Memo_Description,            -- 👈 修正：采购表行备注采用 description
        r.siteid AS Site_ID
    FROM 
        Manufacturing_Maximo.matrectrans r
    WHERE 
        r.siteid = 'VNM.ASPM'
        AND r.itemnum IN ('1000-1055', '1000-1034','990-7995','990-9877')
) t
-- 关联 ITEM 主档获取物料长描述
LEFT JOIN 
    Manufacturing_Maximo.item i 
    ON t.Item_Number = i.itemnum 
    AND t.itemsetid = i.itemsetid
ORDER BY 
    t.Item_Number,
    t.Transaction_Date DESC;