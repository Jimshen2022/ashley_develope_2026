Sub a99_Excute_FWP_()
    
    t = Timer
    'ActiveWorkbook.SaveAs ActiveWorkbook.Path & "\Ashton RP Open Orders Fulfillment-" & Format(Now(), "yyyymmdd.hhmm") & ".xlsm"
    Application.ScreenUpdating = False
   
    Call Filter_
    Call a0_FWP_
    Call a01_STO_
    Call a1_Pull_Open_Trips_
    Call a2_ItemData_
    Call a3_fwp_add_columns_
    Call a4_CG_ABC_
    Call a5_ItemData_Class_
    Call a6_Location_vs_Item_mapping_
    Call a7_itemdata_get_location_abc_
    Call a71_item_family_
    Call a8_Metrics_
    Call Filter_
    
    Sheet9.Range("e2").Value = "FinishedAt: " & Format(Now(), "yyyy/mm/dd  hh:mm:ss")
    Sheet9.Range("e2").Font.ColorIndex = 3
    Sheet9.Range("E3").Value = "Updated Successful~  Wall Time: " & Format(Timer - t, "#,##.00") & "s."
    
    Application.ScreenUpdating = True

    ThisWorkbook.Save

    MsgBox "Updated successful~ " & Chr(10) & " Wall Time: " & Format(Timer - t, "#,##.00") & "s."
    
    
End Sub

Sub Filter_()
    On Error Resume Next
    Dim i%, sht As Worksheet
    
    For Each sht In Worksheets
        If sht.AutoFilterMode = True Then sht.AutoFilterMode = 0
        If sht.AutoFilterMode = False Then sht.Range("a1").AutoFilter Field:=1
    Next
    
End Sub

