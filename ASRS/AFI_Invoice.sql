WITH RankedInvoices AS (
    SELECT 
        -- 发票与明细字段
        shcInvoiceNumber,
        shcOrderNumber,
        shcWarehouse,
        shcTripNumber,
        shcCustomerNumber,
        shcBusinessType,
        shcHomestoreFlag,
        shcBillToName,        
        -- 核心计算与排序字段
        shcItemNumber,
        shcInvoiceDate,
        shcGrossQuantityShipped,
        shcGrossAmountShipped,
        shcExtStandardUnitCost, -- 提取明细行标准总成本        
        -- 使用您指定的字段计算销售单价 (用 NULLIF 避免发生除以 0 的致命错误)
        (shcGrossAmountShipped / NULLIF(shcGrossQuantityShipped, 0)) AS UnitPrice,        
        -- 按料号分组，按发票日期降序排列打上序号
        ROW_NUMBER() OVER(
            PARTITION BY shcItemNumber 
            ORDER BY shcInvoiceDate DESC
        ) AS rn
    FROM CostAccounting_Enh.ShippedHistoryCubeData
)
-- 筛选出每个料号最新的一笔记录 (rn = 1)
SELECT 
    shcItemNumber,
    shcInvoiceDate AS LatestInvoiceDate,
    shcGrossAmountShipped,    -- Gross Sale Amount
    shcGrossQuantityShipped,  -- Gross Sale Qty
    UnitPrice AS LatestUnitPrice, -- 销售单价
    
    -- 成本相关字段
    shcExtStandardUnitCost,   -- 明细行标准总成本 (金额)
    (shcExtStandardUnitCost / NULLIF(shcGrossQuantityShipped, 0)) AS SingleUnitCost, -- 真实单件成本 (用于和销售单价对比毛利)
    
    -- 其他维度字段
    shcInvoiceNumber,
    shcOrderNumber,
    shcWarehouse,
    shcTripNumber,
    shcCustomerNumber,
    shcBusinessType,
    shcHomestoreFlag,
    shcBillToName
FROM RankedInvoices
WHERE rn = 1;