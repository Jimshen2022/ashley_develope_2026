let
    // ⬇️ 定义递归分配函数（最顶层）
    allocFunc = (needed as list, remain as number) as list =>
        if List.IsEmpty(needed) then
            {}
        else
            let
                currentNeed = needed{0},
                alloc = if remain >= currentNeed then currentNeed else (if remain > 0 then remain else 0),
                newRemain = remain - alloc,
                rest = @allocFunc(List.RemoveFirstN(needed, 1), newRemain)
            in
                {alloc} & rest,

    Source = PowerPlatform.Dataflows(null),
    Workspaces = Source{[Id="Workspaces"]}[Data],
    #"8edf7929-ae1a-4e4e-8b6a-f955dc7f1f4d" = Workspaces{[workspaceId="8edf7929-ae1a-4e4e-8b6a-f955dc7f1f4d"]}[Data],
    #"33ec429d-f728-400b-a1a8-c5b58be9cc8b" = #"8edf7929-ae1a-4e4e-8b6a-f955dc7f1f4d"{[dataflowId="33ec429d-f728-400b-a1a8-c5b58be9cc8b"]}[Data],
    TripAvailableSTO_ = #"33ec429d-f728-400b-a1a8-c5b58be9cc8b"{[entity="TripAvailableSTO",version=""]}[Data],


    // // 连接到 SharePoint 文件
    // Source = SharePoint.Files("https://masterashley.sharepoint.com/sites/AsiaWarehouseOperations/", [ApiVersion = 15]),

    // // 筛选指定文件夹及其子文件夹下的文件
    // #"Filtered Folder" = Table.SelectRows(Source, each Text.StartsWith([Folder Path], "https://masterashley.sharepoint.com/sites/AsiaWarehouseOperations/Shared Documents/Ashton/dowloaded_trip_available_report/")),

    // // 仅筛选 .xlsx 文件
    // #"Excel Files Only" = Table.SelectRows( #"Filtered Folder", each Text.EndsWith([Name], ".xlsx")),
    // // 仅保留 Date created 最大值的行
    // #"Filtered Latest File" = Table.SelectRows(#"Excel Files Only", each [Date created] = List.Max(#"Excel Files Only"[Date created])),

    // // 展开二进制内容
    // #"Added Custom" = Table.AddColumn(#"Filtered Latest File", "Excel Tables", each Excel.Workbook([Content])),

    // // 展开 Excel 表格
    // #"Expanded Excel Tables" = Table.ExpandTableColumn(#"Added Custom", "Excel Tables", {"Data", "Item", "Kind", "Hidden"}, {"Data", "Item", "Kind", "Hidden"}),

    // // 仅保留名为 "DATA" 的工作表
    // #"Filtered Sheets" = Table.SelectRows(#"Expanded Excel Tables", each [Item] = "Sheet1"),
    // #"Removed Other Columns" = Table.SelectColumns(#"Filtered Sheets",{"Data"}),
    // #"Expanded Data" = Table.ExpandTableColumn(#"Removed Other Columns", "Data", {"Column1", "Column2", "Column3", "Column4", "Column5", "Column6", "Column7", "Column8", "Column9", "Column10", "Column11", "Column12", "Column13", "Column14", "Column15", "Column16", "Column17", "Column18", "Column19", "Column20", "Column21", "Column22", "Column23"}, {"Column1", "Column2", "Column3", "Column4", "Column5", "Column6", "Column7", "Column8", "Column9", "Column10", "Column11", "Column12", "Column13", "Column14", "Column15", "Column16", "Column17", "Column18", "Column19", "Column20", "Column21", "Column22", "Column23"}),
    // #"Promoted Headers" = Table.PromoteHeaders(#"TripAvailableSTO_", [PromoteAllScalars=true]),
    #"Changed Type" = Table.TransformColumnTypes(#"TripAvailableSTO_",{{"Wh Id", Int64.Type}, {"Dispatch Date", type datetime}, {"Item Number", type text}, {"Trip Number", type text},  {"Trip Needed", Int64.Type}, {"Trip Picked", Int64.Type}, {"Available Sto", Int64.Type}, {"Available Staged", Int64.Type}, {"Stage Qty", Int64.Type}, {"No Received Qty", Int64.Type}, {"Yard Qty", Int64.Type}, {"New Asn Qty", Int64.Type}, {"Earliest Date", type date}, {"Negative Qty", Int64.Type}, {"Negative Tot", Int64.Type}, {"MFG Schedule Qty", Int64.Type}, {"Overflow Qty", type any}, {"Offsite Qty", Int64.Type}, {"Carrier", type text}, {"In Transit", Int64.Type}, {"Prod Qty", Int64.Type}, {"Location Id", type any}}),

    // 添加新列，提取Trip Number中破折号前的部分并转为整数
    #"Added Trip ID" = Table.AddColumn(#"Changed Type", "Trip_nbr", each if Text.Contains([Trip Number], "-") then Number.FromText(Text.BeforeDelimiter([Trip Number], "-")) else null, Int64.Type),

    // 根据 Dispatch Date 和 Item Number 排序
    #"Sorted Rows" = Table.Sort(#"Added Trip ID",{{"Item Number", Order.Ascending},{"Dispatch Date", Order.Ascending},{"Trip Number",Order.Ascending}}),

    // 增加辅助列
    #"Added Negative Flag" = Table.AddColumn(#"Added Trip ID", "Negative Flag", each if [Negative Qty] < 0 then 1 else 0, Int64.Type),

    // Allocation
    #"Added Allocated Qty" = Table.AddColumn(#"Added Negative Flag", "Allocated_qty", each if [Available Sto] > 0 then [Trip Needed] else 0, type number),

    // 创建一个包含每个Trip Number的Negative Flag总和的表
    #"Grouped By Trip" = Table.Group(#"Added Allocated Qty", {"Trip Number"}, {{"Total Negative", each List.Sum([Negative Flag]), type number}}),

    // 将总和信息合并回原表
    #"Merged Queries" = Table.NestedJoin(#"Added Allocated Qty", {"Trip Number"}, #"Grouped By Trip", {"Trip Number"}, "Trip Negative Info", JoinKind.LeftOuter),
    #"Expanded Trip Negative Info" = Table.ExpandTableColumn(#"Merged Queries", "Trip Negative Info", {"Total Negative"}, {"Total Negative"}),

    // 添加trip_ready_status列
    #"Added Ready Status" = Table.AddColumn(#"Expanded Trip Negative Info", "trip_ready_status", each if [Total Negative] = 0 then "Ready" else "Shortage", type text),
    #"Renamed Columns" = Table.RenameColumns(#"Added Ready Status",{{"Total Negative", "Trips_Shortage_SKUs"}}),
    // #"Filtered Rows" = Table.SelectRows(#"Renamed Columns", each ([Item Number] = "7189835")),


