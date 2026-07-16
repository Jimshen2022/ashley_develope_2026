Attribute VB_Name = "a0_Pull_HJ_data"

Sub a0_Pull_HJ_SN_IN_WH_SQLADD_()
    Dim wb As Workbook
    Dim arr, brr(), i&, j&, k&, nrow&, crr()
    
    't = Timer
    Application.ScreenUpdating = False
    'Sheet25.Range("a1").Value = "Data collected at:" & Format(Now(), "hhmm,mm-dd-yyyy")
    
    Sheet2.Cells.ClearContents
    Set wb = GetObject("C:\Users\jishen\Downloads\AT_SN_INWAREHOUSE.xlsx") '´ò¿ª¹¤×÷²¾
    arr = wb.ActiveSheet.[a1].CurrentRegion
    wb.Close False
'    ReDim brr(1 To UBound(arr), 1 To 16)
'    For i = 1 To UBound(arr)
'        For j = 1 To 16
'            brr(i, j) = arr(i, j)
'        Next
'    Next
    With Sheet2
        .Columns("a:o").NumberFormat = "@"
        .Columns("a:o").EntireColumn.AutoFit
        .Range("a1").Resize(UBound(arr)).Value = Application.Index(arr, , 1)
        .Range("b1").Resize(UBound(arr)).Value = Application.Index(arr, , 2)
        .Range("c1").Resize(UBound(arr)).Value = Application.Index(arr, , 3)
        .Range("d1").Resize(UBound(arr)).Value = Application.Index(arr, , 5)
        .Range("e1").Resize(UBound(arr)).Value = Application.Index(arr, , 6)
        .Range("f1").Resize(UBound(arr)).Value = Application.Index(arr, , 9)
        .Range("g1").Resize(UBound(arr)).Value = Application.Index(arr, , 11)
        
    End With



    Erase arr
'    Erase brr
    
    Call Pull_AT_SN_Loaded
    Call Pull_AT_SN_Hold
    Call Pull_AS_NG_SN
    Call Pull_AT_Orphaned_SN
    Call Pull_AT_SNA_REPORT
    
    
    ' get rid of HJ_SN Sheet that Active Status = orphaned
    
    With Sheet2
        nrow = .Range("d1048576").End(3).Row
        For i = nrow To 2 Step -1
            If .Cells(i, "d") = "Orphaned" Then
                .Cells(i, "d").EntireRow.Delete
            End If
        Next

    End With
    
    Application.ScreenUpdating = True
    'MsgBox Format(Timer - t, "0.00" & "s")
    
End Sub

Sub Pull_AT_SN_Loaded() '¿ç¹¤×÷±¡ÌáÈ¡NG_SN_LOADED_LIST --- finished
    
    On Error Resume Next
    Application.ScreenUpdating = False
    Dim wb As Workbook
    Dim arr, brr(), i&, j&, k&, nrow&, crr()
    nrow = Sheet2.Range("a1048576").End(3).Row

    Set wb = GetObject("C:\Users\jishen\Downloads\AT_SN_LOADED.xlsx") '´ò¿ª¹¤×÷²¾
'    arr = wb.ActiveSheet.[a1].CurrentRegion
    arr = wb.ActiveSheet.Range("a2:p" & wb.ActiveSheet.Range("a1048576").End(3).Row)
    
'    ReDim brr(2 To UBound(arr), 1 To 16)
    wb.Close False
    
'    For i = 2 To UBound(arr)
'            For j = 1 To 16
'            brr(i, j) = arr(i, j)
'        Next
'    Next

    With Sheet2
    
        .Range("a1048576").End(3).Offset(1).Resize(UBound(arr)).Value = Application.Index(arr, , 1)
        .Range("b1048576").End(3).Offset(1).Resize(UBound(arr)).Value = Application.Index(arr, , 2)
        .Range("c1048576").End(3).Offset(1).Resize(UBound(arr)).Value = Application.Index(arr, , 3)
        .Range("d1048576").End(3).Offset(1).Resize(UBound(arr)).Value = Application.Index(arr, , 5)
        .Range("e1048576").End(3).Offset(1).Resize(UBound(arr)).Value = Application.Index(arr, , 6)
        .Range("f1048576").End(3).Offset(1).Resize(UBound(arr)).Value = Application.Index(arr, , 9)
        .Range("g1048576").End(3).Offset(1).Resize(UBound(arr)).Value = Application.Index(arr, , 11)
        
    'Sheet22.Range("a" & nrow).Offset(1).Resize(UBound(arr) - 1, 15) = brr
    
    End With
    
    Erase arr
    
    
    Application.ScreenUpdating = True
    'MsgBox "udpated"
