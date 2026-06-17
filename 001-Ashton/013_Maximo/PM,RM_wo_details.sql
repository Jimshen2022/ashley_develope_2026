SELECT DISTINCT
    f.[Asset Number] AS Equipment_Number,
    a.[Asset Description] AS Equipment_Description,
    a.[Asset Type] AS Equipment_Type,
    f.[Site ID] AS Site_ID,
    f.[Work Order Number] AS Work_Order_Number,
    wd.[Work Order Description] AS Work_Order_Description,
    wd.[Work Type] AS Work_Type,
    wd.[Work Order Status] AS Work_Order_Status,
    wd.[Report Date] AS Report_Date,
    f.[Total Hours] AS Logged_Hours  -- 每一张工单上实际登记的工时
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
    f.[Site ID] = 'VNM.ASPM'            -- 保持相同的站点过滤
    AND wd.[Work Type] IN ('PM', 'RM')  -- 保持相同的工单类型过滤
    AND wd.[Work Order Status] IN ('CLOSE','COMP') -- 过滤工单状态为关闭或完成
    AND (
        f.[Asset Number] LIKE 'VE%' OR   -- 筛选以 VE 开头的设备
        f.[Asset Number] LIKE 'VR%' OR   -- 筛选以 VR 开头的设备
        f.[Asset Number] LIKE 'VS%' OR   -- 筛选以 VS 开头的设备
        f.[Asset Number] LIKE 'VJ%'      -- 筛选以 VJ 开头的设备
    )
ORDER BY 
    f.[Asset Number], 
    wd.[Report Date] DESC;