let
    GetTotalHours = (EmployeeID as text, DestinationFileDate as any) as nullable number =>
    let
        // 确保 DestinationFileDate 是日期类型
        DestinationDate = if Value.Is(DestinationFileDate, type date) then DestinationFileDate else Date.FromText(DestinationFileDate),
        // 引用 Fct_HR_Work_Hours_append 表，并添加 File_Date 条件
        MatchedRow = Table.SelectRows(Fact_HR_Work_Hrs, each [EmployeeID] = EmployeeID and [WorkDate] = DestinationDate),
        // 获取 Total_Hours 值
        TotalHours = if Table.IsEmpty(MatchedRow) then 0 else MatchedRow{0}[Total_Hours]
    in
        TotalHours
in
    GetTotalHours





// let
//     GetTotalHours = (EmployeeID as text, DestinationFileDate as text) as nullable number =>
//     let
//         // 引用 Fct_HR_Work_Hours_append 表，并添加 File_Date 条件
//         MatchedRow = Table.SelectRows(Fact_HR_Work_Hours_append, each [EmployeeID] = EmployeeID and [WorkDate] = DestinationFileDate),
//         // 获取 Total_Hours 值
//         TotalHours = if Table.IsEmpty(MatchedRow) then null else MatchedRow{0}[Total_Hours]
//     in
//         TotalHours
// in
//     GetTotalHours

