SELECT 
    f.[Asset Number] AS Equipment_Number,
    a.[Asset Description] AS Equipment_Description,
    a.[Asset Type] AS Equipment_Type,
    f.[Site ID] AS Site_ID,
    -- 分别统计 PM 和 RM 的总工时
    SUM(CASE WHEN wd.[Work Type] = 'PM' THEN f.[Total Hours] ELSE 0 END) AS PM_Total_Hours,
    SUM(CASE WHEN wd.[Work Type] = 'RM' THEN f.[Total Hours] ELSE 0 END) AS RM_Total_Hours,
    -- 统计总累计工时
    SUM(f.[Total Hours]) AS Total_Logged_Hours,
    -- 统计工单数量
    COUNT(DISTINCT CASE WHEN wd.[Work Type] = 'PM' THEN f.[Work Order Number] END) AS PM_WorkOrder_Count,
    COUNT(DISTINCT CASE WHEN wd.[Work Type] = 'RM' THEN f.[Work Order Number] END) AS RM_WorkOrder_Count,
    COUNT(DISTINCT f.[Work Order Number]) AS Total_WorkOrder_Count
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
    f.[Site ID] = 'VNM.ASPM'            -- 过滤特定的越南站点
    AND wd.[Work Type] IN ('PM', 'RM')  -- 过滤工单类型
GROUP BY 
    f.[Asset Number],
    a.[Asset Description],
    a.[Asset Type],
    f.[Site ID]
ORDER BY 
    Total_Logged_Hours DESC;            -- 优先把耗时最长的设备排在前面