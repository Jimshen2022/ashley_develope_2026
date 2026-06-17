SELECT 
    f.[Asset Number] AS Equipment_Number,
    a.[Asset Description] AS Equipment_Description,
    a.[Asset Type] AS Equipment_Type,
    f.[Site ID] AS Site_ID,
    -- Total Hours Breakdown by Work Type
    SUM(CASE WHEN wd.[Work Type] = 'PM' THEN f.[Total Hours] ELSE 0 END) AS PM_Total_Hours,
    SUM(CASE WHEN wd.[Work Type] = 'RM' THEN f.[Total Hours] ELSE 0 END) AS RM_Total_Hours,
    -- Total Logged Hours (Matches the sum of Logged_Hours in Detail for this equipment)
    SUM(f.[Total Hours]) AS Total_Logged_Hours,
    -- Distinct Work Order Counts (Matches the distinct count of Work_Order_Number in Detail)
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
    f.[Site ID] = 'VNM.ASPM'
    AND wd.[Work Type] IN ('PM', 'RM')
    AND wd.[Work Order Status] IN ('CLOSE','COMP') -- 过滤工单状态为关闭或完成
    AND (
        f.[Asset Number] LIKE 'VE%' OR
        f.[Asset Number] LIKE 'VR%' OR
        f.[Asset Number] LIKE 'VS%' OR
        f.[Asset Number] LIKE 'VJ%'
    )
GROUP BY 
    f.[Asset Number],
    a.[Asset Description],
    a.[Asset Type],
    f.[Site ID]
ORDER BY 
    Total_Logged_Hours DESC;