Attribute VB_Name = "Module1"
Sub TestAceProvider()
    Dim cnn As Object, v As Variant, ok As Boolean, s As String
    v = Array("Microsoft.ACE.OLEDB.16.0", "Microsoft.ACE.OLEDB.12.0")
    For Each s In v
        On Error Resume Next
        Set cnn = CreateObject("ADODB.Connection")
        cnn.Open "Provider=" & s & ";Data Source=" & ThisWorkbook.FullName & _
                 ";Extended Properties=""Excel 12.0;HDR=YES;IMEX=1;ReadOnly=1"";"
        ok = (err.Number = 0)
        On Error GoTo 0
        If ok Then
            MsgBox "OK: " & s, vbInformation: cnn.Close: Exit Sub
        End If
    Next
    MsgBox "ACE Provider Î´°²×°»òÎ»Êý²»Æ¥Åä£¨16.0/12.0¶¼²»¿ÉÓÃ£©¡£", vbCritical
End Sub

