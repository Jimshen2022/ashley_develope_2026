let
    Source = SharePoint.Files("https://masterashley.sharepoint.com/sites/AsiaWarehouseOperations/", [ApiVersion = 15]),
    #"Filtered Rows" = Table.SelectRows(Source, each ([Extension] = ".xlsx") and ([Name] = "Ashton_Damaged_List - 2024.xlsx")),
    Custom1 = #"Filtered Rows"{[Name="Ashton_Damaged_List - 2024.xlsx",#"Folder Path"="https://masterashley.sharepoint.com/sites/AsiaWarehouseOperations/Shared Documents/Ashton/Four Box/Inventory/"]}[Content],
    #"Imported Excel Workbook" = Excel.Workbook(Custom1),
    #"Filtered Rows1" = Table.SelectRows(#"Imported Excel Workbook", each ([Name] = "Damaged_Defect")),
    #"Removed Columns" = Table.RemoveColumns(#"Filtered Rows1",{"Name"}),
    #"Expanded Data" = Table.ExpandTableColumn(#"Removed Columns", "Data", {"Column1", "Column2", "Column3", "Column4", "Column5", "Column6", "Column7", "Column8", "Column9", "Column10", "Column11", "Column12", "Column13", "Column14", "Column15", "Column16"}, {"Data.Column1", "Data.Column2", "Data.Column3", "Data.Column4", "Data.Column5", "Data.Column6", "Data.Column7", "Data.Column8", "Data.Column9", "Data.Column10", "Data.Column11", "Data.Column12", "Data.Column13", "Data.Column14","Data.Column15","Data.Column16"}),
    #"Promoted Headers" = Table.PromoteHeaders(#"Expanded Data", [PromoteAllScalars=true]),
    #"Changed Type1" = Table.TransformColumnTypes(#"Promoted Headers",{{"Qty", Int64.Type}}),
    #"Changed Type" = Table.TransformColumnTypes(#"Changed Type1",{{"Infor date", type date}, {"Serial Number", type text}, {"Location", type text}, {"ITEM", type text}, {"Master MO/PO", type text}, {"Vendor", type text}, {"Issue from", type text}, {"Damaged Description", type text}, {"Product", type text}, {"Reason", type text}, {"Damaged by", type text}, {"Whse deal with status", type text}, {"CS replied", type text}, {"CS Estimated Due Date", type any}}),
    #"Filtered Rows2" = Table.SelectRows(#"Changed Type", each ([ITEM] <> null))
    // #"Removed Other Columns" = Table.SelectColumns(#"Filtered Rows1",{"Data"}),
    // #"Expanded Data" = Table.ExpandTableColumn(#"Removed Other Columns", "Data", {"Column1", "Column2", "Column3", "Column4", "Column5", "Column6", "Column7", "Column8", "Column9", "Column10", "Column11", "Column12", "Column13", "Column14", "Column15", "Column16"}, {"Column1", "Column2", "Column3", "Column4", "Column5", "Column6", "Column7", "Column8", "Column9", "Column10", "Column11", "Column12", "Column13", "Column14", "Column15", "Column16"}),
    // #"Promoted Headers" = Table.PromoteHeaders(#"Expanded Data", [PromoteAllScalars=true]),
    // #"Changed Type" = Table.TransformColumnTypes(#"Promoted Headers",{{"Whse ID", Int64.Type}, {"Inv. Age Days Range", type text}, {"Product Type", type text}, {"Item Number", type text}, {"Item Class", type text}, {"Item Descripiton", type text}, {"On Hand", type number}, {"Inventory Age (Days)", Int64.Type}, {"Next 70 Days Demand", Int64.Type}, {"Balance", type number}, {"Balance_Type", type text}, {"PUR (Jade)", type text}, {"CS (Ho, Mike)", type any}, {"IE (Le Bryan)", type any}, {"Owner", type any}, {"DueDate", type any}}),
    // #"Trimmed Text" = Table.TransformColumns(#"Changed Type",{{"Item Number", Text.Trim, type text}})
in
    // #"Trimmed Text"
        #"Filtered Rows2"