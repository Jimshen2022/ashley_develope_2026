Attribute VB_Name = "a017_copy_old_data_to_previous"
Sub a017_copy_old_data_to_previous_()
Attribute a017_copy_old_data_to_previous_.VB_ProcData.VB_Invoke_Func = " \n14"
    Application.ScreenUpdating = False
    Dim ws1 As Worksheet
        Dim ws2 As Worksheet
        Dim dataRange As Range
    
        ' ÉèÖÃ¹¤×÷±í
        Set ws1 = ThisWorkbook.Sheets("DATA")
        Set ws2 = ThisWorkbook.Sheets("Previous_Data")
    
        ' Çå³ý Sheet2 ÖÐËùÓÐÊý¾Ý
        ws2.Cells.Clear
    
        ' È·¶¨Êý¾Ý·¶Î§
        Set dataRange = ws1.UsedRange
    
        ' ¼ì²éÊÇ·ñ´¦ÓÚÉ¸Ñ¡×´Ì¬
        With ws1
            If .AutoFilterMode Then
                ' Èç¹û´¦ÓÚÉ¸Ñ¡×´Ì¬£¬È¡ÏûÉ¸Ñ¡
                .AutoFilterMode = False
            End If
        End With
    
        ' ¸´ÖÆ²¢Õ³ÌùÊý¾Ý
        dataRange.Copy
        ws2.Range("A1").PasteSpecial Paste:=xlPasteValues
    
        ' Çå³ý¼ôÌù°å
        Application.CutCopyMode = False
    
    
    Application.ScreenUpdating = True
    MsgBox "copied successfully"

End Sub
