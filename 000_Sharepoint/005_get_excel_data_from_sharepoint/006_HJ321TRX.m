let
    // 连接 SharePoint 并筛选目标文件夹内的最新 .xlsx 文件
    Source = SharePoint.Files("https://masterashley.sharepoint.com/sites/AsiaWarehouseOperations/", [ApiVersion = 15]),
    FilteredFolder = Table.SelectRows(Source, each Text.StartsWith([Folder Path], "https://masterashley.sharepoint.com/sites/AsiaWarehouseOperations/Shared Documents/Ashton/Four Box/Shipping/LoadingByHour/download_hj_322/") and Text.EndsWith([Name], ".xlsx")),
    LatestFile = Table.SelectRows(FilteredFolder, each [Date created] = List.Max(FilteredFolder[Date created])),
    
    // 读取 Excel 内容并展开指定工作表
    ExcelData = Excel.Workbook(LatestFile{0}[Content]),
    SheetData = Table.SelectRows(ExcelData, each [Item] = "Sheet1"){0}[Data],
    
    // 设置列名并转换数据类型
    #"Promoted Headers" = Table.PromoteHeaders(SheetData, [PromoteAllScalars = true]),
    #"Changed Type" = Table.TransformColumnTypes(#"Promoted Headers", {
        {"Item Number", type text}, {"Commodity Code", type text}, {"Pick Put ID", type text},
        {"Conversion Factor", Int64.Type}, {"Lot Number", type text}, {"Warehouse ID", Int64.Type},
        {"From Location ID", type text}, {"From Loc type", type text}, {"To Location ID", type text},
        {"To Loc Type", type text}, {"WA Order", type text}, {"Reference", type text}, 
        {"System Quantity", Int64.Type}, {"Transaction Quantity", Int64.Type}, {"License Plate", type any},
        {"Transaction Code", Int64.Type}, {"Description", type text}, {"Employee Name", type text}, 
        {"Supervisor", type text}, {"Date", type date}, {"Time In", type time}, {"Time Out", type time}, 
        {"Elapsed Time", Int64.Type}, {"Backorder Reason", type any}, {"Creation Transaction", type any}, 
        {"Pick Run ID", type any}, {"MO Number", type text}, {"Department", type text}, 
        {"Wh Id 2", type text}, {"Equipment Zone", type text}
    }),

    // 添加 Hour 列（提取 Time In 的小时部分并格式化为两位数）
    #"Added Hour Column" = Table.AddColumn(#"Changed Type", "Hour", each Text.PadStart(Text.From(Time.Hour([Time In])), 2, "0"), type text)
    
in
    #"Added Hour Column"