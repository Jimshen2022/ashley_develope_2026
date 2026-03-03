SELECT  *
FROM  CostAccounting_Enh.ShippedHistoryCubeData as t
WHERE t.shcWarehouse = '335'
	and t.shcInvoiceDate between '2025-05-04' and '2025-05-10'
	and t.shcTripNumber <>0



SELECT t.[Invoice date], t.[Trip Number], SUM(t.[Quantity Shipped]) as shipped_quantity, SUM(t.[Contract Price Amount]) AS contract_price_amount
FROM AFISales_DW.FactShippedHistory as t
where t.Warehouse = '335' and t.[invoice date] between '2025-05-04' and '2025-05-10'
Group by 
	t.[Invoice date],
	t.[Trip Number]

SELECT  TOP 10 *
FROM AFISales_DW.FactShippedHistory as t
where t.Warehouse = '335'
