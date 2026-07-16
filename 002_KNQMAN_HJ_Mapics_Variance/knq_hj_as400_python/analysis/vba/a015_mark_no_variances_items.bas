Attribute VB_Name = "a015_mark_no_variances_items"
Sub a015_mark_no_variances_items_()
    Application.ScreenUpdating = False
    Dim i&, j&, lrow&, nrow&
    
    With Sheet1
        lrow = .Range("a1048576").End(3).Row
        
        For i = 2 To lrow
            ' from Column AB to AG
            If .Cells(i, 3) = 0 And .Cells(i, 21) = 0 Then
                If .Cells(i, 15) > 0 And .Cells(i, 16) = 0 Then
                    .Cells(i, 2).Interior.ColorIndex = 16
                    .Cells(i, 28) = "POs are still not updated to KNQ"
                    .Cells(i, 29) = "KNQ update time variance"
                    .Cells(i, 30) = "no need action"
                    .Cells(i, 31) = "Rita"
                    .Cells(i, 32) = Date + 2
                    .Cells(i, 33) = "Closed"

                ElseIf .Cells(i, 15) = 0 And .Cells(i, 16) > 0 Then
                    .Cells(i, 2).Interior.ColorIndex = 16
                    .Cells(i, 28) = "Trip shipped but still not be updated to KNQ"
                    .Cells(i, 29) = "KNQ update time variance"
                    .Cells(i, 30) = "no need action"
                    .Cells(i, 31) = "Rita"
                    .Cells(i, 32) = Date
                    .Cells(i, 33) = "Closed"
                ElseIf .Cells(i, 4) = .Cells(i, 7) And .Cells(i, 7) = .Cells(i, 12) Then
                    .Cells(i, 2).Interior.ColorIndex = 16
                    .Cells(i, 28) = "No Variance"
                    .Cells(i, 29) = "No Variance"
                    .Cells(i, 30) = "no need action"
                    .Cells(i, 31) = "All"
                    .Cells(i, 32) = Date
                    .Cells(i, 33) = "Closed"
                Else

                End If
            End If
        
        Next

    End With
    
    
    
    With Sheet26
        nrow = .Range("b1048576").End(3).Row
        For i = 2 To nrow
            .Range("e" & i).Value = Date + 2
        Next
    
    End With
    
    
    Application.ScreenUpdating = True
End Sub
