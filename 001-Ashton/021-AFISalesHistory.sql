SELECT
[Invoice date],
Warehouse,
SUM([Amount Shipped]) AS [Total Amount],
c.[Customer Name],
i.AFIFinanceDivision

FROM [AFISales_DW].[FactShippedHistory] fs
LEFT JOIN AFISales_DW.DimCustomers c ON fs.[Account And ShipTo Number]=c.[Account And ShipTo Number]
LEFT JOIN Enterprise_DW.DimItemMaster i ON fs.[Item SKU]=i.ItemSKU

WHERE [Invoice date] BETWEEN DATEADD(MONTH,-12,CAST(GETDATE() AS DATE)) AND CAST(GETDATE() AS DATE)

GROUP BY
[Invoice date],
Warehouse,
c.[Customer Name],
i.AFIFinanceDivision

HAVING SUM([Amount Shipped]) <>0