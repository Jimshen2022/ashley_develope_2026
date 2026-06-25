Sub a1_Pull_Open_Trips_()

    Application.ScreenUpdating = False
'    t = Timer
    Dim i As Long, j&, arr
    Dim adors As New Recordset
    Sheets("OpenTrips").Cells.Clear

    Set Db = New Connection
    Db.CursorLocation = adUseClient
    If Db.State = 1 Then Db.Close

    UName = Sheet9.Range("a1")
    UPass = Sheet9.Range("a2")

    Db.Open "Provider =IBMDASQL.DataSource.1" & _
     ";Catalog Library List=JIMTDTA" & _
     ";Persist Security Info=True" & _
     ";Force Translate=0" & _
     ";Data Source = AFIPROD" & _
     ";User ID = " & UName & "" & _
     ";Password =" & UPass

     Set adors = New Recordset
     If adors.State = 1 Then adors.Close

    cmdtxt = "SELECT * FROM (SELECT a1.HOUSE,a1.ORDNO,A1.ITMSQ,a1.ITNBR,a1.ITDSC,a1.ITCLS,a1.CCUSNO,a1.CSHPNO,a1.CUSNM,char(a1.TKNDAT) Order_Taken_Date,char(a1.FRZDAT) Original_Request_Date, char(a1.RQSDAT) CRD,char(a1.RQIDT) CPD, char(a1.MFIDT)  LoadDate, " & _
            " a1.ORDUSR,a1.COQTY,a1.QTYSH,a1.QTYBO,a1.OPEN_CO_QTY,a1.ALC,a1.Product,char(x1.BDTRP#) as BDTRP#,x1.BDISEQ, x1.BDITQT as Trip_Qty, " & _
            " x1.BDITCT , x1.BDITWT, x1.BDREF#, x1.BHCDAT, x1.BHCTIM, x1.BHRDAT, x1.BHLDAT, x1.BHLTIM, t0.PICKPUT, t0.ITMCLSID " & _
            " FROM (Select  t1.HOUSE,t1.ORDNO,t1.ITMSQ,t1.ITNBR,t1.ITDSC,t1.ITCLS, t1.CCUSNO,t3.CUSNM, T1.CSHPNO, T1.RQIDT,T1.MFIDT,T1.UNMSR, " & _
            " (CASE WHEN t1.ITCLS NOT LIKE 'Z%' THEN 'RP'  WHEN SUBSTR(t1.ITNBR,1,4)='100-' THEN 'CG' WHEN SUBSTR(t1.ITNBR,1,1) in ('A','B','D','E','H','L','M','Q','R','T','W','Z') THEN 'CG'  Else 'UPH' END) as Product,t2.TKNDAT,t2.FRZDAT,t2.RQSDAT,t2.ORDUSR, t1.COQTY,t1.QTYSH,t1.QTYBO, T1.COQTY-T1.QTYSH AS OPEN_CO_QTY, " & _
            " (CASE WHEN t1.IAFLG=0 THEN 'N' WHEN t1.IAFLG = 2 THEN 'Y' Else 'Check' END) AS ALC " & _
            " FROM AFILELIB.CODATAN t1, AFILELIB.EXTORD t2,AFILELIB.ACUSMASJ t3, AFILELIB.COMAST t4, AMFLIBA.ITMRVA t5 " & _
            " WHERE t2.XORDNO =t1.ORDNO AND t3.CUSNO = t1.CCUSNO AND t1.ORDNO=t4.ORDNO AND t1.ITNBR = T5.ITNBR AND t1.house = T5.STID AND t1.house IN ('335') AND t1.COQTY-t1.QTYSH<>0) as a1 " & _
            " LEFT JOIN (SELECT b.ITNBR, b.TIHIUNLD, b.PICKPUT, b.ITMCLSID, b.UNITSWIDE, b.UNITLAYERS, b.UNITSDEEP, b.SCOOPQTY, b.SKIDSIZE, b.house  FROM AFILELIB.ITBEXT as b WHERE b.House in ('335')) AS t0 ON t0.itnbr = a1.itnbr  " & _
            " Left Join (SELECT  t1.BDTRP#,t1.BDORD#,t1.BDISEQ,t1.BDITM#,t1.BDITMD,t1.BDCUS#, t1.BDITQT,t1.BDITCT , t1.BDITWT, t1.BDREF#, t1.BDCDAT, t1.BDCTIM, t2.BHTRPS, t2.BHCDAT, t2.BHCTIM, t2.BHRDAT, t2.BHLDAT, t2.BHLTIM " & _
            " FROM DISTLIB.BTTRIPD t1, DISTLIB.BTTRIPH t2 " & _
            " WHERE t2.BHWHS# IN ('335') AND t2.BHLDAT BETWEEN 0 AND 29991231 AND t2.BHTRPS IN ('A','R','X') AND t1.BDTRP# = t2.BHTRP# " & _
            " ORDER BY t1.BDTRP#,t1.BDISEQ,t1.BDITM#) x1  ON a1.ORDNO||a1.ITMSQ||a1.ITNBR||a1.CCUSNO = x1.BDORD#||x1.BDISEQ||x1.BDITM#||x1.BDCUS# " & _
            " ORDER BY a1.ITNBR,a1.MFIDT) d1 "


    adors.Open cmdtxt, Db, 3, 3

     With Sheet8
        For i = 0 To adors.Fields.Count - 1
            .Cells(1, i + 1) = adors.Fields(i).Name
        Next i


        .Columns("a:i").NumberFormat = "@"
        .Columns("v:v").NumberFormat = "@"
        .Range("a2").CopyFromRecordset adors
        adors.Close
        Set adors = Nothing
       .Columns("a:ah").AutoFit
        arr = .Range("j1:n" & .Range("b1048576").End(3).Row)
        For i = 2 To UBound(arr)
            arr(i, 1) = rq(Application.WorksheetFunction.Text(arr(i, 1), 0))
            arr(i, 2) = rq(Application.WorksheetFunction.Text(arr(i, 2), 0))
            arr(i, 3) = rq(Application.WorksheetFunction.Text(arr(i, 3), 0))
            arr(i, 4) = rq(Application.WorksheetFunction.Text(arr(i, 4), 0))
            arr(i, 5) = rq(Application.WorksheetFunction.Text(arr(i, 5), 0))

        Next
          .Range("j1").Resize(UBound(arr), UBound(arr, 2)).Value = arr
    End With
    Erase arr
   ThisWorkbook.Save
   Application.ScreenUpdating = True
'   MsgBox "it took " & Format(Timer - t, "##.00") & "s!"


End Sub


Function rq(str As String)
rq = DateSerial(Left(str, 4), Mid(str, 5, 2), Right(str, 2))
End Function


