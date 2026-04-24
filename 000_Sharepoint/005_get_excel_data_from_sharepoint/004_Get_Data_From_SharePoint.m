let
    // 连接到 SharePoint 文件
    Source = SharePoint.Files("https://masterashley.sharepoint.com/sites/AsiaWarehouseOperations/", [ApiVersion = 15]),
    
    // 筛选指定文件夹及其子文件夹下的文件
    #"Filtered Folder" = Table.SelectRows(Source, each Text.StartsWith([Folder Path], "https://masterashley.sharepoint.com/sites/AsiaWarehouseOperations/Shared Documents/Ashton/Four Box/Ashton_PPH/")),
    
    // 仅筛选 .xlsx 文件
    #"Excel Files Only" = Table.SelectRows(#"Filtered Folder", each Text.EndsWith([Name], ".xlsx")),
    
    // 展开二进制内容
    #"Added Custom" = Table.AddColumn(#"Excel Files Only", "Excel Tables", each Excel.Workbook([Content])),
    
    // 展开 Excel 表格
    #"Expanded Excel Tables" = Table.ExpandTableColumn(#"Added Custom", "Excel Tables", {"Data", "Item", "Kind", "Hidden"}, {"Data", "Item", "Kind", "Hidden"}),
    
    // 仅保留名为 "DATA" 的工作表
    #"Filtered Sheets" = Table.SelectRows(#"Expanded Excel Tables", each [Item] = "DATA"),
    
    // 展开数据内容 - 修正参数
    #"Expanded Data" = Table.ExpandTableColumn(#"Filtered Sheets", "Data", Table.ColumnNames(#"Filtered Sheets"[Data]{0})),
    
    // 添加源文件信息列
    #"Added Source Info" = Table.AddColumn(#"Expanded Data", "Source File", each [Name], type text),
    #"Added Folder Info" = Table.AddColumn(#"Added Source Info", "Source Folder", each [Folder Path], type text),
    #"Removed Other Columns" = Table.SelectColumns(#"Added Folder Info",{"Column1", "Column2", "Column3", "Column4", "Column5", "Column6", "Column7", "Column8", "Column9", "Column10", "Source File", "Source Folder"}),

// Add an index column for row manipulation
#"Added Index" = Table.AddIndexColumn(#"Removed Other Columns", "Row Index", 1, 1),
// Modify the first 5 rows of File Date to be a placeholder
#"Modified First 1 Rows Source File" = Table.AddColumn(
    #"Added Index", 
    "Source_File", 
    each if [Row Index] <= 1
        then "Source_File" 
        else Text.From([Source File]), 
    type text
),
    #"Modified First 1 Rows Source Folder" = Table.AddColumn(
    #"Modified First 1 Rows Source File", 
    "Source_Folder", 
    each if [Row Index] <= 1
        then "Source_Folder" 
        else Text.From([Source Folder]), 
    type text
),
    #"Removed Columns" = Table.RemoveColumns(#"Modified First 1 Rows Source Folder",{"Source File", "Source Folder", "Row Index"}),
    #"Promoted Headers" = Table.PromoteHeaders(#"Removed Columns", [PromoteAllScalars=true]),
    #"Changed Type" = Table.TransformColumnTypes(#"Promoted Headers",{{"Group", type text}, {"Date", type any}, {"Employee_ID", type any}, {"Name", type text}, {"Team", type any}, {"PPH_Type", type text}, {"Final_Hrs_All_In", type any}, {"Final_Hrs_Individual", type any}, {"Shift", type text}, {"Position", type text}, {"Source_Folder", type text}}),
    #"Filtered Rows" = Table.SelectRows(#"Changed Type", each ([Date] <> null and [Date] <> "Date")),
    
    // 将Date列转换为日期类型
    #"Changed Date Type" = Table.TransformColumnTypes(#"Filtered Rows",{{"Date", type date}}),
    
    // 筛选最近7天的数据
    #"Filtered Last 7 Days" = Table.SelectRows(#"Changed Date Type", 
        each [Date] >= Date.AddDays(Date.From(DateTime.LocalNow()), -7) and 
             [Date] <= Date.From(DateTime.LocalNow())),
    
    // 将Employee_ID转换为文本类型
    #"Changed Employee_ID Type" = Table.TransformColumnTypes(#"Filtered Last 7 Days",{{"Employee_ID", type text}}),
    
    // 格式化Employee_ID为5位字符，不足补0
    #"Formatted Employee_ID" = Table.TransformColumns(#"Changed Employee_ID Type", {
        {"Employee_ID", each if _ = null then null else Text.PadStart(Text.From(_), 5, "0")}
    }),
    #"Changed Type1" = Table.TransformColumnTypes(#"Formatted Employee_ID",{{"Employee_ID", type text}}),
    #"Removed Columns1" = Table.RemoveColumns(#"Changed Type1",{"Source_File", "Source_Folder"}),
    #"Added Custom1" = Table.AddColumn(
    #"Removed Columns1", 
    "HR_Total_Hrs", 
    each GetTotalHours(
        [Employee_ID],
        [Date])  // 或者使用你需要的日期格式
    ),
    #"Changed Type2" = Table.TransformColumnTypes(#"Added Custom1",{{"HR_Total_Hrs", type number}}),
    #"Added Custom2" = Table.AddColumn(#"Changed Type2", "HJ_Transaction_Pieces", each GetTotalPieces([Date],[Employee_ID],[PPH_Type])),
    #"Removed Columns2" = Table.RemoveColumns(#"Added Custom2",{"HJ_Transaction_Pieces"})
in
    #"Removed Columns2"