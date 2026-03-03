
 
 -- Logistics planned order fulfillment
select * 
from Wholesale_DemandPlanning_AFI.SupplyPlanDetail 
where 1=1 
	and spdWarehouse = '335' 
	and spdItem = '1030125'
	and dtec = (select max(dtec) from Wholesale_DemandPlanning_AFI.SupplyPlanDetail)
order by spdWeekEnding 
