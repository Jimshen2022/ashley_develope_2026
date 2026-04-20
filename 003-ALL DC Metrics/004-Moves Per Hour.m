let
    Source = Table.FromRows(Json.Document(Binary.Decompress(Binary.FromText("Lcy5EYBAEMTAXNbGQMcfy9blnwbUCKc9qbvWmksXccQt7vGIZ7ziHR+rP7bGHHsc4AEX+MAJXsZ3mS8=", BinaryEncoding.Base64), Compression.Deflate)), let _t = ((type nullable text) meta [Serialized.Text = true]) in type table [#"Moves Per Hour" = _t]),
    #"Changed Type" = Table.TransformColumnTypes(Source,{{"Moves Per Hour", Int64.Type}})
in
    #"Changed Type"