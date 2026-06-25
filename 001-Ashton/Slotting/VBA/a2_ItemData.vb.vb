Sub a2_ItemData_()

'    t = Timer
    Application.ScreenUpdating = False

    Dim i&, arr, crr, srr, drr, err, frr, nrow&, item As String, d As Object, d2 As Object, d3 As Object, d4 As Object, d5 As Object, items As String, k&, srow&, str2, str1, str$
    Set d = CreateObject("scripting.dictionary")
    Set d2 = CreateObject("scripting.dictionary")
    Set d3 = CreateObject("scripting.dictionary")
    Set d4 = CreateObject("scripting.dictionary")
    Set d5 = CreateObject("scripting.dictionary")
    Sheet12.Cells.Clear

    ' String for sql

        With Sheet11
            srr = .Range("a1").CurrentRegion
            For i = 1 To UBound(srr)
                str = str & " " & srr(i, 1)
            Next
        End With

        'combination all items as string
'        snow = Sheet4.Range("e1048576").End(3).Row
'        srr = Sheet4.Range("e3:e" & snow)
'
'        ' Item string for cubes
'        For j = 1 To UBound(srr)
'            d(srr(j, 1)) = ""
'        Next
'        Erase srr
'        str1 = d.keys
'
'        For j = 0 To UBound(str1)
'            If j = 0 And UBound(str1) >= 0 Then
'              str2 = "'" & str1(j) & "'"
'            ElseIf j > 0 And j <= UBound(str1) Then
'              str2 = str2 & ",'" & str1(j) & "'"
'            End If
'        Next

    'PULL ITEMS

        With Sheet9
            UserID = .Range("a1").Value
            pw = .Range("a2").Value
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

        cmdtxt = str

        adors.Open cmdtxt, Db, 3, 3
       adors.MoveFirst
'        arr = Application.Transpose(adors.GetRows())
        crr = adors.GetRows()
        ReDim arr(0 To UBound(crr, 2), 0 To UBound(crr))
        For i = 0 To UBound(crr)
            For j = 0 To UBound(crr, 2)
                If crr(i, j) <> "" Then
                    arr(j, i) = CStr(crr(i, j))
                Else
                    arr(j, i) = ""
                End If
            Next
        Next

        With Sheet12
            .Columns("a:a").NumberFormat = "@"
             For i = 0 To adors.Fields.Count - 1
                 .Cells(1, i + 1) = adors.Fields(i).Name
             Next i

            .Range("a2").Resize(UBound(arr) + 1, UBound(arr, 2) + 1).Value = arr
'           .Range("a2").CopyFromRecordset adors
            Erase arr

            With .Range("a1:ah" & .Range("a1048576").End(3).Row)
                .Sort .Range("a1"), 1, , , , , , xlYes
            End With

            ' fwd location into d
            drr = Sheet3.Range("a1").CurrentRegion
            For i = 2 To UBound(drr)
                d(drr(i, 4)) = drr(i, 2)
            Next
            Erase drr

            ' TripQty and CO qTY  into d3 and d4
            With Sheet8
                err = .Range("a1").CurrentRegion
                For i = 2 To UBound(err)
                    ' Trip Qty
                    If err(i, 22) <> "" Then
                        d3(err(i, 4)) = d3(err(i, 4)) + err(i, 19)
                    Else
                    ' CO Qty
                        d4(err(i, 4)) = d4(err(i, 4)) + err(i, 19)
                    End If
                Next
            End With
            Erase err

            ' Disabled locations
            With Sheet5
                frr = .Range("a1").CurrentRegion
                For i = 2 To UBound(frr)
                    d5(frr(i, 1)) = frr(i, 3)
                Next
            End With
            Erase frr

            .Range("af:al").Cells.Clear
            .Range("af1:al1").Value = Array("FWP", "PRDWIN2", "PRDHIN2", "PRDLIN2", "TripQty", "CO_Qty", "Disabled")
             arr = .Range("a1").CurrentRegion
            For i = 2 To UBound(arr)
                If d.exists(arr(i, 1)) Then
                    arr(i, 32) = d(arr(i, 1))
                Else
                    arr(i, 32) = "No Primary location"
                End If

                arr(i, 33) = arr(i, 22) * 0.0254
                arr(i, 34) = arr(i, 23) * 0.0254
                arr(i, 35) = arr(i, 24) * 0.0254

                ' Trip Qty
                If d3.exists(arr(i, 1)) Then
                    arr(i, 36) = d3(arr(i, 1))
                Else
                    arr(i, 36) = 0
                End If

                 ' CO Qty
                If d4.exists(arr(i, 1)) Then
                    arr(i, 37) = d4(arr(i, 1))
                Else
                    arr(i, 37) = 0
                End If

                 ' Disabled location check
                If d5.exists(arr(i, 32)) Then
                    arr(i, 38) = d5(arr(i, 32))
                Else
                    arr(i, 38) = "Active"
                End If


            Next

            .Range("af1").Resize(UBound(arr), 1).Value = Application.Index(arr, , 32)
            .Range("ag1").Resize(UBound(arr), 1).Value = Application.Index(arr, , 33)
            .Range("ah1").Resize(UBound(arr), 1).Value = Application.Index(arr, , 34)
            .Range("ai1").Resize(UBound(arr), 1).Value = Application.Index(arr, , 35)
            .Range("aj1").Resize(UBound(arr), 1).Value = Application.Index(arr, , 36)
            .Range("ak1").Resize(UBound(arr), 1).Value = Application.Index(arr, , 37)
            .Range("al1").Resize(UBound(arr), 1).Value = Application.Index(arr, , 38)


            .Range("ag:ai").NumberFormat = "###,##0.00"
            .Range("ac:ac").NumberFormat = "###,##0.00"
            .Range("z:z").NumberFormat = "###,##0.00"
            .Columns("a:al").AutoFit

            .Range("af1:am1").Interior.ColorIndex = 10
            .Range("af1:am1").Font.ColorIndex = 2


         End With

         Erase arr
         adors.Close
         Set adors = Nothing
         Set d = Nothing
         Set d2 = Nothing
         Set d3 = Nothing
         Set d4 = Nothing
        Application.ScreenUpdating = True
'        MsgBox "Query Successful in " & Format(Timer - t, "0.00" & "s") & "!"
End Sub












