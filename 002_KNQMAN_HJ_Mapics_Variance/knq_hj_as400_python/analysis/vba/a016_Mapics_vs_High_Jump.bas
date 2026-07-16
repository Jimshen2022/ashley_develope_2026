Attribute VB_Name = "a016_Mapics_vs_High_Jump"
Sub a016_Mapics_vs_High_Jump_()

    Application.ScreenUpdating = False
    Dim wb As Workbook
    Dim arr, brr(), i&, j&, k&, nrow&, crr()
    
    't = Timer
'    Sheet4.Range("a1").Value = "Data collected at:" & Format(Now(), "hhmm,mm-dd-yyyy")
    
    Sheet27.Cells.Clear
    
    Set wb = GetObject("C:\Users\jishen\Downloads\Mapics_vs._High_Jump_vs.xlsx")
    arr = wb.ActiveSheet.[a1].CurrentRegion
    wb.Close False
'    ReDim brr(1 To UBound(arr), 1 To 18)
'    For i = 1 To UBound(arr)
'        For j = 1 To 18
'            brr(i, j) = arr(i, j)
'        Next
'    Next
    With Sheet27

        .Columns("a:ab").NumberFormat = "@"
        .Range("a1").Resize(UBound(arr), UBound(arr, 2)) = arr
        .Range("P1").Value = 1
        .Range("P1").Copy
         
 
        nrow = .Range("a1048576").End(3).Row
        .Range("C3:M" & nrow).PasteSpecial xlPasteValues, xlPasteSpecialOperationMultiply, False, False
        
        .Columns("a:m").AutoFit
        
    End With
    
    Application.ScreenUpdating = True
    'MsgBox Format(Timer - t, "0.00" & "s")
    
End Sub
