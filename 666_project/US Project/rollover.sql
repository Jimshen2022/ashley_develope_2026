select top 10 *   FROM [SupplyChain_Enh].[PSWWeeklyExtractSnapshot] PSW
select top 10 *   FROM [PowerBI_SupplyChain].[CurrentProductDetails] 

SELECT PSW.[Item]
      ,CPD.[Collective Class]
      ,CPD.[Product Line]
      ,PSW.[Whse]
      ,PSW.[Vendor]
      ,PSW.[WeekNum]
      ,PSW.[ITDESC]
      ,PSW.[VNAME]
      ,cast(PSW.[SQty] as int) as Ship_Qty
      ,cast(PSW.[FQty] as int) as Firm_Qty
      ,cast(PSW.[PQty] as int) as Plan_Qty
      ,cast(PSW.[SPRunDate] as date) as Snapshot_Date
      ,DD.[CalendarWeekIndicator]
      ,DD.[CalendarDayOfWeekName]
      ,CASE
            WHEN PSW.[Vendor] = '900639' THEN 'Wanek 2'
            WHEN PSW.[Vendor] = '600039' THEN 'Wanek 3'
            WHEN PSW.[Vendor] = '900515' THEN 'Wanek 4'
            WHEN PSW.[Vendor] = '624556' THEN 'Millennium'
       END AS Facility
 
  FROM [SupplyChain_Enh].[PSWWeeklyExtractSnapshot] PSW
 
 
LEFT JOIN [Enterprise_DW].[DimDate] DD ON DD.[DateID] = [SPRunDate]
LEFT JOIN [PowerBI_SupplyChain].[CurrentProductDetails] CPD ON PSW.[Item] = CPD.[Item SKU]		
 
where PSW.[Vendor] in ('600039','900515','900639', '624556')
  and PSW.[WeekNum] = 0 
  --and DD.[CalendarWeekIndicator] between -1 and 0
  --and DD.[CalendarDayOfWeekName] = 'Saturday'
  and CPD.[Collective Class] is not null
  and PSW.[SQty] + PSW.[FQty] + PSW.[PQty] > 0
  and FORMAT(PSW.[SPRunDate], 'yyyy-MM-dd') = format(getdate(),'yyyy-MM-dd')