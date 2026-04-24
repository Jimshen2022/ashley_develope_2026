let
    // 连接到 SharePoint 文件
     Source = SharePoint.Files("https://masterashley.sharepoint.com/sites/AsiaWarehouseOperations/", [ApiVersion = 15]),

    // 筛选指定文件夹及其子文件夹下的文件
    #"Filtered Folder" = Table.SelectRows(Source, each Text.StartsWith([Folder Path], "https://masterashley.sharepoint.com/sites/AsiaWarehouseOperations/Shared Documents/Ashton/Four Box/Shipping/ashton_receiving_loading_by_hour/")),

    // 仅筛选 .xlsx 文件
    #"Excel Files Only" = Table.SelectRows(#"Filtered Folder", each Text.EndsWith([Name], ".xlsx")),

    // 展开二进制内容
    #"Added Custom" = Table.AddColumn(#"Excel Files Only", "Excel Tables", each Excel.Workbook([Content])),

    // 展开 Excel 表格
    #"Expanded Excel Tables" = Table.ExpandTableColumn(#"Added Custom", "Excel Tables", {"Data", "Item", "Kind", "Hidden"}, {"Data", "Item", "Kind", "Hidden"}),

    // 仅保留名为 "DATA" 的工作表
    #"Filtered Sheets" = Table.SelectRows(#"Expanded Excel Tables", each [Item] = "Sheet1"),
    #"Removed Other Columns1" = Table.SelectColumns(#"Filtered Sheets",{"Data"}),

    // 展开数据内容 - 修正参数
    #"Expanded Data" = Table.ExpandTableColumn(#"Removed Other Columns1", "Data", Table.ColumnNames(#"Removed Other Columns1"[Data]{0})),
    #"Promoted Headers" = Table.PromoteHeaders(#"Expanded Data", [PromoteAllScalars=true]),
    #"Changed Type" = Table.TransformColumnTypes(#"Promoted Headers",{{"Shift", type text}, {"Product", type text}, {"Plan Hour", Int64.Type}, {"Pieces/Hour", Int64.Type}, {"Planned Qty", Int64.Type}})
in
    #"Changed Type"