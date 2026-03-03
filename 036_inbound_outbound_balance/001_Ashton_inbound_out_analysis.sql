 with itm as (
    select 
        trim(a.itnbr) as item_number, 
        a.itcls as item_class, 
        b.pickput as pickput_id, 
        b.ITMCLSID as putaway_class, 
        a.B2Z95S as unit_cube,
        case 
            when a.itcls not like 'Z%' then 'RP'
            when b.pickput = 'UPH' then 'UPH'
            when b.ITMCLSID like 'RUG%' then 'RUGS'
            when b.ITMCLSID like 'FLO%' then 'BULK'
            ELSE 'CG' 
        END as product 
    from (select * from MasterData_ItemMaster_AFI.ITMRVA where stid = '335' ) as a
    left join (SELECT * FROM MasterData_ItemMaster_AFI.ITBEXT  WHERE HOUSE = '335') as b 
        on b.itnbr = a.itnbr and a.stid = b.house
    where a.itcls like 'Z%' and a.itcls not like 'Z%K'
),
-- Logistics planned order fulfillment
sp as 
(
    SELECT *
    FROM Wholesale_DemandPlanning_AFI.SupplyPlanDetail AS  T1
    where t1.spdWarehouse = '335'
    and dtec = (select max(dtec) from Wholesale_DemandPlanning_AFI.SupplyPlanDetail)
)
select sp.*, itm.item_class, itm.pickput_id, itm.putaway_class, itm.unit_cube, itm.product
from sp
left join itm on sp.spdItem = itm.item_number
order by sp.spdWeekEnding 

