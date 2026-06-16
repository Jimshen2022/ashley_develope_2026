Sub a16_UpdateCapacityDemandSupply_()
    '========================================================================================
    ' Optimize Excel application settings to maximize execution speed
    '========================================================================================
    Application.ScreenUpdating = False
    Application.Calculation = xlCalculationManual
    Application.EnableEvents = False

    '========================================================================================
    ' Define worksheet objects
    '========================================================================================
    Dim wb As Workbook: Set wb = ThisWorkbook
    Dim wsCap As Worksheet: Set wsCap = wb.Sheets("Capacity vs Demand vs Supply")
    Dim wsItem As Worksheet: Set wsItem = wb.Sheets("Item_Master")
    Dim wsLoc As Worksheet: Set wsLoc = wb.Sheets("LocationCapacity")
    Dim wsOnHand As Worksheet: Set wsOnHand = wb.Sheets("Onhand")
    Dim wsYard As Worksheet: Set wsYard = wb.Sheets("Yard")
    Dim wsOpenPO As Worksheet: Set wsOpenPO = wb.Sheets("OpenPO")
    Dim wsFirmedPO As Worksheet: Set wsFirmedPO = wb.Sheets("Firmed_Planned_PO")
    Dim wsCO As Worksheet: Set wsCO = wb.Sheets("CustomerOrder")

    '========================================================================================
    ' Step 0: Clear all filters from all worksheets before processing
    '========================================================================================
    Dim tempWs As Worksheet
    For Each tempWs In wb.Worksheets
        If tempWs.AutoFilterMode Then
            tempWs.AutoFilterMode = False
        End If
    Next tempWs

    '========================================================================================
    ' Step 1: Write dynamic dates into E2~L2 (Saturday of current week, +7 days for next)
    '========================================================================================
    Dim dToday As Date: dToday = Date
    ' Find the Saturday of the current week
    Dim satDate As Date: satDate = dToday - Weekday(dToday, vbSunday) + 7
    Dim c As Integer
    For c = 5 To 12 ' Corresponds to columns E to L
        wsCap.Cells(2, c).Value = satDate + (c - 5) * 7
    Next c

    '========================================================================================
    ' Step 2: Load Item_Master into a dictionary for ultra-fast VLOOKUP
    '========================================================================================
    Dim dictItem As Object: Set dictItem = CreateObject("Scripting.Dictionary")
    dictItem.CompareMode = vbTextCompare
    Dim lrItem As Long: lrItem = wsItem.Cells(wsItem.Rows.Count, "A").End(xlUp).Row
    Dim arrItem As Variant: arrItem = wsItem.Range("A2:F" & lrItem).Value
    Dim i As Long
    For i = 1 To UBound(arrItem)
        If Not IsEmpty(arrItem(i, 1)) And Not IsError(arrItem(i, 1)) Then
            ' Key: itnbr (Col A), Value: Product (Col F)
            dictItem(CStr(arrItem(i, 1))) = arrItem(i, 6)
        End If
    Next i

    ' Initialize dictionaries for aggregated metrics
    Dim dictCap As Object: Set dictCap = CreateObject("Scripting.Dictionary")
    Dim dictOH As Object: Set dictOH = CreateObject("Scripting.Dictionary")
    Dim dictYard As Object: Set dictYard = CreateObject("Scripting.Dictionary")
    Dim dictInTransit As Object: Set dictInTransit = CreateObject("Scripting.Dictionary")
    Dim dictPO As Object: Set dictPO = CreateObject("Scripting.Dictionary")
    Dim dictFirmed As Object: Set dictFirmed = CreateObject("Scripting.Dictionary")
    Dim dictPlanned As Object: Set dictPlanned = CreateObject("Scripting.Dictionary")
    Dim dictTripped As Object: Set dictTripped = CreateObject("Scripting.Dictionary")
    Dim dictOpenCO As Object: Set dictOpenCO = CreateObject("Scripting.Dictionary")

    Dim lr As Long, arr As Variant, arrP2 As Variant, itm As String, prod As String
    Dim qty As Double, dt As Long
    Dim colQty As Variant, colDate As Variant

    '========================================================================================
    ' Step 3: Iterate and summarize LocationCapacity sheet (Rule 1)
    '========================================================================================
    lr = wsLoc.Cells(wsLoc.Rows.Count, "A").End(xlUp).Row
    Dim colSub As Variant, colCtrl As Variant
    colSub = Application.Match("Sub_Area_1", wsLoc.Rows(1), 0)
    colCtrl = Application.Match("Loc_Control_Value", wsLoc.Rows(1), 0)

    ' Expanded array range from A2:W to A2:AG to prevent "Subscript out of range"
    arr = wsLoc.Range("A2:AG" & lr).Value

    For i = 1 To UBound(arr)
        ' Verify that Match found the columns successfully
        If Not IsError(colCtrl) And Not IsError(colSub) Then
            ' Bypass #N/A or error cells to prevent Type Mismatch (Error 13)
            If Not IsError(arr(i, colCtrl)) And Not IsError(arr(i, colSub)) Then
                If arr(i, colCtrl) = "A" Then
                    prod = CStr(arr(i, colSub))
                    qty = val(arr(i, 23)) ' Col W is always 23
                    dictCap(prod) = dictCap(prod) + qty
                    dictCap("ALL") = dictCap("ALL") + qty ' Aggregate to ALL
                End If
            End If
        End If
    Next i

    '========================================================================================
    ' Step 4: Iterate and summarize Onhand sheet (Rules 2, 7)
    '========================================================================================
    lr = wsOnHand.Cells(wsOnHand.Rows.Count, "A").End(xlUp).Row
    wsOnHand.Range("I1").Value = "Product2"
    arr = wsOnHand.Range("A2:I" & lr).Value ' A:item_number, B:Qty, I:Product2
    ReDim arrP2(1 To UBound(arr), 1 To 1)
    For i = 1 To UBound(arr)
        If Not IsError(arr(i, 1)) Then
            itm = CStr(arr(i, 1))
            If dictItem.Exists(itm) Then arr(i, 9) = dictItem(itm)
        End If
        arrP2(i, 1) = arr(i, 9) ' Prepare to write back to Col I
        If Not IsError(arr(i, 9)) Then
            prod = CStr(arr(i, 9))
            qty = val(arr(i, 2))
            dictOH(prod) = dictOH(prod) + qty
            dictOH("ALL") = dictOH("ALL") + qty
        End If
    Next i
    wsOnHand.Range("I2:I" & lr).Value = arrP2 ' Write back in batch to improve efficiency

    '========================================================================================
    ' Step 5: Iterate and summarize Yard sheet (Rules 3, 8)
    '========================================================================================
    lr = wsYard.Cells(wsYard.Rows.Count, "K").End(xlUp).Row
    wsYard.Range("U1") = "Product2"
    colQty = Application.Match("Qty Remaining", wsYard.Rows(1), 0)
    colDate = Application.Match("WeekSaturday", wsYard.Rows(1), 0)
    arr = wsYard.Range("A2:U" & lr).Value ' K:Item Number, U:Product2
    ReDim arrP2(1 To UBound(arr), 1 To 1)
    For i = 1 To UBound(arr)
        If Not IsError(arr(i, 11)) Then
            itm = CStr(arr(i, 11)) ' Col K
            If dictItem.Exists(itm) Then arr(i, 21) = dictItem(itm) ' Col U
        End If
        arrP2(i, 1) = arr(i, 21)

        If Not IsError(arr(i, 21)) And Not IsError(arr(i, colDate)) Then
            prod = CStr(arr(i, 21))
            If IsDate(arr(i, colDate)) Then
                ' Use Int() to strip out any time component and strictly retain the date
                dt = CLng(Int(CDate(arr(i, colDate))))
                qty = val(arr(i, colQty))
                dictYard(prod & "|" & dt) = dictYard(prod & "|" & dt) + qty
                dictYard("ALL|" & dt) = dictYard("ALL|" & dt) + qty
            End If
        End If
    Next i
    wsYard.Range("U2:U" & lr).Value = arrP2

    '========================================================================================
    ' Step 6: Iterate and summarize OpenPO sheet (Rules 4, 9, 10)
    '========================================================================================
    lr = wsOpenPO.Cells(wsOpenPO.Rows.Count, "B").End(xlUp).Row
    wsOpenPO.Range("t1").Value = "Product2"
    colDate = Application.Match("WeekSaturday", wsOpenPO.Rows(1), 0)
    arr = wsOpenPO.Range("A2:T" & lr).Value ' B:ITNBR, N:OPEN_PO, Q:New_Status, T:Product2
    ReDim arrP2(1 To UBound(arr), 1 To 1)
    For i = 1 To UBound(arr)
        If Not IsError(arr(i, 2)) Then
            itm = CStr(arr(i, 2))
            If dictItem.Exists(itm) Then arr(i, 20) = dictItem(itm)
        End If
        arrP2(i, 1) = arr(i, 20)

        If Not IsError(arr(i, 20)) And Not IsError(arr(i, colDate)) And Not IsError(arr(i, 17)) Then
            prod = CStr(arr(i, 20))
            If IsDate(arr(i, colDate)) Then
                ' Strip time component
                dt = CLng(Int(CDate(arr(i, colDate))))
                qty = val(arr(i, 14)) ' Col N OPEN_PO
                Dim stat As String: stat = CStr(arr(i, 17)) ' Col Q New_Status
                If stat = "In_Transit" Then
                    dictInTransit(prod & "|" & dt) = dictInTransit(prod & "|" & dt) + qty
                    dictInTransit("ALL|" & dt) = dictInTransit("ALL|" & dt) + qty
                ElseIf stat = "Open_PO" Then
                    dictPO(prod & "|" & dt) = dictPO(prod & "|" & dt) + qty
                    dictPO("ALL|" & dt) = dictPO("ALL|" & dt) + qty
                End If
            End If
        End If
    Next i
    wsOpenPO.Range("T2:T" & lr).Value = arrP2

    '========================================================================================
    ' Step 7: Iterate and summarize Firmed_Planned_PO sheet (Rules 5, 11, 12)
    '========================================================================================
    lr = wsFirmedPO.Cells(wsFirmedPO.Rows.Count, "A").End(xlUp).Row
    wsFirmedPO.Range("i1").Value = "Product2"
    colDate = Application.Match("spdWeekEnding", wsFirmedPO.Rows(1), 0)
    arr = wsFirmedPO.Range("A2:I" & lr).Value ' A:spdItem, D:spdFirm, E:spdPlanned, I:Product2
    ReDim arrP2(1 To UBound(arr), 1 To 1)
    For i = 1 To UBound(arr)
        If Not IsError(arr(i, 1)) Then
            itm = CStr(arr(i, 1))
            If dictItem.Exists(itm) Then arr(i, 9) = dictItem(itm)
        End If
        arrP2(i, 1) = arr(i, 9)

        If Not IsError(arr(i, 9)) And Not IsError(arr(i, colDate)) Then
            prod = CStr(arr(i, 9))
            If IsDate(arr(i, colDate)) Then
                ' Strip time component
                dt = CLng(Int(CDate(arr(i, colDate))))
                dictFirmed(prod & "|" & dt) = dictFirmed(prod & "|" & dt) + val(arr(i, 4)) ' Col D
                dictFirmed("ALL|" & dt) = dictFirmed("ALL|" & dt) + val(arr(i, 4))
                dictPlanned(prod & "|" & dt) = dictPlanned(prod & "|" & dt) + val(arr(i, 5)) ' Col E
                dictPlanned("ALL|" & dt) = dictPlanned("ALL|" & dt) + val(arr(i, 5))
            End If
        End If
    Next i
    wsFirmedPO.Range("I2:I" & lr).Value = arrP2

    '========================================================================================
    ' Step 8: Iterate and summarize CustomerOrder sheet (Rules 6, 13, 14)
    '========================================================================================
    lr = wsCO.Cells(wsCO.Rows.Count, "E").End(xlUp).Row
    wsCO.Range("ar1").Value = "Product2"
    arr = wsCO.Range("A2:AR" & lr).Value ' E:ITNBR, U:OPEN_CO_QTY, Z:BDITQT, AP(42):WEEKSATURDAY, AR(44):Product2
    ReDim arrP2(1 To UBound(arr), 1 To 1)
    For i = 1 To UBound(arr)
        If Not IsError(arr(i, 5)) Then
            itm = CStr(arr(i, 5))
            If dictItem.Exists(itm) Then arr(i, 44) = dictItem(itm)
        End If
        arrP2(i, 1) = arr(i, 44)

        If Not IsError(arr(i, 44)) And Not IsError(arr(i, 42)) Then
            prod = CStr(arr(i, 44))
            If IsDate(arr(i, 42)) Then
                ' Strip time component
                dt = CLng(Int(CDate(arr(i, 42))))
                Dim bditqt As Double: bditqt = val(arr(i, 26))
                Dim openco As Double: openco = val(arr(i, 21))

                dictTripped(prod & "|" & dt) = dictTripped(prod & "|" & dt) + bditqt
                dictTripped("ALL|" & dt) = dictTripped("ALL|" & dt) + bditqt

                If bditqt = 0 Then
                    dictOpenCO(prod & "|" & dt) = dictOpenCO(prod & "|" & dt) + openco
                    dictOpenCO("ALL|" & dt) = dictOpenCO("ALL|" & dt) + openco
                End If
            End If
        End If
    Next i
    wsCO.Range("AR2:AR" & lr).Value = arrP2

    '========================================================================================
    ' Step 9: Populate data and formulas into the main dashboard sheet (Rules 15, 16, 17)
    '========================================================================================
    lr = wsCap.Cells(wsCap.Rows.Count, "D").End(xlUp).Row
    Dim r As Long, curCat As String, typeStr As String, dKey As String
    Dim dateVal As Variant

    ' Clear the target cells (E3 to L last row) before populating new data
    If lr >= 3 Then
        wsCap.Range("E3:L" & lr).ClearContents
    End If

    For r = 3 To lr
        ' Safely extract Category from Column B (Bypass #N/A)
        If Not IsError(wsCap.Cells(r, "B").Value) Then
            If Trim(wsCap.Cells(r, "B").Value) <> "" Then curCat = Trim(CStr(wsCap.Cells(r, "B").Value))
        End If

        ' Safely extract Type from Column D (Bypass #N/A)
        If IsError(wsCap.Cells(r, "D").Value) Then
            typeStr = "" ' Treat error as blank string to prevent Type Mismatch
        Else
            typeStr = Trim(CStr(wsCap.Cells(r, "D").Value))
        End If

        ' Only process if typeStr is not empty
        If typeStr <> "" Then
            For c = 5 To 12 ' Columns E to L
                ' Safely parse the Date header (Main sheet dates do not have time format)
                dateVal = wsCap.Cells(2, c).Value
                If IsNumeric(dateVal) Or IsDate(dateVal) Then
                    dKey = curCat & "|" & CLng(dateVal)
                Else
                    dKey = curCat & "|0"
                End If

                ' Match D column text intelligently to map data
                If InStr(1, typeStr, "Capacity Balance", vbTextCompare) > 0 Then
                    wsCap.Cells(r, c).FormulaR1C1 = "=R[-10]C-R[-1]C"

                ElseIf InStr(1, typeStr, "Capacity", vbTextCompare) > 0 Then
                    ' Round Capacity to 0 decimal places to remove decimals
                    wsCap.Cells(r, c).Value = Round(val(dictCap(curCat)), 0)

                ElseIf InStr(1, typeStr, "ONHAND", vbTextCompare) > 0 Or InStr(1, typeStr, "Onhand", vbTextCompare) > 0 Then
                    If c = 5 Then wsCap.Cells(r, c).Value = val(dictOH(curCat)) ' Fill Col E only

                ElseIf InStr(1, typeStr, "Yard", vbTextCompare) > 0 Then
                    wsCap.Cells(r, c).Value = val(dictYard(dKey))

                ElseIf InStr(1, typeStr, "In-Transit", vbTextCompare) > 0 Then
                    wsCap.Cells(r, c).Value = val(dictInTransit(dKey))

                ElseIf InStr(1, typeStr, "OpenPO", vbTextCompare) > 0 Or InStr(1, typeStr, "Open PO", vbTextCompare) > 0 Then
                    wsCap.Cells(r, c).Value = val(dictPO(dKey))

                ElseIf InStr(1, typeStr, "Firmed", vbTextCompare) > 0 Or InStr(1, typeStr, "Fimed", vbTextCompare) > 0 Then
                    wsCap.Cells(r, c).Value = val(dictFirmed(dKey))

                ElseIf InStr(1, typeStr, "Planned", vbTextCompare) > 0 Then
                    wsCap.Cells(r, c).Value = val(dictPlanned(dKey))

                ElseIf InStr(1, typeStr, "Tripped", vbTextCompare) > 0 Then
                    wsCap.Cells(r, c).Value = val(dictTripped(dKey))

                ElseIf InStr(1, typeStr, "OpenCO", vbTextCompare) > 0 Or InStr(1, typeStr, "Open CO", vbTextCompare) > 0 Then
                    wsCap.Cells(r, c).Value = val(dictOpenCO(dKey))

                ElseIf InStr(1, typeStr, "DS Balance", vbTextCompare) > 0 Then
                    If c = 5 Then
                        wsCap.Cells(r, c).FormulaR1C1 = "=R[-8]C+R[-7]C+R[-6]C+R[-5]C+R[-3]C-R[-2]C-R[-1]C"
                    Else
                        wsCap.Cells(r, c).FormulaR1C1 = "=RC[-1]+R[-7]C+R[-6]C+R[-5]C+R[-3]C-R[-2]C-R[-1]C"
                    End If

                ElseIf InStr(1, typeStr, "Utilization", vbTextCompare) > 0 Then
                    wsCap.Cells(r, c).FormulaR1C1 = "=IF(R[-11]C=0,0,R[-2]C/R[-11]C)"
                    wsCap.Cells(r, c).NumberFormat = "0.00%"

                End If
            Next c
        End If
    Next r

    '========================================================================================
    ' Step 10: Clean up memory (Clear dictionaries and arrays)
    '========================================================================================
    Erase arrItem
    Erase arr
    Erase arrP2

    Set dictItem = Nothing
    Set dictCap = Nothing
    Set dictOH = Nothing
    Set dictYard = Nothing
    Set dictInTransit = Nothing
    Set dictPO = Nothing
    Set dictFirmed = Nothing
    Set dictPlanned = Nothing
    Set dictTripped = Nothing
    Set dictOpenCO = Nothing

    '========================================================================================
    ' Restore Excel application settings
    '========================================================================================
    Application.Calculation = xlCalculationAutomatic
    Application.ScreenUpdating = True
    Application.EnableEvents = True

    MsgBox "Data successfully updated!", vbInformation
End Sub
