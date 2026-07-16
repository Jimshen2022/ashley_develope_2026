Attribute VB_Name = "Z998_hide"
Sub HideUnlistedSheets()
    Dim ws As Worksheet
    Dim keepSheets As Variant
    Dim nameToKeep As Variant
    Dim found As Boolean

    ' ÐèÒª±£ÁôµÄ¹¤×÷±íÃû
    keepSheets = Array("EX001AA2", "EX001AA1", "SH001AA1", "NG001VD3", _
                       "KNQ Variances List", "Summary", "DATA")

    ' ±éÀú¹¤×÷²¾ÖÐµÄËùÓÐ¹¤×÷±í
    For Each ws In ThisWorkbook.Worksheets
        found = False
        For Each nameToKeep In keepSheets
            If ws.Name = nameToKeep Then
                found = True
                Exit For
            End If
        Next nameToKeep

        ' Èç¹û²»ÔÚ±£ÁôÁÐ±íÖÐ£¬ÉèÎªÉî¶ÈÒþ²Ø
        If Not found Then
            ws.Visible = xlSheetVeryHidden
        End If
    Next ws

    MsgBox "successfully", vbInformation
End Sub


