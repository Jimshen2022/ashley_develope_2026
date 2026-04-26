/****** Load Audit by Shift  ******/
SELECT  
	   e.[Fiscal Year] as Year
	  ,e.[Fiscal Week Ended] as [W/E]
	  ,e.[Fiscal Week] as Week
	  ,e.[Week Day] as Day
	  ,e.[WeekDayID] as Day_Nbr
	  ,min(case when Cast(a.[CreatedDate] as Time) >= '04:00:00.000' and Cast(a.[CreatedDate] as Time) < '14:30:00.000' then 1 else 2 end) as Shift
      ,a.[DocumentReference]
	  ,b.[Name]
	  ,case when CHARINDEX('Not Selected', b.[name]) > 0 then 1 else 0 End as 'Not Selected'
	  ,case when CHARINDEX('Passed', b.[name]) > 0 or CHARINDEX('Failed', b.[name]) > 0 then 1 else 0 End as 'Selected'
	  ,case when CHARINDEX('Passed', b.[name]) > 0 then 1 else 0 End as 'Passed'
	  ,case when CHARINDEX('Failed', b.[name]) > 0 then 1 else 0 End as 'Failed'
	  ,case when CHARINDEX('forced', a.[EvaluationResult]) > 0 then 1 Else 0 end as 'Forced Audit'
	  ,case when CHARINDEX('Held', b.[name]) > 0 or CHARINDEX('Progress', b.[name]) > 0 then 1 else 0 End as 'Pending'
      ,a.[InspectionDate]
      ,a.[CreatedDate]
      ,a.[EvaluationResult]
      ,a.[InspectedByFirstName]
      ,a.[InspectedByLastName]
  FROM [Distribution_Warehouse_Wholesale].[InspectionItem] a
  LEFT JOIN [Distribution_Warehouse_Wholesale].[InspectionStatus] b on a.wh_id = b.wh_id and a.InspectionStatus = b.ID
  Left join [Distribution_DW].[DimDateFile] e on cast (a.[createddate] as date)= cast (e.[Transaction Date] as date)
  where a.wh_id = '28' and a.createdDate >= '2021-01-01 00:00:01.000'
  Group by e.[Fiscal Year]
	  ,e.[Fiscal Week Ended]
	  ,e.[Fiscal Week]
	  ,e.[Week Day]
	  ,e.[WeekDayID]
	  ,a.[DocumentReference]
	  ,b.[Name]
      ,a.[InspectionDate]
	  ,a.[CreatedDate]
	  ,a.[EvaluationResult]
	  ,a.[InspectedByFirstName]
      ,a.[InspectedByLastName]