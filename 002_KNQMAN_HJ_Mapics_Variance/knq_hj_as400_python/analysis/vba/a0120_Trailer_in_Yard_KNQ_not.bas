Attribute VB_Name = "a0120_Trailer_in_Yard_KNQ_not"
Sub a0120_Trailer_in_Yard_KNQ_not_()

    Application.ScreenUpdating = False
    Dim i&, j&, arr, brr, crr(), d As Object
    Set d = CreateObject("scripting.dictionary")
    
    'KNQMAN PO INFORMATION
    With Sheet10
        brr = .Range("a1").CurrentRegion
        For i = 2 To UBound(brr)
            d(brr(i, 6)) = ""
        Next
    End With
    
    ' yard
    With Sheet5
        arr = .Range("a1").CurrentRegion
        For i = 2 To UBound(arr)
            If Not d.exists(arr(i, 9)) Then
                n = n + 1
                ReDim Preserve crr(1 To 29, 1 To n)
                For j = 1 To UBound(arr, 2)
                    crr(j, n) = arr(i, j)
                Next
            End If
        Next
    End With
    
    With Sheet22
        .Cells.Clear
        .Range("a:k").NumberFormat = "@"
'        .Range("f:k").NumberFormat = "@"
'        .Range("a2").Resize(UBound(crr, 2), UBound(crr)).Value = Application.Transpose(crr)
        If Not IsEmpty(n) Then
            .Range("a2").Resize(UBound(crr, 2), UBound(crr)).Value = Application.Transpose(crr)
            Sheet5.Range("a1:ac1").Copy
            .Range("a1:ac1").PasteSpecial xlPasteValues
            .Columns("a:ac").AutoFit
        Else
            
        End If
        
     End With
    
    
    Erase arr, brr, crr
    Set d = Nothing
    
    Application.ScreenUpdating = True
End Sub


'Function IsEmptyArray(crr As Variant) As Boolean
'    Dim i As Long, j As Long
'    For i = LBound(crr, 1) + 1 To UBound(crr, 1)
'        For j = LBound(crr, 2) To UBound(crr, 2)
'            If Not IsEmpty(crr(i, j)) Then
'                IsEmptyArray = False
'                Exit Function
'            End If
'        Next j
'    Next i
'    IsEmptyArray = True
'End Function



