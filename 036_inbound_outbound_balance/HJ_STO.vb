
Sub a03_Pull_HJ_STO_()
    ' Declare objects for connection and recordset
    Dim conn As Object
    Dim rs As Object
    Dim strConn As String
    Dim strSQL As String
    Dim ws As Worksheet
    Dim i As Integer
    
    ' --- Configuration Section ---
    ' Target worksheet where data will be pasted
    Set ws = ThisWorkbook.Sheets("OnHand")
    
    ' Connection String for Windows Authentication
    ' Replace 'Your_Database_Name' with the actual database name on AshtonWHJSQLprod
    strConn = "Provider=SQLOLEDB;Data Source=AshtonWHJSQLprod;Initial Catalog=AAD;Integrated Security=SSPI;"

    ' SQL Query definition
    strSQL = "SELECT sto.item_number, sto.actual_qty, sto.status, sto.wh_id, sto.location_id, loc.type, sto.type " &
             "FROM t_stored_item sto " &
             "JOIN t_location loc ON sto.location_id = loc.location_id AND sto.wh_id = loc.wh_id " &
             "JOIN t_item_master itm ON sto.item_number = itm.item_number AND sto.wh_id = itm.wh_id " &
             "WHERE sto.wh_id = '335' " &
             "AND loc.type IN ('I', 'M', 'P', 'X', 'S', 'D', 'V', 'F') " &
             "AND sto.status = 'A' " &
             "AND sto.location_id NOT IN ('RP998XL1', 'SH001AA1', 'NG001VD3', 'NG001OP3', 'RP998XL3') " &
             "AND sto.item_number <> 'RP ORDER' " &
             "ORDER BY sto.item_number, sto.location_id;"

    ' --- Execution Section ---
    On Error GoTo ErrorHandler
    
    ' Initialize ADODB objects
    Set conn = CreateObject("ADODB.Connection")
    Set rs = CreateObject("ADODB.Recordset")
    
    ' Open connection and execute query
    conn.Open strConn
    rs.Open strSQL, conn

    ' Clear existing data in the sheet to prevent overlap
    ws.Cells.Clear

    ' Write Header row using field names from the database
    For i = 0 To rs.Fields.Count - 1
        ws.Cells(1, i + 1).Value = rs.Fields(i).Name
    Next i

    ' Copy data from recordset starting at cell A2
    If Not rs.EOF Then
        ws.Range("A2").CopyFromRecordset rs
        MsgBox "Data extraction successful!", vbInformation
    Else
        MsgBox "No data found matching the criteria.", vbExclamation
    End If

CleanUp:
    ' Close connections and release memory
    If Not rs Is Nothing Then
        If rs.State = 1 Then rs.Close
    End If
    If Not conn Is Nothing Then
        If conn.State = 1 Then conn.Close
    End If
    Set rs = Nothing
    Set conn = Nothing
    Exit Sub

ErrorHandler:
    ' Display error message if something goes wrong
    MsgBox "An error occurred: " & Err.Description, vbCritical
    Resume CleanUp
End Sub

