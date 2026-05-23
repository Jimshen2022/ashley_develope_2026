// edw calendar
let
    Source = Sql.Database("ashley-edw.database.windows.net", "ASHLEY_EDW", [Query="  " &
            "SELECT *#(lf)  FROM [PowerBI_Enterprise].[DimDate]#(lf)  --WHERE Date_ID between '12/1/2021' and getdate() #(lf)  WHERE CAST(Date_ID AS DATE) BETWEEN DATEADD(Month,-2,GETDATE()) AND GETDATE()", CreateNavigationProperties=false, CommandTimeout=#duration(0, 2, 40, 0)]),
    #"Changed Type" = Table.TransformColumnTypes(Source,{{"Date_ID", type date}})
in
    #"Changed Type"

// Jim's Calendar Table

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