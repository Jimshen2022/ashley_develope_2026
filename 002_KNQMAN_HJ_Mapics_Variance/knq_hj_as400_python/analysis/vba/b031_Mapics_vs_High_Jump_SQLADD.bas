Attribute VB_Name = "b031_Mapics_vs_High_Jump_SQLADD"
Sub b031_Mapics_vs_High_Jump_SQLADD_()
    Application.ScreenUpdating = False

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
    
'    startdate = Sheet25.Range("c2").Value
'    enddate = Sheet25.Range("c3").Value
'
    ' Initialize the variables
    Dim server_name As String
    Dim database_name As String
    server_name = "AshtonWHJSQLprod"
    database_name = "AAD"

sql_query = "SELECT o.item_number, CAST(LEFT(o.order_number, 7) AS INT) AS trip_nbr, " & _
            "CASE WHEN o.item_number = 'RP ORDER' THEN CAST(RIGHT(o.c_number, 7) AS VARCHAR(7)) " & _
            "ELSE CAST(RIGHT(o.c_number, 6) AS VARCHAR(6)) END AS c_number, " & _
            "SUM(o.qty_shipped) AS qty " & _
            "FROM t_order_detail_breakdown AS o " & _
            "WHERE CAST(LEFT(o.order_number, 7) AS INT) IN ( " & _
                "SELECT CAST(LEFT(l.control_number_2, 7) AS INT) FROM t_tran_log AS l " & _
                "WHERE l.tran_type = '347' AND l.start_tran_date >= DATEADD(DAY, -2, CAST(GETDATE() AS DATE)) " & _
                "GROUP BY CAST(LEFT(l.control_number_2, 7) AS INT)) " & _
            "GROUP BY o.item_number, CAST(LEFT(o.order_number, 7) AS INT), " & _
            "CASE WHEN o.item_number = 'RP ORDER' THEN CAST(RIGHT(o.c_number, 7) AS VARCHAR(7)) " & _
            "ELSE CAST(RIGHT(o.c_number, 6) AS VARCHAR(6)) END" & _
             " HAVING  SUM(o.qty_shipped)> 0 "
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
    Set excel_ws = ThisWorkbook.Sheets("HJ_2W_SA")
    
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
    
    ' Apply formatting before writing data
    With excel_ws
        .Columns("A:c").NumberFormat = "@"
'        .Columns("C").NumberFormat = "yyyy-mm-dd"
'        .Columns("F").NumberFormat = "@"
        
        ' Bulk write array to sheet in one operation (fastest method)
        .Range("A2").Resize(rowCount, colCount).Value = arrT
        
        .Columns("A:F").AutoFit
    End With
    
    ' Close recordset and connection
    rs.Close
    connection.Close
    Set rs = Nothing
    Set connection = Nothing
Application.ScreenUpdating = True
        
    'MsgBox "Data downloaded successfully! " & rowCount & " rows loaded.", vbInformation

End Sub






