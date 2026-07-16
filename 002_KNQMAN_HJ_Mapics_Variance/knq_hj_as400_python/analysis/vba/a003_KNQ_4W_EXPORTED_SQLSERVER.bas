Attribute VB_Name = "a003_KNQ_4W_EXPORTED_SQLSERVER"
Sub a003_KNQ_4W_EXPORTED_SQLSERVER_()
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
    Dim rawStart As String
    Dim rawEnd As String
    Dim rowCount As Long
    Dim colCount As Long
    
    ' ³õÊ¼»¯Êý¾Ý¿âÁ¬½Ó²ÎÊý
    Dim server_name As String
    Dim database_name As String
    server_name = "VPHUVNVPSQ23267"
    database_name = "ECUS5_KNQ"
    
    ' ¡ï ºËÐÄÐÞ¸´£º´Óµ¥Ôª¸ñ»ñÈ¡ÈÕÆÚ£¬Ôö¼Ó¡¾·Àµ¯ÇåÏ´»úÖÆ¡¿£¬³¹µ×¹ýÂËµôÇ±·üµÄµ¥ÒýºÅºÍË«ÒýºÅ
    rawStart = Replace(Replace(Sheet25.Range("C2").Value, "'", ""), """", "")
    rawEnd = Replace(Replace(Sheet25.Range("C3").Value, "'", ""), """", "")
    
    ' Ç¿ÖÆ¸ñÊ½»¯Îª SQL ÈÏÊ¶µÄ±ê×¼¸ñÊ½ yyyy-MM-dd
    startdate = Format(rawStart, "yyyy-MM-dd")
    enddate = Format(rawEnd, "yyyy-MM-dd")
    
    ' =========================================================================
    ' ¹¹ÔìÖÕ¼«ÍêÕû°æ KNQ_4W_EXPORTED SQL ½Å±¾
    ' =========================================================================
    sql_query = ""
    sql_query = sql_query & "SET NOCOUNT ON; " & vbCrLf
    sql_query = sql_query & "SET ANSI_WARNINGS OFF; " & vbCrLf
    sql_query = sql_query & "SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED; " & vbCrLf
    
    ' ¡ï ÑÏ¸ñ¹æ·¶µÄµ¥ÒýºÅ°ü¹ü£¬È·±£Éú³ÉµÄ SQL ÊÇÕýÈ·µÄ '2026-05-01' ¸ñÊ½
    sql_query = sql_query & "DECLARE @MaKNQ NVARCHAR(50) = 'VNNSL'; " & vbCrLf
    sql_query = sql_query & "DECLARE @StartDate DATETIME = '" & startdate & "'; " & vbCrLf
    sql_query = sql_query & "DECLARE @EndDate DATETIME = '" & enddate & "'; " & vbCrLf
    
    ' STEP 1: ÌáÈ¡¼¯×°ÏäÖØÏä
    sql_query = sql_query & "IF OBJECT_ID('tempdb..#XUAT') IS NOT NULL DROP TABLE #XUAT; " & vbCrLf
    sql_query = sql_query & "SELECT CAST('' AS NVARCHAR(100)) AS CKEYS, A.TYPE, A.SOTK AS SOTK_X, A.NGAY_DK AS NGAY_DK_X, A.SO_PHIEU, A.NGAY_PHIEU, A.DPHIEUID, A.DHOPDONGID, A.SO_HD, A.NGAY_HD, "
    sql_query = sql_query & "MAX(A.SO_BBBG) AS SO_BBBG, MAX(A.SO_CHUNG_TU) AS SO_CHUNG_TU, MAX(A.TEN_NGUOI_NHAN_HANG) AS TEN_NGUOI_NHAN_HANG, MAX(A.TONG_SO_KIEN) AS TONG_SO_KIEN, MAX(A.PHUONG_TIEN) AS PHUONG_TIEN, "
    sql_query = sql_query & "B.SO_PHIEU_N, B.STTHANG_N, B.STTHANG, B.SO_TK, CAST(B.NGAY_DK AS DATE) AS NGAY_DK, B.MA_SP, B.DINH_DANH_HANG_HOA, B.SO_CONT, "
    sql_query = sql_query & "MAX(B.TEN_SP) AS TEN_SP, MAX(B.MA_NUOC) AS MA_NUOC, MAX(B.MA_HS) AS MA_HS, SUM(B.SO_LUONG) AS SO_LUONG, MAX(B.MA_DVT) AS MA_DVT, SUM(B.TRONG_LUONG_GW) AS TRONG_LUONG_GW, SUM(B.TRONG_LUONG_NW) AS TRONG_LUONG_NW, "
    sql_query = sql_query & "SUM(B.TRI_GIA) AS TRI_GIA, MAX(B.VI_TRI_HANG) AS VI_TRI_HANG, MAX(I.TEN_DVT) AS TEN_DVT, MAX(T.TEN_CK) AS TEN_CK, MAX(DF.SO_SEAL) AS SO_SEAL, "
    sql_query = sql_query & "CAST('' AS NVARCHAR(250)) AS GHI_CHU, MAX(B.GHI_CHU) AS GHI_CHU_HANG, CAST(NULL AS DATE) AS NGAY_NHAP, CAST(NULL AS INT) AS SO_NGAY_TON, MAX(B.SO_QUAN_LY) AS SO_QUAN_LY "
    sql_query = sql_query & "INTO #XUAT FROM DPHIEU A WITH (NOLOCK) "
    sql_query = sql_query & "INNER JOIN DPHIEU_HANG B WITH (NOLOCK) ON A.DPHIEUID = B.DPHIEUID AND ISNULL(B.IS_HUY, 0) = 0 "
    sql_query = sql_query & "INNER JOIN DCONTAINER DF WITH (NOLOCK) ON DF.DPHIEUID = A.DPHIEUID AND DF.IS_RUTHANG = 0 AND DF.TINH_TRANG = 1 AND A.DRUTHANGID IS NULL "
    sql_query = sql_query & "LEFT JOIN SDVT I WITH (NOLOCK) ON B.MA_DVT = I.MA_DVT "
    sql_query = sql_query & "LEFT JOIN SCUAKHAU T WITH (NOLOCK) ON T.MA_CK = A.MA_CK_XUAT "
    sql_query = sql_query & "WHERE A.MA_KNQ = @MaKNQ AND A.TYPE = 1 AND A._XORN = 'X' AND A.MA_NGUON <> 'X4' AND A.TRANG_THAI = 'T' "
    sql_query = sql_query & "AND ((A.PB_PHIEU = 'CT' AND A.DPHIEUID_NEXT IS NULL) OR (A.PB_PHIEU = 'SU' AND A.DPHIEUID_PREV IS NOT NULL)) "
    sql_query = sql_query & "AND A.NGAY_PHIEU >= @StartDate AND A.NGAY_PHIEU <= @EndDate "
    sql_query = sql_query & "GROUP BY A.TYPE, A.SOTK, A.NGAY_DK, A.SO_PHIEU, A.NGAY_PHIEU, A.DPHIEUID, A.DHOPDONGID, A.SO_HD, A.NGAY_HD, B.SO_PHIEU_N, B.STTHANG_N, B.STTHANG, B.SO_TK, CAST(B.NGAY_DK AS DATE), B.MA_SP, B.DINH_DANH_HANG_HOA, B.SO_CONT; " & vbCrLf
    
    ' STEP 2: ×·¼ÓÉ¢»õ³ö¿â
    sql_query = sql_query & "INSERT INTO #XUAT SELECT CAST('' AS NVARCHAR(100)) AS CKEYS, A.TYPE, A.SOTK AS SOTK_X, A.NGAY_DK AS NGAY_DK_X, A.SO_PHIEU, A.NGAY_PHIEU, A.DPHIEUID, A.DHOPDONGID, A.SO_HD, A.NGAY_HD, "
    sql_query = sql_query & "MAX(A.SO_BBBG) AS SO_BBBG, MAX(A.SO_CHUNG_TU) AS SO_CHUNG_TU, MAX(A.TEN_NGUOI_NHAN_HANG) AS TEN_NGUOI_NHAN_HANG, MAX(A.TONG_SO_KIEN) AS TONG_SO_KIEN, MAX(A.PHUONG_TIEN) AS PHUONG_TIEN, "
    sql_query = sql_query & "B.SO_PHIEU_N, B.STTHANG_N, B.STTHANG, B.SO_TK, CAST(B.NGAY_DK AS DATE) AS NGAY_DK, B.MA_SP, B.DINH_DANH_HANG_HOA, B.SO_CONT, "
    sql_query = sql_query & "MAX(B.TEN_SP) AS TEN_SP, MAX(B.MA_NUOC) AS MA_NUOC, MAX(B.MA_HS) AS MA_HS, SUM(B.SO_LUONG) AS SO_LUONG, MAX(B.MA_DVT) AS MA_DVT, "
    sql_query = sql_query & "SUM(B.TRONG_LUONG_GW) AS TRONG_LUONG_GW, SUM(B.TRONG_LUONG_NW) AS TRONG_LUONG_NW, SUM(B.TRI_GIA) AS TRI_GIA, MAX(B.VI_TRI_HANG) AS VI_TRI_HANG, "
    sql_query = sql_query & "MAX(I.TEN_DVT) AS TEN_DVT, MAX(T.TEN_CK) AS TEN_CK, '' AS SO_SEAL, '' AS GHI_CHU, MAX(B.GHI_CHU) AS GHI_CHU_HANG, CAST(NULL AS DATE) AS NGAY_NHAP, CAST(NULL AS INT) AS SO_NGAY_TON, MAX(B.SO_QUAN_LY) AS SO_QUAN_LY "
    sql_query = sql_query & "FROM DPHIEU A WITH (NOLOCK) INNER JOIN DPHIEU_HANG B WITH (NOLOCK) ON (A.DPHIEUID = B.DPHIEUID AND ISNULL(B.IS_HUY, 0) = 0) "
    sql_query = sql_query & "LEFT JOIN SDVT I WITH (NOLOCK) ON B.MA_DVT = I.MA_DVT LEFT JOIN SCUAKHAU T WITH (NOLOCK) ON T.MA_CK = A.MA_CK_XUAT "
    sql_query = sql_query & "WHERE A.MA_KNQ = @MaKNQ AND A.TYPE = 2 AND A._XORN = 'X' AND A.MA_NGUON <> 'X4' AND A.TRANG_THAI = 'T' "
    sql_query = sql_query & "AND ((A.PB_PHIEU = 'CT' AND A.DPHIEUID_NEXT IS NULL) OR (A.PB_PHIEU = 'SU' AND A.DPHIEUID_PREV IS NOT NULL)) "
    sql_query = sql_query & "AND A.NGAY_PHIEU >= @StartDate AND A.NGAY_PHIEU <= @EndDate "
    sql_query = sql_query & "GROUP BY A.TYPE, A.SOTK, A.NGAY_DK, A.SO_PHIEU, A.NGAY_PHIEU, A.DPHIEUID, A.DHOPDONGID, A.SO_HD, A.NGAY_HD, B.SO_PHIEU_N, B.STTHANG_N, B.STTHANG, B.SO_TK, CAST(B.NGAY_DK AS DATE), B.MA_SP, B.DINH_DANH_HANG_HOA, B.SO_CONT; " & vbCrLf
    
    ' STEP 3: ÒýÈëº£¹ØÏú»Ùµ¥Æ½ÕË
    sql_query = sql_query & "INSERT INTO #XUAT SELECT CAST('' AS NVARCHAR(100)) AS CKEYS, 2 AS TYPE, '' AS SOTK_X, NULL AS NGAY_DK_X, B.SO_PHIEU, B.NGAY_PHIEU, 0 AS DPHIEUID, A.DHOPDONGID, A.SO_HD, H.NGAY_NHAP AS NGAY_HD, E.SO_BBBG, '' AS SO_CHUNG_TU, '' AS TEN_NGUOI_NHAN_HANG, A.SO_KIEN, E.PHUONG_TIEN, A.SO_PHIEU_N, E.STTHANG_N, NULL AS STTHANG, E.SO_TK, CAST(E.NGAY_DK AS DATE) AS NGAY_DK, A.MA_SP, A.DINH_DANH_HANG_HOA, E.SO_CONT, A.TEN_SP, E.MA_NUOC, E.MA_HS, A.SO_LUONG, A.MA_DVT, E.TRONG_LUONG_GW, E.TRONG_LUONG_NW, E.TRI_GIA, E.VI_TRI_HANG, I.TEN_DVT, T.TEN_CK, '' AS SO_SEAL, CAST(N'H¨¤ng ti¨ºu h?y' AS NVARCHAR(250)) AS GHI_CHU, A.GHI_CHU AS GHI_CHU_HANG, E.NGAY_PHIEU AS NGAY_NHAP, CAST(NULL AS INT) AS SO_NGAY_TON, '' AS SO_QUAN_LY "
    sql_query = sql_query & "FROM DTIEUHUY_CT A WITH (NOLOCK) INNER JOIN DTIEUHUY B WITH (NOLOCK) ON A.DTIEUHUYID = B.DTIEUHUYID "
    sql_query = sql_query & "INNER JOIN (SELECT D.DHOPDONGID, D.SO_PHIEU, D.NGAY_PHIEU, D.SO_BBBG, D.PHUONG_TIEN, D.MA_CK_XUAT, D.MA_NGUON, C.STTHANG_N, C.DINH_DANH_HANG_HOA, C.SO_TK, CAST(C.NGAY_DK AS DATE) AS NGAY_DK, C.SO_CONT, C.MA_NUOC, C.MA_HS, C.TRONG_LUONG_NW, C.TRONG_LUONG_GW, C.TRI_GIA, C.VI_TRI_HANG FROM DPHIEU_HANG C INNER JOIN DPHIEU D ON C.DPHIEUID = D.DPHIEUID AND D.MA_KNQ = @MaKNQ AND D.TYPE = 2 AND D._XORN = 'N' AND D.TRANG_THAI = 'T' AND ((D.PB_PHIEU = 'CT' AND D.DPHIEUID_NEXT IS NULL) OR (D.PB_PHIEU = 'SU' AND D.DPHIEUID_PREV IS NOT NULL))) E ON A.DHOPDONGID = E.DHOPDONGID AND A.DINH_DANH_HANG_HOA = E.DINH_DANH_HANG_HOA AND A.SO_PHIEU_N = E.SO_PHIEU "
    sql_query = sql_query & "INNER JOIN DHOPDONG H WITH (NOLOCK) ON A.DHOPDONGID = H.DHOPDONGID LEFT JOIN SDVT I WITH (NOLOCK) ON A.MA_DVT = I.MA_DVT LEFT JOIN SCUAKHAU T WITH (NOLOCK) ON T.MA_CK = E.MA_CK_XUAT "
    sql_query = sql_query & "WHERE B.MA_KNQ = @MaKNQ AND B.TRANG_THAI = '1' AND B.NGAY_PHIEU >= @StartDate AND B.NGAY_PHIEU <= @EndDate; " & vbCrLf
    
    ' STEP 4: ´©Í¸ËÝÔ´Èë¿âµ¥
    sql_query = sql_query & "UPDATE X SET "
    sql_query = sql_query & "X.SO_TK = ISNULL(NULLIF(X.SO_TK, ''), PN.SO_TK), "
    sql_query = sql_query & "X.NGAY_DK = ISNULL(X.NGAY_DK, CAST(PN.NGAY_DK AS DATE)), "
    sql_query = sql_query & "X.SO_HD = ISNULL(NULLIF(X.SO_HD, ''), P.SO_HD), "
    sql_query = sql_query & "X.NGAY_HD = ISNULL(X.NGAY_HD, P.NGAY_HD), "
    sql_query = sql_query & "X.NGAY_NHAP = ISNULL(X.NGAY_NHAP, CAST(P.NGAY_PHIEU AS DATE)) "
    sql_query = sql_query & "FROM #XUAT X "
    sql_query = sql_query & "INNER JOIN DPHIEU P WITH (NOLOCK) ON X.SO_PHIEU_N = P.SO_PHIEU AND P.MA_KNQ = @MaKNQ AND P._XORN = 'N' "
    sql_query = sql_query & "INNER JOIN DPHIEU_HANG PN WITH (NOLOCK) ON P.DPHIEUID = PN.DPHIEUID AND X.DINH_DANH_HANG_HOA = PN.DINH_DANH_HANG_HOA; " & vbCrLf
    
    ' Ëã×¼¿â´æÕËÁä
    sql_query = sql_query & "UPDATE #XUAT SET SO_NGAY_TON = DATEDIFF(dd, NGAY_NHAP, NGAY_PHIEU) + 1; " & vbCrLf
    
    ' STEP 5: ×îÖÕÊä³ö (ÍêÃÀ¶ÔÆëExcel±íÍ·ÓëÅÅÐò)
    sql_query = sql_query & "SELECT ROW_NUMBER() OVER(ORDER BY NGAY_PHIEU DESC, SO_PHIEU DESC) AS [STT], "
    sql_query = sql_query & "SO_TK AS [S? TK nh?p], NGAY_DK AS [Ng¨¤y TK], SO_HD AS [S? h?p ??ng], NGAY_HD AS [Ng¨¤y h?p ??ng], SO_PHIEU AS [S? phi?u], NGAY_PHIEU AS [Ng¨¤y phi?u], "
    sql_query = sql_query & "SO_CHUNG_TU AS [Ch?ng t? n?i b?], TONG_SO_KIEN AS [T?ng s? ki?n], TEN_NGUOI_NHAN_HANG AS [Ng??i nh?n h¨¤ng], SOTK_X AS [S? t? khai/CT], NGAY_DK_X AS [Ng¨¤y t? khai], "
    sql_query = sql_query & "NGAY_PHIEU AS [Ng¨¤y xu?t kho], NGAY_NHAP AS [Ng¨¤y nh?p], SO_NGAY_TON AS [S? ng¨¤y t?n], MA_SP AS [M? h¨¤ng], TEN_SP AS [T¨ºn h¨¤ng], MA_NUOC AS [Xu?t x?], "
    sql_query = sql_query & "SO_LUONG AS [L??ng], TEN_DVT AS [??n v? t¨ªnh], TRONG_LUONG_GW AS [Tr?ng l??ng GW], TRONG_LUONG_NW AS [Tr?ng l??ng NW], TRI_GIA AS [Tr? Gi¨¢], "
    sql_query = sql_query & "SO_QUAN_LY AS [S? qu?n ly NB], SO_CONT AS [S? container], SO_SEAL AS [S? ch¨¬ HQ], GHI_CHU AS [Ghi ch¨²], GHI_CHU_HANG AS [Ghi ch¨² h¨¤ng] "
    sql_query = sql_query & "FROM #XUAT ORDER BY [Ng¨¤y phi?u] DESC, [S? phi?u] DESC; " & vbCrLf
    sql_query = sql_query & "DROP TABLE #XUAT;"
    ' =========================================================================
    
    ' Create a new connection
    Set connection = CreateObject("ADODB.Connection")
    With connection
        .ConnectionString = "Provider=SQLOLEDB;Data Source=" & server_name & _
                            ";Initial Catalog=" & database_name & _
                            ";Integrated Security=SSPI;"
        .CommandTimeout = 0 ' ·ÀÖ¹²éÑ¯³¬Ê±
        .Open
    End With
    
    ' Execute SQL query
    Set rs = CreateObject("ADODB.Recordset")
    
    ' ¡ï ºËÐÄÐÞ¸´£ºÉèÖÃ CursorLocation = 3 ÒÔ±ãÕýÈ·´¦Àí·µ»ØµÄÓÎ±ê
    rs.CursorLocation = 3 ' adUseClient
    
    ' ¡ï ÅÅ´íÉñÆ÷£ºÈç¹ûÄã»¹»áÓöµ½´íÎó£¬Çë°´ÏÂ¼üÅÌÉÏµÄ Ctrl + G (´ò¿ªÁ¢¼´´°¿Ú) ¼ì²é´òÓ¡³öÀ´µÄ SQL
    Debug.Print sql_query
    
    ' ¿ªÆô¼ÇÂ¼¼¯
    rs.Open sql_query, connection
    
    ' ¡ï ´©Í¸ËùÓÐ SQL ¹ý³Ì²úÉúµÄ¿ÕÓÎ±ê£¬Ö±µ½ÕÒµ½ÕæÕý°üº¬×îÖÕ SELECT Êý¾ÝµÄ Recordset
    Do While rs.State = 0 ' adStateClosed
        Set rs = rs.NextRecordset
        If rs Is Nothing Then Exit Do
    Loop
    
    ' Set excel_ws to the target sheet
    Set excel_ws = ThisWorkbook.Sheets("KNQ_4W_Export")
    
    ' Clear existing content
    excel_ws.Cells.Clear
    
    ' ÑéÖ¤ rs ×´Ì¬ÊÇ·ñÕý³£´ò¿ª
    If rs Is Nothing Or rs.State = 0 Then
        MsgBox "²éÑ¯ÖÐ¶Ï£¡Î´ÄÜ»ñÈ¡µ½ÓÐÐ§Êý¾Ý¼¯¡£", vbCritical
        GoTo Cleanup
    End If
    
    ' Write field names (column headers)
    fieldCount = rs.Fields.Count
    For i = 0 To fieldCount - 1
        excel_ws.Cells(1, i + 1).Value = rs.Fields(i).Name
    Next i
    
    ' ·À»¤£ºÈç¹û¼ÇÂ¼¼¯Îª¿Õ£¬Ö±½ÓÌø¹ýÌî³ä²½Öè
    If Not rs.EOF Then
        ' Load data into array
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
        
        ' ¡ï Trim HÁÐ£¨µÚ8ÁÐ£©Ê×Î²¿Õ¸ñ
        Dim k As Long
        For k = 1 To rowCount
            If Not IsEmpty(arrT(k, 8)) Then
                arrT(k, 8) = Trim(arrT(k, 8))
            End If
        Next k
        
        ' Apply formatting before writing data
        With excel_ws
            ' ¸ù¾ÝÌáÈ¡³öÀ´µÄ Excel ¸ñÊ½£¬Ç¿ÖÆÉèÖÃ¹Ø¼üÁÐÎªÎÄ±¾¸ñÊ½£¬·ÀÖ¹¹ñºÅ/±¨¹Øµ¥ºÅ/0¿ªÍ·µÄÊý×Ö¶ªÊ§
            .Columns("B").NumberFormat = "@"
            .Columns("C").NumberFormat = "yyyy-mm-dd"
            .Columns("D").NumberFormat = "@"
            .Columns("E").NumberFormat = "yyyy-mm-dd"
            .Columns("F").NumberFormat = "@"
            .Columns("G").NumberFormat = "yyyy-mm-dd"
            .Columns("H").NumberFormat = "@"
            .Columns("K").NumberFormat = "@"
            .Columns("L").NumberFormat = "yyyy-mm-dd"
            .Columns("M").NumberFormat = "yyyy-mm-dd"
            .Columns("N").NumberFormat = "yyyy-mm-dd"
            .Columns("P").NumberFormat = "@"
            .Columns("X").NumberFormat = "@"
            .Columns("Y").NumberFormat = "@"
            .Columns("Z").NumberFormat = "@"
            
            ' Bulk write array to sheet in one operation
            .Range("A2").Resize(rowCount, colCount).Value = arrT
        End With
        
        'MsgBox "KNQ_4W_EXPORTED Data downloaded successfully! " & rowCount & " rows loaded.", vbInformation
    Else
        'MsgBox "²éÑ¯Íê³É£¬µ«ÔÚËùÑ¡Ê±¼ä¶ÎÄÚÃ»ÓÐ³ö¿âÊý¾Ý¡£", vbExclamation
    End If
    
    ' Ó¦ÓÃÄãµÄ½çÃæÑùÊ½ (ÎÞÂÛÊÇ·ñÓÐÊý¾Ý¶¼Ö´ÐÐ)
    With excel_ws
        .Columns.AutoFit
        .Range("G1:H1").Interior.ColorIndex = 10
        .Range("G1:H1").Font.ColorIndex = 2
        .Range("P1").Interior.ColorIndex = 10
        .Range("P1").Font.ColorIndex = 2
        .Range("S1").Interior.ColorIndex = 10
        .Range("S1").Font.ColorIndex = 2
    End With

Cleanup:
    ' Close recordset and connection
    If Not rs Is Nothing Then
        If rs.State = 1 Then rs.Close
    End If
    If Not connection Is Nothing Then
        If connection.State = 1 Then connection.Close
    End If
    Set rs = Nothing
    Set connection = Nothing
    Application.ScreenUpdating = True
    
End Sub

