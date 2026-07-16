Attribute VB_Name = "a020_CopyFilteredData_SH001AA2"
Sub a020_CopyFilteredData_SH001AA2_()
    Dim wsSource As Worksheet, wsDest As Worksheet
    Dim lastRow As Long, lastCol As Long
    Dim locationCol As Integer
    
    ' Set the source worksheet
    Set wsSource = ThisWorkbook.Sheets("HJ_SN")
    
    ' Ensure the destination worksheet exists; if not, create it
    On Error Resume Next
    Set wsDest = ThisWorkbook.Sheets("SH001AA2")
    If wsDest Is Nothing Then
        Set wsDest = ThisWorkbook.Sheets.Add
        wsDest.Name = "SH001AA2"
    End If
    On Error GoTo 0
    
    ' Clear all contents in the destination worksheet
    wsDest.Cells.Clear
    
    ' Find the last row and last column in the source worksheet
    lastRow = wsSource.Cells(wsSource.Rows.Count, 1).End(xlUp).Row
    lastCol = wsSource.Cells(1, wsSource.Columns.Count).End(xlToLeft).Column
    
    ' Locate the "Location" column
    locationCol = 0
    Dim cell As Range
    For Each cell In wsSource.Rows(1).Cells
        If cell.Value = "location_id" Then
            locationCol = cell.Column
            Exit For
        End If
    Next cell
    
    ' If "Location" column is not found, exit
    If locationCol = 0 Then
        MsgBox "Location column not found", vbExclamation
        Exit Sub
    End If
    
    ' Apply AutoFilter to filter only rows where Location = SH001AA1
    wsSource.Range(wsSource.Cells(1, 1), wsSource.Cells(lastRow, lastCol)).AutoFilter Field:=locationCol, Criteria1:="SH001AA2"
    
    ' Copy visible data including header
    wsSource.UsedRange.SpecialCells(xlCellTypeVisible).Copy
    
    ' Paste into the destination worksheet
    wsDest.Range("A1").PasteSpecial Paste:=xlPasteAll
    
    ' Turn off AutoFilter
    wsSource.AutoFilterMode = False
    
    ' Clear clipboard to improve performance
    Application.CutCopyMode = False
    
'    MsgBox "Data copied successfully!", vbInformation
End Sub


