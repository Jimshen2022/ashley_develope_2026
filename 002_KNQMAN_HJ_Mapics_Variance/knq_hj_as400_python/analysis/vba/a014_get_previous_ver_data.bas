Attribute VB_Name = "a014_get_previous_ver_data"
Sub a014_get_previous_ver_data_()

    Application.ScreenUpdating = False
    Dim i&, j&, arr, brr, crr, d As Object, d1 As Object, nrow&
    Set d = CreateObject("scripting.dictionary")
    Set d1 = CreateObject("scripting.dictionary")
    
    With Sheet14
        
        brr = .Range("a1").CurrentRegion
        For i = 2 To UBound(brr)
            d(brr(i, 2)) = brr(i, 28) & "|" & brr(i, 29) & "|" & brr(i, 30) & "|" & brr(i, 31) & "|" & brr(i, 32) & "|" & brr(i, 33)
        Next
    End With

    With Sheet23
        crr = .Range("a1").CurrentRegion
        For i = 2 To UBound(crr)
            d1(crr(i, 4)) = d1(crr(i, 4)) + crr(i, 6)
        Next
    End With

    With Sheet1
        arr = .Range("a1").CurrentRegion
        For i = 2 To UBound(arr)
            If d.exists(arr(i, 2)) Then
                arr(i, 28) = Split(d(arr(i, 2)), "|")(0)
                arr(i, 29) = Split(d(arr(i, 2)), "|")(1)
                arr(i, 30) = Split(d(arr(i, 2)), "|")(2)
                arr(i, 31) = Split(d(arr(i, 2)), "|")(3)
                arr(i, 32) = Split(d(arr(i, 2)), "|")(4)
                arr(i, 33) = Split(d(arr(i, 2)), "|")(5)
            Else
            End If
        
            
            ' Variance List
            If d1.exists(arr(i, 2)) Then
                arr(i, 34) = d1(arr(i, 2))
            Else
                arr(i, 34) = 0
            End If
            
  
        Next
        
          'Shipped Not Invoiced
'          .Range("e2:e" & UBound(arr)).NumberFormat = "General" '½«¸ñÊ½¸ÄÎªÒ»°ã£¬·ñÔòÏÂ¹«Ê½»á±íÏÖÎªÎÄ±¾¶øÎÞ·¨Æð×÷ÓÃ
'          .Range("e2") = "=SUMIFS(HJDATA!g:g,HJDATA!B:B,DATA!B2)"
'          .Range("e2").AutoFill Destination:=.Range("e2:e" & UBound(arr)) '¸´ÖÆ¹«Ê½¹ÜÆë£¬ÕâÀï±ØÐëÒª°üÀ¨À´Ô´µÄ·¶Î§
            
          
          
          'RollBack
          .Range("aa2:aa" & UBound(arr)).NumberFormat = "General" '½«¸ñÊ½¸ÄÎªÒ»°ã£¬·ñÔòÏÂ¹«Ê½»á±íÏÖÎªÎÄ±¾¶øÎÞ·¨Æð×÷ÓÃ
          .Range("aa2") = "=SUMIFS(rollback!H:H,rollback!C:C,DATA!B2)"
          .Range("aa2").AutoFill Destination:=.Range("aa2:aa" & UBound(arr)) '¸´ÖÆ¹«Ê½¹ÜÆë£¬ÕâÀï±ØÐëÒª°üÀ¨À´Ô´µÄ·¶Î§
                      
        
        
        .Range("ab1").Resize(UBound(arr), 1).Value = Application.Index(arr, , 28)
        .Range("ac1").Resize(UBound(arr), 1).Value = Application.Index(arr, , 29)
        .Range("ad1").Resize(UBound(arr), 1).Value = Application.Index(arr, , 30)
        .Range("ae1").Resize(UBound(arr), 1).Value = Application.Index(arr, , 31)
        .Range("af1").Resize(UBound(arr), 1).Value = Application.Index(arr, , 32)
        .Range("ag1").Resize(UBound(arr), 1).Value = Application.Index(arr, , 33)
        .Range("ah1").Resize(UBound(arr), 1).Value = Application.Index(arr, , 34)
                
                
        nrow = .Range("a1048576").End(3).Row
        .Range("ai2").Formula = "=IF(AH2=0,""No_Variance"",IF(AH2<0,""KNQ Qty > HJ Qty"",""KNQ Qty < HJ Qty"")) "
        .Range("ai2:ai2").AutoFill Destination:=.Range("ai2:ai" & nrow)
        .Range("k2").Formula = "=SUMIFS(exception!B:B,exception!A:A,DATA!B2)"
        .Range("k2:k2").AutoFill Destination:=.Range("k2:k" & nrow)
        .Range("aj2").Formula = "=abs(ah2)"
        .Range("aj2:aj2").AutoFill Destination:=.Range("aj2:aj" & nrow)
'        .Range("W2").Formula = "=COUNTIFS(EX001AA1!C:C,DATA!B2)"
'        .Range("W2:W2").AutoFill Destination:=.Range("W2:W" & nrow)
         .Columns("a:ai").AutoFit
        .Range("d2:d" & nrow).Font.ColorIndex = 3
        .Range("g2:g" & nrow).Font.ColorIndex = 3
        .Range("l2:l" & nrow).Font.ColorIndex = 3
        .Range("o1:w" & nrow).Font.Color = RGB(0, 0, 0)
        .Columns("c:v").ColumnWidth = 6.29
        .Columns("w:w").ColumnWidth = 6.29
        .Columns("y:aa").ColumnWidth = 6.29
        .Columns("ab:ac").ColumnWidth = 41
         
    End With
    
    Application.ScreenUpdating = True

End Sub
