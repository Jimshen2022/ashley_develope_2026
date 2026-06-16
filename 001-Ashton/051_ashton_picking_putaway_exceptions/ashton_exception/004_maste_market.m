let
    // Double click on [Source] to make updates.
    Source = Table.FromRows(Json.Document(Binary.Decompress(Binary.FromText("NY9BCsIwEEWvErKehbZK3ZZSULAqraBQuhiagAVJa5Mq3t6ZxGw+eXmT4adtZa7eaHotQa4zij+COBWyA9Jzj2pA1mwDgbgdgrUPNxoSabplHZBN2c8L3ZRFzUkAomq8OWptp3F2vJIfRQZxyf1Ape1rGRxXSnYUkUFc736g1uqJRllyvCAiiCIsaCY0+MEvuU1CEZlqh4HSGf5RtuJudAZx3suu+wE=", BinaryEncoding.Base64), Compression.Deflate)), let _t = ((type nullable text) meta [Serialized.Text = true]) in type table [Market = _t, #"#" = _t, #"Long Name" = _t]),
    #"Replaced Value" = Table.ReplaceValue(Source,"??","70",Replacer.ReplaceText,{"#"})
in
    #"Replaced Value"