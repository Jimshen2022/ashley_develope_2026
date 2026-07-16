Attribute VB_Name = "a022_EX001AA2"
Sub a022_EX001AA2_()
    Application.ScreenUpdating = False
    Dim i&, arr, brr, d As Object
    Set d = CreateObject("scripting.dictionary")
    
    With Sheet38
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
        .Range("Z2:Z1048576").Cells.Clear
        brr = .Range("a1").CurrentRegion
        For i = 2 To UBound(brr)
            If d.exists(brr(i, 2)) Then
                brr(i, 26) = CInt(d(brr(i, 2)))
            Else
                brr(i, 26) = 0
            End If
                
        Next
         .Columns("Z:Z").NumberFormat = "0"
            
        .Range("Z1").Resize(UBound(brr), 1).Value = Application.Index(brr, , 26)
        .Range("Z1").Value = "EX001AA2"
        .Range("Z1").Interior.Color = RGB(214, 39, 40)
        
    End With
    ThisWorkbook.Save
    Application.ScreenUpdating = True
End Sub

