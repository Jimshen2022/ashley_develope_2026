let
    // 连接 SharePoint 并筛选目标文件夹内的最新 .xlsx 文件
    Source = SharePoint.Files("https://masterashley.sharepoint.com/sites/AsiaWarehouseOperations/", [ApiVersion = 15]),
    FilteredFolder = Table.SelectRows(Source, each Text.StartsWith([Folder Path], "https://masterashley.sharepoint.com/sites/AsiaWarehouseOperations/Shared Documents/Power BI Source Files/") and Text.EndsWith([Name], ".xlsx")),
    LatestFile = Table.SelectRows(FilteredFolder, each [Date created] = List.Max(FilteredFolder[Date created])),
    
    // 读取 Excel 内容并展开指定工作表
    ExcelData = Excel.Workbook(LatestFile{0}[Content]),
    SheetData = Table.SelectRows(ExcelData, each [Item] = "Sheet1"){0}[Data],
    
    // 设置列名并转换数据类型
    #"Promoted Headers" = Table.PromoteHeaders(SheetData, [PromoteAllScalars = true]),
    #"Changed Type" = Table.TransformColumnTypes(#"Promoted Headers",{{"Goal", Int64.Type}})
in
    #"Changed Type"