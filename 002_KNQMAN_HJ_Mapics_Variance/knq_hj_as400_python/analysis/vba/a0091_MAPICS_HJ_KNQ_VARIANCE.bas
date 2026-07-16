Attribute VB_Name = "a0091_MAPICS_HJ_KNQ_VARIANCE"
Sub a0091_MAPICS_HJ_KNQ_VARIANCE_()
    
    Application.ScreenUpdating = False
    Dim wb As Workbook, i&
    Dim arr, brr, krr, mrr, hrr, yrr, d As Object, d1 As Object, d2 As Object, d3 As Object, k
    Dim d4 As Object, d5 As Object, d6 As Object, d7 As Object
    Dim user_name As String
    Set d = CreateObject("scripting.dictionary")
    Set d1 = CreateObject("scripting.dictionary")
    Set d2 = CreateObject("scripting.dictionary")
    Set d3 = CreateObject("scripting.dictionary")
    Set d4 = CreateObject("scripting.dictionary")
    Set d5 = CreateObject("scripting.dictionary")
    Set d6 = CreateObject("scripting.dictionary")
    Set d7 = CreateObject("scripting.dictionary")
    Set d8 = CreateObject("scripting.dictionary")
 
   
    ' ASYARD
    With Sheet5
        yrr = .Range("a1").CurrentRegion
        For i = 2 To UBound(yrr)
            d4(yrr(i, 16)) = d4(yrr(i, 16)) + yrr(i, 17)  ' Qty Shipped
            d5(yrr(i, 16)) = d5(yrr(i, 16)) + yrr(i, 19)  ' Qty Received
            d6(yrr(i, 16)) = d6(yrr(i, 16)) + yrr(i, 21)  ' Qty Remaining
            
            If Mid(yrr(i, 6), 1, 1) = "D" Then
                d7(yrr(i, 16)) = d7(yrr(i, 16)) + yrr(i, 17)
            End If
            
        Next
    End With
    
    With Sheet1
        .Range("a2:ao10000").Cells.Clear
        .Columns("a:b").NumberFormat = "@"
        
        ' combine all items here
            ' KNQ_OnHand
            krr = Sheet9.Range("a1").CurrentRegion
            For i = 2 To UBound(krr)
                d1(krr(i, 1)) = d1(krr(i, 1)) + krr(i, 4)
                d(krr(i, 1)) = ""
            Next
            Erase krr
            
            ' HJ_SN
            ' get rid of duplicated sn in HJ_SN Sheet
            With Sheet2
                Dim nrow&
                nrow = .Range("a1048576").End(3).Row
                .Range("a1:G" & nrow).RemoveDuplicates Columns:=2, Header:=xlNo
                
                hrr = .Range("a1").CurrentRegion
                For i = 2 To UBound(hrr)
                  If hrr(i, 6) <> "SH001AA2" Then
                    d2(hrr(i, 3)) = d2(hrr(i, 3)) + 1
                    d(hrr(i, 3)) = ""
                  End If
                Next
            End With
            Erase hrr
            
            ' Mapics_OnHand
            mrr = Sheet3.Range("a1").CurrentRegion
            For i = 2 To UBound(mrr)
                d3(mrr(i, 1)) = d3(mrr(i, 1)) + mrr(i, 4)
                d(mrr(i, 1)) = ""
            Next
            Erase mrr
            
            ' get all onhand items
            k = d.keys
            Sheet1.Range("b2").Resize(d.Count, 1) = Application.Transpose(k)
                

                
            ThisWorkbook.Save
            
            ' get HJ SA done, but AS400 still not cut off qty from sheet HJ_2W_SA
            Call b04_update_shipped_not_invoiced_
            
            arr = .Range("a1").CurrentRegion
            
            For i = 2 To UBound(arr)
                arr(i, 1) = "335"
                
                ' Mapics
                If d3.exists(arr(i, 2)) Then
                    arr(i, 4) = d3(arr(i, 2))
                Else
                    arr(i, 4) = 0
                End If
                
                ' WA - HJ QTY
                If d2.exists(arr(i, 2)) Then
                    arr(i, 7) = d2(arr(i, 2))
                Else
                    arr(i, 7) = 0
                End If
                
                ' KNQMAN Qty
                If d1.exists(arr(i, 2)) Then
                    arr(i, 12) = d1(arr(i, 2))
                Else
                    arr(i, 12) = 0
                End If
                
                
                ' YA Qty
                If d4.exists(arr(i, 2)) Then
                    arr(i, 8) = d4(arr(i, 2))
                Else
                    arr(i, 8) = 0
                End If
            
            
                ' YA Received
                If d5.exists(arr(i, 2)) Then
                    arr(i, 9) = d5(arr(i, 2))
                Else
                    arr(i, 9) = 0
                End If
                
                ' YA Qty Remained
                If d6.exists(arr(i, 2)) Then
                    arr(i, 10) = d6(arr(i, 2))
                Else
                    arr(i, 10) = 0
                End If
                
                'YA DOOR Qty
                If d7.exists(arr(i, 2)) Then
                    arr(i, 6) = d7(arr(i, 2))
                Else
                    arr(i, 6) = 0
                End If
                
                ' Mapics HJ Diff
                arr(i, 3) = arr(i, 7) + arr(i, 6) + arr(i, 5) - arr(i, 4)
                
                'KNQ HJ Variance
                arr(i, 13) = arr(i, 7) + arr(i, 8) + arr(i, 5) - arr(i, 12)
            
            Next
            .Range("b:b").NumberFormat = "@"
'            .Range("b:b").NumberFormat = "@"
            
            Sheet1.Range("a1").Resize(UBound(arr), UBound(arr, 2)).Value = arr
            
            With Sheet1.Range("a1:ai" & .Range("a1048576").End(3).Row)
                .Sort .Range("y1"), xlAscending, .Range("b1"), , xlAscending, , , xlYes
            End With
            
            .Columns.AutoFit
            
        End With
        
    Erase arr
    Set d = Nothing
    Set d1 = Nothing
    Set d2 = Nothing
    Set d3 = Nothing
    Set d4 = Nothing
    Set d5 = Nothing
    Set d6 = Nothing
    Set d7 = Nothing
    
    Application.ScreenUpdating = True
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
