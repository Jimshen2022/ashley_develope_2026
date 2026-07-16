Attribute VB_Name = "a009_KNQ_Declared_but_HJ_NOT"
Sub a009_KNQ_Declared_but_HJ_NOT_()

    Application.ScreenUpdating = False
    Dim i&, j&, arr, brr, crr(), d As Object
    Set d = CreateObject("scripting.dictionary")
    
    'HJ RECEIVED PO INFORMATION
    With Sheet12
        brr = .Range("a1").CurrentRegion
        For i = 2 To UBound(brr)
            d(brr(i, 3)) = ""
        Next
    End With
    
    ' KNQMAN DECLARED
    With Sheet10
        arr = .Range("a1").CurrentRegion
        For i = 2 To UBound(arr)
            If CInt(Date - arr(i, 10)) <= 14 And Not d.exists(arr(i, 6)) Then
                n = n + 1
                ReDim Preserve crr(1 To UBound(arr, 2), 1 To n)
                For j = 1 To UBound(arr, 2)
                    crr(j, n) = arr(i, j)
                Next
            End If
        Next
        
    End With
    
    With Sheet7
        .Cells.Clear
        .Range("a:D").NumberFormat = "@"
        .Range("f:k").NumberFormat = "@"
'        .Range("a2").Resize(UBound(crr, 2), UBound(crr)).Value = Application.Transpose(crr)
        If Not IsEmpty(n) Then
            .Range("a2").Resize(UBound(crr, 2), UBound(crr)).Value = Application.Transpose(crr)
            Sheet10.Range("a1:v1").Copy
            .Range("a1:v1").PasteSpecial xlPasteValues
            .Columns("a:v").AutoFit
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


