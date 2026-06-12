SELECT DISTINCT
    spd.spdItem,
    spd.spdWarehouse,
    itp.[Collective class],
    itp.[Item Class Code],
    itp.[AFI Finance Division],
    itp.[AFI Sales Category]
FROM Wholesale_DemandPlanning_AFI.SupplyPlanDetail AS spd 
    LEFT JOIN PowerBI_SupplyChain.ITPItemMaster AS itp
        ON spd.spditem = itp.[Item SKU]
WHERE spd.spdWarehouse = '335'
ORDER BY spd.spdItem;
