// nromally use this one

let
  //StartDate = Date.From(DateTime.LocalNow()) - #duration(90, 0, 0, 0),  // 90 days before today
    StartDate = #date(2025, 1, 1),
    EndDate = Date.From(DateTime.LocalNow()) + #duration(15, 0, 0, 0),  // 14 days after today
    NumDays = Duration.Days(EndDate - StartDate) + 1,  // Calculate number of days
    DateList = List.Generate(
        () => StartDate,
        each _ <= EndDate,
        each _ + #duration(1, 0, 0, 0)
    ),
    CalendarTable = Table.FromList(DateList, Splitter.SplitByNothing(), {"Date"}),
    AddWeekday = Table.AddColumn(CalendarTable, "Weekday", each Date.DayOfWeekName([Date])),
    AddYear = Table.AddColumn(AddWeekday, "Year", each Date.Year([Date])),

    // 添加月份和年份的列，如 Jan.2024
    AddMonthWithYear = Table.AddColumn(AddYear, "MonthWithYear", each Date.ToText([Date], "MMM.yyyy")),  // Month with year (Jan.2024)

    // 添加仅包含月份缩写的列，如 Jan, Feb
    AddMonthShort = Table.AddColumn(AddMonthWithYear, "MonthShort", each Date.ToText([Date], "MMM")),  // Only month (Jan, Feb)

    // 新增一列，用 YYYYMM 格式表示年月，并转换为整数格式
    AddYearMonth = Table.AddColumn(AddMonthShort, "YearMonth", each Number.FromText(Text.From([Year]) & Text.PadStart(Text.From(Date.Month([Date])), 2, "0"))),  // YearMonth as integer (202401)

    AddWeeknum = Table.AddColumn(AddYearMonth, "Weeknum", each Date.WeekOfYear([Date])),
    AddYearWeek = Table.AddColumn(AddWeeknum, "YearWeek", each [Year] * 100 + [Weeknum]),
    Custom1 = Table.AddColumn(AddYearWeek, "Week", each Date.DayOfWeek([Date])),

    // 新增一列表示每周六的日期
    WeekEnding = Table.AddColumn(Custom1, "SaturdayDate", each Date.AddDays([Date], 6 - Date.DayOfWeek([Date]))),

    #"Changed Type" = Table.TransformColumnTypes(WeekEnding,{{"Date", type date}, {"Weekday", type text}, {"Year", Int64.Type}, {"MonthWithYear", type text}, {"MonthShort", type text}, {"YearMonth", Int64.Type}, {"Weeknum", Int64.Type}, {"YearWeek", Int64.Type}, {"Week", Int64.Type}, {"SaturdayDate", type date}})
in
    #"Changed Type"



    // edw calendar
let
    Source = Sql.Database("ashley-edw.database.windows.net", "ASHLEY_EDW", [Query=strcat("  ",
            "SELECT *#(lf)  FROM [PowerBI_Enterprise].[DimDate]#(lf)  --WHERE Date_ID between '12/1/2021' and getdate() #(lf)  WHERE CAST(Date_ID AS DATE) BETWEEN DATEADD(Month,-2,GETDATE()) AND GETDATE()"), CreateNavigationProperties=false, CommandTimeout=#duration(0, 2, 40, 0)]),
    #"Changed Type" = Table.TransformColumnTypes(Source,{{"Date_ID", type date}})
in
    #"Changed Type"


// Jim's Calendar Table

let
    Source = List.Dates(StartDate, Length, #duration(1, 0, 0, 0)),
    #"Converted to Table" = Table.FromList(Source, Splitter.SplitByNothing(), null, null, ExtraValues.Error),
    #"Filtered Rows" = Table.SelectRows(#"Converted to Table", each [Column1] > #date(2022, 6, 22)),
    #"Renamed Columns" = Table.RenameColumns(#"Filtered Rows",{{"Column1", "Date"}}),
    #"Changed Type" = Table.TransformColumnTypes(#"Renamed Columns",{{"Date", type date}}),
    StartDate = #date(2020, 1, 1),
    Today = DateTime.Date(DateTime.LocalNow()),
    Length = Duration.Days(Today - StartDate),
    Custom1 = #"Changed Type",
    #"Added Custom" = Table.AddColumn(Custom1, "Year", each Date.Year([Date])),
    #"Added Custom2" = Table.AddColumn(#"Added Custom", "Month", each Date.MonthName([Date])),
    #"Added Custom1" = Table.AddColumn(#"Added Custom2", "Day of the Month", each Date.Day([Date])),
    #"Added Custom3" = Table.AddColumn(#"Added Custom1", "Week Ending", each Date.EndOfWeek([Date])),
    #"Added Custom4" = Table.AddColumn(#"Added Custom3", "Day Name", each Date.DayOfWeekName([Date])),
    #"Added Custom5" = Table.AddColumn(#"Added Custom4", "Week Number", each Date.WeekOfYear([Date])),
    #"Added Custom6" = Table.AddColumn(#"Added Custom5", "Month Number", each Date.Month([Date])),
    #"Added Custom7" = Table.AddColumn(#"Added Custom6", "Month Ending", each Date.EndOfMonth([Date])),
    #"Added Custom8" = Table.AddColumn(#"Added Custom7", "Month Ending Sort", each Date.EndOfMonth([Date])),
    #"Added Custom9" = Table.AddColumn(#"Added Custom8", "Week Ending Sort", each Date.EndOfWeek([Date])),
    #"Changed Type1" = Table.TransformColumnTypes(#"Added Custom9",{{"Week Ending Sort", Int64.Type}, {"Month Ending Sort", Int64.Type}, {"Month Ending", type date}, {"Week Ending", type date}, {"Date", type date}})
in
    #"Changed Type1"


