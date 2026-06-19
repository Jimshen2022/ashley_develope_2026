SELECT 
    inv.itemnum AS Item_Number,
    i.description AS Item_Description,
    inv.location AS Store_Location,
    inv.siteid AS Site_ID,
    
    -- 配置参数 (已对上)
    inv.minlevel AS Order_Point,               
    inv.sstock AS Safety_Stock,                
    inv.maxlevel AS Max_Level,                 
    inv.orderqty AS Reorder_Qty_EOQ,           
    
    -- 👈 终极对账：将负数、挂起数全部归零，完美拉齐前台显示的 0
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
        -- 💡 终极过滤：只抓取最新快照日期，并且只算大于 0 的真实在库库存
        SELECT 
            b.itemnum, 
            b.location, 
            b.siteid, 
            SUM(b.curbal) AS Active_CurBal
        FROM 
            Manufacturing_Maximo.invbalances b
        WHERE 
            -- 绝招 1：只锁定最新的快照日期（防止历史几百天的数据无限累加）
            b.SnapshotDate = (
                SELECT MAX(SnapshotDate) 
                FROM Manufacturing_Maximo.invbalances 
                WHERE itemnum = b.itemnum AND location = b.location AND siteid = b.siteid
            )
            -- 绝招 2：排除掉临时货位
            AND UPPER(RTRIM(b.binnum)) NOT IN ('STAGE', 'STAGING', 'INSPECT', 'SCRAP', 'HOLD')
        GROUP BY 
            b.itemnum, b.location, b.siteid
    ) bal
    ON inv.itemnum = bal.itemnum 
    AND inv.location = bal.location 
    AND inv.siteid = bal.siteid
WHERE 
    inv.siteid = 'VNM.ASPM'
    AND inv.itemnum = '990-9877' -- 👈 对账锁
ORDER BY 
    inv.location;