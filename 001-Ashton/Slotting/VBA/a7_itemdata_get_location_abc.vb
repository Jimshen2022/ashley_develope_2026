Sub a7_itemdata_get_location_abc_()

    Application.ScreenUpdating = False
    Dim i&, j&, arr, drr, d As Object
    Set d = CreateObject("scripting.dictionary")


    drr = Sheet4.Range("a1").CurrentRegion

    For i = 2 To UBound(drr)
        d(drr(i, 13)) = drr(i, 1)
    Next
    Erase drr

    With Sheet12
      .Range("ap:ap").ClearContents
      .Range("ap1").Value = "Loc_Type"
      arr = .Range("a1").CurrentRegion
      For i = 2 To UBound(arr)
        If Left(arr(i, 32), 1) = "A" And d.exists(arr(i, 32)) Then
            arr(i, 42) = d(arr(i, 32))
        Else
            arr(i, 42) = "NoFWP"
        End If
      Next
        .Range("ap1").Resize(UBound(arr)).Value = Application.Index(arr, , 42)

        .Range("ap1:ap1").Interior.ColorIndex = 10
        .Range("ap1:ap1").Font.ColorIndex = 2
        .Columns("a:ap").AutoFit
    End With
    Erase arr
    Set d = Nothing

    Application.ScreenUpdating = True
End Sub
