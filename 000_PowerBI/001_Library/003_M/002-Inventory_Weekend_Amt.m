-- Create a calculated table to get the weekend dates
WeekendDates = 
VAR FirstWeekendDate = DATE(YEAR(TODAY()), MONTH(TODAY()), 1) - WEEKDAY(FirstWeekendDate, 2) + 7
RETURN
    GENERATESERIES(
        FirstWeekendDate,
        TODAY(),
        7
    )

-- Create a measure to get the inventory for each weekend
WeekendInventory = 
VAR WeekendDate = SELECTEDVALUE(WeekendDates[Date])
RETURN
    CALCULATE(
        SUM(CurrentStockTableSnapshot[Qty]),
        FILTER(
            ALL(CurrentStockTableSnapshot),
            CurrentStockTableSnapshot[Item Number] = SELECTEDVALUE(CurrentStockTableSnapshot[Item Number])
            && InOutTransaction[Date] = WeekendDate
            && InOutTransaction[Transaction Type] = "In"
        )
    ) -
    CALCULATE(
        SUM(InOutTransaction[Qty]),
        FILTER(
            ALL(InOutTransaction),
            InOutTransaction[Item Number] = SELECTEDVALUE(InOutTransaction[Item Number])
            && InOutTransaction[Date] = WeekendDate
            && InOutTransaction[Transaction Type] = "Out"
        )
    )
    