End Sub

Sub Pull_AT_SN_Hold() '¿ç¹¤×÷±¡ÌáÈ¡NG_SN_hold_LIST --- finished
    
    On Error Resume Next
    Application.ScreenUpdating = False
    Dim wb As Workbook
    Dim arr, brr(), i&, j&, k&, nrow&, crr()
    nrow = Sheet2.Range("a1048576").End(3).Row

    Set wb = GetObject("C:\Users\jishen\Downloads\AT_SN_HOLD.xlsx") '´ò¿ª¹¤×÷²¾
    arr = wb.ActiveSheet.[a1].CurrentRegion
    ReDim brr(2 To UBound(arr), 1 To 16)
    wb.Close False
    
'    For i = 2 To UBound(arr)
'            For j = 1 To 16
'            brr(i, j) = arr(i, j)
'        Next
'    Next
    With Sheet2
        .Range("a1048576").End(3).Offset(1).Resize(UBound(arr)).Value = Application.Index(arr, , 1)
        .Range("b1048576").End(3).Offset(1).Resize(UBound(arr)).Value = Application.Index(arr, , 2)
        .Range("c1048576").End(3).Offset(1).Resize(UBound(arr)).Value = Application.Index(arr, , 3)
        .Range("d1048576").End(3).Offset(1).Resize(UBound(arr)).Value = Application.Index(arr, , 5)
        .Range("e1048576").End(3).Offset(1).Resize(UBound(arr)).Value = Application.Index(arr, , 6)
        .Range("f1048576").End(3).Offset(1).Resize(UBound(arr)).Value = Application.Index(arr, , 9)
        .Range("g1048576").End(3).Offset(1).Resize(UBound(arr)).Value = Application.Index(arr, , 11)
    End With
    'Sheet22.Range("a" & nrow).Offset(1).Resize(UBound(arr) - 1, 15) = brr
'    Sheet22.Activate
    Erase arr
'    Erase brr
    Application.ScreenUpdating = True
    'MsgBox "udpated"
End Sub


Sub Pull_AS_NG_SN()
    '¿ç¹¤×÷±¡ÌáÈ¡NG_SN_LIST --- finished
    Application.ScreenUpdating = False
    
    Dim arr, brr, i&, j&, n&
    Dim warehouseCol&, serialCol&, itemCol&, locationCol&, dateCol&
    Dim targetCols As Variant
    
    n = 0 ' ³õÊ¼»¯¼ÆÊýÆ÷
    
    With Sheet2
        arr = .Range("a1").CurrentRegion
        
        ' ²éÕÒÄ¿±êÁÐµÄÎ»ÖÃ
        warehouseCol = 0: serialCol = 0: itemCol = 0: locationCol = 0: dateCol = 0
        
        For j = 1 To UBound(arr, 2)
            Select Case UCase(Trim(arr(1, j)))
                Case "WAREHOUSE"
                    warehouseCol = j
                Case "SERIAL NUMBER"
                    serialCol = j
                Case "ITEM NUMBER"
                    itemCol = j
                Case "LOCATION"
                    locationCol = j
                Case "RECEIVED DATE"
                    dateCol = j
            End Select
        Next
        
        ' COUNT HOW MANY ROWS OF NG
        For i = 2 To UBound(arr)
            If arr(i, 6) Like "NG*" Then
                n = n + 1
            End If
        Next
        
        ' Èç¹ûÓÐNGÊý¾Ý£¬Ôò´¦Àí
        If n > 0 Then
            ' ÉùÃ÷½á¹ûÊý×é£¬5ÁÐ(Ä¿±ê×Ö¶Î)
            ReDim brr(1 To n + 1, 1 To 5)
            
            ' ÉèÖÃ±êÌâÐÐ
            brr(1, 1) = "Warehouse"
            brr(1, 2) = "Serial Number"
            brr(1, 3) = "Item Number"
            brr(1, 4) = "Location"
            brr(1, 5) = "Received Date"
            
            ' ÖØÖÃ¼ÆÊýÆ÷£¬ÓÃÓÚbrrÊý×éµÄÐÐË÷Òý
            n = 1
            
            ' ¸´ÖÆNGÊý¾ÝµÄÖ¸¶¨ÁÐ
            For i = 2 To UBound(arr)
                If arr(i, 6) Like "NG*" Then
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

