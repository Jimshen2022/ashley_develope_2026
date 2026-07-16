Attribute VB_Name = "b02_DATA_VARIANCE"
Sub b02_DATA_VARIANCE_()

 Dim ws As Worksheet
    Dim lastRow As Long
    
    Set ws = ThisWorkbook.Worksheets("DATA")
    
    ' ÐÔÄÜÓÅ»¯¿ª¹Ø
    With Application
        .ScreenUpdating = False
        .EnableEvents = False
        .Calculation = xlCalculationManual
    End With
    
    ' ÕÒBÁÐ×îºóÒ»ÐÐ
    lastRow = ws.Cells(ws.Rows.Count, "B").End(xlUp).Row
    
    ' Ò»´ÎÐÔÐ´ÈëÕûÁÐ¹«Ê½£¨¹Ø¼üµã£©
    ws.Range("AH2:AH" & lastRow).Formula = "=-U2"
    ws.Range("AJ2:AJ" & lastRow).Formula = "=ABS(AH2)"
    ws.Range("AK2:AK" & lastRow).Formula = "=SUMIFS('KNQ Variances List'!G:G,'KNQ Variances List'!C:C,B2)"
    ws.Range("AL2:AL" & lastRow).Formula = "=AK2-AJ2"
    
    ' Ò»´ÎÐÔ¼ÆËã£¨±ÜÃâ¶à´Î´¥·¢£©
    Application.Calculate
    
    ' »Ö¸´ÉèÖÃ
    With Application
        .Calculation = xlCalculationAutomatic
        .EnableEvents = True
        .ScreenUpdating = True
    End With

End Sub
