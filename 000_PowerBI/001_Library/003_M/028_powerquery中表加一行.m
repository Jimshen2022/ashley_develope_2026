
let
    Source = Table.FromList({"CG", "UPH", "ACCESSORY"}, Splitter.SplitByNothing(), {"Value"})
in
    Source




let
    // 定义表格的列内容，包括新的一行
    Defined = {"Inventory", "Transactions", "Inventory_Age","Weighted_Avgerage_Inventory_Age", "Demand"},
    Description = {
        "Inventory NOT IN locations: ('S01ST1','FIQC') in AS400 WH51.",
        "Receipt transaction code in ('RP','RI','RM','RS') and transaction date in the past 2 years in MAPICS.",
        "Item_Inventory_Age = Current Date - Item Receipt Date ",
        "Weighted_Avgerage_Inventory_Age = (Sum of (Item Inventory Age * Quantity)) / Item Total Quantity",
        "Next 70days demand in AMFLIBL.MBCDRESM(FG) and AMFLIBL.REQMTS(RawMaterial)" // 这里是你新增的一行描述
    },

    // 生成表格
    TableContent = Table.FromColumns({Defined, Description}, type table [Defined=text, Description=text])

in
    TableContent