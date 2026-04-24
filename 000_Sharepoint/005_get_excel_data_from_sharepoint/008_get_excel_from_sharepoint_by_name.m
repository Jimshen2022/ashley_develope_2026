let
    // 1. 在这里输入你要抓取的指定文件名（请确保包含 .xlsx 后缀）
    TargetFileName = "Fct_DCs.xlsx",

    // 2. 连接 SharePoint
    Source = SharePoint.Files("https://masterashley.sharepoint.com/sites/AsiaWarehouseOperations/", [ApiVersion = 15]),

    // 3. 筛选目标文件夹，并精确匹配指定的文件名
    TargetFile = Table.SelectRows(Source, each Text.StartsWith([Folder Path], "https://masterashley.sharepoint.com/sites/AsiaWarehouseOperations/Shared Documents/powerbiprojects/NetworkLaborPlanning/") and [Name] = TargetFileName),

    // 4. 读取 Excel 内容并展开指定工作表 (获取筛选结果的第一行内容的Content)
    ExcelData = Excel.Workbook(TargetFile{0}[Content]),

    // 5. 获取 Sheet1 的数据（如果你的工作表名字不是Sheet1，请在这里修改）
    SheetData = Table.SelectRows(ExcelData, each [Item] = "Sheet1"){0}[Data],

    // 6. 将第一行提升为列名
    #"Promoted Headers" = Table.PromoteHeaders(SheetData, [PromoteAllScalars = true])
in
    #"Promoted Headers"