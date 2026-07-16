Attribute VB_Name = "b04_update_shipped_not_invoiced"
Sub b04_update_shipped_not_invoiced_()
    Application.ScreenUpdating = False

    ' ©¤©¤ Declare worksheet variables ©¤©¤
    Dim wsData As Worksheet, wsHJ As Worksheet, wsAS As Worksheet
    Set wsData = ThisWorkbook.Sheets("DATA")
    Set wsHJ = ThisWorkbook.Sheets("HJ_2W_SA")
    Set wsAS = ThisWorkbook.Sheets("AS400_SA")

    ' ©¤©¤ Get last used row in each sheet ©¤©¤
    Dim lastRowDATA As Long, lastRowHJ As Long, lastRowAS As Long
    lastRowDATA = wsData.Cells(wsData.Rows.Count, "B").End(xlUp).Row
    lastRowHJ = wsHJ.Cells(wsHJ.Rows.Count, "A").End(xlUp).Row
    lastRowAS = wsAS.Cells(wsAS.Rows.Count, "A").End(xlUp).Row

    ' ¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T
    ' STEP 1: Locate column indices in DATA sheet by header name
    '         - "Item Number"          ¡ú colDATAItem
    '         - "Shipped Not Invoiced" ¡ú colDATAShipped
    ' ¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T
    Dim colDATAItem As Integer, colDATAShipped As Integer
    Dim hCell As Range
    For Each hCell In wsData.Rows(1).Cells
        If hCell.Value = "" Then Exit For
        Select Case UCase(Trim(hCell.Value))
            Case "ITEM NUMBER":          colDATAItem = hCell.Column
            Case "SHIPPED NOT INVOICED": colDATAShipped = hCell.Column
        End Select
    Next hCell

    ' ¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T
    ' STEP 2: Locate column indices in HJ_2W_SA sheet by header name
    '         - "item_number"      ¡ú colHJItem
    '         - "c_number"         ¡ú colHJCNum
    '         - "qty"              ¡ú colHJQty
    '         - "AS400_SA_Status"  ¡ú colHJStatus
    ' ¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T
    Dim colHJItem As Integer, colHJCNum As Integer
    Dim colHJQty  As Integer, colHJStatus As Integer
    For Each hCell In wsHJ.Rows(1).Cells
        If hCell.Value = "" Then Exit For
        Select Case UCase(Trim(hCell.Value))
            Case "ITEM_NUMBER":     colHJItem = hCell.Column
            Case "C_NUMBER":        colHJCNum = hCell.Column
            Case "QTY":             colHJQty = hCell.Column
            Case "AS400_SA_STATUS": colHJStatus = hCell.Column
        End Select
    Next hCell

    ' ¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T
    ' STEP 3: Locate column indices in AS400_SA sheet by header name
    '         - "ITNBR" ¡ú colASITNBR  (item number in AS400)
    '         - "REFNO" ¡ú colASREFNO  (reference number; right 7 chars matched to c_number)
    '         - "Qty"   ¡ú colASQty
    ' ¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T
    Dim colASITNBR As Integer, colASREFNO As Integer, colASQty As Integer
    For Each hCell In wsAS.Rows(1).Cells
        If hCell.Value = "" Then Exit For
        Select Case UCase(Trim(hCell.Value))
            Case "ITNBR": colASITNBR = hCell.Column
            Case "REFNO": colASREFNO = hCell.Column
            Case "QTY":   colASQty = hCell.Column
        End Select
    Next hCell

    ' ¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T
    ' STEP 4: Build Dictionary 1 (dictNormal)
    '         Source  : HJ_2W_SA
    '         Filter  : AS400_SA_Status = "AS400_STILL_NO_SA"
    '                   AND item_number <> "RP ORDER"
    '         Key     : item_number
    '         Value   : SUM(qty)
    '         Purpose : Used to look up total unresolved qty for regular items
    '                   when writing back to DATA ¡ú Shipped Not Invoiced
    ' ¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T
    Dim dictNormal As Object
    Set dictNormal = CreateObject("Scripting.Dictionary")

    ' ¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T
    ' STEP 5: Build Dictionary 2 (dictRP)
    '         Source  : HJ_2W_SA
    '         Filter  : AS400_SA_Status = "AS400_STILL_NO_SA"
    '                   AND item_number = "RP ORDER"
    '         Key     : c_number
    '         Value   : True (flag only; used as a lookup set)
    '         Purpose : Identifies which c_numbers (from RP ORDER rows) need
    '                   to be cross-referenced against AS400_SA REFNO (right 7 chars)
    ' ¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T
    Dim dictRP As Object
    Set dictRP = CreateObject("Scripting.Dictionary")

    Dim hjItem As String, hjCNum As String, hjQty As Double, hjStatus As String
    Dim k As Long
    For k = 2 To lastRowHJ
        hjItem = Trim(CStr(wsHJ.Cells(k, colHJItem).Value))
        hjStatus = Trim(CStr(wsHJ.Cells(k, colHJStatus).Value))

        If UCase(hjStatus) = "AS400_STILL_NO_SA" Then
            hjQty = Val(wsHJ.Cells(k, colHJQty).Value)
            hjCNum = Trim(CStr(wsHJ.Cells(k, colHJCNum).Value))

            If hjItem = "RP ORDER" Then
                ' Flag this c_number for later REFNO matching in AS400_SA
                If Not dictRP.exists(hjCNum) Then dictRP.Add hjCNum, True
            Else
                ' Accumulate qty by item_number for regular items
                If dictNormal.exists(hjItem) Then
                    dictNormal(hjItem) = dictNormal(hjItem) + hjQty
                Else
                    dictNormal.Add hjItem, hjQty
                End If
            End If
        End If
    Next k

    ' ¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T
    ' STEP 6: Build Dictionary 3 (dictRPResult)
    '         Source  : AS400_SA
    '         Filter  : Right(REFNO, 7) exists in dictRP (i.e. matches a
    '                   c_number flagged from RP ORDER rows in HJ_2W_SA)
    '         Key     : ITNBR (item number in AS400_SA)
    '         Value   : SUM(Qty)
    '         Purpose : Aggregates AS400_SA qty by item number for RP ORDER rows,
    '                   so the total can be added to Shipped Not Invoiced in DATA
    ' ¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T
    Dim dictRPResult As Object
    Set dictRPResult = CreateObject("Scripting.Dictionary")

    Dim asITNBR As String, asREFNO As String, asQty As Double, refno7 As String
    Dim m As Long
    For m = 2 To lastRowAS
        asREFNO = Trim(CStr(wsAS.Cells(m, colASREFNO).Value))
        If Len(asREFNO) >= 7 Then
            refno7 = Right(asREFNO, 7)
            ' Check if this REFNO suffix matches any flagged RP ORDER c_number
            If dictRP.exists(refno7) Then
                asITNBR = Trim(CStr(wsAS.Cells(m, colASITNBR).Value))
                asQty = Val(wsAS.Cells(m, colASQty).Value)
                If dictRPResult.exists(asITNBR) Then
                    dictRPResult(asITNBR) = dictRPResult(asITNBR) + asQty
                Else
                    dictRPResult.Add asITNBR, asQty
                End If
            End If
        End If
    Next m

    ' ¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T
    ' STEP 7: Write back to DATA sheet ¡ú Shipped Not Invoiced column
    '         Logic:
    '           1. Clear the cell first regardless of whether there is a match
    '           2. Look up item number in dictNormal  (regular items)
    '           3. Look up item number in dictRPResult (RP ORDER derived qty)
    '           4. Write the combined total if > 0
    ' ¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T
    Dim dataItem As String
    Dim totalQty As Double
    Dim n As Long
    For n = 2 To lastRowDATA
        dataItem = Trim(CStr(wsData.Cells(n, colDATAItem).Value))

        ' Always clear the cell before writing to avoid stale values
        wsData.Cells(n, colDATAShipped).ClearContents

        totalQty = 0

        ' Add qty from regular item match (HJ_2W_SA, non-RP ORDER)
        If dictNormal.exists(dataItem) Then
            totalQty = totalQty + dictNormal(dataItem)
        End If

        ' Add qty from RP ORDER match (derived from AS400_SA via REFNO)
        If dictRPResult.exists(dataItem) Then
            totalQty = totalQty + dictRPResult(dataItem)
        End If

        ' Only write if there is a non-zero value to populate
        If totalQty <> 0 Then
            wsData.Cells(n, colDATAShipped).Value = totalQty
        End If
    Next n

    Application.ScreenUpdating = True
    'MsgBox "Done! Shipped Not Invoiced column has been updated in DATA sheet.", vbInformation
End Sub
