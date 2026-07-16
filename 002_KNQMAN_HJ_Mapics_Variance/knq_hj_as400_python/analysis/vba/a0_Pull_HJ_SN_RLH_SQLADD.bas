Attribute VB_Name = "a0_Pull_HJ_SN_RLH_SQLADD"
Sub a0_Pull_HJ_SN_RLH_SQLADD_()
    ' Declare the variables
    Dim connection As Object
    Dim rs As Object
    Dim sql_query As String
    Dim excel_ws As Worksheet
    Dim arr As Variant
    Dim arrT() As Variant
    Dim i As Long, j As Long
    Dim fieldCount As Integer
    Dim startdate As String
    Dim enddate As String
    Dim rowCount As Long
    Dim colCount As Long
    
    startdate = Sheet25.Range("c2").Value
    enddate = Sheet25.Range("c3").Value
    
    ' Initialize the variables
    Dim server_name As String
    Dim database_name As String
    server_name = "AshtonWHJSQLprod"
    database_name = "AAD"
    
    sql_query = "WITH sn AS (" & _
               "SELECT t1.wh_id, t1.serial_number, t1.item_number, t1.serial_no_status, t1.location_id, t1.received_date " & _
               "FROM t_serial_active AS t1 " & _
               "WHERE t1.wh_id IN ('335') AND t1.serial_no_status not in ('O','S') and t1.location_id != 'NG001OP3' " & _
               "), " & _
               "im AS (" & _
               "SELECT item_number, serial_number, wh_id, serial_no_status " & _
               "FROM t_serial_master " & _
               "WHERE wh_id IN ('335') " & _
               ") " & _
               "SELECT t1.wh_id, t1.serial_number, t1.item_number, t1.serial_no_status, " & _
               "im.serial_no_status AS master_status, t1.location_id, t1.received_date " & _
               "FROM sn t1 " & _
               "INNER JOIN im ON t1.serial_number = im.serial_number"
    
    ' Create a new connection
    Set connection = CreateObject("ADODB.Connection")
    With connection
        .ConnectionString = "Provider=SQLOLEDB;Data Source=" & server_name & _
                            ";Initial Catalog=" & database_name & _
                            ";Integrated Security=SSPI;"
        .Open
    End With
    
    ' Execute SQL query
    Set rs = CreateObject("ADODB.Recordset")
    rs.Open sql_query, connection
    
    ' Set excel_ws to the target sheet
    Set excel_ws = ThisWorkbook.Sheets("HJ_SN")
    
    ' Clear existing content
    excel_ws.Cells.Clear
    
    ' Write field names (column headers)
    fieldCount = rs.Fields.Count
    For i = 0 To fieldCount - 1
        excel_ws.Cells(1, i + 1).Value = rs.Fields(i).Name
    Next i
    
    ' Load data into array
    ' rs.GetRows returns (0 to fieldCount-1, 0 to rowCount-1) ¡ú (col, row)
    arr = rs.GetRows
    
    rowCount = UBound(arr, 2) + 1   ' Êµ¼ÊÐÐÊý
    colCount = UBound(arr, 1) + 1   ' Êµ¼ÊÁÐÊý
    
    ' Manually transpose: arrT(row, col) format for bulk write
    ReDim arrT(1 To rowCount, 1 To colCount)
    For i = 1 To rowCount
        For j = 1 To colCount
            arrT(i, j) = arr(j - 1, i - 1)
        Next j
    Next i
    
    ' Apply formatting and bulk write
    With excel_ws
        .Columns("B:C").NumberFormat = "@"
        .Columns("G").NumberFormat = "yyyy-mm-dd"
        
        ' Bulk write array to sheet in one operation (fastest method)
        .Range("A2").Resize(rowCount, colCount).Value = arrT
        
        .Columns("A:G").AutoFit
    End With
    
    ' Close recordset and connection
    rs.Close
    connection.Close
    Set rs = Nothing
    Set connection = Nothing
    
    Erase arr, arrT
    
    'MsgBox "Data downloaded successfully! " & rowCount & " rows loaded.", vbInformation

End Sub

