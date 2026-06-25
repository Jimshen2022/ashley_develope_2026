Sub a4_CG_ABC_()
    Application.ScreenUpdating = False
    Dim i&, j&, arr, brr, drr, d As Object, d1 As Object, d2 As Object, d3 As Object, d4 As Object, d5 As Object, k, t
    Set d = CreateObject("scripting.dictionary")
    Set d1 = CreateObject("scripting.dictionary")
    Set d2 = CreateObject("scripting.dictionary")
    Set d3 = CreateObject("scripting.dictionary")
    Set d4 = CreateObject("scripting.dictionary")
    Set d5 = CreateObject("scripting.dictionary")

    With Sheet8
        brr = .Range("a1").CurrentRegion
        For i = 2 To UBound(brr)
            ' CG Open CO Qty sum into d
            ' item OPEN co qty sum into d1
            If (brr(i, 33) = "PALLT" Or brr(i, 4) Like "M*") And brr(i, 34) <> "" Then
                d(brr(i, 21)) = d(brr(i, 21)) + brr(i, 19) ' CG total open CO qty
                d1(brr(i, 4)) = d1(brr(i, 4)) + brr(i, 19) ' CG item open co qty
            ElseIf brr(i, 21) = "UPH" Then
                d2(brr(i, 21)) = d2(brr(i, 21)) + brr(i, 19)  ' UPH total open co qty
                d3(brr(i, 4)) = d3(brr(i, 4)) + brr(i, 19)     ' UPH item open co qty
            End If
        Next
    End With
    Erase brr

    ' Disco & U
    With Sheet12
        drr = .Range("a1").CurrentRegion
        For i = 2 To UBound(drr)
            If drr(i, 9) = "N" Then
                d5(drr(i, 1)) = "New"
            ElseIf drr(i, 9) = "D" Then
                d5(drr(i, 1)) = "Disco"
            ElseIf drr(i, 2) = "U" Then
                d5(drr(i, 1)) = "Unavailable"
            Else
                d5(drr(i, 1)) = "Active"
            End If
        Next
    End With
    Erase drr

    With Sheet13
        k = d1.Keys
        t = d1.items
        .Cells.Clear
        .Range("a:a").NumberFormat = "@"
        .Range("a1:f1").Value = Array("Item", "Open_CO_Qty", "Total_Open_CO_Qty", "Open_CO(%)", "Acc(%)", "Item_Status")
        .Range("a2").Resize(d1.Count, 1).Value = Application.Transpose(k)
        .Range("b2").Resize(d1.Count, 1).Value = Application.Transpose(t)
    End With

    With Sheet13
        With .Range("a1:f" & .Range("a1048576").End(3).Row)
            .Sort .Range("b1"), xlDescending, , , , , , xlYes
        End With

        arr = .Range("a1").CurrentRegion
        For i = 2 To UBound(arr)
            arr(i, 3) = d("CG")  ' Total_Open_CO_Qty
            arr(i, 4) = arr(i, 2) / arr(i, 3) ' Open_CO(%)

            ' Acc(%)
            If i = 2 Then
                arr(i, 5) = arr(i, 4)
            Else
                arr(i, 5) = arr(i - 1, 5) + arr(i, 4)
            End If

            ' Item_Status
            If d5.exists(arr(i, 1)) Then
                arr(i, 6) = d5(arr(i, 1))
            Else
                arr(i, 6) = "Active"
            End If

        Next



        .Range("a:a").NumberFormat = "@"
        .Range("b:c").NumberFormat = "###,###"
        .Range("d:e").NumberFormat = "##0.00%"

        .Range("a1").Resize(UBound(arr), UBound(arr, 2)).Value = arr


    End With

    Application.ScreenUpdating = True
End Sub
