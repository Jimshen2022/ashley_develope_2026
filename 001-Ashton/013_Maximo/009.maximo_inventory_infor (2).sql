SELECT 
    inv.itemnum AS [Item],                                 -- 1. 物料编码
    i.description AS [Description],                       -- 2. 物料描述 (来自 ITEM 表)
    inv.location AS [Storeroom],                           -- 3. 库房
    inv.abctype AS [ABC Type],                             -- 4. ABC分类
    inv.binnum AS [Bin Location],                         -- 5. 货位编码
    
    -- 6. 核心对齐的实时合规库存数 (若为负数或空值自动归零，完美对齐前台)
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
    inv.status AS [Status],                               -- 13. 库存状态 (ACTIVE)
    inv.lastissuedate AS [Last Issue Date],               -- 14. 最后领用日期
    inv.statusdate AS [Date added to Storeroom],          -- 15. 加入库房日期
    i.commoditygroup AS [Commodity Group],                -- 16. 修正：商品组真正来自于 ITEM 表 (i.commoditygroup)
    inv.minlevel AS [Reorder Point],                      -- 17. 重订货点 (完美对应前台显示的15)
    inv.orderqty AS [Economic Order Quantity],            -- 18. 经济订货量
    inv.deliverytime AS [Lead Time],                       -- 19. 采购提前期 (对应前台Lead Time Days)
    inv.vendor AS [Primary Vendor],                       -- 20. 主供应商
    inv.afiil1 AS [VNM Category],                         -- 21. 本地分类扩展字段
    inv.afiil3 AS [VNM Costgroup],                        -- 22. 本地成本组扩展字段
    inv.costtype AS [Issue Cost Type],                    -- 23. 计价方式
    inv.issueunit AS [Issue Unit],                        -- 24. 发料单位
    inv.consignment AS [Consignment]                      -- 25. 是否寄售
FROM 
    Manufacturing_Maximo.inventory inv
LEFT JOIN 
    Manufacturing_Maximo.item i 
    ON inv.itemnum = i.itemnum 
    AND inv.itemsetid = i.itemsetid                        -- 跨站点精确关联物料主档
LEFT JOIN 
    (
        -- 💡 库存对账防线：严格按最新快照日期聚合，扣除临时货位干扰，确保实时数量绝对对齐前台界面
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
ORDER BY 
    inv.location, 
    inv.itemnum;