SELECT t.WhID as [Wh Id],
    t.DispatchDate as [Dispatch Date],
    t.ItemNumber as [Item Number],
--     CAST(LEFT(t.TripNumber, CHARINDEX('-', t.TripNumber) - 1) AS INT) as [Trip Number],
   t.TripNumber as [Trip Number],
    t.LdmStatus,
    t.TripNeeded as [Trip Needed],
    t.TripPicked as [Trip Picked],
    t.AvailableSto as [Available Sto],
    t.AvailableStaged AS [Available Staged],
    t.StageQty as [Stage Qty],
    t.NoReceivedQty as [No Received Qty],
    t.YardQty as [Yard Qty],
    t.NewAsnQty as [New Asn Qty],
    t.EarliestDate as [Earliest Date],
    t.NegativeQty as [Negative Qty],
    t.NegativeTot as [Negative Tot],
    t.MFGScheduleQty as [MFG Schedule Qty],
    t.OverflowQty as [Overflow Qty],
    t.OffsiteQty as [Offsite Qty],
    t.Carrier,
    t.InTransit as [In Transit],
    t.ProdQty as [Prod Qty],
    t.LocationId as [Location Id],
    (SELECT TOP 1 t2.tpkModified
     FROM dw_developer.tabledictionary t2
     WHERE t2.tpktablename = 'TripAvailableSTO') AS refreshed_time
FROM Distribution_Warehouse_Wholesale.TripAvailableSTO as t
where     t.SearchType = 'All Items'
     AND t.WhID = '335'
order by t.ItemNumber, t.DispatchDate , t.TripNumber


SELECT t.WhID as [Wh Id],
    t.DispatchDate as [Dispatch Date],
    t.ItemNumber as [Item Number],
--     CAST(LEFT(t.TripNumber, CHARINDEX('-', t.TripNumber) - 1) AS INT) as [Trip Number],
   t.TripNumber as [Trip Number],
    t.LdmStatus,
    t.TripNeeded as [Trip Needed],
    t.TripPicked as [Trip Picked],
    t.AvailableSto as [Available Sto],
    t.AvailableStaged AS [Available Staged],
    t.StageQty as [Stage Qty],
    t.NoReceivedQty as [No Received Qty],
    t.YardQty as [Yard Qty],
    t.NewAsnQty as [New Asn Qty],
    t.EarliestDate as [Earliest Date],
    t.NegativeQty as [Negative Qty],
    t.NegativeTot as [Negative Tot],
    t.MFGScheduleQty as [MFG Schedule Qty],
    t.OverflowQty as [Overflow Qty],
    t.OffsiteQty as [Offsite Qty],
    t.Carrier,
    t.InTransit as [In Transit],
    t.ProdQty as [Prod Qty],
    t.LocationId as [Location Id],
    (SELECT TOP 1 t2.tpkModified
     FROM dw_developer.tabledictionary t2
     WHERE t2.tpktablename = 'TripAvailableSTO') AS refreshed_time
FROM Distribution_Warehouse_Wholesale.TripAvailableSTO as t
where t.SearchType = 'All Items'
    and t.WhID = '335'
order by t.ItemNumber, t.DispatchDate, t.TripNumber



