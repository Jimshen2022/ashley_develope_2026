Attribute VB_Name = "ThisWorkbook"
Attribute VB_Base = "0{00020819-0000-0000-C000-000000000046}"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = True
Attribute VB_TemplateDerived = False
Attribute VB_Customizable = True

Private Sub Workbook_BeforeClose(Cancel As Boolean)
ThisWorkbook.Save
End Sub

Private Sub Workbook_Open()
    On Error Resume Next
    With ThisWorkbook
        .SaveCopyAs .Path & "\mapics_hj_knqman_variance_backup\" & "Backup_" & Format(Now, "YYYYDDMM HHMMSS") & "__" & .Name
    End With

    Call InitDates
    
    Dim ws As Worksheet
    For Each ws In ThisWorkbook.Worksheets
        ws.Visible = xlSheetVisible
    Next ws
    
End Sub






