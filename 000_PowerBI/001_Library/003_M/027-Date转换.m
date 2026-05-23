let
    Source = Odbc.Query("dsn=AFIPROD", "SELECT t1.ORDNO, TRIM(t1.ITNBR) AS ITNBR, t1.HOUSE, t1.ITCLS, t1.DUEDT, t1.VNDNR, t1.PSTTS, t3.VNDRVM, t3.VNNMVM, SUM(t1.QTYOR) AS Open_PO#(lf)FROM (#(lf)    SELECT t1.ORDNO, t1.ITNBR, t1.HOUSE, t1.ITCLS, t1.DUEDT, t1.VNDNR, t2.PSTTS, t1.QTYOR#(lf)    FROM AMFLIBA.POITEM t1, AMFLIBA.POMAST t2 #(lf)    WHERE t1.ORDNO = t2.ORDNO AND t2.HOUSE = t1.HOUSE AND T2.PSTTS IN ('20')#(lf)) AS t1 #(lf)LEFT JOIN AMFLIBA.VENNAML0 t3 ON t1.VNDNR = t3.VNDRVM#(lf)WHERE t3.VNDRVM IN ('600039', '900639', '900515') #(lf)GROUP BY t1.ORDNO, TRIM(t1.ITNBR), t1.HOUSE, t1.ITCLS, t1.DUEDT, t1.VNDNR, t1.PSTTS, t3.VNDRVM, t3.VNNMVM#(lf)ORDER BY t1.DUEDT, t1.ORDNO, TRIM(t1.ITNBR)#(lf)"),
    #"Changed Type" = Table.TransformColumnTypes(Source,{{"DUEDT", type text}}),
    #"AddedCustom" = Table.AddColumn(#"Changed Type", "ConvertedDate", each 
    let
        // 提取年份 (前两位) 并加上 '20'
        YearText = Text.Middle([DUEDT],1, 2),
        Year = "20" & YearText,
        
        // 提取月份 (中间两位)
        MonthText = Text.Middle([DUEDT], 3, 2),
        
        // 提取日期 (最后两位)
        DayText = Text.End([DUEDT], 2),
        
        // 拼接为 YYYY-MM-DD 格式
        DateText = Year & "-" & MonthText & "-" & DayText,
        
        // 转换为日期类型
        ConvertedDate = Date.FromText(DateText)
    in
        ConvertedDate
),
    #"Changed Type1" = Table.TransformColumnTypes(AddedCustom,{{"ConvertedDate", type date}}),

    // 以下代码等同于上面的代码
    Custom1 = Table.AddColumn(#"Changed Type1", "TransactionDate", each try Date.FromText("20"&Text.Range(Text.From([DUEDT]),1,6)) otherwise Date.FromText(Text.From("1901-01-01")),type date)
in
    Custom1