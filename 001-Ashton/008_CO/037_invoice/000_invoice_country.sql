--select top 10 * from CostAccounting_Enh.ShippedHistoryCubeData

select t.shcInvoiceNumber,
	t.shcInvoiceDate,
	t.shcWarehouse,
	t.shcTripNumber,
	t.shcCustomerNumber,
	t.shcShipToNumber,
	t.shcBusinessType,
	t.shcHomestoreFlag,
	t.shcBillToName,
	t.shcBillToCountry,
	t.shcShiptoCountry,
	Sum(t.shcGrossQuantityShipped) shcGrossQuantityShipped,
	Sum(t.shcGrossAmountShipped) shcGrossAmountShipped,
	Sum(t.shcNetQuantityShipped) shcNetQuantityShipped,
	Sum(t.shcNetAmountShipped) shcNetAmountShipped
from CostAccounting_Enh.ShippedHistoryCubeData t
where t.shcInvoiceDate >= '2024-01-01' and t.shcWarehouse = '335'
group by 
	t.shcInvoiceNumber,
	t.shcInvoiceDate,
	t.shcWarehouse,
	t.shcTripNumber,
	t.shcCustomerNumber,
	t.shcShipToNumber,
	t.shcBusinessType,
	t.shcHomestoreFlag,
	t.shcBillToName,
	t.shcBillToCountry,
	t.shcShiptoCountry

