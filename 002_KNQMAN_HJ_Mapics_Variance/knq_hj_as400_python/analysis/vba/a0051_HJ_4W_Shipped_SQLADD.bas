Attribute VB_Name = "a0051_HJ_4W_Shipped_SQLADD"
Sub a0051_HJ_4W_Shipped_SQLADD_()
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
    
    sql_query = "SELECT t.item_number as Item#, t.control_number_2 as Trip#, t.start_tran_date as [Date], t.routing_code as CTN#, SUM(t.tran_qty) as Shipped_Qty, CAST(CAST(SUBSTRING(control_number_2, 1, 7) AS INT) AS VARCHAR) AS Trip_Number " & _
                " FROM t_tran_log as t WHERE t.start_tran_date between " & startdate & " AND " & enddate & _
                " AND t.tran_type IN ('347') " & _
                " GROUP BY t.item_number,t.control_number_2,t.start_tran_date,t.routing_code, CAST(CAST(SUBSTRING(control_number_2, 1, 7) AS INT) AS VARCHAR) "
    
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
    Set excel_ws = ThisWorkbook.Sheets("HJ_4W_Shipped")
    
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
        .Columns("A").NumberFormat = "@"
        .Columns("C").NumberFormat = "yyyy-mm-dd"
        .Columns("F").NumberFormat = "@"
        
        ' Bulk write array to sheet in one operation (fastest method)
        .Range("A2").Resize(rowCount, colCount).Value = arrT
        
        .Columns("A:F").AutoFit
    End With
    
    ' Close recordset and connection
    rs.Close
    connection.Close
    Set rs = Nothing
    Set connection = Nothing
    
    'MsgBox "Data downloaded successfully! " & rowCount & " rows loaded.", vbInformation

End Sub

