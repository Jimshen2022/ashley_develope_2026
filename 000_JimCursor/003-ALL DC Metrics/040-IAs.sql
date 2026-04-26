Select
details.[warehouse]
,details.[transaction date]
,sum(details.[adjustment cost]) as [Total IA $]

From (
SELECT   [Warehouse]
      ,[BatchNumber]
      ,[WorkstationID]
      ,[TransactionCode]
      ,[ItemNumber]
      --,[UpdateTime]
      ,[TransactionQuantity]
	  ,[CurrentSTPCost]
      ,[TransactionAmount]
	  ,case when [CurrentSTPCost]='0' then [transactionquantity]*b.[UCDEF] else [transactionquantity]*[CurrentSTPCost] end as [Adjustment Cost]
      ,cast([TransactionDate] as date) AS [Transaction Date]
      ,[ReversalCode]
      ,[PreviousSTPCost]
      ,[EntryUnitOfMeasure]
      ,[VendorNumber]
      ,[ReferenceNumber]
      ,[BatchType]
      ,[LastDateAffectQtyOnHand]
      ,[InventoryFlag]
      ,[SalesAnalysisFlag]
      ,[ReasonCode]
      ,[AverageUnitCost]
      ,[QualityControlFlag]
      ,[FIFODate]
	  ,[previousquantityonhand]
	  ,[newquantityonhand]
      --,[PostedTimestamp]
	  --,b.UCDEF*a.[TransactionQuantity]
	  ,c.AFIFinanceDivision
      ,c.AFISalesDivision
      ,c.ItemClassCode
      ,c.SellableItemFlag
	  ,c.itemgrouping
	  ,c.associationcode
  FROM [PowerBI_Distribution].[IMHIST] a
    left join [PowerBI_Distribution].[ITEMASA]b
    on a.[ItemNumber]=b.itnbr
	LEFT JOIN [PowerBI_Distribution].[Dimitemmaster] c
	on a.[ItemNumber] = c.ItemSKU
   where a.[TransactionCode] ='IA'
   and (a.[workstationid] not in ('ROBOTOPER','WSMFGDW','WSPICTRNTW') or a.[transactioncode]='IA')
   and (a.[workstationid] <> 'SYSLXARN' OR a.[TransactionCode] = 'IA')
   and b.itcls like 'Z%'
   and b.itcls not like '%k'
   and cast(a.transactiondate as date) BETWEEN DATEADD(day,-45,GETDATE()) AND GETDATE()
   and [warehouse] IN ('1','15','17','ECR','28','42','5','335')
   )details

   group by 
   details.[warehouse]
  ,details.[transaction date]