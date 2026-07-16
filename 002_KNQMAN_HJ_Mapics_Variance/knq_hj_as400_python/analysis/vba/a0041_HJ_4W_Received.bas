Attribute VB_Name = "a0041_HJ_4W_Received"
Sub a0041_HJ_4W_Received_()

    Application.ScreenUpdating = False
    Dim wb As Workbook, wb2 As Workbook
    Dim arr, arr2, tempArray, n&, i&
    Dim user_name As String
    Dim k$, key, d As Object
    Set d = CreateObject("scripting.dictionary")
    
    user_name = Environ("Username")
    
    ' ¶ÁÈ¡µÚÒ»¸öÎÄ¼þ
    Set wb = GetObject("C:\Users\" & user_name & "\Downloads\HJ_4W_RECEIVED.xlsx")
    arr = wb.ActiveSheet.[a1].CurrentRegion
    wb.Close False

    ' ¶ÁÈ¡µÚ¶þ¸öÎÄ¼þ
    Set wb2 = GetObject("C:\Users\" & user_name & "\Downloads\HJ_4W_RECEIVED_951.xlsx")
    arr2 = wb2.ActiveSheet.[a1].CurrentRegion
    wb2.Close False

    ' ºÏ²¢Á½¸öÊý×é
    If UBound(arr2, 1) > 1 Then ' È·±£µÚ¶þ¸öÎÄ¼þ²»ÊÇ¿ÕµÄ
        ReDim tempArray(1 To UBound(arr, 1) + UBound(arr2, 1) - 1, 1 To UBound(arr, 2))
        For i = 1 To UBound(arr, 1)
            For j = 1 To UBound(arr, 2)
                tempArray(i, j) = arr(i, j)
            Next j
        Next i
        For i = 2 To UBound(arr2, 1) ' ´ÓµÚ¶þÐÐ¿ªÊ¼£¬ÒòÎªÎÒÃÇ¼ÙÉèµÚÒ»ÐÐÊÇ±êÌâÐÐ
            For j = 1 To UBound(arr2, 2)
                If j = 14 Then
                    tempArray(UBound(arr, 1) + i - 1, j) = CInt(-CInt(arr2(i, j)))  ' ½«TRX QTY×ª»»Îª¸ºÊý
                Else
                    tempArray(UBound(arr, 1) + i - 1, j) = arr2(i, j)
                End If
            Next j
        Next i
        arr = tempArray ' ¸üÐÂarrÎªºÏ²¢ºóµÄÊý×é
    End If

    ' ´¦ÀíºÏ²¢ºóµÄÊý×é
    For i = 2 To UBound(arr)
        ' Item Number, CTN, PO, DATE, TRX QTY
        d(arr(i, 1) & "|" & arr(i, 11) & "|" & arr(i, 12) & "|" & arr(i, 20)) = d(arr(i, 1) & "|" & arr(i, 11) & "|" & arr(i, 12) & "|" & arr(i, 20)) + CInt(arr(i, 14))
    Next

    With Sheet12
        .Cells.Clear
'        .Columns("g:g").NumberFormat = "dd-mm-yyyy"
        .Columns("a:c").NumberFormat = "@"
'        .Columns("h:h").NumberFormat = "@"
'        .Columns("p:p").NumberFormat = "@"
'        .Range("g2:g" & .Range("a1048576").End(3).Row).Value = .Range("g2:g" & .Range("a1048576").End(3).Row).Value
        If IsEmptyArray(arr) Then
           Exit Sub
        Else
            n = 2
            For Each key In d.keys
                .Range("a" & n) = Split(key, "|")(0)
                .Range("b" & n) = Split(key, "|")(1)
                .Range("c" & n) = Split(key, "|")(2)
                .Range("d" & n) = Split(key, "|")(3)
                .Range("e" & n) = d(key)
                n = n + 1
            Next
            
            .Range("a1:e1").Value = Array("Item#", "Container#", "PO#", "Date", "Received_Qty")
            
                    
        End If
    
    .Columns.AutoFit
    .Range("a1:e1").Interior.ColorIndex = 10
    .Range("a1:e1").Font.ColorIndex = 2
'    .Range("p1").Interior.ColorIndex = 10
'    .Range("p1").Font.ColorIndex = 2
'    .Range("s1").Interior.ColorIndex = 10
'    .Range("s1").Font.ColorIndex = 2
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
