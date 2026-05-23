let
    FirmedPO = #"Firmed_PO", // 这里替换为你的 Firmed_PO 查询
    HJReceivedTrx= HJ_Received_Trx , // 这里替换为你的 HJ transaction 查询
    Yard = Ashton_Yard, // 这里替换为你的 Yard 查询

    // 重命名字段名
    Renamed_FirmedPO = Table.RenameColumns(FirmedPO,{{"Item #", "item_number"}}),
    Renamed_HJ_Received_Trx = Table.RenameColumns(HJ_Received_Trx,{{"item_number", "item_number"}}),
   Renamed_Ashton_Yard = Table.RenameColumns(Ashton_Yard,{{"item_number", "item_number"}}),

    // 合并三个查询的结果
    Combined = Table.Combine({Renamed_FirmedPO, Renamed_HJ_Received_Trx, Renamed_Ashton_Yard}),

    // 选择 item_number 字段
    Selected = Table.SelectColumns(Combined,{"item_number"}),
    #"Trimmed Text" = Table.TransformColumns(Selected,{{"item_number", Text.Trim, type text}}),
    #"Removed Duplicates" = Table.Distinct(#"Trimmed Text"),
    #"Merged Queries" = Table.NestedJoin(#"Removed Duplicates", {"item_number"}, Item_Master, {"ITNBR"}, "Item_Master", JoinKind.LeftOuter),
    #"Expanded Item_Master" = Table.ExpandTableColumn(#"Merged Queries", "Item_Master", {"ITCLS"}, {"ITCLS"}),
    #"Added Conditional Column" = Table.AddColumn(#"Expanded Item_Master", "Product", each if not Text.StartsWith([ITCLS], "Z") then "RP" else if List.Contains({"0","1","2","3","4","5","6","7","8","9","U"}, Text.Start([item_number], 1)) then "UPH" else "CG")
in
    #"Added Conditional Column"