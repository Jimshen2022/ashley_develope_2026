Attribute VB_Name = "b032_mapics_sa_transaction"
Sub b032_mapics_sa_transaction_()

Dim i As Long
    Dim adors As New Recordset
    Dim dtEnd As Date
    Dim dtStart As Date
    Dim strEnd As String
    Dim strStart As String

    dtEnd = Date                    ' ½ñÌì
    dtStart = Date - 3             ' ÍùÇ°14Ìì£¨º¬½ñÌì¹²14Ìì£©
    ' ×ª»»³É CYYMMDD ¸ñÊ½£¨Ê×Î»²¹1£©
    strEnd = "1" & Format(dtEnd, "YYMMDD")
    strStart = "1" & Format(dtStart, "YYMMDD")



    Application.ScreenUpdating = False
    Application.Calculation = xlCalculationManual
    Application.StatusBar = "Loading Trx, please wait ......"
    U = Sheet25.Range("r1").Value
    p = Sheet25.Range("r2").Value
    Sheet47.Cells.Clear
    
    Set Db = New connection
    Db.CursorLocation = adUseClient
    If Db.State = 1 Then Db.Close
    
    
    Db.Open "Provider =IBMDASQL.DataSource.1" & _
            ";Catalog Library List=JIMTDTA" & _
            ";Persist Security Info=True" & _
            ";Force Translate=0" & _
            ";Data Source = AFIPROD" & _
            ";User ID =" & U & "" & _
            ";Password =" & p
    
    Set adors = New Recordset
    If adors.State = 1 Then adors.Close
    
cmdtxt = "SELECT a.TCODE, a.ORDNO, a.ITNBR, b.ITCLS, a.HOUSE, a.UPDDT, a.UPDTM, a.TRQTY, a.TRNDT, a.LBHNO, a.REFNO, a.REASN, a.USRSQ " & _
         "FROM AMFLIBA.IMHIST a, AMFLIBA.ITMRVA b, AMFLIBA.WHSMST c " & _
         "WHERE b.ITNBR = a.ITNBR AND b.STID = c.STID AND a.HOUSE = c.WHID " & _
         "AND a.HOUSE='335' AND (a.UPDDT >= " & strStart & " AND a.UPDDT <= " & strEnd & ") " & _
         "AND a.TRQTY <> 0 AND a.TCODE = 'SA' " & _
         "ORDER BY a.UPDDT"
    
    
    adors.Open cmdtxt, Db, 3, 3
    For i = 0 To adors.Fields.Count - 1
        Sheet47.Cells(1, i + 1) = adors.Fields(i).Name
    Next i
    
    
    Sheet47.Range("A2").CopyFromRecordset adors
    adors.Close
    Set adors = Nothing
    
    Dim nrow&
    With Sheet47
        .Columns("c:c").NumberFormat = "@"
        nrow = .Range("a1048576").End(3).Row
        .Range("n1").Value = "Qty"
        .Range("n2").Formula = "=IF(AND(A2=""SS"",H2<0),-H2,IF(AND(OR(A2=""SS"",A2=""IS""),H2>0),-H2,H2))"
        .Range("n2").AutoFill Destination:=.Range("n2:n" & nrow)
    
    End With
    Application.Calculation = xlCalculationAutomatic
    Application.ScreenUpdating = True
    Application.StatusBar = False


End Sub
