Attribute VB_Name = "a001_Pull_HJ_SN_O_SQLADD"
Sub a001_Pull_HJ_SN_O_SQLADD_()

        ' Declare the variables
    Dim connection As Object
    Dim rs As Object
    Dim sql_query As String
    Dim excel_ws As Worksheet
    Dim arr As Variant
    Dim i As Long, j As Long
    Dim fieldCount As Integer
    Dim startdate As String
    Dim enddate As String
    Dim brr
    
    startdate = Sheet25.Range("c2").Value
    enddate = Sheet25.Range("c3").Value
    

    ' Initialize the variables
    Dim server_name As String
    Dim database_name As String
    server_name = "AshtonWHJSQLprod"  ' Replace with your server name
    database_name = "AAD"  ' Replace with your database name
sql_query = "with sn as ( " & _
      "SELECT t1.wh_id, t1.serial_number, t1.item_number, t1.serial_no_status,t1.po_number, t1.location_id, t1.received_date, t1.trip_number " & _
      "FROM t_serial_active AS t1 " & _
      "WHERE t1.wh_id IN ('335') AND t1.serial_no_status = 'O' " & _
      "), im as ( " & _
      "select item_number,serial_number, wh_id, serial_no_status from t_serial_master " & _
      "where wh_id in ('335') and serial_no_status <> 'S' " & _
      ") " & _
      "SELECT t1.wh_id, t1.serial_number, t1.item_number, t1.serial_no_status, im.serial_no_status as master_status, t1.trip_number, t1.po_number, t1.location_id, t1.received_date " & _
      "FROM sn t1 inner join im on t1.serial_number = im.serial_number order by t1.item_number, t1.serial_number"

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

    ' Set excel_ws to the "LinkToVBA" sheet in the workbook where this VBA code resides
    Set excel_ws = ThisWorkbook.Sheets("HJ_SN_Orphaned")
    
    ' Clear existing content from the sheet (optional)
    excel_ws.Cells.Clear

    ' Write field names (column headers)
    fieldCount = rs.Fields.Count
    For i = 0 To fieldCount - 1
        excel_ws.Cells(1, i + 1).Value = rs.Fields(i).Name
    Next i

    ' Load data into array
    arr = rs.GetRows
    
    ReDim brr(0 To UBound(arr, 2), 0 To UBound(arr))
    
    For i = 0 To UBound(arr, 2)
        For j = 0 To UBound(arr)
            brr(i, j) = arr(j, i)
        Next
    Next
    
    
    With Sheet18
        .Columns("b:c").NumberFormat = "@"
        .Columns("i").NumberFormat = "yyyy-mm-dd"
        
            ' ×ªÖÃÊý×é£¬Ê¹Æä±ä³É (ÐÐ, ÁÐ)
'        arr = Application.WorksheetFunction.Transpose(arr)
        
        ' °ÑÊý×éÐ´µ½¹¤×÷±í
        With excel_ws
            
            .Range("A2").Resize(UBound(brr, 1) + 1, UBound(brr, 2) + 1).Value = brr
        End With



    ' Write data from array to Excel
'    For i = 0 To UBound(arr, 1)
'        For j = 0 To UBound(arr, 2)
'            excel_ws.Cells(j + 2, i + 1).Value = arr(i, j)
'        Next j
'    Next i
    
        .Columns("A:E").AutoFit
    End With
    ' No need to save, as data is written directly to the workbook in use

    ' Close recordset and connection
    rs.Close
    connection.Close
    Set rs = Nothing
    Set connection = Nothing
    
    Erase arr, brr
    'MsgBox "Data downloaded successfully!", vbInformation
End Sub






