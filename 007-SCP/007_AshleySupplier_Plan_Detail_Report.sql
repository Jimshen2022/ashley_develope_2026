  -- Logistics planned order fulfillment
select * 
from Wholesale_DemandPlanning_AFI.SupplyPlanDetail 
where 1=1 
	and spdWarehouse = '335' 
	and spdItem = '100-17'
	and dtec = (select max(dtec) from Wholesale_DemandPlanning_AFI.SupplyPlanDetail)
order by spdWeekEnding 


-- get vendor shipped by Koha
select  *
from [SupplyChain_Enh].[PSWWeeklyExtractSnapshot] as t1
WHERE t1.whse = '335'
  --and t1.Sqty > 0
  and t1.Item = '1030125'
  and t1.SPRunDate = (select max(SPRunDate) from [SupplyChain_Enh].[PSWWeeklyExtractSnapshot])

