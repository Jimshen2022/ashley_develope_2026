let
    Source = Table.FromRows(Json.Document(Binary.Decompress(Binary.FromText("Lc/JDcAgEEPRXubMIZ6ErRaU/tvI2M7tC1k8OCeuaJGIt50AM5XJvJU381E+lZ52HqpGlYezyrtV1VW7avhyQtNJaDkJbSehWqkl/a+iBWOgBnOgB4OgCJOgCaNJFFaTKswmWdhNfbDc9wM=", BinaryEncoding.Base64), Compression.Deflate)), let _t = ((type nullable text) meta [Serialized.Text = true]) in type table [Hour = _t, Index = _t]),
    #"Changed Type" = Table.TransformColumnTypes(Source,{{"Hour", Int64.Type}, {"Index", Int64.Type}})
in
    #"Changed Type"