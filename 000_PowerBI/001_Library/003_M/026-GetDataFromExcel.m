let
    Source = Excel.Workbook(File.Contents("Z:\UPH FG Warehouse\Public\Inventory\Inventory -JimShen\BI_Excel\WH335\Ashton Damaged&Defect Process - 20240801.xlsx"), null, true),
    #"Location Meaning_Sheet" = Source{[Item="Location Meaning",Kind="Sheet"]}[Data],
    #"Changed Type" = Table.TransformColumnTypes(#"Location Meaning_Sheet",{{"Column1", type text}, {"Column2", type text}, {"Column3", type text}}),
    #"Promoted Headers" = Table.PromoteHeaders(#"Changed Type", [PromoteAllScalars=true]),
    #"Changed Type1" = Table.TransformColumnTypes(#"Promoted Headers",{{"Location ID", type text}, {"Location Function", type text}, {"SN Received Date Defined", type text}}),
    #"Replaced Value" = Table.ReplaceValue(#"Changed Type1",null,"",Replacer.ReplaceValue,{"SN Received Date Defined"})
in
    #"Replaced Value"