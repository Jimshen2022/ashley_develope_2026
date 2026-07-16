Attribute VB_Name = "a0_mapics_adjusted"

Sub a0_mapics_adjusted_()

    Dim i As Long
    Dim adors As New Recordset
    

    Application.ScreenUpdating = False
    Application.Calculation = xlCalculationManual
    Application.StatusBar = "Loading Trx, please wait ......"
    U = Sheet25.Range("r1").Value
    p = Sheet25.Range("r2").Value
    Sheet16.Cells.Clear
    
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
            "WHERE b.ITNBR = a.ITNBR AND b.STID = c.STID AND a.HOUSE = c.WHID AND ((a.HOUSE='335') AND (a.UPDDT>= 1210101 And a.UPDDT<= 1381231 ) AND (a.TRQTY<>0) AND (a.TCODE ='IA' OR a.TCODE ='IS' OR a.TCODE ='SS' OR a.TCODE ='RC')) " & _
            "ORDER BY UPDDT"
    
    
    adors.Open cmdtxt, Db, 3, 3
    For i = 0 To adors.Fields.Count - 1
        Sheet16.Cells(1, i + 1) = adors.Fields(i).Name
    Next i
    
    
    Sheet16.Range("A2").CopyFromRecordset adors
    adors.Close
    Set adors = Nothing
    
    Dim nrow&
    nrow = Sheet16.Range("a1048576").End(3).Row
    Sheet16.Range("n1").Value = "Qty"
    Sheet16.Range("n2").Formula = "=IF(AND(A2=""SS"",H2<0),-H2,IF(AND(OR(A2=""SS"",A2=""IS""),H2>0),-H2,H2))"
    Sheet16.Range("n2").AutoFill Destination:=Sheet16.Range("n2:n" & nrow)
    
    Application.Calculation = xlCalculationAutomatic
    Application.ScreenUpdating = True
    Application.StatusBar = False
    
    
    
End Sub

