Sub a8_Metrics_()

    Application.ScreenUpdating = False
    Dim i&, nrow&, arr, drr, d As Object
    Set d = CreateObject("scripting.dictionary")

    With Sheet12
        drr = .Range("a1").CurrentRegion
        For i = 2 To UBound(drr)
            If (Not drr(i, 11) Like "FLOO*") And (Not drr(i, 11) Like "RUG*") Then
                d(drr(i, 40) & "|" & drr(i, 42)) = d(drr(i, 40) & "|" & drr(i, 42)) + 1
            End If
        Next

    End With

    With Sheet10
        nrow = .Range("b1048576").End(3).Row + 1
        .Cells(nrow, 1) = Format(Date, "ddd,mm d,yyyy")
        For i = 2 To 17
            .Cells(nrow, i) = d(.Cells(1, i) & "|" & .Cells(2, i))
        Next
        .Cells(nrow, 18).Value = Application.Sum(.Range("b" & nrow, "q" & nrow))
    End With

    Application.ScreenUpdating = True
End Sub
