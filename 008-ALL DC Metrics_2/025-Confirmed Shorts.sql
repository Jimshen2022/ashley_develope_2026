Select
    shorts.warehouse
	,shorts.[date]
	,Sum(shorts.tran_qty) AS [Confirmed Shorts]
From
(
select a.Warehouse
     , a.[Date]
     , a.lot_number
     , a.tran_qty
from  (select c.Warehouse
     , cast(max(c.end_tran_date) as date) as [Date]
     , cast(max(c.end_tran_time) as time) as [Time]
     , c.[Invoice Number]
     , c.[Invoice Date]
     , c.[Item SKU]
     , c.Trip
     , c.lot_number
     , c.tran_qty
     , c.[Credit Date]
from
(
    select a.tran_type
         , b.Warehouse
         , a.end_tran_date
         , a.end_tran_time
         , b.[Invoice Number]
         , b.[Invoice Date]
         , b.[Item SKU]
	  , b.[Account And ShipTo Number]
         , b.[tran_qty]
         , b.[lot_number]
         , b.[Trip]
         , b.[Credit Date]
    from PowerBI_Distribution.TranLog a
        join
        (
            select b.[Credit Number]
                 , b.[Credit Date]
                 , b.[Invoice Number]
                 , b.[Invoice Date]
                 , b.[Trip]
                 , b.[OrderNumber]
                 , b.[Item SKU]
                 , c.[lot_number]
                 , c.tran_qty
                 , b.[Account And ShipTo Number]
                 , b.[Warehouse]
                 , b.[Vendor Number]
                 , b.[Short Ship Quantity]
                 , b.[Short Ship Amount]
            from
            (
                Select
                    [RowID]
                  , [Credit Number]
                  , [Credit Date]
                  , a.[Invoice Number]
                  , cast(b.[InvoiceDate] as date)      as [Date]
                  , case
                        when len(cast(b.TripNumber as varchar)) = 1 then
                            '000000' + cast(b.TripNumber as varchar)
                        when len(cast(b.TripNumber as varchar)) = 2 then
                            '00000' + cast(b.TripNumber as varchar)
                        when len(cast(b.TripNumber as varchar)) = 3 then
                            '0000' + cast(b.TripNumber as varchar)
                        when len(cast(b.TripNumber as varchar)) = 4 then
                            '000' + cast(b.TripNumber as varchar)
                        when len(cast(b.TripNumber as varchar)) = 5 then
                            '00' + cast(b.TripNumber as varchar)
                        when len(cast(b.TripNumber as varchar)) = 6 then
                            '0' + cast(b.TripNumber as varchar)
                        else
                            cast(b.TripNumber as varchar)
                    end                              as [Trip]
                  , a.[Invoice Date]
                  , b.[OrderNumber]
                  , [Scrap Code]
                  , [Item SKU]
                  , [Item Status]
                  , [Serial Number]
                  , a.[Shipto AddressID]
                  ,  a.[Warehouse]
                  , [Location Code]
                  , [Mfg Warehouse Code]
                  , [Vendor Number]
                  , a.[Account And ShipTo Number]
                  , [Total Quality Quantity]
                  , [Quality Credit Quantity]
                  , [Quality Credits]
                  , [Non-Quality Credit Quantity]
                  , [Non-Quality Credits]
                  , [Quality Return Quantity]
                  , [Quality Returns Amount]
                  , [Non-Quality Return Quantity]
                  , [Non-Quality Returns Amount]
                  , [Short Ship Quantity]
                  , [Short Ship Amount]
                  , [Allocated]
                  , [Scrap Code with CS Control Code]
                from [PowerBI_QTIL].[FactQualityCostHistory]                a
                    left join 
				(SELECT DISTINCT 
					InvoiceNumber
					,InvoiceDate
					,ItemNumber
					,OrderNumber
					,TripNumber 
				FROM [PowerBI_Finance].[invoicedetail]) b
                        on a.[Invoice Number] = b.InvoiceNumber
                           and a.[Invoice Date] = b.InvoiceDate
                           and a.[Item SKU] = b.ItemNumber
                where a.[Short Ship Quantity] > 0
                      and a.[Credit Date]
                      between dateadd(day, -90, getdate()) and getdate()
            )     b
                join
                (
                select a.wh_id
                      ,a.control_number_2
                      ,a.item_number
                      ,a.tran_qty
                      ,a.end_tran_date
                      ,a.lot_number
                      ,a.routing_code
                 from PowerBI_Distribution.TranLog a
                 where a.tran_type = '321'
                ) c
                    on b.Warehouse = c.wh_id
                       and b.[Item SKU] = c.item_number
                       and b.Trip = cast(left(control_number_2, 7) as varchar)
                       and cast(b.[Invoice Date] as date) = cast(c.end_tran_date as date)
                       and b.OrderNumber = c.routing_code
                )  b
                    on a.lot_number = b.lot_number
                 where a.end_tran_date > b.[Invoice Date]
) c
group by c.Warehouse
       , c.[Invoice Number]
       , c.[Invoice Date]
       , c.[Item SKU]
       , c.lot_number
       , c.Trip
       , c.tran_qty
       , c.[Credit Date]
	   )                            a
    left join
    (
        select lot_number
             , employee_id
             , a.wh_id
             , control_number_2
        from PowerBI_Distribution.TranLog a
        where tran_type = '321'
    )                                     b
        on a.Warehouse = b.wh_id
           and a.Trip = cast(left(b.control_number_2, 7) as varchar)
           and a.lot_number = b.lot_number
		   )shorts
		   left join
		       (SELECT Distinct
   [SerialNumber]
FROM PowerBI_ADS.RARETNFL
WHERE SUBSTRING(CAST([ReportDate] as varchar),1,4)  BETWEEN YEAR(GETDATE())-1 AND YEAR(GETDATE()) 
)ras
ON shorts.[lot_number] = ras.[SerialNumber]
where ras.[SerialNumber] is null
group by
    shorts.warehouse
	,shorts.[date]