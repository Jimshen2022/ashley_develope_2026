Attribute VB_Name = "a0_Mapics_OnHand"
Sub a0_Mapics_OnHand_()

    Application.ScreenUpdating = False
'    Application.Calculation = xlCalculationManual
'    Application.StatusBar = "Loading Mapics On Hand, please wait ......"

    Dim i As Long
    Dim adors As New Recordset
    Sheet3.Cells.Clear
    
    Set Db = New connection
    Db.CursorLocation = adUseClient
    If Db.State = 1 Then Db.Close
    
    UName = Sheet25.Range("r1")
    UPass = Sheet25.Range("r2")
   
    Db.Open "Provider =IBMDASQL.DataSource.1" & _
     ";Catalog Library List=JIMTDTA" & _
     ";Persist Security Info=True" & _
     ";Force Translate=0" & _
     ";Data Source = AFIPROD " & _
     ";User ID = " & UName & "" & _
     ";Password =" & UPass
     
     Set adors = New Recordset
     If adors.State = 1 Then adors.Close

    cmdtxt = "SELECT ITEMBL.ITNBR, ITEMBL.HOUSE, ITEMBL.ITCLS, ITEMBL.MOHTQ, ITEMBL.WHSLC, ITEMBL.QTSYR, ITMRVA.ITDSC " & _
             "FROM AMFLIBA.ITEMBL ITEMBL, AMFLIBA.ITMRVA ITMRVA, AMFLIBA.WHSMST WHSMST " & _
             "WHERE ITMRVA.ITCLS = ITEMBL.ITCLS AND ITMRVA.ITNBR = ITEMBL.ITNBR AND ITMRVA.STID = WHSMST.STID AND ITEMBL.HOUSE = WHSMST.WHID AND ((ITEMBL.HOUSE='335') AND (ITEMBL.MOHTQ<>0)) " & _
             "ORDER BY ITEMBL.ITNBR "

    adors.Open cmdtxt, Db, 3, 3
     For i = 0 To adors.Fields.Count - 1
         Sheet3.Cells(1, i + 1) = adors.Fields(i).Name
     Next i
     
     Sheet3.Columns("A:b").NumberFormat = "@"
     Sheet3.Range("a2").CopyFromRecordset adors
     adors.Close
     Set adors = Nothing
    
    

    
'    Application.Calculation = xlCalculationAutomatic
    Application.ScreenUpdating = True
'    Application.StatusBar = False
    
    
    

End Sub

