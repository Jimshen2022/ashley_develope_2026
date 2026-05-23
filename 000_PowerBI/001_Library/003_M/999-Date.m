JimShen
Text
获取当前日期
6/4  计算两个日期之间的天数
= Table.AddColumn(#"Filtered Rows", "PendingDays", each (Number.From(DateTime.FixedLocalNow())-Number.From([LastSale_Date])),Int64.Type)

= Table.AddColumn(OrderStatus, "Pending Days", each Number.Round(((Number.From(DateTime.FixedLocalNow())-Number.From([ENTDAT]))/24),1),Int64.Type)   ---- 天数保留小数点1位


= Table.TransformColumns(源,{"姓名",each _&"男同学"})

将AS400转出来的1210103转成日期格式
= Table.AddColumn(#"Removed Columns", "TransactionDate", each try Date.FromText("20"&Text.Range(Text.From([UPDDT]),1,6)) otherwise Date.FromText(Text.From("1901-01-01")),type date)


= Table.AddColumn(#"AddedCustom4", "AMT($USD)", each [VALUESHIP]+[TOFFRT],type number)

If 语句判定后，定义列的type
= Table.AddColumn(#"AddedCustom4", "AMT($USD)", each if [CMACUSTOMERCLASSCODE]="CHN",([VALUESHIP]+[TOFFRT])/6.82 else [VALUESHIP]+[TOFFRT],type number)
