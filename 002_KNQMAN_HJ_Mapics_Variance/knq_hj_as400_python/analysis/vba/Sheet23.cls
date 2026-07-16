Attribute VB_Name = "Sheet23"
Attribute VB_Base = "0{00020820-0000-0000-C000-000000000046}"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = True
Attribute VB_TemplateDerived = False
Attribute VB_Customizable = True
Private Sub Worksheet_Change(ByVal Target As Range)
    Dim cell As Range
    Dim lastCol As Long
    Dim firstCol As Long
    Dim ws As Worksheet
    Set ws = Me

    ' Only respond to changes in Column B
    If Not Intersect(Target, ws.Columns("B")) Is Nothing Then
        Application.EnableEvents = False ' Prevent recursive events

        For Each cell In Intersect(Target, ws.Columns("B"))
            ' Find the last column with data in the same row
            lastCol = ws.Cells(cell.Row, ws.Columns.Count).End(xlToLeft).Column
            firstCol = 1 ' Start from Column A (can be adjusted if needed)

            ' Clear background color in the range with data in this row
            ws.Range(ws.Cells(cell.Row, firstCol), ws.Cells(cell.Row, lastCol)).Interior.ColorIndex = xlNone

            ' Apply color based on the cell value in Column B
            Select Case cell.Value
                Case "KNQ Qty < HJ Qty"
                    ws.Range(ws.Cells(cell.Row, firstCol), ws.Cells(cell.Row, lastCol)).Interior.Color = RGB(191, 191, 191) ' Yellow
                Case "KNQ Qty > HJ Qty"
                    ws.Range(ws.Cells(cell.Row, firstCol), ws.Cells(cell.Row, lastCol)).Interior.Color = RGB(255, 255, 0) ' Gray
                Case Else
                    ' Do nothing for other values
            End Select
        Next cell

        Application.EnableEvents = True ' Re-enable events
    End If
End Sub

