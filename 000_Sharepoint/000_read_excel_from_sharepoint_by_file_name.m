let
    BaseUrl = "https://masterashley.sharepoint.com/sites/AsiaWarehouseOperations/MIL/",
    FolderPath = BaseUrl & "Shared Documents/picking location/",

    Source = SharePoint.Files(BaseUrl, [ApiVersion = 15]),

    TargetFile = Table.SelectRows(Source, each [Folder Path] = FolderPath and [Name] = "Picking location.xlsx"),

    Sheet1Data = Table.SelectRows(
                    Table.ExpandTableColumn(
                        Table.AddColumn(TargetFile, "wb", each Excel.Workbook([Content])),
                        "wb", {"Data","Item"}, {"Data","Item"}
                    ),
                    each [Item] = "Sheet1")[Data]{0},

    Result = Table.SelectColumns(
                Table.PromoteHeaders(Sheet1Data, [PromoteAllScalars=true]),
                {"LOCATION", "Building"})
in
    Result