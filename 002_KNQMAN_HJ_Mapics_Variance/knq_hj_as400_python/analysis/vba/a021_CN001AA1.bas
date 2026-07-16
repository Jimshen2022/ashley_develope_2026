Attribute VB_Name = "a021_CN001AA1"
Sub a021_CN001AA1_()
    Application.ScreenUpdating = False
    Dim i&, arr, brr, d As Object
    Set d = CreateObject("scripting.dictionary")
    
    With Sheet42
        arr = .Range("a1").CurrentRegion
        For i = 2 To UBound(arr)
            If d.exists(arr(i, 3)) Then
                d(arr(i, 3)) = d(arr(i, 3)) + 1
            Else
                d(arr(i, 3)) = 1
            End If
        Next i
    End With
    
    With Sheet1
        .Range("x2:x1048576").Cells.Clear
        brr = .Range("a1").CurrentRegion
        For i = 2 To UBound(brr)
            If d.exists(brr(i, 2)) Then
                brr(i, 24) = CInt(d(brr(i, 2)))
            Else
                brr(i, 24) = 0
            End If
                
        Next
         .Columns("x:x").NumberFormat = "0"
            
        .Range("x1").Resize(UBound(brr), 1).Value = Application.Index(brr, , 24)
        .Range("x1").Value = "SH001AA1"
        
    End With
    ThisWorkbook.Save
    Application.ScreenUpdating = True
End Sub
