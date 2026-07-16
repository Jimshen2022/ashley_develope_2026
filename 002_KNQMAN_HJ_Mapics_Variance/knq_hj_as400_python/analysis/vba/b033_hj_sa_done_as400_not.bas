Attribute VB_Name = "b033_hj_sa_done_as400_not"
Sub b033_hj_sa_done_as400_not_()
    Application.ScreenUpdating = False
    Dim wsHJ As Worksheet
    Dim wsAS As Worksheet
    Dim lastRowHJ As Long
    Dim lastRowAS As Long
    Dim i As Long
    Dim j As Long
    
    Set wsHJ = ThisWorkbook.Sheets("HJ_2W_SA")
    Set wsAS = ThisWorkbook.Sheets("AS400_SA")
    
    lastRowHJ = wsHJ.Cells(wsHJ.Rows.Count, "A").End(xlUp).Row
    lastRowAS = wsAS.Cells(wsAS.Rows.Count, "A").End(xlUp).Row
    
    Dim newCol As Integer
    newCol = 5
    wsHJ.Cells(1, newCol).Value = "AS400_SA_Status"
    
    ' ©¤©¤ ×Öµä1£ºITNBR|ORDNO -> ¼Ó×Ü Qty£¨AS400¶Ë£©
    Dim dictAS As Object
    Set dictAS = CreateObject("Scripting.Dictionary")
    
    ' ©¤©¤ ×Öµä2£ºITEM_NUMBER|C_NUMBER -> ¼Ó×Ü Qty£¨HJ¶Ë£©
    Dim dictHJ As Object
    Set dictHJ = CreateObject("Scripting.Dictionary")
    
    ' ©¤©¤ ×Öµä3£ºREFNOÓÒ7Î» -> True£¨RP ORDERÓÃ£©
    Dim dictREFNO As Object
    Set dictREFNO = CreateObject("Scripting.Dictionary")
    
    ' ÕÒ AS400_SA ¸÷ÁÐË÷Òý
    Dim colITNBR As Integer, colORDNO As Integer, colQtyAS As Integer, colREFNO As Integer
    Dim hCell As Range
    
    For Each hCell In wsAS.Rows(1).Cells
        If hCell.Value = "" Then Exit For
        Select Case UCase(hCell.Value)
            Case "ITNBR":  colITNBR = hCell.Column
            Case "ORDNO":  colORDNO = hCell.Column
            Case "QTY":    colQtyAS = hCell.Column
            Case "REFNO":  colREFNO = hCell.Column
        End Select
    Next hCell
    
    ' AS400¶Ë£º°´ ITNBR|ORDNO ¼Ó×Ü Qty
    For j = 2 To lastRowAS
        Dim itnbr As String
        Dim ordno As String
        Dim qtyAS As Double
        Dim keyAS As String
        
        itnbr = Trim(CStr(wsAS.Cells(j, colITNBR).Value))
        ordno = Trim(CStr(wsAS.Cells(j, colORDNO).Value))
        qtyAS = Val(wsAS.Cells(j, colQtyAS).Value)
        keyAS = itnbr & "|" & ordno
        
        If dictAS.exists(keyAS) Then
            dictAS(keyAS) = dictAS(keyAS) + qtyAS
        Else
            dictAS.Add keyAS, qtyAS
        End If
        
        ' REFNO ÓÒ7Î»
        If colREFNO > 0 Then
            Dim refnoVal As String
            refnoVal = Trim(CStr(wsAS.Cells(j, colREFNO).Value))
            If Len(refnoVal) >= 7 Then
                Dim refnoKey As String
                refnoKey = Right(refnoVal, 7)
                If Not dictREFNO.exists(refnoKey) Then
                    dictREFNO.Add refnoKey, True
                End If
            End If
        End If
    Next j
    
    ' ÕÒ HJ_2W_SA ¸÷ÁÐË÷Òý
    Dim colItem As Integer, colCNum As Integer, colQtyHJ As Integer
    
    For Each hCell In wsHJ.Rows(1).Cells
        If hCell.Value = "" Then Exit For
        Select Case UCase(hCell.Value)
            Case "ITEM_NUMBER": colItem = hCell.Column
            Case "C_NUMBER":    colCNum = hCell.Column
            Case "QTY":         colQtyHJ = hCell.Column
        End Select
    Next hCell
    
    ' HJ¶Ë£º°´ ITEM_NUMBER|C_NUMBER ¼Ó×Ü Qty£¨ÅÅ³ý RP ORDER£©
    For i = 2 To lastRowHJ
        Dim itemNum As String
        Dim cNum As String
        Dim qtyHJ As Double
        Dim keyHJ As String
        
        itemNum = Trim(CStr(wsHJ.Cells(i, colItem).Value))
        cNum = Trim(CStr(wsHJ.Cells(i, colCNum).Value))
        qtyHJ = Val(wsHJ.Cells(i, colQtyHJ).Value)
        keyHJ = itemNum & "|" & cNum
        
        If itemNum <> "RP ORDER" Then
            If dictHJ.exists(keyHJ) Then
                dictHJ(keyHJ) = dictHJ(keyHJ) + qtyHJ
            Else
                dictHJ.Add keyHJ, qtyHJ
            End If
        End If
    Next i
    
    ' ÖðÐÐÐ´Èë×´Ì¬
    For i = 2 To lastRowHJ
        itemNum = Trim(CStr(wsHJ.Cells(i, colItem).Value))
        cNum = Trim(CStr(wsHJ.Cells(i, colCNum).Value))
        keyHJ = itemNum & "|" & cNum
        
        If itemNum = "RP ORDER" Then
            ' RP ORDER£º¼ì²é REFNO ÓÒ7Î»
            If dictREFNO.exists(cNum) Then
                wsHJ.Cells(i, newCol).Value = "AS400_SA_DONE"
            Else
                wsHJ.Cells(i, newCol).Value = "AS400_STILL_NO_SA"
            End If
        Else
            ' Ò»°ã¶©µ¥£ºHJ¼Ó×Ü <= AS400¼Ó×Ü Ôò DONE
            If dictAS.exists(keyHJ) Then
                If dictHJ(keyHJ) <= dictAS(keyHJ) Then
                    wsHJ.Cells(i, newCol).Value = "AS400_SA_DONE"
                Else
                    wsHJ.Cells(i, newCol).Value = "AS400_STILL_NO_SA"
                End If
            Else
                wsHJ.Cells(i, newCol).Value = "AS400_STILL_NO_SA"
            End If
        End If
    Next i
    
    Application.ScreenUpdating = True
    'MsgBox "Done! Column 'AS400_SA_Status' has been added to HJ_2W_SA.", vbInformation
End Sub
