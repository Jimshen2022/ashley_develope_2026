/* 
select top 10 * from CostAccounting_Enh.ShippedHistoryCubeData where shcWarehouse = '335' and shcTripNumber = ''
select top 10 * from Wholesale_SalesHistory_AFI.InvoiceDetail


select top 1000 * from CostAccounting_Enh.ShippedHistoryCubeData where shcWarehouse = '335' and shcTripNumber = '97827'
select top 1000 * from Wholesale_SalesHistory_AFI.InvoiceDetail where   Warehouse = '335' and TripNumber = '97827' order by InvoiceDate desc

select  * from Wholesale_SalesHistory_AFI.InvoiceDetail where  OrderNumber = 'D739656'  and Warehouse = '335'
select top 10 * from Wholesale_SalesHistory_AFI.InvoiceDetail where Warehouse = '335' and CustomerNumber = '3223700' and TripNumber = '24436'
where ORDNO = 'D739656'

select top 10 * from AFISales_DW.DimInvoiceHeader 
select top 10 * from AFISales_DW.FactOnTimeDeliveryInvoiceDetail  

*/

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
    WHERE --shcWarehouse = '335' 
        shcItemNumber IN (
          '2490438','9510439','B251-94','B984-94','B1199-82','B735-95',
          'U2710515','B129-82','W781-68','9810366','M75X32','B944-58',
          'D647-25','B192-53','B660-57','B777-57','B822-31','EW0200-127',
          '9810317','M52531','100-54','M14231','A8000327','2810535',
          '1440446','M72731','5020577','D634-01','M1X1272','M91X32',
          'A2000663','A8010291','A2000683','B267-92','A8010370',
          'A8000263','L204174','A2000753','M1B0131','A2000553','L734341',
          'A2000487','M1X1102B','M1X3102B','A2000631','L000978','L734402','A2000587'
      )
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