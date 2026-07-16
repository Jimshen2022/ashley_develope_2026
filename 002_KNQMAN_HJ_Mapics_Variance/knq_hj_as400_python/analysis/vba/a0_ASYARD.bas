Attribute VB_Name = "a0_ASYARD"
Sub a0_ASYARD_()
    
    Application.ScreenUpdating = False
    Dim wb As Workbook
    Dim arr, n&
    Dim user_name As String
    Dim k$, key, d As Object
    Set d = CreateObject("scripting.dictionary")
    
    user_name = Environ("Username")
    Set wb = GetObject("C:\Users\" & user_name & "\Downloads\ASYARD.xlsx")
    arr = wb.ActiveSheet.[a1].CurrentRegion
    wb.Close False
    
    For i = 2 To UBound(arr)
        arr(i, 8) = CDate(arr(i, 8))
    Next
    
    With Sheet5
        .Cells.Clear
'        .Columns("e:e").NumberFormat = "dd-mm-yyyy"
        .Columns("A:G").NumberFormat = "@"
'        .Columns("f:f").NumberFormat = "@"
        .Columns("k:k").NumberFormat = "@"
        
        If IsEmptyArray(arr) Then
           Exit Sub
        Else
            .Range("a1").Resize(UBound(arr), UBound(arr, 2)).Value = arr
                    
        End If
    
    .Columns.AutoFit
    .Range("e1:f1").Interior.ColorIndex = 10
    .Range("e1:f1").Font.ColorIndex = 2
    .Range("k1").Interior.ColorIndex = 10
    .Range("k1").Font.ColorIndex = 2
    .Range("n1").Interior.ColorIndex = 10
    .Range("n1").Font.ColorIndex = 2
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



