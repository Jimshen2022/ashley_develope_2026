let
    Source = Table.FromRows(Json.Document(Binary.Decompress(Binary.FromText("i45WSlCKjQUA", BinaryEncoding.Base64), Compression.Deflate)), let _t = ((type nullable text) meta [Serialized.Text = true]) in type table [Background = _t]),
    #"Changed Type" = Table.TransformColumnTypes(Source,{{"Background", type text}})
in
    #"Changed Type"