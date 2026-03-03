SELECT 
    -- Invoice details
    t1.shcInvoiceNumber,
    t1.shcOrderNumber,
    t1.shcItemNumber,
    t1.shcItemSequenceNumber,
    t1.shcInvoiceDate,
    t1.shcFiscalYearPeriod,
    
    -- Order details
    t1.shcOrderDate,
    t1.shcWarehouse,
    t1.shcTripNumber,
    t1.shcOrderType2,
    t1.shcOrderType4,
    
    -- Customer details
    t1.shcCustomerNumber,
    t1.shcShipToNumber,
    t1.shcBillToStatus,
    t1.shcShipToStatus,
    t1.shcBusinessType,
    t1.shcHomestoreFlag,
    
    -- Billing information
    t1.shcBillToName,
    t1.shcBillToCity,
    t1.shcBillToState,
    t1.shcBillToZipCode,
    t1.shcBillToCountry,
    
    -- Shipping information
    t1.shcShipToName,
    t1.shcShipToCity,
    t1.shcShipToState,
    t1.shcShipToZipCode,
    t1.shcShipToCountry,
    
    -- Item details
    t1.shcItemClass,
    t1.shcItemClassDescription,
    t1.shcItemDescription,
    t1.shcItemType,
    
    -- Financial details
    t1.shcFinancialDivisionDesc,
    t1.shcSalesDivisionDescription,
    t1.shcPriceCode,
    t1.shcSeries,
    
    -- Quantity and amount details
    t1.shcGrossQuantityShipped,
    t1.shcGrossAmountShipped,

    -- Region classification based on country code
    CASE
        WHEN UPPER(LTRIM(RTRIM(t1.shcBillToCountry))) IN (
            'CN', 'JP', 'KR', 'KP', 'TW', 'HK', 'MO', 'MN', 'VN', 'TH', 'MY', 'SG',
            'ID', 'PH', 'MM', 'LA', 'KH'
        ) THEN 'Far East'

        WHEN UPPER(LTRIM(RTRIM(t1.shcBillToCountry))) IN (
            'GB', 'UK', 'DE', 'FR', 'IT', 'ES', 'PL', 'NL', 'BE', 'AT', 'CH', 'SE', 'NO',
            'FI', 'DK', 'IE', 'PT', 'GR', 'CZ', 'HU', 'RO', 'BG', 'SK', 'SI', 'UA',
            'RU', 'RS', 'HR', 'LT', 'LV', 'EE', 'IS'
        ) THEN 'Europe'

        WHEN UPPER(LTRIM(RTRIM(t1.shcBillToCountry))) IN (
            'SA', 'AE', 'IL', 'QA', 'KW', 'BH', 'OM', 'JO', 'LB', 'SY', 'IQ', 'IR', 'YE', 'PS'
        ) THEN 'Middle East'

        WHEN UPPER(LTRIM(RTRIM(t1.shcBillToCountry))) IN (
            'BR', 'AR', 'CL', 'PE', 'CO', 'EC', 'BO', 'PY', 'UY', 'VE', 'GY', 'SR'
        ) THEN 'South America'

        WHEN UPPER(LTRIM(RTRIM(t1.shcBillToCountry))) IN (
            'US', 'CA', 'MX', 'GL', 'BM', 'BS', 'CU', 'JM', 'DO', 'HT', 'GT', 'HN',
            'SV', 'NI', 'CR', 'PA','USA'
        ) THEN 'North America'

        ELSE 'Africa / Other'
    END AS shcRegion

FROM
    CostAccounting_Enh.ShippedHistoryCubeData AS t1
WHERE
    t1.shcWarehouse = '335'
	AND t1.shcInvoiceDate >= DATEADD(YEAR, -2, CAST(GETDATE() AS DATE))
	AND t1.shcInvoiceDate <= CAST(GETDATE() AS DATE)
    AND t1.shcTripNumber <> 0;
