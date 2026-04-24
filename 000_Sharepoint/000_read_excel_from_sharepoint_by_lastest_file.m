let
    BaseUrl = "https://masterashley.sharepoint.com/sites/AsiaWarehouseOperations/MIL/",
    FolderPath = BaseUrl & "Shared Documents/picking location/",

    Source = SharePoint.Files(BaseUrl, [ApiVersion = 15]),

    ExcelFiles = Table.SelectRows(Source, each 
        Text.StartsWith([Folder Path], FolderPath) and [Name] = "Picking location.xlsx"),

    LatestFile = Table.SelectRows(ExcelFiles, each 
        [Date created] = List.Max(ExcelFiles[Date created])),

    Sheet1Data = Table.SelectRows(
                    Table.ExpandTableColumn(
                        Table.AddColumn(LatestFile, "wb", each Excel.Workbook([Content])),
                        "wb", {"Data","Item"}, {"Data","Item"}
                    ),
                    each [Item] = "Sheet1")[Data]{0},

    Result = Table.SelectColumns(
                Table.PromoteHeaders(Sheet1Data, [PromoteAllScalars=true]),
                {"LOCATION", "Building"})
in
    Result