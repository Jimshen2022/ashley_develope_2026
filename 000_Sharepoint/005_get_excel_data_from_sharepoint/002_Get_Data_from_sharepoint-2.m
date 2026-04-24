let
// Connect to SharePoint Files from a specific site
Source = SharePoint.Files("https://masterashley.sharepoint.com/sites/Ashton Operations/", [ApiVersion = 15]),
// Filter to only include files in the specific Ashton PPH folder
#"Filtered Folder" = Table.SelectRows(Source, each Text.StartsWith([Folder Path], "https://masterashley.sharepoint.com/sites/Ashton Operations/Shared Documents/Ashton Wharehouse/Logistics/")),

// Further filter to only include Excel (.xlsx) files with a specific naming pattern
#"Filtered Files" = Table.SelectRows(#"Filtered Folder", each Text.EndsWith([Name], ".xlsx") and Text.Middle([Name], Text.Length([Name]) - 8, 8) <> null),

// Extract and format the date from the filename
#"Added Date Column" = Table.AddColumn(#"Filtered Files", "File Date", each
    let
        rawDate = Text.Middle([Name], Text.Length([Name]) - 13, 8),
        day = Text.Middle(rawDate, 6, 2),
        month = Text.Middle(rawDate, 3, 2),
        year = "20" & Text.Middle(rawDate, 0, 2)
    in
        Date.FromText(year & "-" & month & "-" & day, [Format = "yyyy-MM-dd"])
),

    // Add filter for last 6 days
    // 添加最近7天的筛选条件
    #"Filtered Last 7 Days" = Table.SelectRows(#"Added Date Column", each
        [File Date] >= Date.AddDays(Date.From(DateTime.LocalNow()), -13) and
        [File Date] <= Date.From(DateTime.LocalNow())
    ),

    // Continue with the rest of your original steps, but starting from #"Filtered Last 7 Days" instead of #"Added Date Column"
    #"Added Custom" = Table.AddColumn(#"Filtered Last 7 Days", "File Content", each Excel.Workbook([Content])),

// Rename the 'Name' column to 'File Name'
#"Renamed Columns" = Table.RenameColumns(#"Added Custom", {{"Name", "File Name"}}),

// Expand the file content to show worksheet details
#"Expanded File Content" = Table.ExpandTableColumn(#"Renamed Columns", "File Content", {"Name", "Data", "Item"}, {"Name", "Data", "Item"}),

// Filter to only include the "Loading+ Picking" worksheet
#"Filtered Rows" = Table.SelectRows(#"Expanded File Content", each ([Name] = "DATA")),

// Keep only relevant columns
#"Removed Other Columns" = Table.SelectColumns(#"Filtered Rows",{"Data", "File Date", "Name"}),

// Reorder columns
#"Reordered Columns" = Table.ReorderColumns(#"Removed Other Columns",{"File Date", "Name", "Data"}),

// Expand the data columns (handling up to 46 columns)
#"Expanded Data" = Table.ExpandTableColumn(#"Reordered Columns", "Data",
    List.Generate(() => 1, each _ <= 46, each _ + 1, each "Column" & Text.From(_)),
    List.Generate(() => 1, each _ <= 46, each _ + 1, each "Column" & Text.From(_))
),
    #"Removed Other Columns1" = Table.SelectColumns(#"Expanded Data",{"File Date", "Name", "Column1", "Column2", "Column3", "Column4", "Column5", "Column6", "Column7", "Column8", "Column9", "Column10"}),

// Add an index column for row manipulation
#"Added Index" = Table.AddIndexColumn(#"Removed Other Columns1", "Row Index", 1, 1),

// Modify the first 5 rows of File Date to be a placeholder
#"Modified First 5 Rows File Date" = Table.AddColumn(
    #"Added Index",
    "Modified File Date",
    each if [Row Index] <= 1
        then "File_Date"
        else Text.From([File Date]),
    type text
),

