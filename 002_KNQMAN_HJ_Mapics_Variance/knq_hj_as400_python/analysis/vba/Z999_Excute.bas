Attribute VB_Name = "Z999_Excute"
Sub a999_Ashton_KNQMAN_vs_HJ_Report_()
    
    t = Timer
    'ActiveWorkbook.SaveAs ActiveWorkbook.Path & "\Ashton RP Open Orders Fulfillment-" & Format(Now(), "yyyymmdd.hhmm") & ".xlsm"
    Application.ScreenUpdating = False
   
    Call Filter_
    Call a0_ASYARD_2_SQLADD_
    'Call a0_KNQ_ONHAND_
    
    ' HJ SA done but AS400 still not
    Call b031_Mapics_vs_High_Jump_SQLADD_
    Call b032_mapics_sa_transaction_
    Call b033_hj_sa_done_as400_not_
    
    Call a0_Mapics_OnHand_
    Call a0_mapics_adjusted_
    Call a0_Pull_HJ_SN_RLH_SQLADD_
    Call a001_Pull_HJ_NG_SQLADD_
    Call a001_Pull_HJ_SN_O_SQLADD_
    'Call a002_KNQ_4W_IMPORTED_
    Call a0_KNQ_ONHAND_SQLSERVER_
    Call a002_KNQ_4W_IMPORTED_SQLSERVER_
    'Call a003_KNQ_4W_EXPORTED_
    Call a003_KNQ_4W_EXPORTED_SQLSERVER_
    Call a0042_HJ_4W_Received_SQLADD_
    Call a0051_HJ_4W_Shipped_SQLADD_
    'Call a016_Mapics_vs_High_Jump_
    
    Call a007_PO_
    Call a008_Trip_
    Call a009_KNQ_Declared_but_HJ_NOT_
    Call a0091_MAPICS_HJ_KNQ_VARIANCE_
    Call a010_get_item_class_
    Call a0120_Trailer_in_Yard_KNQ_not_
    Call a0121_Copy_formula_from_N_to_U_
    Call a013_Products_item_class_
    Call a014_get_previous_ver_data_
    Call a015_mark_no_variances_items_
    Call a018_CopyFilteredData_
    Call a019_CopyFilteredData_SH001AA1_
    Call a020_CopyFilteredData_NG001VD3_
    Call a020_1CopyFilteredData_EX001AA2_
    Call a020_CopyFilteredData_SH001AA2_
    Call a021_CN001AA1_
    Call a022_EX001AA2_
    Call b01_add_orphaned_column_
    Call b02_DATA_VARIANCE_
    Call b05_product_
    Call B06_sh001aa2_to_sheet1_
    Call Filter_
    
    Sheet24.Range("a2").Value = "DataCollectedAt: " & Format(Now(), "yyyy/mm/dd  hh:mm:ss")
    Sheet24.Range("a2").Font.ColorIndex = 3

    Sheet25.Range("e1").Value = "Updated Successful~  Wall Time: " & Format(Timer - t, "#,##.00") & "s."
    Application.ScreenUpdating = True
    
    Sheet1.Select
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


