let
    Source = SharePoint.Files("https://masterashley.sharepoint.com/sites/AsiaWarehouseOperations/", [ApiVersion = 15]),
    #"Filtered Rows" = Table.SelectRows(Source, each ([Extension] = ".xlsx") and ([Name] = "Ashton Capacity.xlsx")),
    Custom1 = #"Filtered Rows"{[Name="Ashton Capacity.xlsx",#"Folder Path"="https://masterashley.sharepoint.com/sites/AsiaWarehouseOperations/Shared Documents/Ashton/Four Box/Inventory/whse_capacity/"]}[Content],
    #"Imported Excel Workbook" = Excel.Workbook(Custom1),
    #"Filtered Rows1" = Table.SelectRows(#"Imported Excel Workbook", each ([Name] = "F_Ashton_Locations")),
    #"Removed Columns" = Table.RemoveColumns(#"Filtered Rows1",{"Name"}),
    #"Removed Other Columns" = Table.SelectColumns(#"Removed Columns",{"Data"}),
    #"Expanded Data" = Table.ExpandTableColumn(#"Removed Other Columns", "Data", {"Column1", "Column2", "Column3", "Column4", "Column5", "Column6", "Column7", "Column8", "Column9", "Column10", "Column11", "Column12", "Column13", "Column14", "Column15", "Column16", "Column17", "Column18", "Column19", "Column20", "Column21", "Column22", "Column23", "Column24", "Column25", "Column26", "Column27", "Column28", "Column29", "Column30"}, {"Column1", "Column2", "Column3", "Column4", "Column5", "Column6", "Column7", "Column8", "Column9", "Column10", "Column11", "Column12", "Column13", "Column14", "Column15", "Column16", "Column17", "Column18", "Column19", "Column20", "Column21", "Column22", "Column23", "Column24", "Column25", "Column26", "Column27", "Column28", "Column29", "Column30"}),
    #"Promoted Headers" = Table.PromoteHeaders(#"Expanded Data", [PromoteAllScalars=true]),
    #"Changed Type" = Table.TransformColumnTypes(#"Promoted Headers",{{"Bay", Int64.Type}, {"67th", type text}, {"Side", type text}, {"6th", type text}, {"Aisle", Int64.Type}, {"Tier", Int64.Type}, {"Warehouse ID", Int64.Type}, {"Location ID", type text}, {"Type", type text}, {"Status", type text}, {"Picking Flow", Int64.Type}, {"Pick Area", type text}, {"Capacity Volume", Int64.Type}, {"Item Hu Indicator", type text}, {"Loc_Control_Value", type text}, {"Width", type number}, {"Height", type number}, {"Depth", type number}, {"Loc_CBM", type number}, {"Location Pallet Type", type text}, {"Location_Pallets_Capacity", Int64.Type}, {"Avg. Pieces/Pallet", Int64.Type}, {"Capacity(By Pieces)", Int64.Type}, {"Sub_Area_2", type text}, {"Sub_Area_1", type text}, {"Area", type text}, {"Area Avg.CBM/Pieces", type number}, {"Utilization", type number}, {"Capacity(By CBM)", Int64.Type}, {"Switch", type text}}),
    #"Trimmed Text" = Table.TransformColumns(#"Changed Type",{{"Location Pallet Type", Text.Trim, type text}}),
    #"Added Conditional Column" = Table.AddColumn(#"Trimmed Text", "Location_Pallets_CBM",
    each if [Sub_Area_2] = "CG - Rails"  then [Width]*[Depth]*[Height]
    else if [Location Pallet Type] = "No-Skid" and Text.StartsWith([Sub_Area_2], "UPH")  then [Width]*[Depth]*2.3  // UPH average stack hight 2.3m
    else if [Location Pallet Type] = "No-Skid" and [Sub_Area_2] ="CG - BulkStack"  and [Aisle] = 19 then [Width]*[Depth]*5   // stack 3 meters
    else if [Location Pallet Type] = "No-Skid" and [Sub_Area_2] ="CG - BulkStack"  and [Aisle] = 10 then [Width]*[Depth]*4   // stack 5 meters
    else if [Location Pallet Type] = "No-Skid" and [Sub_Area_2] ="CG - Rugs"  and [Aisle] = 18 then [Width]*[Depth]*1.524   // 1.524m height on iron plate
    else if [Location Pallet Type] = "5X8" and [Tier] = 1 then 5*8*4.92126*0.028317*[Location_Pallets_Capacity]    // 1.5m height
    else if [Location Pallet Type] = "5X8" and [Tier] = 2 then 5*8*3.51*0.028317*[Location_Pallets_Capacity]   // 1.07m height
    else if [Location Pallet Type] = "5X8" and [Tier] = 3 then 5*8*5*0.028317*[Location_Pallets_Capacity]   // 1.07m height
    else if [Location Pallet Type] = "5X8" and [Tier] = 4 then 5*8*5*0.028317*[Location_Pallets_Capacity]   // 1.07m height
    else if [Location Pallet Type] = "5X8" and [Tier] = 5 then 5*8*5*0.028317*[Location_Pallets_Capacity]   // 1.07m height
    else if [Location Pallet Type] = "5X7" then 5*7*5*0.028317*[Location_Pallets_Capacity]
    else if [Location Pallet Type] = "5X5" then 5*5*5*0.028317*[Location_Pallets_Capacity]
    else if [Location Pallet Type] = "3.5X7" then 3.5*7*5*0.028317*[Location_Pallets_Capacity]
    else if [Location Pallet Type] = "3.5X5" then 3.5*5*5*0.028317*[Location_Pallets_Capacity]
    else 0),
    #"Changed Type1" = Table.TransformColumnTypes(#"Added Conditional Column",{{"Location_Pallets_CBM", type number}}),
    #"Filtered Rows2" = Table.SelectRows(#"Changed Type1", each ([Loc_Control_Value] = "A")),
    #"Removed Columns1" = Table.RemoveColumns(#"Filtered Rows2",{"Utilization", "Capacity(By CBM)"})

in
   #"Removed Columns1"