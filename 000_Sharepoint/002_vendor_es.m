let
    BaseUrl = "https://masterashley.sharepoint.com/sites/AsiaWarehouseOperations/",
    FolderPath = BaseUrl & "Shared Documents/Ashton/Four Box/Inventory/",

    Source = SharePoint.Files(BaseUrl, [ApiVersion = 15]),

    TargetFile = Table.SelectRows(Source, each [Folder Path] = FolderPath and [Name] = "Ashton_Damaged_List - 2024.xlsx"),

    Sheet1Data = Table.SelectRows(
                    Table.ExpandTableColumn(
                        Table.AddColumn(TargetFile, "wb", each Excel.Workbook([Content])),
                        "wb", {"Data","Item"}, {"Data","Item"}
                    ),
                    each [Item] = "Vendor_Over_Short_Shipment")[Data]{0},

    // 移除了 Table.SelectColumns，直接提升表头并保留所有列
    Result = Table.PromoteHeaders(Sheet1Data, [PromoteAllScalars=true]),
    #"Removed Other Columns" = Table.SelectColumns(Result,{"Infor date", "Serial Number", "Qty", "Location", "Item", "PO#", "Vendor", "Product", "Type", "CS replied", "CS Estimated Due Date", "Status"}),
    #"Changed Type1" = Table.TransformColumnTypes(#"Removed Other Columns",{{"Infor date", type date}, {"Serial Number", type text}, {"Qty", Int64.Type}, {"Item", type text}, {"CS Estimated Due Date", type text}}),
    #"Trimmed Text" = Table.TransformColumns(#"Changed Type1",{{"Serial Number", Text.Trim, type text}})
in
    #"Trimmed Text"