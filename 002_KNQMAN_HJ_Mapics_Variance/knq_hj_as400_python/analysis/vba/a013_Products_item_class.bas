Attribute VB_Name = "a013_Products_item_class"

Sub a013_Products_item_class_()

    Application.ScreenUpdating = False

    
    Dim i&, nrow&, arr, brr, d As Object
    
    Set d = CreateObject("scripting.dictionary")
    brr = Sheet15.Range("a1").CurrentRegion
    For i = 2 To UBound(brr)
        d(brr(i, 2)) = brr(i, 3)
    Next
    
    With Sheet1
        arr = .Range("a1").CurrentRegion
        For i = 2 To UBound(arr)
            If d.exists(arr(i, 2)) Then
                arr(i, 26) = d(arr(i, 2))
                If Not arr(i, 26) Like "Z*" Then
                    arr(i, 25) = "RP"
                Else
                    If Mid(arr(i, 2), 1, 1) Like "[ABDQREHTWZ]" Then
                       arr(i, 25) = "CG"
                    Else
                        arr(i, 25) = "UPH"
                    End If
                End If
            Else
                arr(i, 26) = "Check"
                arr(i, 25) = "Check"
            End If
         Next
     
        .Range("z1").Resize(UBound(arr), 1).Value = Application.Index(arr, , 26)
        .Range("y1").Resize(UBound(arr), 1).Value = Application.Index(arr, , 25)
'        .Range("a1").CurrentRegion.Copy Sheet5.Range("a1048576").End(3).Offset(1)
        End With
    Erase arr, brr
    Set d = Nothing
    Application.ScreenUpdating = True

End Sub

