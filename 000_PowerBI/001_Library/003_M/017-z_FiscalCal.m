// Ashley Fiscal Calendar
let
    Source = PowerBI.Dataflows(null),
    #"a47e4573-c455-40af-a9ad-e22c81a07926" = Source{[workspaceId="a47e4573-c455-40af-a9ad-e22c81a07926"]}[Data],
    #"346f2aa1-dd50-4c11-9630-b17f75854663" = #"a47e4573-c455-40af-a9ad-e22c81a07926"{[dataflowId="346f2aa1-dd50-4c11-9630-b17f75854663"]}[Data],
    AshleyFiscalCalendarV2 = #"346f2aa1-dd50-4c11-9630-b17f75854663"{[entity="AshleyFiscalCalendarV2"]}[Data],
    #"Changed Type" = Table.TransformColumnTypes(AshleyFiscalCalendarV2,{{"Transaction Date", type date}, {"Fiscal Month (calendar start)", type date}, {"Fiscal Year Start", type date}, {"Fiscal Year End", type date}, {"Fiscal Month Start", type date}, {"Fiscal Month End", type date}, {"Fiscal Week Start", type date}, {"Fiscal Week End", type date}})
in
    #"Changed Type"