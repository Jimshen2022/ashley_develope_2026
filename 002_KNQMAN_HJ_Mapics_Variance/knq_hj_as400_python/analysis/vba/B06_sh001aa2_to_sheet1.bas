Attribute VB_Name = "B06_sh001aa2_to_sheet1"
Sub B06_sh001aa2_to_sheet1_()
    Application.ScreenUpdating = False
    
    Dim wsSrc As Worksheet, wsData As Worksheet
    Dim arrSrc, arrData
    Dim dict As Object
    Dim i As Long, nrow As Long
    Dim key As String
    
    Set wsSrc = Sheets("SH001AA2")
    Set wsData = Sheet1   ' Code name of the DATA sheet; change to Sheets("DATA") if needed
    
    '---------- Step 1: Load SH001AA2 into an array and count occurrences per item_number ----------
    Set dict = CreateObject("Scripting.Dictionary")
    dict.CompareMode = vbTextCompare   ' Case-insensitive matching; remove if not needed
    
    
    arrSrc = wsSrc.Range("A1").CurrentRegion.Value  ' Columns A:G, including header row
    
    For i = 2 To UBound(arrSrc, 1)
        key = Trim(arrSrc(i, 3))   ' Column C = item_number
        If Len(key) > 0 Then
            If dict.exists(key) Then
                dict(key) = dict(key) + 1
            Else
                dict(key) = 1
            End If
        End If
    Next i
    
    '---------- Step 2: Load DATA sheet, look up dictionary by Item Number (column B), build result array for column Y ----------
    
    Sheet1.Range("y1").Value = "SH001AA2"
    arrData = wsData.Range("A1").CurrentRegion.Value  ' Includes header row
    nrow = UBound(arrData, 1)
    
    
    Dim result()
    ReDim result(1 To nrow, 1 To 1)
    result(1, 1) = "SH001AA2"   ' Header for Y1; keep as-is or remove if header already exists
    
    For i = 2 To nrow
        key = Trim(arrData(i, 2))   ' Column B = Item Number
        If dict.exists(key) Then
            result(i, 1) = dict(key)
        Else
            result(i, 1) = 0
        End If
    Next i
    
    '---------- Step 3: Write the result array back to column Y in a single operation ----------
    wsData.Range("Y1").Resize(nrow, 1).Value = result
    
    Application.ScreenUpdating = True
    
    'MsgBox "Done! " & dict.Count & " unique item_numbers counted.", vbInformation
End Sub
