let
    BaseUrl = "https://masterashley.sharepoint.com/sites/AsiaWarehouseOperations/",
    FolderPath = BaseUrl & "Shared Documents/WANEK 3/DirectFulfillment/CS_BOOKING/",

    Source = SharePoint.Files(BaseUrl, [ApiVersion = 15]),

    TargetFile = Table.SelectRows(Source, each [Folder Path] = FolderPath and [Name] = "CS_BOOKING.xlsx"),

    Sheet1Data = Table.SelectRows(
                    Table.ExpandTableColumn(
                        Table.AddColumn(TargetFile, "wb", each Excel.Workbook([Content])),
                        "wb", {"Data","Item"}, {"Data","Item"}
                    ),
                    each [Item] = "Sheet1")[Data]{0},
    #"Promoted Headers" = Table.PromoteHeaders(Sheet1Data, [PromoteAllScalars=true]),
    #"Changed Type" = Table.TransformColumnTypes(#"Promoted Headers",{{"WH", type text}, {"CUST PO", type any}, {"Ashley_PO        ", type text}, {"Wanek ETD", type date}, {"Cargo Ready Date", type date}, {"Customer", type text}, {"Booking#", type any}, {"Vessel Date", type date}, {"Pick Up", type date}, {"Closing Time", type any}, {"New load", Int64.Type}, {"QTY", Int64.Type}, {"Remark", type text}, {"Port Of Discharge", type text}, {"Place of delivery", type text}, {"s", Int64.Type}, {"Container Size", type text}, {"Ship Via", type text}, {"Load location", type text}, {"CARRIER", type text}, {"CO STATUS", type text}, {"Booking Submit Date", type date}, {"Booking Received", type date}, {"Note for Doc", type date}, {"Booking ref number", type text}, {"Booking Status", type text}, {"sum1", Int64.Type}, {"sum2", Int64.Type}, {"check", type text}, {"Date US Uploaded", type text}, {"Copy to US Uploading file", type text}}),
    #"Filtered Rows" = Table.SelectRows(#"Changed Type", each true)
in
    #"Filtered Rows"