#"Removed Columns" = Table.RemoveColumns(#"Modified First 5 Rows File Date",{"File Date", "Row Index"}),
#"Renamed Columns1" = Table.RenameColumns(#"Removed Columns",{{"Modified File Date", "File_Date"}}),
    #"Reordered Columns2" = Table.ReorderColumns(#"Renamed Columns1",{"File_Date", "Name", "Column1", "Column2", "Column3", "Column4", "Column5", "Column6", "Column7"}),
#"Promoted Headers" = Table.PromoteHeaders(#"Reordered Columns2", [PromoteAllScalars=true]),
    #"Filtered Rows1" = Table.SelectRows(#"Promoted Headers", each ([Employee_ID] <> null and [Employee_ID] <> "0" and [Employee_ID] <> "Employee_ID")),
    #"Changed Type4" = Table.TransformColumnTypes(#"Filtered Rows1",{{"DATA", type text}, {"Group", type text}, {"Date", type date}, {"Employee_ID", type text}, {"Name", type text}}),
    // Pad ID HR and ID to ensure they are 5 digits long, adding leading zeros if needed
    // 填充ID HR和ID以确保它们是5位长，如有需要添加前导零
    #"Padded ID HR" = Table.TransformColumns(#"Changed Type4",
    {
        {"Employee_ID", each if Text.Length(Text.From(_)) < 5 then Text.PadStart(Text.From(_), 5, "0") else Text.From(_), type text}

    }
),
    #"Changed Type2" = Table.TransformColumnTypes(#"Padded ID HR",{{"Final Hour/#(lf)Individual", type number}, {"Final Hour/#(lf)All in PPH", type number}, {"Shift", type text}, {"Section", type text}, {"Team", type text}, {"PPH_Type", type text}}),

    // employ id updated
    // AddUpdatedColumn = Table.AddColumn( #"Changed Type2", "Updated_Employee_ID", each if ([Employee_ID] = "00000" or [Employee_ID] = null) and [Name] <> null then [Name] else [Employee_ID]),
    // RemoveOldColumn = Table.RemoveColumns(AddUpdatedColumn, {"Employee_ID"}),
    // RenameColumn = Table.RenameColumns(RemoveOldColumn, {{"Updated_Employee_ID", "Employee_ID"}}),

    #"Changed Type" = Table.TransformColumnTypes(#"Changed Type2",{{"Employee_ID", type text}}),
    //增加字符串
    #"Added Custom3" = Table.AddColumn(#"Changed Type", "emp_date_string", each
    Text.PadStart(Text.From(Date.Year(Date.From([File_Date]))) & "-" &
    Text.PadStart(Text.From(Date.Month(Date.From([File_Date]))), 2, "0") & "-" &
    Text.PadStart(Text.From(Date.Day(Date.From([File_Date]))), 2, "0"), 10, "0") &
    "_" & [Employee_ID],  type text
),

        //增加字符串
    #"Added Custom2" = Table.AddColumn(#"Added Custom3", "emp_date_job_string", each
    Text.PadStart(Text.From(Date.Year(Date.From([File_Date]))) & "-" &
    Text.PadStart(Text.From(Date.Month(Date.From([File_Date]))), 2, "0") & "-" &
    Text.PadStart(Text.From(Date.Day(Date.From([File_Date]))), 2, "0"), 10, "0") &
    "_" & [Employee_ID] & "_" & [PPH_Type],  type text
),
    #"Removed Blank Rows" = Table.SelectRows(#"Added Custom2", each not List.IsEmpty(List.RemoveMatchingItems(Record.FieldValues(_), {"", null}))),
    #"Removed Duplicates" = Table.Distinct(#"Removed Blank Rows"),
    #"Grouped Rows" = Table.Group(#"Removed Duplicates", {"File_Date", "DATA", "Group", "Date", "Employee_ID", "Team", "PPH_Type", "Section", "Shift", "emp_date_string", "emp_date_job_string"}, {{"Final Hour/Individual", each List.Sum([#"Final Hour/#(lf)Individual"]), type nullable number}, {"Final Hour/All in PPH", each List.Sum([#"Final Hour/#(lf)All in PPH"]), type nullable number}})
in
    #"Grouped Rows"