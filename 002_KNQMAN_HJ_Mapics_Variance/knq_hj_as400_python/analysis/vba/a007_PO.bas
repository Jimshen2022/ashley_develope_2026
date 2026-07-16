Attribute VB_Name = "a007_PO"
Sub a007_PO_()

    Application.ScreenUpdating = False
    Dim i&, j&, arr, brr, crr(), d As Object
    Set d = CreateObject("scripting.dictionary")
    
    ' KNQ IMPORTED PO INFORMATIO
    With Sheet10
        brr = .Range("a1").CurrentRegion
        For i = 2 To UBound(brr)
            d(brr(i, 6)) = ""
        Next
    End With
    
    n = 0
    With Sheet12
      ' HJ received
        arr = .Range("a1").CurrentRegion
        For i = 2 To UBound(arr)
            If CInt(Date - arr(i, 4)) <= 14 And Not d.exists(arr(i, 3)) Then
                n = n + 1
                ReDim Preserve crr(1 To 5, 1 To n)
                For j = 1 To UBound(arr, 2)
                    crr(j, n) = arr(i, j)
                Next
            End If
        Next
        
    End With
    
    With Sheet6
        .Cells.Clear
        .Range("a:c").NumberFormat = "@"
        If n = 0 Then
            GoTo 100
        Else
            .Range("a2").Resize(UBound(crr, 2), UBound(crr)).Value = Application.Transpose(crr)
        End If
100
        .Range("a1:e1").Value = Array("Item#", "CNT#", "PO#", "Received_Date", "Received_Qty")
        .Columns("a:e").AutoFit
    End With
    
    
    Erase arr, brr, crr
    Set d = Nothing
    
    Application.ScreenUpdating = True
End Sub
