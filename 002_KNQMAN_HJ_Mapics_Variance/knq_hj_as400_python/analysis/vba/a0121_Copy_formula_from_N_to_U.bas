Attribute VB_Name = "a0121_Copy_formula_from_N_to_U"
Sub a0121_Copy_formula_from_N_to_U_()
    
    Application.ScreenUpdating = False
    Dim i&, lrow&
    lrow = Sheet1.Range("A1048576").End(xlUp).Row
    With Sheet1
        .Range("n2").Formula = "=ABS(M2)"
        .Range("o2").Formula = "=SUMIFS(PO!E:E,PO!A:A,DATA!B2)"
        .Range("p2").Formula = "=SUMIFS(Trips!E:E,Trips!A:A,DATA!B2)"
        .Range("q2").Formula = "=SUMIFS(Adjusted!H:H,Adjusted!C:C,DATA!B2)"
        .Range("r2").Formula = "=COUNTIFS(HJ_NG!C:C,DATA!B2)"
        .Range("s2").Formula = "=SUMIFS('KNQ delared but HJ not'!N:N,'KNQ delared but HJ not'!K:K,DATA!B2)"
        .Range("t2").Formula = "=SUMIFS('Trailer in Yard but KNQ not'!N:N,'Trailer in Yard but KNQ not'!K:K,DATA!B2)"
        .Range("u2").Formula = "=L2+O2-P2-S2-G2"
        .Range("v2").Formula = "=L2-D2"
        .Range("W2").Formula = "=COUNTIFS(HJ_SN!C:C,DATA!B2,HJ_SN!F:F,""=EX001AA1"")"
'        .Range("w2").Formula = "=IF(AND(D2=G2,G2=L2),""MAPICS=HJ=KNQMAN"",IF(AND(D2=G2+H2,G2+H2=L2),""MAPICS=HJ=KNQMAN"",IF(AND(D2=G2+H2,G2+H2<>L2),""MAPICS=HJ<>KNQMAN"",IF(AND(D2=G2,G2<>L2),""MAPICS=HJ<>KNQMAN"",IF(AND(D2<>G2,G2=L2),""MAPICS<>HJ=KNQMAN"",IF(AND(D2=L2,G2<>L2),""MAPICS=KNQMAN<>HJ"",IF(AND(D2<>L2,G2<>L2),""MAPICS<>HJ<>KNQMAN"",""VIEW"")))))))"
    
        .Range("n2:w2").AutoFill Destination:=.Range("n2:w" & lrow)
'        .Range("u2:v2").AutoFill Destination:=.Range("u2:v" & lrow)
        .Range("x2:x" & lrow).NumberFormat = "@"
        .Range("b2:b" & lrow).Copy Destination:=.Range("x2:x" & lrow)
        
'        .Range("x2:x" & lrow).Value = .Range("x2:x" & lrow).Value
'        .Range("a1048576").End(3).Offset(1, 0).Resize(50000, 39).Clear
        
    
    End With
    Application.ScreenUpdating = True
    
    
    
End Sub
