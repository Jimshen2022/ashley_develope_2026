SELECT 
    inv.itemnum AS Item_Number,
    i.description AS Item_Description,
    inv.location AS Store_Location,
    inv.siteid AS Site_ID,
    
    -- 👈 已经完全对齐的控制参数
    inv.minlevel AS Order_Point,               -- Reorder Point (前台显示的 15)
    inv.sstock AS Safety_Stock,                -- Safety Stock
    inv.maxlevel AS Max_Level,                 -- Max Level
    inv.orderqty AS Reorder_Qty_EOQ,           -- Reorder Quantity
    inv.deliverytime AS Lead_Time_Days,         -- Lead Time (Days) (前台显示的 15)
    
    -- 👈 新增：历史盘点频率参数
    inv.frequency AS CC_Frequency,              -- 盘点频率数字 (如：12, 30)
    inv.frequnit AS CC_Frequency_Unit,          -- 盘点频率单位 (如：MONTHS, DAYS)
    
    -- 👈 新增：前台界面显示的各年度历史领用累计
    inv.issueytd AS Issue_YTD,                 -- 年累计领用量
    inv.issue1yrago AS Issue_1_Yr_Ago,         -- 去年领用量
    inv.issue2yrago AS Issue_2_Yrs_Ago,        -- 两年前领用量
    inv.issue3yrago AS Issue_3_Yrs_Ago,        -- 三年前领用量
    
    -- 👈 已经完全对齐的合规实时库存数 (显示为0)
    CASE 
        WHEN bal.Active_CurBal <= 0 THEN 0 
        ELSE bal.Active_CurBal 
    END AS Current_Balance,  
    
    inv.vendor AS Default_Vendor
FROM 
    Manufacturing_Maximo.inventory inv
LEFT JOIN 
    Manufacturing_Maximo.item i 
    ON inv.itemnum = i.itemnum 
    AND inv.itemsetid = i.itemsetid
LEFT JOIN 
    (
        -- 严格锁定最新一天的实时库存快照，排除历史翻倍和临时货位的杂音
        SELECT 
            b.itemnum, 
            b.location, 
            b.siteid, 
            SUM(b.curbal) AS Active_CurBal
        FROM 
            Manufacturing_Maximo.invbalances b
        WHERE 
            b.SnapshotDate = (
                SELECT MAX(SnapshotDate) 
                FROM Manufacturing_Maximo.invbalances 
                WHERE itemnum = b.itemnum AND location = b.location AND siteid = b.siteid
            )
            AND UPPER(RTRIM(b.binnum)) NOT IN ('STAGE', 'STAGING', 'INSPECT', 'SCRAP', 'HOLD')
        GROUP BY 
            b.itemnum, b.location, b.siteid
    ) bal
    ON inv.itemnum = bal.itemnum 
    AND inv.location = bal.location 
    AND inv.siteid = bal.siteid
WHERE 
    inv.siteid = 'VNM.ASPM'
    and inv.minlevel >0 -- 👈 只看有设置订单点的物料，没问题后删掉即可看全库数据
    -- AND inv.itemnum = '990-9877' -- 👈 对账阶段可以用这一行锁死单点，没问题后删掉即可看全库数据
ORDER BY 
    inv.location, 
    inv.itemnum;