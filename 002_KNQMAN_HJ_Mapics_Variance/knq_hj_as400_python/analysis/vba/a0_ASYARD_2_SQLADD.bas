Attribute VB_Name = "a0_ASYARD_2_SQLADD"
Sub a0_ASYARD_2_SQLADD_()
    ' Declare the variables
    Dim connection As Object
    Dim rs As Object
    Dim sql_query As String
    Dim excel_ws As Worksheet
    Dim arr As Variant
    Dim i As Long, j As Long
    Dim fieldCount As Integer

    ' Initialize the variables
    Dim server_name As String
    Dim database_name As String
    server_name = "AshtonWHJSQLprod"  ' Replace with your server name
    database_name = "AAD"  ' Replace with your database name
    sql_query = " WITH tmp_RP_item_order AS (SELECT DISTINCT d.item_number,'RP' AS item_type FROM dbo.t_order o WITH(NOLOCK) " & _
" JOIN dbo.t_order_detail d WITH(NOLOCK) ON o.order_number=d.order_number AND o.wh_id=d.wh_id WHERE o.type_id='1159'), main_query AS (SELECT DISTINCT t.equipment_id,t.trailer_id,t.status,t.state,t.carrier_id,l.location_name,t_ya_work_q.zone,asn.disposition,d.customer_po_number,p.vendor_code,t.counted,t.entered_yard,(CASE WHEN l.[type]='DRAYAGE' THEN NULL ELSE 'Go To' END) AS disposition_unit,t.exited_yard,asn.asn_number,d.item_number,SUM(d.quantity_shipped) AS Qty_shipped,ROUND(SUM(d.quantity_shipped)/ISNULL(uom.conversion_factor,1),0) AS conversion_ship,SUM(d.quantity_received) AS Qty_received,ROUND(SUM(d.quantity_received)/ISNULL(uom.conversion_factor,1),0) AS conversion_rec,SUM(d.quantity_shipped)-SUM(d.quantity_received) AS Qty_remaining,ROUND((SUM(d.quantity_shipped)-SUM(d.quantity_received))/ISNULL(uom.conversion_factor,1),0) AS conversion_rem,SUM(d.quantity_received) AS Qty_rec, " & _
" SUM(d.quantity_shipped)-SUM(d.quantity_received) AS Qty_rem,asn.trailer_type_name,tc.comments,CASE WHEN (t_ya_work_q.zone IS NOT NULL AND t_ya_work_q.status='UNASSIGNED') THEN 'Y' ELSE 'N' END AS Scheduled,a.area_id,CASE WHEN ((ita.inventory_type IN ('FG','RM') AND ita.commodity_code IN ('LA','TA')) OR rpi.item_type='RP') THEN 'RP' ELSE 'OTHERS' END AS Item_Type FROM dbo.t_trailer t WITH(NOLOCK) LEFT JOIN dbo.t_trailer_asn trl WITH(NOLOCK) ON t.trailer_id=trl.trailer_id LEFT JOIN dbo.t_asn asn WITH(NOLOCK) ON trl.asn_id=asn.asn_id AND asn.equipment_id=t.equipment_id LEFT OUTER JOIN dbo.t_ya_work_q WITH(NOLOCK) ON t.trailer_id=t_ya_work_q.trailer_id AND t_ya_work_q.status='UNASSIGNED' AND t_ya_work_q.type='52' LEFT OUTER JOIN (SELECT t2.trailer_id,tc1.comments FROM dbo.t_trailer_comments tc1 WITH(NOLOCK) INNER JOIN (SELECT trailer_id,MAX(sequence) AS maxsequence FROM dbo.t_trailer_comments WITH(NOLOCK) " & _
" GROUP BY trailer_id) t2 ON tc1.trailer_id=t2.trailer_id AND tc1.sequence=t2.maxsequence) tc ON t.trailer_id=tc.trailer_id " & _
" JOIN dbo.t_asn_detail d WITH(NOLOCK) ON asn.asn_id=d.asn_id JOIN dbo.t_ya_location l WITH(NOLOCK) ON t.location_id=l.location_id " & _
" JOIN dbo.t_area a WITH(NOLOCK) ON t.area_id=a.area_id JOIN dbo.t_po_master p WITH(NOLOCK) ON d.customer_po_number=p.po_number LEFT JOIN dbo.t_item_uom uom WITH(NOLOCK) ON uom.item_number=d.item_number AND uom.default_receipt_uom='YES' LEFT JOIN dbo.t_item_master itm WITH(NOLOCK) ON d.item_number=itm.item_number LEFT JOIN dbo.t_item_attributes ita WITH(NOLOCK) ON d.item_number=ita.item_number LEFT JOIN tmp_RP_item_order rpi ON d.item_number=rpi.item_number WHERE l.location_name LIKE '%' AND a.area_name LIKE '%' AND t.state LIKE '%' AND ISNULL(asn.trailer_type_name,'') LIKE '%' AND ISNULL(tc.comments,'') LIKE '%' AND d.item_number LIKE '%' AND itm.commodity_code LIKE '%' AND ISNULL(p.vendor_code,'') LIKE '%' AND d.customer_po_number LIKE '%' AND t.status NOT IN ('HISTORY','LOST') " & _
" GROUP BY t.equipment_id,t.trailer_id,t.status,t.state,t.carrier_id,l.location_name,t.counted,t.entered_yard, " & _
" t.exited_yard,asn.asn_number,d.item_number,asn.trailer_type_name,tc.comments,d.customer_po_number,p.vendor_code,t_ya_work_q.zone,asn.disposition,t_ya_work_q.status,a.area_id,uom.conversion_factor,l.[type],ita.inventory_type,ita.commodity_code,rpi.item_type) " & _
" SELECT * FROM main_query m WHERE ('@in_itemtype' <> 'RP' OR ('@in_itemtype'='RP' AND m.equipment_id IN (SELECT equipment_id FROM main_query WHERE Item_Type='RP'))) ORDER BY m.entered_yard; "


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
    Set excel_ws = ThisWorkbook.Sheets("ASYARD")
    
    ' Clear existing content from the sheet (optional)
    excel_ws.Cells.Clear

    ' Write field names (column headers)
    fieldCount = rs.Fields.Count
    For i = 0 To fieldCount - 1
        excel_ws.Cells(1, i + 1).Value = rs.Fields(i).Name
    Next i

    ' Load data into array
    arr = rs.GetRows
    
    With Sheet5
        .Columns("p").NumberFormat = "@"
    End With
    ' Write data from array to Excel
    For i = 0 To UBound(arr, 1)
        For j = 0 To UBound(arr, 2)
            excel_ws.Cells(j + 2, i + 1).Value = arr(i, j)
        Next j
    Next i



    ' ×ªÖÃÊý×é£¬Ê¹Æä±ä³É (ÐÐ, ÁÐ)
'    arr = Application.WorksheetFunction.Transpose(arr)
    
    ' °ÑÊý×éÐ´µ½¹¤×÷±í
'    With excel_ws
'        .Range("A2").Resize(UBound(arr, 1), UBound(arr, 2)).Value = arr
'    End With
    ' No need to save, as data is written directly to the workbook in use

    ' Close recordset and connection
    rs.Close
    connection.Close
    Set rs = Nothing
    Set connection = Nothing

    'MsgBox "Data downloaded successfully!", vbInformation
End Sub






