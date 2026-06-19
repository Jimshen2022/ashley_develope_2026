SELECT 
    inv.itemnum AS [Item],                                 -- 1. 物料编码
    i.description AS [Description],                       -- 2. 物料描述
    inv.location AS [Storeroom],                           -- 3. 库房
    inv.abctype AS [ABC Type],                             -- 4. ABC分类
    inv.binnum AS [Bin Location],                         -- 5. 货位编码
    
    -- 6. 实时合规库存数
    CASE 
        WHEN bal.Active_CurBal <= 0 THEN 0 
        ELSE bal.Active_CurBal 
    END AS [Current Balance],  
    
    inv.issueytd AS [Year to Date],                       -- 7. 年累计领用量
    inv.issue1yrago AS [Last Year],                       -- 8. 去年领用量
    inv.issue2yrago AS [2 Years Ago],                      -- 9. 两年前领用量
    inv.issue3yrago AS [3 Years Ago],                      -- 10. 三年前领用量
    
    -- 11. 是否重订货标志
    CASE 
        WHEN inv.minlevel > 0 THEN 'Y' 
        ELSE 'N' 
    END AS [Reorder],
    
    inv.siteid AS [Site],                                 -- 12. 站点ID
    inv.status AS [Status],                               -- 13. 库存状态
    CAST(inv.lastissuedate AS DATE) AS [Last Issue Date], -- 14. 最后领用日期
    CAST(inv.statusdate AS DATE) AS [Date added to Storeroom], -- 15. 加入库房日期
    i.commoditygroup AS [Commodity Group],                -- 16. 商品组
    inv.minlevel AS [Reorder Point],                      -- 17. 重订货点
    inv.orderqty AS [Economic Order Quantity],            -- 18. 经济订货量
    inv.deliverytime AS [Lead Time],                       -- 19. 采购提前期
    inv.vendor AS [Primary Vendor],                       -- 20. 主供应商
    
    ---------------------------------------------------------
    -- 👈 针对这 3 列的物理底层字段拼写进行终极修正
    ---------------------------------------------------------
    -- 21. 完美修正：清除前后空格。如果仍为空，显示为 'PIV'（或保留底表原始值）
    ISNULL(RTRIM(LTRIM(inv.afiil1)), '') AS [VNM Category], 
    
    -- 22. 完美修正：清除前后空格。对齐您的 PIV 模板数据
    ISNULL(RTRIM(LTRIM(inv.afiil3)), '') AS [VNM Costgroup], 
    
    inv.costtype AS [Issue Cost Type],                    -- 23. 计价方式
    inv.issueunit AS [Issue Unit],                        -- 24. 发料单位
    
    -- 25. 寄售标志全兼容转换 (支持 1 / '1' / 'Y' / 'TRUE')
    CASE 
        WHEN inv.consignment = 1 OR UPPER(RTRIM(LTRIM(CAST(inv.consignment AS VARCHAR)))) IN ('1', 'Y', 'YES', 'TRUE') THEN 'Y' 
        ELSE 'N' 
    END AS [Consignment]                                  
    ---------------------------------------------------------

FROM 
    Manufacturing_Maximo.inventory inv
LEFT JOIN 
    Manufacturing_Maximo.item i 
    ON inv.itemnum = i.itemnum 
    AND inv.itemsetid = i.itemsetid
LEFT JOIN 
    (
        -- 库存对账防线：严格按最新快照日期聚合
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
    inv.siteid = 'VNM.ASPM'                               -- 锁定 ASPM 园区
    and  inv.itemnum in ('1000-1055','1000-1034')
ORDER BY 
    inv.location, 
    inv.itemnum;