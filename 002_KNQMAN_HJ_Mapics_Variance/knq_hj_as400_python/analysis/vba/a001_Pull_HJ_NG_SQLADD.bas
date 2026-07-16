Attribute VB_Name = "a001_Pull_HJ_NG_SQLADD"
Sub a001_Pull_HJ_NG_SQLADD_()
    '¿ç¹¤×÷±¡ÌáÈ¡NG_SN_LIST --- finished
    Application.ScreenUpdating = False
    
    Dim arr, brr, i&, j&, n&
    Dim warehouseCol&, serialCol&, itemCol&, locationCol&, dateCol&
    Dim targetCols As Variant
    
    n = 0 ' ³õÊ¼»¯¼ÆÊýÆ÷
    
    With Sheet2
        arr = .Range("a1").CurrentRegion
        
        ' ²éÕÒÄ¿±êÁÐµÄÎ»ÖÃ
        warehouseCol = 1: serialCol = 2: itemCol = 3: locationCol = 6: dateCol = 7
        
        For j = 1 To UBound(arr, 2)
            Select Case UCase(Trim(arr(1, j)))
                Case "wh_id"
                    warehouseCol = j
                Case "serial_number"
                    serialCol = j
                Case "item_number"
                    itemCol = j
                Case "location_id"
                    locationCol = j
                Case "received_date"
                    dateCol = j
            End Select
        Next
        
        ' COUNT HOW MANY ROWS OF NG
        For i = 2 To UBound(arr)
            If arr(i, 6) Like "NG*" And arr(i, 6) <> "NG001SC3" Then
                n = n + 1
            End If
        Next
        
        ' Èç¹ûÓÐNGÊý¾Ý£¬Ôò´¦Àí
        If n > 0 Then
            ' ÉùÃ÷½á¹ûÊý×é£¬5ÁÐ(Ä¿±ê×Ö¶Î)
            ReDim brr(1 To n + 1, 1 To 5)
            
            ' ÉèÖÃ±êÌâÐÐ
            brr(1, 1) = "wh_id"
            brr(1, 2) = "serial_number"
            brr(1, 3) = "item_number"
            brr(1, 4) = "location_id"
            brr(1, 5) = "received_date"
            
            ' ÖØÖÃ¼ÆÊýÆ÷£¬ÓÃÓÚbrrÊý×éµÄÐÐË÷Òý
            n = 1
            
            ' ¸´ÖÆNGÊý¾ÝµÄÖ¸¶¨ÁÐ
            For i = 2 To UBound(arr)
                If arr(i, 6) Like "NG*" And arr(i, 6) <> "NG001SC3" Then
                    n = n + 1
                    brr(n, 1) = IIf(warehouseCol > 0, arr(i, warehouseCol), "")
                    brr(n, 2) = IIf(serialCol > 0, arr(i, serialCol), "")
                    brr(n, 3) = IIf(itemCol > 0, arr(i, itemCol), "")
                    brr(n, 4) = IIf(locationCol > 0, arr(i, locationCol), "")
                    brr(n, 5) = IIf(dateCol > 0, arr(i, dateCol), "")
                End If
            Next
            
            ' Êä³öµ½Sheet17
            With Sheet17
                .Cells.Clear
                .Columns("b:c").NumberFormat = "@"
                .Range("a1").Resize(UBound(brr), UBound(brr, 2)).Value = brr
            End With
        Else
            ' Èç¹ûÃ»ÓÐNGÊý¾Ý£¬Ö»Çå¿ÕSheet17
            Sheet17.Cells.Clear
        End If
    End With
    
    Application.ScreenUpdating = True
End Sub
