Attribute VB_Name = "b01_add_orphaned_column"
Sub b01_add_orphaned_column_()

    Application.ScreenUpdating = False
    Dim i&, arr, brr, d As Object
    Set d = CreateObject("scripting.dictionary")
    brr = Sheet18.Range("a1").CurrentRegion
    
    For i = 2 To UBound(brr)
       If Not brr(i, 8) Like "NG001OP*" Then
        d(brr(i, 3)) = d(brr(i, 3)) + 1
       End If
    Next
    
    
    With Sheet1
        .Range("an1:an1048576").Clear
        .Range("an1").Value = "Orphaned"
        arr = .Range("a1").CurrentRegion
        For i = 2 To UBound(arr)
            If d.exists(arr(i, 2)) Then
                 arr(i, 40) = d(arr(i, 2))
            Else
                arr(i, 40) = 0
            End If
        Next
        .Range("an1").Resize(UBound(arr), 1).Value = Application.Index(arr, , 40)
        .Range("ah1:an1").Interior.ColorIndex = 12
        .Range("ah1:an1").Font.ColorIndex = 1
    End With
    Erase arr, brr
    Set d = Nothing
    
    Application.ScreenUpdating = True
End Sub
