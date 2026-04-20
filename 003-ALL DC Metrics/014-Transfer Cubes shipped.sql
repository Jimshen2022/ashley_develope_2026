Select
	  shippedtransfers.[From Warehouse]
	  ,shippedtransfers.[Trailer ID]
	  ,shippedtransfers.[Week Ending Date]
	  ,sum([QTY]) AS [QTY Shipped]
	  ,sum([Total Cubes]) AS [Shipped Cubes]
	  ,case when sum([Total Cubes])<'1700' or sum([Total Cubes])>'3750' then 'No' else 'Yes' end as [threshold]

From(SELECT [TTRIP#] AS [Trip Number]
      ,[TITNBR] AS [Item Number]
      ,[TTFRNO] AS [Transfer Number]
      ,[TFWHSE] AS [From Warehouse]
      ,[TTWHSE] AS [To Warehouse]
      ,[TEQUIP] AS [Trailer ID]
      ,[TSHPQT] AS [QTY]
      ,convert(date,convert(varchar(8),[TSHPDT])) AS [Shipped Date]
	  ,items.[CUBES]
	  ,items.[CUBES]*[TSHPQT] AS [Total Cubes]
	  ,dateadd(day,6,dateadd(week,datediff(week,-1,convert(date,convert(varchar(8),[TSHPDT]))),-1)) AS [Week Ending Date]
FROM [PowerBI_Distribution].[TODETL] transfers
  left join [PowerBI_Wholesale].[ITMEXT] items
  on transfers.titnbr=items.ITNBR
  left join [PowerBI_Distribution].[ITEMASA] class
  on transfers.titnbr=class.ITNBR
  where class.[ITCLS] like 'z%'
 and class.[ITCLS] not like '%k'
 and convert(date,convert(varchar(8),[TSHPDT]))> DATEADD(DAY, -60, GETDATE())
 --and [tequip]='HGIU509523'
-- order by [TSHPDT] asc
 )shippedtransfers
 Group by
 	  shippedtransfers.[From Warehouse]
	  ,shippedtransfers.[Trailer ID]
	  ,shippedtransfers.[Week Ending Date]
order by [Shipped Cubes] asc