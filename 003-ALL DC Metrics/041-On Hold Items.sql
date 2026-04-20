Select
details.whs
--,details.[date added]
,sum(details.[qty on hold]) as [Total Units on Hold]
,sum(details.[holding transfer qty]) AS [Total Units on Holding Transfer]
From(
Select onhold.ItemNumber AS [Item #],
       QtyOnHand AS [Qty On Hand],
       QtyOnHold AS [Qty On Hold],
       QtyNotOnHold AS [Qty Not On Hold],
       TotalDemand AS [Total Demand],
       ActiveDeficiency AS [Active Deficiency],
       RoutedDeficiency AS [Routed Deficiency],
       UnRoutedDeficiency AS [Unrouted Deficiency],
       WhID AS [Whs],
       DateAdded AS [Date Added],
	   DATEDIFF(DAY, DateAdded, GETDATE()) AS [Days Over 24 Hr Commitment],
	   trans.ItemClass AS [Item Class],
		trans.[Holding Transfer Qty],
		trans.[Count of HT],
		trans.[Min Shipment Date],
		trans.[Max Shipment Date],
		trans.[Min Delivery Date],
		trans.[Holding Transfer In Place (Y/N)]
FROM [PowerBI_Distribution].[OnHoldDemandDeficiency] onhold
	LEFT JOIN 
	(
		SELECT 
			header.FromWarehouse
			,CASE WHEN header.transfernumber LIKE 'HT%' THEN 'Y' ELSE NULL END AS [Holding Transfer In Place (Y/N)]
			,MIN(header.ShipmentDate) AS [Min Shipment Date]
			,MAX(header.ShipmentDate) AS [Max Shipment Date]
			,MIN(header.DeliveryDate) AS [Min Delivery Date]
			,detail.ItemNumber
			,detail.ItemClass
			,COUNT(DISTINCT(header.TransferNumber)) AS [Count of HT]
			,SUM(detail.TransferQty) AS [Holding Transfer Qty]
		FROM PowerBI_ADS.TFRHDR header
			LEFT JOIN PowerBI_ADS.TFRDTL detail
				ON detail.TransferNumber = header.TransferNumber
		WHERE header.TransferNumber LIKE 'HT%' AND header.ToWarehouse = header.FromWarehouse --AND header.FromWarehouse = '17' AND ItemNumber = 'M8X332'--AND header.TransferNumber LIKE 'HT828617'
		GROUP BY  header.fromwarehouse, detail.ItemNumber, detail.ItemClass, CASE WHEN header.transfernumber LIKE 'HT%' THEN 'Y' ELSE NULL END
	) trans
		ON onhold.itemnumber = trans.itemnumber AND onhold.WhID = trans.fromwarehouse)details
		group by
		details.whs
        --,details.[date added]