// 分组处理逻辑
    GroupedTable = Table.Group(#"Renamed Columns", {"Item Number"}, {"AllData", each _, type table [Wh Id=nullable number, Dispatch Date=nullable datetime, Item Number=nullable text, Trip Number=nullable text, Trip Needed=nullable number, Available Sto=nullable number, Available Staged=nullable number, Stage Qty=nullable number, No Received Qty=nullable number, Yard Qty=nullable number, New Asn Qty=nullable number, Earliest Date=nullable date, Negative Qty=nullable number, Negative Tot=nullable number, MFG Schedule Qty=nullable number, Overflow Qty=nullable any, Offsite Qty=nullable number, Carrier=nullable text, In Transit=nullable number, Prod Qty=nullable number, Location Id=nullable any, Trip_nbr=nullable number, Negative Flag=nullable number, Allocated_qty=nullable number, Trips_Shortage_SKUs=nullable number, trip_ready_status=nullable text]}),

    AddAllocatedColumn = Table.AddColumn(GroupedTable, "WithAllocated", each
        let
            tbl = [AllData],
            sorted = Table.Sort(tbl, {{"Dispatch Date", Order.Ascending}, {"Trip Number", Order.Ascending}}),
            availableStoMax = List.Max(sorted[Available Sto]),
            // neededList = sorted[Trip Needed],
            neededList = List.Transform(
                List.Zip({sorted[Trip Needed], sorted[Trip Picked]}),
                each _{0} - _{1}
            ),
            allocatedList =
                if availableStoMax = 0 then
                    List.Repeat({0}, Table.RowCount(sorted))
                else
                    allocFunc(neededList, availableStoMax),
            addCol = Table.FromColumns(Table.ToColumns(sorted) & {allocatedList}, Table.ColumnNames(sorted) & {"allocated_qty_2"})
        in
            addCol
    ),

    #"Expanded Allocated Data" = Table.Combine(AddAllocatedColumn[WithAllocated])
    // #"Filtered Rows" = Table.SelectRows(#"Expanded Allocated Data", each ([Item Number] = "7189835"))
in
    #"Expanded Allocated Data"