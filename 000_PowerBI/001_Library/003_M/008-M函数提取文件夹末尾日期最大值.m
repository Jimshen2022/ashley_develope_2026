let
    Source = Folder.Files("W:\UPH FG Warehouse\Public\Inventory\Inventory -JimShen\BI_Excel\SafetyStock"),
    AddCustom = Table.AddColumn(Source, "Date", each Text.Middle([Name], Text.Length("Ashton Phu My Safety Stock_"), 10)),
    ChangeType = Table.TransformColumnTypes(AddCustom,{{"Date", type date}}),
    SortedRows = Table.Sort(ChangeType,{{"Date", Order.Descending}}),
    KeptFirstRows = Table.FirstN(SortedRows,1)
in
    KeptFirstRows