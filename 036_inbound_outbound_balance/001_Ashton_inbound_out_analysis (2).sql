    with itm as (
    select 
        trim(a.itnbr) as item_number, 
        a.itcls as item_class, 
        b.pickput as pickput_id, 
        b.ITMCLSID as putaway_class, 
        a.B2Z95S as unit_cube,
        coalesce(case 
                    when a.itcls not like 'Z%' then 'RP'
                    when b.pickput = 'UPH' then 'UPH'
                    when b.ITMCLSID like 'RUG%' then 'RUGS'
                    when b.ITMCLSID like 'FLO%' then 'BULK'
                    ELSE 'CG'
        END, 
        'CG') as product 
    from (select * from MasterData_ItemMaster_AFI.ITMRVA where stid = '335' ) as a
    left join (SELECT * FROM MasterData_ItemMaster_AFI.ITBEXT  WHERE HOUSE = '335') as b 
        on b.itnbr = a.itnbr and a.stid = b.house
    where a.itcls like 'Z%' and a.itcls not like 'Z%K'
),
sp as 
(
    SELECT *
    FROM Wholesale_DemandPlanning_AFI.SupplyPlanDetail AS  T1
    where t1.spdWarehouse = '335'
    and dtec = (select max(dtec) from Wholesale_DemandPlanning_AFI.SupplyPlanDetail)
)
select 
    sp.*,
    itm.item_class, 
    itm.pickput_id, 
    itm.putaway_class, 
    itm.unit_cube, 
    itm.product,
    -- Jim baseon fulfillment calculation request
    sp.spdFirmDemands as outbound,
    sp.spdFirmPurchaseOrders + sp.spdPlannedPurchaseOrders as inbound,
    --- 针对您提到的 spdBeginingBalance 及其后续字段补充计算 ---
    (sp.spdBeginingBalance * ISNULL(itm.unit_cube, 0)) as cube_BeginingBalance,
    (sp.spdFirmDemands * ISNULL(itm.unit_cube, 0)) as cube_FirmDemands,
    (sp.spdNetForecast * ISNULL(itm.unit_cube, 0)) as cube_NetForecast,
    (sp.spdFirmTransferOut * ISNULL(itm.unit_cube, 0)) as cube_FirmTransferOut,
    (sp.spdFirmProduction * ISNULL(itm.unit_cube, 0)) as cube_FirmProduction,
    (sp.spdFirmPurchaseOrders * ISNULL(itm.unit_cube, 0)) as cube_FirmPurchaseOrders,
    (sp.spdInTransitTransferIn * ISNULL(itm.unit_cube, 0)) as cube_InTransitTransferIn,
    (sp.spdOnOrderTransferIn * ISNULL(itm.unit_cube, 0)) as cube_OnOrderTransferIn,
    (sp.spdPlannedTransferIn * ISNULL(itm.unit_cube, 0)) as cube_PlannedTransferIn,
    (sp.spdPlannedTransferOut * ISNULL(itm.unit_cube, 0)) as cube_PlannedTransferOut,
    (sp.spdPlannedProduction * ISNULL(itm.unit_cube, 0)) as cube_PlannedProduction,
    (sp.spdPlannedPurchaseOrders * ISNULL(itm.unit_cube, 0)) as cube_PlannedPurchaseOrders,
    (sp.spdFirmDemands * ISNULL(itm.unit_cube, 0)) as cube_inbound,
    ((sp.spdFirmPurchaseOrders + sp.spdPlannedPurchaseOrders) * ISNULL(itm.unit_cube, 0)) as cube_outbound,
    -- 在之前的 SELECT 列表中添加这一行
(sp.spdShippableInventory * ISNULL(itm.unit_cube, 0)) as cube_ShippableInventory
from sp
left join itm on sp.spdItem = itm.item_number
order by sp.spdWeekEnding