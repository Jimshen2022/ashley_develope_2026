// WarehouseMaster (BI Dev Dataflow)
    // Source - PowerBI_SupplyChain.VendorMaster

let
    Source = PowerBI.Dataflows(null),
    #"a47e4573-c455-40af-a9ad-e22c81a07926" = Source{[workspaceId="a47e4573-c455-40af-a9ad-e22c81a07926"]}[Data],
    #"346f2aa1-dd50-4c11-9630-b17f75854663" = #"a47e4573-c455-40af-a9ad-e22c81a07926"{[dataflowId="346f2aa1-dd50-4c11-9630-b17f75854663"]}[Data],
    WarehouseMaster1 = #"346f2aa1-dd50-4c11-9630-b17f75854663"{[entity="WarehouseMaster"]}[Data]
in
    WarehouseMaster1