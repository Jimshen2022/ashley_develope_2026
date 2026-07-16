Attribute VB_Name = "a003_KNQ_4W_EXPORTED"
Sub a003_KNQ_4W_EXPORTED_()
    
    Application.ScreenUpdating = False
    Dim wb As Workbook
    Dim arr, n&, i&
    Dim user_name As String
    Dim k$, key, d As Object
    Set d = CreateObject("scripting.dictionary")
    
    user_name = Environ("Username")
    Set wb = GetObject("C:\Users\" & user_name & "\Downloads\KNQ_4W_EXPORTED.xlsx")
    arr = wb.ActiveSheet.[a1].CurrentRegion
    wb.Close False
'
    For i = 2 To UBound(arr)
        arr(i, 7) = CStr(Mid(arr(i, 7), 4, 2) & "/" & Mid(arr(i, 7), 1, 2) & "/" & Mid(arr(i, 7), 7, 4))
        arr(i, 12) = CStr(Mid(arr(i, 12), 4, 2) & "/" & Mid(arr(i, 12), 1, 2) & "/" & Mid(arr(i, 12), 7, 4))
        arr(i, 8) = CStr(Trim(arr(i, 8)))
        arr(i, 16) = CStr(Trim(arr(i, 16)))
        
    Next
    
    With Sheet11
        .Cells.Clear
'        .Columns("g:g").NumberFormat = "dd-mm-yyyy"
        .Columns("b:b").NumberFormat = "@"
        .Columns("h:h").NumberFormat = "@"
        .Columns("p:p").NumberFormat = "@"
'        .Range("g2:g" & .Range("a1048576").End(3).Row).Value = .Range("g2:g" & .Range("a1048576").End(3).Row).Value
        If IsEmptyArray(arr) Then
           Exit Sub
        Else
            .Range("a1").Resize(UBound(arr), UBound(arr, 2)).Value = arr
                    
        End If
    
    .Columns.AutoFit
    .Range("g1:h1").Interior.ColorIndex = 10
    .Range("g1:h1").Font.ColorIndex = 2
    .Range("p1").Interior.ColorIndex = 10
    .Range("p1").Font.ColorIndex = 2
    .Range("s1").Interior.ColorIndex = 10
    .Range("s1").Font.ColorIndex = 2
    End With
    
    Erase arr

    Application.ScreenUpdating = True
End Sub


Function IsEmptyArray(arr As Variant) As Boolean
    Dim i As Long, j As Long
    For i = LBound(arr, 1) + 1 To UBound(arr, 1)
        For j = LBound(arr, 2) To UBound(arr, 2)
            If Not IsEmpty(arr(i, j)) Then
                IsEmptyArray = False
                Exit Function
            End If
        Next j
    Next i
    IsEmptyArray = True
End Function



