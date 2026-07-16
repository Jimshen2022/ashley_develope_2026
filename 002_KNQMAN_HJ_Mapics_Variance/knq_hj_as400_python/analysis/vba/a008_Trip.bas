Attribute VB_Name = "a008_Trip"
Sub a008_Trip_()
    On Error Resume Next
    Application.ScreenUpdating = False
    Dim i&, j&, arr, brr, crr(), d As Object
    Set d = CreateObject("scripting.dictionary")
    
    ' KNQ EXPORTED  INFORMATION
    With Sheet11
        brr = .Range("a1").CurrentRegion
        For i = 2 To UBound(brr)
            d(CStr(brr(i, 8))) = ""
        Next
    End With
    
    ' HJ shipped
    With Sheet13
        arr = .Range("a1").CurrentRegion
        For i = 2 To UBound(arr)
            If CInt(Date - arr(i, 3)) <= 14 And Not d.exists(CStr(arr(i, 6))) Then
                n = n + 1
                ReDim Preserve crr(1 To 6, 1 To n)
                For j = 1 To UBound(arr, 2)
                    crr(j, n) = arr(i, j)
                Next
            End If
        Next
        
    End With
    
    With Sheet8
        .Cells.Clear
        .Range("a:b").NumberFormat = "@"
        .Range("f:f").NumberFormat = "@"
        
            .Range("a2").Resize(UBound(crr, 2), UBound(crr)).Value = Application.Transpose(crr)
            .Range("a1:f1").Value = Array("Item#", "trip#", "Date", "CTN#", "Shipped_Qty", "Trip_Number")
            .Columns("a:f").AutoFit
        
    End With
    
    
    Erase arr, brr, crr
    Set d = Nothing
    
    Application.ScreenUpdating = True
End Sub



