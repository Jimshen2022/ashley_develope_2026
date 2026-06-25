Sub a71_item_family_()

    Application.ScreenUpdating = False

    Dim regex As Object
    Set regex = CreateObject("VBScript.RegExp")
    regex.Pattern = "^[^\d]*([\d\w]+)-.*$"
    regex.Global = False
    regex.MultiLine = True
    Dim lastRow As Long

     With Sheet12

        lastRow = .Cells(Rows.Count, 1).End(xlUp).Row
        Dim itemData As Variant
        itemData = .Range("A1:A" & lastRow).Value
        Dim itemFamily As Variant
        ReDim itemFamily(1 To lastRow, 1 To 1)
        Dim i As Long
        For i = 1 To lastRow
            Dim match As Object
            Set match = regex.Execute(itemData(i, 1))
            If match.Count > 0 Then
                itemFamily(i, 1) = match.item(0).SubMatches.item(0)
            Else
                itemFamily(i, 1) = Mid(itemData(i, 1), 1, 5)
            End If
        Next i
        .Range("AQ1:AQ" & lastRow).Value = itemFamily
        .Range("aq1").Value = "Product_Family"

        .Range("aq1:aq1").Interior.ColorIndex = 10
        .Range("aq1:aq1").Font.ColorIndex = 2
        .Columns("a:aq").AutoFit
    Application.ScreenUpdating = True
    End With
End Sub

