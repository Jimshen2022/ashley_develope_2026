Sub a5_ItemData_Class_()
    Application.ScreenUpdating = False
    Dim i&, j&, arr, brr, d As Object
    Set d = CreateObject("scripting.dictionary")

    ' Load acc% into d
    With Sheet13
        brr = .Range("a1").CurrentRegion
        For i = 2 To UBound(brr)
            d(brr(i, 1)) = brr(i, 5) & "|" & brr(i, 6)
        Next
    End With

    ' Item_Class
    With Sheet12
        .Range("am:ao").ClearContents
        .Range("am1:ao1").Value = Array("Acc(%)", "Item_Type", "Item_Status")
        arr = .Range("a1").CurrentRegion
        For i = 2 To UBound(arr)
            If d.exists(arr(i, 1)) Then
                arr(i, 39) = Split(d(arr(i, 1)), "|")(0)
                If (Split(d(arr(i, 1)), "|")(1) = "Disco" Or Split(d(arr(i, 1)), "|")(1) = "Unavailable") And arr(i, 36) + arr(i, 37) = 0 Then
                    arr(i, 39) = 0
                    arr(i, 40) = "SlowMoving"
                ElseIf Split(d(arr(i, 1)), "|")(0) <= 0.2 Then
                    arr(i, 40) = "Top20%"
                ElseIf Split(d(arr(i, 1)), "|")(0) > 0.2 And Split(d(arr(i, 1)), "|")(0) <= 0.9 Then
                    arr(i, 40) = "FastItem"
                Else
                    arr(i, 40) = "NormalItem"
                End If
            Else
                If arr(i, 9) = "N" Then
                    arr(i, 40) = "NormalItem"
                Else
                    arr(i, 39) = 0
                    arr(i, 40) = "SlowMoving"
                End If
            End If

            ' Item_Status
            If arr(i, 9) = "D" Then
                arr(i, 41) = "Disco"
            ElseIf arr(i, 9) = "N" Then
                arr(i, 41) = "New Item"
            ElseIf arr(i, 2) = "U" Then
                arr(i, 41) = "Unavaiable"
            Else
                arr(i, 41) = "Active"
            End If

        Next
        .Range("am:am").NumberFormat = "##0.00%"
        .Range("am1").Resize(UBound(arr), 1).Value = Application.Index(arr, , 39)
        .Range("an1").Resize(UBound(arr), 1).Value = Application.Index(arr, , 40)
        .Range("ao1").Resize(UBound(arr), 1).Value = Application.Index(arr, , 41)


        .Range("ab1:ab1").Interior.ColorIndex = 10
        .Range("ab1:ab1").Font.ColorIndex = 2
        .Range("af1:ao1").Interior.ColorIndex = 10
        .Range("af1:ao1").Font.ColorIndex = 2
        .Columns("a:ao").AutoFit



    End With




    Application.ScreenUpdating = True
End Sub
