Attribute VB_Name = "a010_get_item_class"

Sub a010_get_item_class_()
    On Error Resume Next
'    t = Timer
    Application.ScreenUpdating = False

    Dim i%, crr, arr, nrow&, item As String, d As Object, d1 As Object, srr, items As String, k&, srow&, str2, str1, str$, drr
    Set d = CreateObject("scripting.dictionary")
     Set d1 = CreateObject("scripting.dictionary")
    With Sheet15
        drr = .Range("a1").CurrentRegion
        For i = 2 To UBound(drr)
            d1(drr(i, 2)) = ""
        Next
    End With
        
        
        'combination all items as string
        snow = Sheet1.Range("a1048576").End(3).Row
        srr = Sheet1.Range("b2:b" & snow)
        
        ' Item string for cubes
        For j = 1 To UBound(srr)
            If Not d1.exists(srr(j, 1)) And srr(j, 1) <> "RP ORDER" Then
                d(srr(j, 1)) = ""
            End If
        Next
        Erase srr
        str1 = d.keys

        For j = 0 To UBound(str1)
            If j = 0 And UBound(str1) >= 0 Then
              str2 = "'" & str1(j) & "'"
            ElseIf j > 0 And j <= UBound(str1) Then
              str2 = str2 & ",'" & str1(j) & "'"
            End If
        Next
    
    'PULL ITEMS
    
        With Sheet25
            UserID = .Range("r1").Value
            pw = .Range("r2").Value
        End With
    
        Dim cmdtxt As String
        Dim adors As New Recordset
        Set Db = CreateObject("ADODB.Connection")
        
        Db.CursorLocation = adUseClient
        If Db.State = 1 Then Db.Close
    
        Db.Open "Provider =IBMDASQL.DataSource.1" & _
         ";Catalog Library List=JDETSTDTA" & _
         ";Persist Security Info=True" & _
         ";Force Translate=0" & _
         ";Data Source = AFIPROD " & _
         ";User ID = " & UserID & "" & _
         ";Password = " & pw
         
         Set adors = New Recordset
         If adors.State = 1 Then adors.Close
        
         cmdtxt = "SELECT t1.STID,T1.ITNBR,T1.ITCLS " & _
         "FROM AMFLIBA.ITMRVA AS T1 " & _
         "WHERE T1.STID IN ('335') "
      
        If str2 <> "" Then
              cmdtxt = cmdtxt & " AND T1.ITNBR in " & "(" & str2 & ")"
        Else
            Exit Sub
        End If
        cmdtxt = cmdtxt
     
        adors.Open cmdtxt, Db, 3, 3
        
        adors.MoveLast
        adors.MoveFirst
        arr = Application.Transpose(adors.GetRows())
        
'        ReDim crr(1 To adors.RecordCount, 1 To adors.Fields.Count)
'
'        For i = 1 To adors.RecordCount
'                crr(i, 1) = adors.Fields(0).Value
'                crr(i, 2) = adors.Fields(1).Value
'                crr(i, 3) = adors.Fields(2).Value
'            adors.MoveNext
'        Next
        
        With Sheet15
            .Range("b:b").NumberFormat = "@"
            .Range("a1048576").End(3).Offset(1, 0).Resize(UBound(arr), 1).Value = Application.Index(arr, , 1)
            .Range("b1048576").End(3).Offset(1, 0).Resize(UBound(arr), 1).Value = Application.Index(arr, , 2)
            .Range("c1048576").End(3).Offset(1, 0).Resize(UBound(arr), 1).Value = Application.Index(arr, , 3)
        End With
        
'        crr = adors.GetRows()
        
'        If IsEmptyArray(crr) Then
'            Exit Sub
'        Else
'            ReDim arr(0 To UBound(crr, 2), 0 To UBound(crr))
'            For i = 0 To UBound(crr)
'                For j = 0 To UBound(crr, 2)
'                    If crr(i, j) <> "" Then
'                        arr(j, i) = CStr(crr(i, j))
'                    Else
'                        arr(j, i) = ""
'                    End If
'                Next
'            Next
'        End If
'        With Sheet15
'            .Columns("a:b").NumberFormat = "@"
'             For i = 0 To adors.Fields.Count - 1
'                 .Cells(1, i + 1) = adors.Fields(i).Name
'             Next i
             
'            .Range("b:b").NumberFormat = "@"
'            .Range("a1048576").End(3).Offset(1, 0).Resize(UBound(arr) + 1, UBound(arr, 2) + 1).Value = arr
'           .Range("a2").CopyFromRecordset adors
            
'            With .Range("a1:ah" & .Range("a1048576").End(3).Row)
'                .Sort .Range("a1"), 1, , , , , , xlYes
            
'         End With
         
         Erase drr
         adors.Close
         Set adors = Nothing

        Application.ScreenUpdating = True
'        MsgBox "Query Successful in " & Format(Timer - t, "0.00" & "s") & "!"
End Sub

Function IsEmptyArray(arr As Variant) As Boolean
    Dim i As Long, j As Long
    For i = LBound(arr, 1) + 1 To UBound(arr, 1)
        For j = LBound(arr, 2) To UBound(arr, 2)
            If Not IsEmpty(arr(i, j)) Then
                IsEmptyArray = False
                Exit Function
            End If
        Next j
    Next i
    IsEmptyArray = True
End Function


