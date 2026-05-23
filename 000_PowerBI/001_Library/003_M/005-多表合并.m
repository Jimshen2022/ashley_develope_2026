let
    CO_TRIP = #"CO_TRIP", // 这里替换为你的 CO_TRIP 查询
    OnHand = #"OnHand", // 这里替换为你的 OnHand 查询
    SafetyStock = #"SafetyStock", // 这里替换为你的 SafetyStock 查询

    // 重命名字段名
    Renamed_CO_TRIP = Table.RenameColumns(CO_TRIP,{{"ITNBR", "item_number"}}),
    Renamed_OnHand = Table.RenameColumns(OnHand,{{"ITNBR", "item_number"}}),
   Renamed_SafetyStock = Table.RenameColumns(SafetyStock,{{"Item #", "item_number"}}),

    // 合并三个查询的结果
    Combined = Table.Combine({Renamed_CO_TRIP, Renamed_OnHand, Renamed_SafetyStock}),

    // 选择 item_number 字段
    Selected = Table.SelectColumns(Combined,{"item_number"}),
    #"Trimmed Text" = Table.TransformColumns(Selected,{{"item_number", Text.Trim, type text}}),
    #"Removed Duplicates" = Table.Distinct(#"Trimmed Text")
in
    #"Removed Duplicates"