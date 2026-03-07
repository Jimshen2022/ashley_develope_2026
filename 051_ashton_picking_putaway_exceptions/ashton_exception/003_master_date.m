let
    Source = List.Dates(StartDate, Length, #duration(1, 0, 0, 0)),
    #"Converted to Table" = Table.FromList(Source, Splitter.SplitByNothing(), null, null, ExtraValues.Error),
    #"Renamed Columns" = Table.RenameColumns(#"Converted to Table",{{"Column1", "Date"}}),
    #"Changed Type" = Table.TransformColumnTypes(#"Renamed Columns",{{"Date", type date}}),
    StartDate = #date(2019, 1, 1),
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