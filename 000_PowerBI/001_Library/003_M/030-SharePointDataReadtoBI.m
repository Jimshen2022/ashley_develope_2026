let
    Source = SharePoint.Files("https://masterashley.sharepoint.com/sites/AsiaWarehouseOperations/", [ApiVersion = 15]),
    #"Filtered Rows" = Table.SelectRows(Source, each ([Extension] = ".xlsx") and ([Name] = "MIL Inventory Age Details.xlsx")),
    Custom1 = #"Filtered Rows"{[Name="MIL Inventory Age Details.xlsx",#"Folder Path"="https://masterashley.sharepoint.com/sites/AsiaWarehouseOperations/Shared Documents/Millennium/Inventory/"]}[Content],
    #"Imported Excel Workbook" = Excel.Workbook(Custom1),
    #"Filtered Rows1" = Table.SelectRows(#"Imported Excel Workbook", each ([Name] = "Export")),
    #"Removed Other Columns" = Table.SelectColumns(#"Filtered Rows1",{"Data"}),
    #"Expanded Data" = Table.ExpandTableColumn(#"Removed Other Columns", "Data", {"Column1", "Column2", "Column3", "Column4", "Column5", "Column6", "Column7", "Column8", "Column9", "Column10", "Column11", "Column12"}, {"Column1", "Column2", "Column3", "Column4", "Column5", "Column6", "Column7", "Column8", "Column9", "Column10", "Column11", "Column12"}),
    #"Promoted Headers" = Table.PromoteHeaders(#"Expanded Data", [PromoteAllScalars=true]),
    #"Changed Type" = Table.TransformColumnTypes(#"Promoted Headers",{{"Whse ID", type text}, {"Inv. Age Days Range", type text}, {"Product Type", type text}, {"Pur comment", type text}, {"Item Number", type text}, {"Item Class", type text}, {"Item Descripiton", type text}, {"On Hand", type number}, {"Inventory Age (Days)", Int64.Type}, {"Next 70 Days Demand", Int64.Type}, {"Balance", type number}, {"Balance_Type", type text}}),
    #"Trimmed Text" = Table.TransformColumns(#"Changed Type",{{"Item Number", Text.Trim, type text}})
in
    #"Trimmed Text"