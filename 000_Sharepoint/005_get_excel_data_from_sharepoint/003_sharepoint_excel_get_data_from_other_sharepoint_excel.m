let
// 连接到 SharePoint 文件
Source = SharePoint.Files("https://masterashley.sharepoint.com/sites/GlobalProcurement/", [ApiVersion = 15]),
    // 筛选指定文件夹及其子文件夹下的文件
    #"Filtered Folder" = Table.SelectRows(Source, each Text.StartsWith([Folder Path], "https://masterashley.sharepoint.com/sites/GlobalProcurement/Shared Documents/Ashton Warehouse/Logistics/")),
    // 仅筛选 .xlsx 文件
    #"Excel Files Only" = Table.SelectRows(#"Filtered Folder", each Text.EndsWith([Name], ".xlsx")),

    // 展开二进制内容
    #"Added Custom" = Table.AddColumn(#"Excel Files Only", "Excel Tables", each Excel.Workbook([Content])),

    // 展开 Excel 表格
    #"Expanded Excel Tables" = Table.ExpandTableColumn(#"Added Custom", "Excel Tables", {"Data", "Item", "Kind", "Hidden"}, {"Data", "Item", "Kind", "Hidden"}),

    // 仅保留名为 "DATA" 的工作表
    #"Filtered Sheets" = Table.SelectRows(#"Expanded Excel Tables", each [Item] = "MASTER SHEET"),

    // 展开数据内容 - 修正参数
    #"Expanded Data" = Table.ExpandTableColumn(#"Filtered Sheets", "Data", Table.ColumnNames(#"Filtered Sheets"[Data]{0})),

    // 添加源文件信息列
    #"Added Source Info" = Table.AddColumn(#"Expanded Data", "Source File", each [Name], type text),
    #"Added Folder Info" = Table.AddColumn(#"Added Source Info", "Source Folder", each [Folder Path], type text),
    #"Removed Other Columns1" = Table.SelectColumns(#"Added Folder Info",{"Column1", "Column2", "Column3", "Column4", "Column5", "Column6", "Column7", "Column8", "Column9", "Column10", "Column11", "Column12", "Column13", "Column14", "Column15", "Column16", "Column17", "Column18", "Column19", "Column20", "Column21", "Column22", "Column23", "Column24", "Column25", "Column26", "Column27", "Column28", "Column29", "Column30", "Column31", "Column32", "Column33", "Column34", "Column35", "Column36", "Column37", "Column38", "Column39", "Column40", "Column41", "Column42", "Column43", "Column44", "Column45"}),
    #"Promoted Headers" = Table.PromoteHeaders(#"Removed Other Columns1", [PromoteAllScalars=true]),
    #"Changed Type" = Table.TransformColumnTypes(#"Promoted Headers",{{"TRIP", Int64.Type}, {"Customer Number", Int64.Type}, {"Ship to", type any}, {"Customer name", type text}, {"Cntr Size", type any}, {"Inspect", type text}, {"Fum", type text}, {"Trip Type", type text}, {"POD", type text}, {"Destination", type text}, {"Trip Create Date", type date}, {"Load Date", type date}, {"CRM", type text}, {"Freight Forwarder", type text}, {"Carrier name", type text}, {"Phyto", type any}, {"Carton Qty", Int64.Type}, {"Booking Request Sending date", type date}, {"Booking Confirm receiving date", type datetime}, {"REASON OF#(lf)PENDING BOOKING", type text}, {"Forwarder Follow-up", type any}, {"Remark for booking status", type text}, {"BOOKING", type any}, {"Carrier name_1", type text}, {"Container No", type text}, {"Seal No", type any}, {"Tare weight", Int64.Type}, {"Vessel", type text}, {"WH dispatch date", type date}, {"Port #(lf)Cutoff", type datetime}, {"SI/VGM", type datetime}, {"ETD", type date}, {"ETA", type date}, {"TRUCKING COMPANY", type text}, {"MT TIME FRAME ARRIVAL  REQUESTED", type text}, {"Empty container pick up date/time", type datetime}, {"Empty container arrive to Ashton date/time", type datetime}, {"Full container earliest drop date", type datetime}, {"Full container latest drop date", type datetime}, {"Laden port", type text}, {"Free DET", Int64.Type}, {"Free DEM", Int64.Type}, {"ACTUAL TIME PLANNING TRIP DONE", type datetime}, {"PIC", type text}, {"BLOCK CODE", type text}})
in
    #"Changed Type"