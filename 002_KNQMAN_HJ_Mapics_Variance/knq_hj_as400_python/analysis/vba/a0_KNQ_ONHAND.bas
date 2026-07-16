Attribute VB_Name = "a0_KNQ_ONHAND"
Sub a0_KNQ_ONHAND_()
    
    Application.ScreenUpdating = False
    Dim wb As Workbook
    Dim arr, n&
    Dim user_name As String
    Dim k$, key, d As Object
    Set d = CreateObject("scripting.dictionary")
    
    user_name = Environ("Username")
    Set wb = GetObject("C:\Users\" & user_name & "\Downloads\KNQ_OnHand.xlsx")
    arr = wb.ActiveSheet.[a1].CurrentRegion
    wb.Close False
    
    With Sheet9
        .Cells.Clear
        .Columns("a:a").NumberFormat = "@"
        If IsEmptyArray(arr) Then
           Exit Sub
        Else
            For i = 2 To UBound(arr)
                k = arr(i, 8)
                If Not d.exists(k) Then
                    d.Add k, Array(arr(i, 8), arr(i, 13), arr(i, 16), arr(i, 17))
                Else
                    d(k) = Array(arr(i, 8), d(k)(1) + arr(i, 13), d(k)(2) + arr(i, 16), d(k)(3) + arr(i, 17))
                End If
            Next
            
            n = 2
            For Each key In d.keys
                .Range("a" & n).Value = d(key)(0)
                .Range("b" & n).Value = d(key)(1)
                .Range("c" & n).Value = d(key)(2)
                .Range("d" & n).Value = d(key)(3)
                n = n + 1
                
            Next
            .Range("a1:d1").Value = Array("Item", "ImportedQty", "ExportedQty", "KNQ_ONHAND")
                    
        End If
    .Columns.AutoFit
    End With
    
    Erase arr
    Set d = Nothing
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