Sub Pull_AT_Orphaned_SN() '¿ç¹¤×÷±¡ÌáÈ¡ORPHANED SN ---finished
    
    Dim wb As Workbook
    Dim srr, brr(), i&, j&, k&, nrow&, crr()
    
    't = Timer
    Application.ScreenUpdating = False
    'Sheet25.Range("a1").Value = "Data collected at:" & Format(Now(), "hhmm,mm-dd-yyyy")
    
    Sheet18.Cells.ClearContents
    
    Set wb = GetObject("C:\Users\jishen\Downloads\AT_SN_ORPHANED.xlsx") '´ò¿ª¹¤×÷²¾
    srr = wb.ActiveSheet.[a1].CurrentRegion
    wb.Close False
'    ReDim brr(1 To UBound(srr), 1 To 15)
'    For i = 1 To UBound(srr)
'        For j = 1 To 15
'            brr(i, j) = srr(i, j)
'        Next
'    Next
    
    With Sheet18
     .Columns("a:h").NumberFormat = "@"
     .Range("a1").Resize(UBound(srr)).Value = Application.Index(srr, , 1)
     .Range("b1").Resize(UBound(srr)).Value = Application.Index(srr, , 2)
     .Range("c1").Resize(UBound(srr)).Value = Application.Index(srr, , 3)
     .Range("d1").Resize(UBound(srr)).Value = Application.Index(srr, , 5)
     .Range("e1").Resize(UBound(srr)).Value = Application.Index(srr, , 6)
     .Range("f1").Resize(UBound(srr)).Value = Application.Index(srr, , 7)
     .Range("g1").Resize(UBound(srr)).Value = Application.Index(srr, , 8)
     .Range("h1").Resize(UBound(srr)).Value = Application.Index(srr, , 9)
     .Range("i1").Resize(UBound(srr)).Value = Application.Index(srr, , 11)
    
     .Columns("a:p").EntireColumn.AutoFit
    
    End With
    
    Erase srr
'    Erase brr
    Application.ScreenUpdating = True
    'MsgBox Format(Timer - t, "0.00" & "s")
    
End Sub

Sub Pull_AT_SNA_REPORT() '¿ç¹¤×÷±¡ÌáÈ¡STO*SNA Report from HJ ---finished
    Dim wb As Workbook
    Dim drr, err(), i&, j&
    
    't = Timer
    Application.ScreenUpdating = False
    Sheet19.Cells.Clear
    
    Set wb = GetObject("C:\Users\jishen\Downloads\AT_SNA.xlsx") '´ò¿ª¹¤×÷²¾
    drr = wb.ActiveSheet.Range("a1:g10000")
    wb.Close False
'    ReDim err(1 To UBound(drr), 1 To 7)
'    For i = 1 To UBound(drr)
'        For j = 1 To 7
'            err(i, j) = drr(i, j)
'        Next
'    Next

    With Sheet19
        .Columns("a:c").NumberFormat = "@"
        .Range("a1").Resize(UBound(drr), 7) = drr
        .Columns("a:g").EntireColumn.AutoFit
        .Columns("d:g").NumberFormat = 0
        .Range("d2:g1000").Value = .Range("d2:g1000").Value

    
    End With
    Erase drr
'    Erase err
    Application.ScreenUpdating = True
    'MsgBox Format(Timer - t, "0.00" & "s")
    
End Sub

