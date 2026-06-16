SELECT *
    FROM Wholesale_DemandPlanning_AFI.SupplyPlanDetail AS  T1
    where t1.spdWarehouse = '335'
    and dtec = (select max(dtec) from Wholesale_DemandPlanning_AFI.SupplyPlanDetail)