Sub a6_Location_vs_Item_mapping_()

    Application.ScreenUpdating = False
    Dim i&, j&, arr, brr, frr, d As Object, d1 As Object, d2 As Object
    Set d = CreateObject("scripting.dictionary")
    Set d1 = CreateObject("scripting.dictionary")
    Set d2 = CreateObject("scripting.dictionary")
    ' location & Items of fwd
    With Sheet3
        frr = .Range("a1").CurrentRegion
        For i = 2 To UBound(frr)
            d(frr(i, 2)) = d(frr(i, 2)) & frr(i, 4)
        Next
    End With


    With Sheet12
        brr = .Range("a1").CurrentRegion
        For i = 2 To UBound(brr)
            ' Item Type
            d1(brr(i, 1)) = brr(i, 40)
            ' OnHand
            d2(brr(i, 1)) = d2(brr(i, 1)) + brr(i, 3)
        Next
    End With

    ' Locations
    With Sheet4
        .Range("b2:d" & .Range("m1048576").End(3).Row).Cells.ClearContents
        arr = .Range("a1").CurrentRegion
        For i = 2 To UBound(arr)
            If d.exists(arr(i, 13)) Then
                arr(i, 2) = d(arr(i, 13))
            Else
                arr(i, 2) = "z_empty fwp loc"
            End If

            If d1.exists(arr(i, 2)) Then
                arr(i, 3) = d1(arr(i, 2))
            Else
                arr(i, 3) = "z_Please Check"
            End If

            If d2.exists(arr(i, 2)) Then
                arr(i, 4) = d2(arr(i, 2))
            Else
                arr(i, 4) = 0
            End If
        Next
        .Range("b1").Resize(UBound(arr), 1).Value = Application.Index(arr, , 2)
        .Range("c1").Resize(UBound(arr), 1).Value = Application.Index(arr, , 3)
        .Range("d1").Resize(UBound(arr), 1).Value = Application.Index(arr, , 4)



    End With

    Application.ScreenUpdating = True
End Sub
