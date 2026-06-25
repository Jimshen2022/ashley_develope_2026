Sub a3_fwp_add_columns_()
    Application.ScreenUpdating = False
    Dim i&, arr, brr, err, frr, d As Object, d2 As Object, d3 As Object, d4 As Object, d5 As Object
    Set d = CreateObject("scripting.dictionary")
    Set d2 = CreateObject("scripting.dictionary")
    Set d3 = CreateObject("scripting.dictionary")
    Set d4 = CreateObject("scripting.dictionary")
    Set d5 = CreateObject("scripting.dictionary")

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

    ' STO into D
    With Sheet2
        brr = .Range("a1").CurrentRegion
        For i = 2 To UBound(brr)
            d2(brr(i, 7)) = d2(brr(i, 7)) + brr(i, 3)
        Next
    End With


    With Sheet3
        .Range("Q:T").Cells.Clear
        .Range("q1:t1").Value = Array("TripQty", "CO_Qty", "Disabled", "STO")
        arr = .Range("a1").CurrentRegion

     ' Trip Qty
     For i = 2 To UBound(arr)
        If d3.exists(arr(i, 4)) Then
            arr(i, 17) = d3(arr(i, 4))
        Else
            arr(i, 17) = 0
        End If

         ' CO Qty
        If d4.exists(arr(i, 4)) Then
            arr(i, 18) = d4(arr(i, 4))
        Else
            arr(i, 18) = 0
        End If


         ' Disabled location check
        If d5.exists(arr(i, 2)) Then
            arr(i, 19) = d5(arr(i, 2))
        Else
            arr(i, 19) = "Active"
        End If

        ' STO
         If d2.exists(arr(i, 2)) Then
            arr(i, 20) = d2(arr(i, 2))
        Else
            arr(i, 20) = 0
        End If
   Next




            .Range("q1").Resize(UBound(arr), 1).Value = Application.Index(arr, , 17)
            .Range("r1").Resize(UBound(arr), 1).Value = Application.Index(arr, , 18)
            .Range("s1").Resize(UBound(arr), 1).Value = Application.Index(arr, , 19)
            .Range("t1").Resize(UBound(arr), 1).Value = Application.Index(arr, , 20)



'            .Range("ag:ai").NumberFormat = "###,##0.00"
'            .Range("ac:ac").NumberFormat = "###,##0.00"
'            .Range("z:z").NumberFormat = "###,##0.00"
            .Columns("a:t").AutoFit

            .Range("q1:t1").Interior.ColorIndex = 10
            .Range("q1:t1").Font.ColorIndex = 2


    End With

    Application.ScreenUpdating = True
End Sub
