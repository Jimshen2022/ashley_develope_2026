let
    Source = Table.FromRows(Json.Document(Binary.Decompress(Binary.FromText("i45WMlCK1YlWMgSTRmDSGEyagElTMGkGJs3BpAWYtITogmqG6DYEao8FAA==", BinaryEncoding.Base64), Compression.Deflate)), let _t = ((type nullable text) meta [Serialized.Text = true]) in type table [#"ParameterWork Hours" = _t]),
    #"Changed Type" = Table.TransformColumnTypes(Source,{{"ParameterWork Hours", Int64.Type}})
in
    #"Changed Type"