SELECT 
    a.[Asset Type] AS Equipment_Type,
    COUNT(DISTINCT f.[Asset Number]) AS Total_Equipments,
    COUNT(DISTINCT f.[Work Order Number]) AS Total_Work_Orders,
    SUM(f.[Total Hours]) AS Total_Logged_Hours,
    -- 每台设备的平均总耗时
    ROUND(SUM(f.[Total Hours]) / NULLIF(COUNT(DISTINCT f.[Asset Number]), 0), 2) AS Avg_Hours_Per_Equipment,
    -- 每次工单的平均耗时
    ROUND(SUM(f.[Total Hours]) / NULLIF(COUNT(DISTINCT f.[Work Order Number]), 0), 2) AS Avg_Hours_Per_WorkOrder
FROM 
    Maximo_DW.FactMROWorkOrder f
INNER JOIN 
    Maximo_DW.DimMROWorkOrderDetails wd 
    ON f.[Work Order ID] = wd.[Work Order ID] 
    AND f.[Site ID] = wd.[Site ID]
INNER JOIN 
    Maximo_DW.DimMROAssetDetails a 
    ON f.[Asset Number] = a.[Asset Number] 
    AND f.[Site ID] = a.[Asset Site ID]
WHERE 
    wd.[Work Type] IN ('PM', 'RM') -- 筛选预防性维护(PM)和日常维修(RM)
GROUP BY 
    a.[Asset Type]
ORDER BY 
    Total_Logged_Hours DESC;