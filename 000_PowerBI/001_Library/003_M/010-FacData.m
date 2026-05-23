let
    FirmedPO = Fct_Firmed_PO, // 这里替换为你的 Firmed_PO 查询
    HJReceivedTrx= Fct_HJ_Received_Trx , // 这里替换为你的 HJ transaction 查询
    Yard = FctYard, // 这里替换为你的 Yard 查询

    // 重命名字段名
    Renamed_FirmedPO = Table.RenameColumns(FirmedPO,{{"Item #", "item_number"}}),
    Renamed_HJ_Received_Trx = Table.RenameColumns(Fct_HJ_Received_Trx,{{"item_number", "item_number"}}),
   Renamed_Ashton_Yard = Table.RenameColumns(FctYard,{{"item_number", "item_number"}}),

    // 合并三个查询的结果
    Combined = Table.Combine({Renamed_FirmedPO, Renamed_HJ_Received_Trx, Renamed_Ashton_Yard}),

    // 选择 item_number 字段
    Selected = Table.SelectColumns(Combined,{"item_number"}),
    #"Trimmed Text" = Table.TransformColumns(Selected,{{"item_number", Text.Trim, type text}}),
    #"Removed Duplicates" = Table.Distinct(#"Trimmed Text"),
    #"Merged Queries" = Table.NestedJoin(#"Removed Duplicates", {"item_number"}, Item_Master, {"ITNBR"}, "Item_Master", JoinKind.LeftOuter),
    #"Expanded Item_Master" = Table.ExpandTableColumn(#"Merged Queries", "Item_Master", {"ITCLS"}, {"ITCLS"}),
    #"Added Conditional Column" = Table.AddColumn(#"Expanded Item_Master", "Product", each if not Text.StartsWith([ITCLS], "Z") then "RP" else if List.Contains({"0","1","2","3","4","5","6","7","8","9","U"}, Text.Start([item_number], 1)) then "UPH" else "CG"),
    #"Added Custom" = Table.AddColumn(#"Added Conditional Column", "Custom", each DimCalendar),
    #"Expanded Custom" = Table.ExpandTableColumn(#"Added Custom", "Custom", {"Date"}, {"Custom.Date"}),
    #"Renamed Columns" = Table.RenameColumns(#"Expanded Custom",{{"Custom.Date", "Date"}}),
    #"Merged Queries1" = Table.NestedJoin(#"Renamed Columns", {"item_number", "Date"}, Fct_Firmed_PO, {"Item #", "Date"}, "Fct_Firmed_PO", JoinKind.LeftOuter),
    #"Expanded Fct_Firmed_PO" = Table.ExpandTableColumn(#"Merged Queries1", "Fct_Firmed_PO", {"Vendor #", "Firmed_Qty"}, {"Vendor #", "Firmed_Qty"}),
    #"Replaced Value" = Table.ReplaceValue(#"Expanded Fct_Firmed_PO",null,0,Replacer.ReplaceValue,{"Firmed_Qty"}),
    #"Replaced Value1" = Table.ReplaceValue(#"Replaced Value",null,"",Replacer.ReplaceValue,{"Vendor #"}),
    #"Changed Type" = Table.TransformColumnTypes(#"Replaced Value1",{{"Date", type date}}),
    #"Merged Queries2" = Table.NestedJoin(#"Changed Type", {"item_number", "Date"}, Fct_HJ_Received_Trx, {"item_number", "start_tran_date"}, "Fct_HJ_Received_Trx", JoinKind.LeftOuter),
    #"Expanded Fct_HJ_Received_Trx" = Table.ExpandTableColumn(#"Merged Queries2", "Fct_HJ_Received_Trx", {"container_nbr", "po_nbr", "Received_Q'ty"}, {"container_nbr", "po_nbr", "Received_Q'ty"}),
    #"Replaced Value2" = Table.ReplaceValue(#"Expanded Fct_HJ_Received_Trx",null,"",Replacer.ReplaceValue,{"container_nbr"}),
    #"Replaced Value3" = Table.ReplaceValue(#"Replaced Value2",null,"",Replacer.ReplaceValue,{"po_nbr"}),
    #"Replaced Value4" = Table.ReplaceValue(#"Replaced Value3",null,0,Replacer.ReplaceValue,{"Received_Q'ty"}),
    #"Merged Queries3" = Table.NestedJoin(#"Replaced Value4", {"item_number", "Date"}, FctYard, {"item_number", "EnterYardDate"}, "Ashton_Yard", JoinKind.LeftOuter),
    #"Expanded Ashton_Yard" = Table.ExpandTableColumn(#"Merged Queries3", "Ashton_Yard", {"asn_id", "vendor_id", "carrier_id", "equipment_id", "customer_po_number", "quantity_shipped", "quantity_received", "EnterYardDate", "YardOpenQty"}, {"asn_id", "vendor_id", "carrier_id", "equipment_id", "customer_po_number", "quantity_shipped", "quantity_received", "EnterYardDate", "YardOpenQty"}),
    #"Filtered Rows" = Table.SelectRows(#"Expanded Ashton_Yard", each true),
    #"Replaced Value5" = Table.ReplaceValue(#"Filtered Rows",null,0,Replacer.ReplaceValue,{"quantity_shipped","quantity_received","YardOpenQty"}),
    #"Grouped Rows" = Table.Group(#"Replaced Value5", {"item_number", "ITCLS", "Product", "Date"}, {{"Firmed Q'ty", each List.Sum([Firmed_Qty]), type nullable number}, {"Received Q'ty", each List.Sum([#"Received_Q'ty"]), type number}, {"Yard Q'ty", each List.Sum([YardOpenQty]), type nullable number}}),
    #"Added Conditional Column1" = Table.AddColumn(#"Grouped Rows", "Delivery_Type", 
    each if  [#"Received Q'ty"] + [#"Yard Q'ty"] - [#"Firmed Q'ty"] >0 then "Excess Delivery" 
    else if [#"Firmed Q'ty"] >0 and [#"Received Q'ty"] + [#"Yard Q'ty"] - [#"Firmed Q'ty"] =0 then "On-Plan Delivery" 
    else if [#"Firmed Q'ty"] >0 and [#"Received Q'ty"] + [#"Yard Q'ty"] - [#"Firmed Q'ty"] <0 then "Underdelivery" 
    else "No Activity")
in
    #"Added Conditional Column1"