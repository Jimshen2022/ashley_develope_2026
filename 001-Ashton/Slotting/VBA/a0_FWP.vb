'Pull out all data method

Sub a0_FWP_()                   ' ADO method to get the data

'    t = Timer
    Application.ScreenUpdating = False


    Dim wb As Workbook
    Dim arr, brr(), i&, j&, k&, nrow&, crr, n%, d As Object

    With Sheet9
        .Range("e1").Value = "DataCollectedAt: " & Format(Now(), "yyyy/mm/dd  hh:mm:ss")
        .Range("e1").Font.ColorIndex = 3
    End With

    ' put location vs building into d
'    With Sheet4
'        crr = .Range("a1").CurrentRegion
'
'        Set d = CreateObject("scripting.dictionary")
'            For i = 2 To UBound(crr)
'                d(crr(i, 2)) = crr(i, 13)
'            Next
'
'     End With

    Set wb = GetObject("C:\Users\ndinh\Downloads\Forward_Pick_Locations.xlsx")      'open the workbook
    arr = wb.ActiveSheet.[a1].CurrentRegion
    wb.Close False

'    ReDim Preserve arr(1 To UBound(arr, 1), 1 To 20)
'    arr(1, 17) = "First5"
'    arr(1, 18) = "Product"
'    arr(1, 19) = "Loc_Type"
'    arr(1, 20) = "Site"


'    For i = 1 To UBound(arr)
'        n = n + 1
'        ReDim Preserve brr(1 To 20, 1 To n)
'        For j = 1 To 20
'            arr(i, 17) = Mid(arr(i, 2), 1, 1)
'            If arr(i, 17) Like "[0-9U]*" Then
'                arr(i, 18) = "UPH"
'            ElseIf Len(arr(i, 2)) > 6 And Left(arr(i, 2), 1) = "M" Then
'                arr(i, 18) = "MATT"
'            ElseIf Len(arr(i, 2)) = 6 And Left(arr(i, 2), 1) = "M" Then
'                arr(i, 18) = "PILLOW"
'            Else
'                arr(i, 18) = "CG"
'            End If

            ' Loc_Type
'            If Mid(arr(i, 15), 1, 1) = 0 Then
'                arr(i, 19) = "On Shipping stage"
'            ElseIf Mid(arr(i, 7), 1, 2) = "BD" Then
'                arr(i, 19) = "On Shipping Stage"
'            ElseIf Mid(arr(i, 7), 1, 2) = "RS" Then
'                arr(i, 19) = "On Receiving Stage"
'            ElseIf Mid(arr(i, 7), 1, 5) = "A1094" Then
'                arr(i, 19) = "On Shipping Stage"
'            ElseIf Mid(arr(i, 7), 1, 2) = "CN" Then
'                arr(i, 19) = "In Container from BD to Phumy "
'            ElseIf Mid(arr(i, 7), 1, 2) = "NG" Then
'                arr(i, 19) = "Damaged Location"
'            ElseIf arr(i, 15) = "STORAGE" And Mid(arr(i, 7), 1, 2) = "DR" Or Mid(arr(i, 7), 1, 2) = "UL" Then
'                arr(i, 19) = "In Floppy Location"
'            ElseIf arr(i, 15) = "STORAGE" And Mid(arr(i, 7), 1, 2) = "A3" Or Mid(arr(i, 7), 1, 2) = "A1" Then
'                arr(i, 19) = "In Racking Location"
'            ElseIf arr(i, 15) = "STORAGE" And Mid(arr(i, 7), 1, 2) <> "A3" Then
'                arr(i, 19) = "In Racking Location"
'            Else
'                arr(i, 19) = "Check please"
'            End If

            ' Building
'            If Mid(arr(i, 15), 1, 1) = 0 Then
'                arr(i, 20) = "Phumy"
'            ElseIf d.exists(arr(i, 7)) Then
'                If d(arr(i, 7)) = "A3" Then
'                    arr(i, 20) = "Phumy"
'                ElseIf d(arr(i, 7)) = "A1" Then
'                    arr(i, 20) = "BD"
'                Else
'                    arr(i, 20) = "Check"
'                End If
'            Else
'               arr(i, 20) = "Check"
'            End If
'            arr(1, 20) = "Site"
'
'
'            brr(j, n) = arr(i, j)
'        Next
'    Next


    With Sheet3
        .Cells.Clear
        .Columns("a:d").NumberFormat = "@"

        .Range("a1").Resize(UBound(arr), UBound(arr, 2)).Value = arr
        .Columns("a:p").EntireColumn.AutoFit
'        .Range("q1:s1").Value = Array("First5", "Product", "Loc_Type")

    End With




'    Call CreatePivotTable

    Application.ScreenUpdating = True
'    MsgBox Format(Timer - t, "0.00" & "s")

End Sub
