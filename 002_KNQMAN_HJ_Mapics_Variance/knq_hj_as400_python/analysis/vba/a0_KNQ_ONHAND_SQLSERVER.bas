Attribute VB_Name = "a0_KNQ_ONHAND_SQLSERVER"
Sub a0_KNQ_ONHAND_SQLSERVER_()
    Application.ScreenUpdating = False
    ' Declare the variables
    Dim connection As Object
    Dim rs As Object
    Dim sql_query As String
    Dim wsDetails As Worksheet
    Dim wsSummary As Worksheet
    Dim arr As Variant
    Dim arrT() As Variant
    Dim i As Long, j As Long
    Dim fieldCount As Integer
    Dim targetDateStr As String
    Dim rawDate As String
    Dim rowCount As Long
    Dim colCount As Long
    
    ' ³õÊ¼»¯Êý¾Ý¿âÁ¬½Ó²ÎÊý
    Dim server_name As String
    Dim database_name As String
    server_name = "VPHUVNVPSQ23267"
    database_name = "ECUS5_KNQ"
    
    ' ÖÇÄÜÈÕÆÚ·ÖÅä£ºÈç¹û C3 Îª¿ÕÄ¬ÈÏÈ¡½ñÌì
    rawDate = Replace(Replace(Sheet25.Range("C3").Value, "'", ""), """", "")
    If Trim(rawDate) = "" Then
        targetDateStr = Format(Date, "yyyy-MM-dd")
    Else
        targetDateStr = Format(rawDate, "yyyy-MM-dd")
    End If
    
    ' =========================================================================
    ' ÍêÈ«Ç¶ÈëÄãÌá¹©µÄ¡¾ÖÕ¼« FIFO ºËÐÄºËÏúÒýÇæ¡¿SQL£¬²»×öÈÎºÎÌõ¼þ¸Ä¶¯£¡
    ' =========================================================================
    sql_query = ""
    sql_query = sql_query & "SET NOCOUNT ON; " & vbCrLf
    sql_query = sql_query & "SET ANSI_WARNINGS OFF; " & vbCrLf
    sql_query = sql_query & "SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED; " & vbCrLf
    
    sql_query = sql_query & "DECLARE @MaKNQ NVARCHAR(50) = 'VNNSL'; " & vbCrLf
    sql_query = sql_query & "DECLARE @TargetDate DATETIME = '" & targetDateStr & " 23:59:59'; " & vbCrLf
    
    ' STEP 1
    sql_query = sql_query & "IF OBJECT_ID('tempdb..#NHAP') IS NOT NULL DROP TABLE #NHAP; " & vbCrLf
    sql_query = sql_query & "SELECT CAST(CAST(A.DHOPDONGID AS VARCHAR) + ';' + CAST(A.TYPE AS VARCHAR) + ';' + CAST(B.DINH_DANH_HANG_HOA AS VARCHAR) + ';' AS NVARCHAR(100)) AS CKEYS, "
    sql_query = sql_query & "A.DHOPDONGID, A.TYPE, A.SO_PHIEU, A.NGAY_PHIEU, A.DPHIEUID, A.SO_HD, A.NGAY_HD, A.MA_NGUON, A.MA_NT, A.TY_GIA_VND, "
    sql_query = sql_query & "B.DPHIEU_HANGID, B.SO_TK, CAST(B.NGAY_DK AS DATE) AS NGAY_DK, F.NGAY_NHAP, B.NGAY_VAO_RA, B.DINH_DANH_HANG_HOA, "
    sql_query = sql_query & "B.MA_SP, B.TEN_SP, B.STTHANG, B.MA_NUOC, B.SO_LUONG, B.MA_DVT, B.TRONG_LUONG_GW, B.TRONG_LUONG_NW, "
    sql_query = sql_query & "B.DON_GIA AS GIA_NHAP, B.TRI_GIA, B.MA_HS, B.VI_TRI_HANG, B.SO_CONT, "
    sql_query = sql_query & "D.SO_SEAL, S.TEN_NGUON, T.TEN_DVT, G.TEN_KH, CAST('' AS NVARCHAR(100)) AS GHI_CHU "
    sql_query = sql_query & "INTO #NHAP FROM DPHIEU A WITH (NOLOCK) "
    sql_query = sql_query & "INNER JOIN DPHIEU_HANG B WITH (NOLOCK) ON A.DPHIEUID = B.DPHIEUID AND ISNULL(B.IS_HUY, 0) = 0 "
    sql_query = sql_query & "INNER JOIN DCONTAINER D WITH (NOLOCK) ON D.DPHIEUID = A.DPHIEUID AND D.SO_CONT = B.SO_CONT AND ISNULL(D.IS_HUY, 0) = 0 AND D.IS_RUTHANG = 0 "
    sql_query = sql_query & "LEFT JOIN DHOPDONG F WITH (NOLOCK) ON A.DHOPDONGID = F.DHOPDONGID "
    sql_query = sql_query & "LEFT JOIN SKHACHHANG G WITH (NOLOCK) ON G.MA_KH = F.MA_KH AND F.MA_KNQ = G.MA_KNQ "
    sql_query = sql_query & "LEFT JOIN SNGUONHANG S WITH (NOLOCK) ON S.MA_NGUON = A.MA_NGUON "
    sql_query = sql_query & "LEFT JOIN SDVT T WITH (NOLOCK) ON B.MA_DVT = T.MA_DVT "
    sql_query = sql_query & "WHERE A.MA_KNQ = @MaKNQ AND A.TYPE = 1 AND A._XORN = 'N' AND A.TRANG_THAI = 'T' "
    sql_query = sql_query & "AND ((A.PB_PHIEU = 'CT' AND A.DPHIEUID_NEXT IS NULL) OR (A.PB_PHIEU = 'SU' AND A.DPHIEUID_PREV IS NOT NULL)) AND A.NGAY_PHIEU <= @TargetDate; " & vbCrLf

    ' STEP 2
    sql_query = sql_query & "IF OBJECT_ID('tempdb..#DRUTHANG') IS NOT NULL DROP TABLE #DRUTHANG; " & vbCrLf
    sql_query = sql_query & "SELECT A.DPHIEUID, A.SO_CONT, B.SO_DINH_DANH AS DINH_DANH_HANG_HOA INTO #DRUTHANG FROM DRUTHANG A WITH (NOLOCK) "
    sql_query = sql_query & "INNER JOIN DRUTHANG_CT B WITH (NOLOCK) ON A.DRUTHANGID = B.DRUTHANGID WHERE A.MA_KNQ = @MaKNQ AND A.TRANG_THAI = 2 GROUP BY A.DPHIEUID, A.SO_CONT, B.SO_DINH_DANH; " & vbCrLf
    sql_query = sql_query & "DELETE #NHAP FROM #NHAP A, #DRUTHANG B WHERE A.DPHIEUID = B.DPHIEUID AND A.SO_CONT = B.SO_CONT; DROP TABLE #DRUTHANG; " & vbCrLf

    ' STEP 3
    sql_query = sql_query & "INSERT INTO #NHAP SELECT CAST(CAST(A.DHOPDONGID AS VARCHAR) + ';' + CAST(A.TYPE AS VARCHAR) + ';' + CAST(B.DINH_DANH_HANG_HOA AS VARCHAR) + ';' AS NVARCHAR(100)) AS CKEYS, "
    sql_query = sql_query & "A.DHOPDONGID, A.TYPE, A.SO_PHIEU, A.NGAY_PHIEU, A.DPHIEUID, A.SO_HD, A.NGAY_HD, A.MA_NGUON, A.MA_NT, A.TY_GIA_VND, "
    sql_query = sql_query & "B.DPHIEU_HANGID, B.SO_TK, CAST(B.NGAY_DK AS DATE) AS NGAY_DK, F.NGAY_NHAP, B.NGAY_VAO_RA, B.DINH_DANH_HANG_HOA, "
    sql_query = sql_query & "B.MA_SP, B.TEN_SP, B.STTHANG, B.MA_NUOC, B.SO_LUONG, B.MA_DVT, B.TRONG_LUONG_GW, B.TRONG_LUONG_NW, "
    sql_query = sql_query & "B.DON_GIA AS GIA_NHAP, B.TRI_GIA, B.MA_HS, B.VI_TRI_HANG, B.SO_CONT, '' AS SO_SEAL, S.TEN_NGUON, T.TEN_DVT, G.TEN_KH, CAST('' AS NVARCHAR(100)) AS GHI_CHU "
    sql_query = sql_query & "FROM DPHIEU A WITH (NOLOCK) INNER JOIN DPHIEU_HANG B WITH (NOLOCK) ON A.DPHIEUID = B.DPHIEUID AND ISNULL(B.IS_HUY, 0) = 0 "
    sql_query = sql_query & "LEFT JOIN DHOPDONG F WITH (NOLOCK) ON A.DHOPDONGID = F.DHOPDONGID LEFT JOIN SKHACHHANG G WITH (NOLOCK) ON G.MA_KH = F.MA_KH AND F.MA_KNQ = G.MA_KNQ "
    sql_query = sql_query & "LEFT JOIN SNGUONHANG S WITH (NOLOCK) ON S.MA_NGUON = A.MA_NGUON LEFT JOIN SDVT T WITH (NOLOCK) ON B.MA_DVT = T.MA_DVT "
    sql_query = sql_query & "WHERE A.MA_KNQ = @MaKNQ AND A.TYPE = 2 AND A._XORN = 'N' AND A.TRANG_THAI = 'T' "
    sql_query = sql_query & "AND ((A.PB_PHIEU = 'CT' AND A.DPHIEUID_NEXT IS NULL) OR (A.PB_PHIEU = 'SU' AND A.DPHIEUID_PREV IS NOT NULL)) AND A.NGAY_PHIEU <= @TargetDate; " & vbCrLf

    ' STEP 4
    sql_query = sql_query & "IF OBJECT_ID('tempdb..#XUAT') IS NOT NULL DROP TABLE #XUAT; " & vbCrLf
    sql_query = sql_query & "SELECT CAST('' AS NVARCHAR(100)) AS CKEYS, A.TYPE, A.DHOPDONGID, A.SO_HD, MAX(A.NGAY_PHIEU) AS NGAY_XUAT, B.SO_PHIEU_N, B.MA_SP, B.DINH_DANH_HANG_HOA, ROUND(SUM(B.SO_LUONG), 4) AS SO_LUONG, MAX(B.NGAY_VAO_RA) AS NGAY_GETOUT, 0 AS IS_TIEU_HUY "
    sql_query = sql_query & "INTO #XUAT FROM DPHIEU A WITH (NOLOCK) INNER JOIN DPHIEU_HANG B WITH (NOLOCK) ON (A.DPHIEUID = B.DPHIEUID AND ISNULL(B.IS_HUY, 0) = 0) "
    sql_query = sql_query & "INNER JOIN DCONTAINER DF WITH (NOLOCK) ON DF.DPHIEUID = A.DPHIEUID AND DF.IS_RUTHANG = 0 AND DF.TINH_TRANG = 1 AND A.DRUTHANGID IS NULL "
    sql_query = sql_query & "WHERE A.MA_KNQ = @MaKNQ AND A.TYPE = 1 AND A._XORN = 'X' AND A.MA_NGUON <> 'X4' AND A.TRANG_THAI = 'T' "
    sql_query = sql_query & "AND ((A.PB_PHIEU = 'CT' AND A.DPHIEUID_NEXT IS NULL) OR (A.PB_PHIEU = 'SU' AND A.DPHIEUID_PREV IS NOT NULL)) AND A.NGAY_PHIEU <= @TargetDate "
    sql_query = sql_query & "GROUP BY A.TYPE, A.DHOPDONGID, A.SO_HD, B.SO_PHIEU_N, B.MA_SP, B.DINH_DANH_HANG_HOA; " & vbCrLf

    sql_query = sql_query & "INSERT INTO #XUAT SELECT CAST('' AS NVARCHAR(100)) AS CKEYS, A.TYPE, A.DHOPDONGID, A.SO_HD, MAX(A.NGAY_PHIEU) AS NGAY_XUAT, B.SO_PHIEU_N, B.MA_SP, B.DINH_DANH_HANG_HOA, ROUND(SUM(B.SO_LUONG), 4) AS SO_LUONG, MAX(B.NGAY_VAO_RA) AS NGAY_GETOUT, 0 AS IS_TIEU_HUY "
    sql_query = sql_query & "FROM DPHIEU A WITH (NOLOCK) INNER JOIN DPHIEU_HANG B WITH (NOLOCK) ON (A.DPHIEUID = B.DPHIEUID AND ISNULL(B.IS_HUY, 0) = 0) "
    sql_query = sql_query & "WHERE A.MA_KNQ = @MaKNQ AND A.TYPE = 2 AND A._XORN = 'X' AND A.MA_NGUON <> 'X4' AND A.TRANG_THAI = 'T' "
    sql_query = sql_query & "AND ((A.PB_PHIEU = 'CT' AND A.DPHIEUID_NEXT IS NULL) OR (A.PB_PHIEU = 'SU' AND A.DPHIEUID_PREV IS NOT NULL)) AND A.NGAY_PHIEU <= @TargetDate "
    sql_query = sql_query & "GROUP BY A.TYPE, A.DHOPDONGID, A.SO_HD, B.SO_PHIEU_N, B.MA_SP, B.DINH_DANH_HANG_HOA; " & vbCrLf

    sql_query = sql_query & "INSERT INTO #XUAT SELECT CAST('' AS NVARCHAR(100)) AS CKEYS, 2 AS TYPE, A.DHOPDONGID, A.SO_HD, B.NGAY_PHIEU AS NGAY_XUAT, A.SO_PHIEU_N, A.MA_SP, A.DINH_DANH_HANG_HOA, ROUND(A.SO_LUONG, 4) AS SO_LUONG, NULL AS NGAY_GETOUT, 1 AS IS_TIEU_HUY "
    sql_query = sql_query & "FROM DTIEUHUY_CT A WITH (NOLOCK) INNER JOIN DTIEUHUY B WITH (NOLOCK) ON A.DTIEUHUYID = B.DTIEUHUYID WHERE B.MA_KNQ = @MaKNQ AND B.TRANG_THAI = 1 AND B.NGAY_PHIEU <= @TargetDate; " & vbCrLf

    ' STEP 5: 5´ú´©Í¸
    sql_query = sql_query & "IF OBJECT_ID('tempdb..#DVANBAN') IS NOT NULL DROP TABLE #DVANBAN; IF OBJECT_ID('tempdb..#NHAP_X') IS NOT NULL DROP TABLE #NHAP_X; " & vbCrLf
    sql_query = sql_query & "SELECT CAST(CAST(DHOPDONGID_GUI AS VARCHAR) + ';' + CAST(TYPE AS VARCHAR) + ';' + CAST(DINH_DANH_HANG_HOA AS VARCHAR) + ';' AS NVARCHAR(100)) AS CKEYS, B.DVANBANID, B.DHOPDONGID_GUI, F.SO_HD AS SO_HD_GUI, B.DHOPDONGID_NHAN, G.SO_HD AS SO_HD_NHAN, B.SOTK, A.TYPE, A.SO_PHIEU_N, A.STTHANG_N, A.MA_SP, A.DINH_DANH_HANG_HOA, A.SO_LUONG, A.TRI_GIA, F.NGAY_NHAP, CAST(NULL AS DATETIME) AS NGAY_VAO_RA "
    sql_query = sql_query & "INTO #DVANBAN FROM DVANBAN_HANG A, DVANBAN B, DHOPDONG F, DHOPDONG G WHERE B.MA_KNQ = @MaKNQ AND B.TRANG_THAI = '2' AND A.DVANBANID = B.DVANBANID AND B.DHOPDONGID_GUI = F.DHOPDONGID AND B.DHOPDONGID_NHAN = G.DHOPDONGID AND B.NGAY_CHUYEN_QUYEN <= @TargetDate; " & vbCrLf
    sql_query = sql_query & "SELECT CAST('' AS NVARCHAR(100)) AS CKEYS, A.TYPE, A.SO_PHIEU, A.MA_NGUON, A.DHOPDONGID, A.SO_HD, A.NGAY_HD, A.NGAY_HHHD, B.SO_TK, B.NGAY_DK, B.DINH_DANH_HANG_HOA, F.NGAY_NHAP, B.NGAY_VAO_RA "
    sql_query = sql_query & "INTO #NHAP_X FROM DPHIEU A INNER JOIN DPHIEU_HANG B ON A.DPHIEUID = B.DPHIEUID LEFT JOIN DHOPDONG F ON A.DHOPDONGID = F.DHOPDONGID WHERE A.MA_KNQ = @MaKNQ AND A._XORN = 'N' AND A.TRANG_THAI = 'T' AND A.NGAY_PHIEU <= @TargetDate "
    sql_query = sql_query & "GROUP BY A.TYPE, A.SO_PHIEU, A.MA_NGUON, A.DHOPDONGID, A.SO_HD, A.NGAY_HD, A.NGAY_HHHD, B.SO_TK, B.NGAY_DK, B.DINH_DANH_HANG_HOA, F.NGAY_NHAP, B.NGAY_VAO_RA; " & vbCrLf
    sql_query = sql_query & "DECLARE @c INT = 1, @d INT = 0; WHILE ((@c <= 5) AND @d = 0) BEGIN " & vbCrLf
    sql_query = sql_query & "UPDATE #DVANBAN SET NGAY_VAO_RA = B.NGAY_VAO_RA FROM #DVANBAN A, #NHAP_X B WHERE A.TYPE = B.TYPE AND A.DHOPDONGID_GUI = B.DHOPDONGID AND A.SO_PHIEU_N = B.SO_PHIEU AND A.DINH_DANH_HANG_HOA = B.DINH_DANH_HANG_HOA AND B.NGAY_VAO_RA IS NOT NULL; " & vbCrLf
    sql_query = sql_query & "UPDATE #NHAP SET NGAY_NHAP = B.NGAY_NHAP, NGAY_VAO_RA = B.NGAY_VAO_RA FROM #NHAP A, #DVANBAN B WHERE A.TYPE = B.TYPE AND A.MA_NGUON = 'N4' AND A.DHOPDONGID = B.DHOPDONGID_NHAN AND A.DINH_DANH_HANG_HOA = B.DINH_DANH_HANG_HOA AND B.NGAY_VAO_RA IS NOT NULL; " & vbCrLf
    sql_query = sql_query & "UPDATE #NHAP_X SET NGAY_NHAP = B.NGAY_NHAP, NGAY_VAO_RA = B.NGAY_VAO_RA FROM #NHAP_X A, #DVANBAN B WHERE A.TYPE = B.TYPE AND A.MA_NGUON = 'N4' AND A.DHOPDONGID = B.DHOPDONGID_NHAN AND A.DINH_DANH_HANG_HOA = B.DINH_DANH_HANG_HOA AND B.NGAY_VAO_RA IS NOT NULL; " & vbCrLf
    sql_query = sql_query & "IF NOT EXISTS(SELECT 1 FROM #DVANBAN WHERE NGAY_VAO_RA IS NULL) AND NOT EXISTS(SELECT 1 FROM #NHAP_X WHERE NGAY_VAO_RA IS NULL) AND NOT EXISTS(SELECT 1 FROM #NHAP WHERE NGAY_VAO_RA IS NULL) SELECT @d = 1; SET @c += 1; END; " & vbCrLf

    ' STEP 6: Ö½ÃæÐéÄâºÏÍ¬°þÀë
    sql_query = sql_query & "IF OBJECT_ID('tempdb..#NHAP2') IS NOT NULL DROP TABLE #NHAP2; IF OBJECT_ID('tempdb..#DVANBAN2') IS NOT NULL DROP TABLE #DVANBAN2; " & vbCrLf
    sql_query = sql_query & "SELECT ROW_NUMBER() OVER(PARTITION BY CKEYS ORDER BY NGAY_PHIEU, DPHIEUID, DPHIEU_HANGID) AS STT, *, SO_LUONG AS SO_LUONG2, TRI_GIA AS TRI_GIA2, 0*SO_LUONG AS SO_LUONG_SD, TRI_GIA AS TRI_GIA_SD, 0*TRI_GIA AS TRI_GIA_TON, 0*SO_LUONG AS LUONG_XUAT, 0*SO_LUONG AS LUONG_TON, CAST (NULL AS DATE) AS NGAY_XUAT, CAST (NULL AS INT) AS SO_NGAY_TON "
    sql_query = sql_query & "INTO #NHAP2 FROM #NHAP; " & vbCrLf
    sql_query = sql_query & "SELECT CKEYS, SUM(SO_LUONG) AS SO_LUONG, 0*SUM(SO_LUONG) AS SO_LUONG_SD, SUM(SO_LUONG) AS SO_LUONG_TON, SUM(TRI_GIA) AS TRI_GIA, 0*SUM(TRI_GIA) AS TRI_GIA_SD, SUM(TRI_GIA) AS TRI_GIA_TON INTO #DVANBAN2 FROM #DVANBAN A GROUP BY CKEYS; " & vbCrLf
    sql_query = sql_query & "DECLARE @x INT = 1, @y INT = ISNULL((SELECT MAX(STT) FROM #NHAP2), 1); WHILE (@x <= @y) BEGIN " & vbCrLf
    sql_query = sql_query & "UPDATE #NHAP2 SET SO_LUONG_SD = CASE WHEN B.SO_LUONG_TON > A.SO_LUONG THEN A.SO_LUONG ELSE B.SO_LUONG_TON END, TRI_GIA_SD = CASE WHEN B.TRI_GIA_TON > A.TRI_GIA THEN A.TRI_GIA ELSE B.TRI_GIA_TON END FROM #NHAP2 A, #DVANBAN2 B WHERE A.CKEYS = B.CKEYS AND B.SO_LUONG_TON > 0 AND STT = @x; " & vbCrLf
    sql_query = sql_query & "UPDATE #DVANBAN2 SET SO_LUONG_SD = B.SO_LUONG_SD, TRI_GIA_SD = B.TRI_GIA_SD FROM #DVANBAN2 A, (SELECT CKEYS, SUM(SO_LUONG_SD) SO_LUONG_SD, SUM(TRI_GIA_SD) TRI_GIA_SD FROM #NHAP2 WHERE SO_LUONG_SD > 0 GROUP BY CKEYS) B WHERE A.CKEYS = B.CKEYS; " & vbCrLf
    sql_query = sql_query & "UPDATE #DVANBAN2 SET SO_LUONG_TON = SO_LUONG - SO_LUONG_SD, TRI_GIA_TON = TRI_GIA - TRI_GIA_SD; SET @x += 1; END; " & vbCrLf
    sql_query = sql_query & "UPDATE #NHAP2 SET SO_LUONG = SO_LUONG2 - SO_LUONG_SD, TRI_GIA = TRI_GIA2 - TRI_GIA_SD; DELETE #NHAP2 WHERE SO_LUONG = 0; " & vbCrLf
    sql_query = sql_query & "UPDATE #NHAP_X SET CKEYS = CAST(TYPE AS VARCHAR) + ';' + CAST(SO_PHIEU AS VARCHAR) + ';' + CAST(DINH_DANH_HANG_HOA AS VARCHAR) + ';'; " & vbCrLf
    sql_query = sql_query & "UPDATE #XUAT SET CKEYS = CAST(TYPE AS VARCHAR) + ';' + CAST(SO_PHIEU_N AS VARCHAR) + ';' + CAST(DINH_DANH_HANG_HOA AS VARCHAR) + ';'; " & vbCrLf
    sql_query = sql_query & "UPDATE #XUAT SET DHOPDONGID = B.DHOPDONGID, SO_HD = B.SO_HD FROM #XUAT A, #NHAP_X B WHERE A.CKEYS = B.CKEYS; " & vbCrLf
    sql_query = sql_query & "IF OBJECT_ID('tempdb..#XUAT2') IS NOT NULL DROP TABLE #XUAT2; SELECT ROW_NUMBER() OVER(PARTITION BY DHOPDONGID, TYPE, DINH_DANH_HANG_HOA ORDER BY DHOPDONGID, TYPE, DINH_DANH_HANG_HOA, NGAY_XUAT) AS STT, CAST(CAST(DHOPDONGID AS VARCHAR) + ';' + CAST(TYPE AS VARCHAR) + ';' + CAST(DINH_DANH_HANG_HOA AS VARCHAR) + ';' AS NVARCHAR(100)) AS CKEYS, DHOPDONGID, TYPE, DINH_DANH_HANG_HOA, NGAY_XUAT, SUM(SO_LUONG) AS SO_LUONG, 0*SUM(SO_LUONG) AS LUONG_XUAT, SUM(SO_LUONG) AS LUONG_TON, 0*SUM(SO_LUONG) AS TONG_NHAP, 0*SUM(SO_LUONG) AS TONG_XUAT, SUM(SO_LUONG) AS TONG_TON, 0 AS IS_TIEU_HUY INTO #XUAT2 FROM #XUAT GROUP BY DHOPDONGID, TYPE, DINH_DANH_HANG_HOA, NGAY_XUAT; " & vbCrLf
    sql_query = sql_query & "UPDATE #XUAT2 SET TONG_NHAP = B.SO_LUONG, TONG_TON = B.SO_LUONG FROM #XUAT2 A, (SELECT CKEYS, SUM(SO_LUONG) AS SO_LUONG FROM #XUAT2 GROUP BY CKEYS) B WHERE A.CKEYS = B.CKEYS; " & vbCrLf
    sql_query = sql_query & "UPDATE #XUAT2 SET IS_TIEU_HUY = 1 FROM #XUAT2 A, #XUAT B WHERE A.TYPE = B.TYPE AND A.DHOPDONGID = B.DHOPDONGID AND A.DINH_DANH_HANG_HOA = B.DINH_DANH_HANG_HOA AND B.IS_TIEU_HUY = 1; " & vbCrLf
    sql_query = sql_query & "DROP TABLE #NHAP, #XUAT, #NHAP_X, #DVANBAN, #DVANBAN2; " & vbCrLf

    ' STEP 7: Ë«²ã WHILE ³åµÖ·ÖÌ¯¼ÆËã
    sql_query = sql_query & "UPDATE #NHAP2 SET LUONG_TON = SO_LUONG - LUONG_XUAT, SO_LUONG_SD = 0; DECLARE @stop INT = 0; WHILE (@stop = 0) BEGIN " & vbCrLf
    sql_query = sql_query & "IF OBJECT_ID('tempdb..#XUAT3') IS NOT NULL DROP TABLE #XUAT3; SELECT A.* INTO #XUAT3 FROM #XUAT2 A, (SELECT CKEYS, MIN(STT) AS STT FROM #XUAT2 WHERE LUONG_TON > 0 GROUP BY CKEYS) B WHERE A.CKEYS = B.CKEYS AND A.STT = B.STT; " & vbCrLf
    sql_query = sql_query & "DECLARE @stop2 INT = 0; WHILE (@stop2 = 0) BEGIN " & vbCrLf
    sql_query = sql_query & "IF OBJECT_ID('tempdb..#NHAP3') IS NOT NULL DROP TABLE #NHAP3; SELECT A.* INTO #NHAP3 FROM #NHAP2 A, (SELECT CKEYS, MIN(STT) AS STT FROM #NHAP2 WHERE LUONG_TON > 0 GROUP BY CKEYS) B WHERE A.CKEYS = B.CKEYS AND A.STT = B.STT; " & vbCrLf
    sql_query = sql_query & "IF NOT EXISTS(SELECT 1 FROM #XUAT3 A, #NHAP3 B WHERE A.CKEYS = B.CKEYS AND A.LUONG_TON > 0 AND B.LUONG_TON > 0) SET @stop2 = 1; " & vbCrLf
    sql_query = sql_query & "UPDATE #NHAP3 SET NGAY_XUAT = B.NGAY_XUAT, SO_LUONG_SD = CASE WHEN B.LUONG_TON > A.LUONG_TON THEN A.LUONG_TON ELSE B.LUONG_TON END FROM #NHAP3 A, #XUAT3 B WHERE A.CKEYS = B.CKEYS AND B.LUONG_TON > 0 AND A.LUONG_TON > 0; " & vbCrLf
    sql_query = sql_query & "UPDATE #NHAP3 SET LUONG_XUAT += SO_LUONG_SD; UPDATE #XUAT3 SET LUONG_XUAT += B.SO_LUONG_SD FROM #XUAT3 A, #NHAP3 B WHERE A.CKEYS = B.CKEYS; " & vbCrLf
    sql_query = sql_query & "UPDATE #XUAT3 SET LUONG_TON = SO_LUONG - LUONG_XUAT; UPDATE #NHAP3 SET LUONG_TON = SO_LUONG - LUONG_XUAT; " & vbCrLf
    sql_query = sql_query & "UPDATE #NHAP2 SET LUONG_XUAT = B.LUONG_XUAT, LUONG_TON = B.LUONG_TON, NGAY_XUAT = B.NGAY_XUAT FROM #NHAP2 A, #NHAP3 B WHERE A.CKEYS = B.CKEYS AND A.STT = B.STT; DROP TABLE #NHAP3; END; " & vbCrLf
    sql_query = sql_query & "UPDATE #XUAT2 SET LUONG_XUAT = B.LUONG_XUAT, LUONG_TON = B.LUONG_TON FROM #XUAT2 A, #XUAT3 B WHERE A.CKEYS = B.CKEYS AND A.STT = B.STT; " & vbCrLf
    sql_query = sql_query & "IF NOT EXISTS(SELECT 1 FROM #XUAT2 A, #NHAP2 B WHERE A.CKEYS = B.CKEYS AND A.LUONG_TON > 0 AND B.LUONG_TON > 0) SET @stop = 1; DROP TABLE #XUAT3; END; " & vbCrLf

    ' STEP 8 ×îÖÕÊý¾Ý´¦ÀíÓë¡¾23ÁÐ±íÍ·Ó³ÉäÊä³ö¡¿
    sql_query = sql_query & "UPDATE #NHAP2 SET TRI_GIA_TON = ISNULL(LUONG_TON * GIA_NHAP * TY_GIA_VND, 0); " & vbCrLf
    sql_query = sql_query & "UPDATE #NHAP2 SET GHI_CHU = CASE WHEN A.GHI_CHU = '' THEN '' ELSE A.GHI_CHU + ', ' END + N'Co hang tieu huy' FROM #NHAP2 A, #XUAT2 B WHERE A.CKEYS = B.CKEYS AND B.IS_TIEU_HUY = 1; " & vbCrLf
    sql_query = sql_query & "DELETE #NHAP2 WHERE ROUND(LUONG_TON, 4) <= 0; " & vbCrLf
    sql_query = sql_query & "UPDATE #NHAP2 SET SO_NGAY_TON = DATEDIFF(dd, NGAY_NHAP, @TargetDate) + 1; " & vbCrLf

    ' ÌáÈ¡ 23 ÁÐÔ­Ê¼Êý¾Ý
    sql_query = sql_query & "SELECT ROW_NUMBER() OVER(ORDER BY NGAY_PHIEU ASC, SO_PHIEU ASC, STTHANG ASC) AS STT, "
    sql_query = sql_query & "SO_TK AS [S? TK nh?p], NGAY_DK AS [Ng¨¤y TK], SO_PHIEU AS [S? PNK], NGAY_PHIEU AS [Ng¨¤y NK], SO_HD AS [S? h?p ??ng], NGAY_HD AS [Ng¨¤y h?p ??ng], "
    sql_query = sql_query & "MA_SP AS [M? h¨¤ng], TEN_SP AS [T¨ºn h¨¤ng], DINH_DANH_HANG_HOA AS [??nh danh h¨¤ng h¨®a], MA_NUOC AS [Xu?t x?], MA_HS AS [M? HS], "
    sql_query = sql_query & "SO_LUONG AS [L??ng nh?p], GIA_NHAP AS [??n gi¨¢], TEN_DVT AS [??n v? t¨ªnh], LUONG_XUAT AS [L??ng xu?t], LUONG_TON AS [SL T?n], TRI_GIA_TON AS [Tr? Gi¨¢ T?n], "
    sql_query = sql_query & "MA_NT AS [M? NT], NGAY_NHAP AS [Ng¨¤y nh?p], NGAY_XUAT AS [Ng¨¤y xu?t], SO_NGAY_TON AS [S? ng¨¤y t?n], GHI_CHU AS [Ghi ch¨²] "
    sql_query = sql_query & "FROM #NHAP2 ORDER BY NGAY_PHIEU ASC, SO_PHIEU ASC, STTHANG ASC; " & vbCrLf
    sql_query = sql_query & "DROP TABLE #NHAP2, #XUAT2;"
    ' =========================================================================
    
    ' Create a new connection
    Set connection = CreateObject("ADODB.Connection")
    With connection
        .ConnectionString = "Provider=SQLOLEDB;Data Source=" & server_name & _
                            ";Initial Catalog=" & database_name & _
                            ";Integrated Security=SSPI;"
        .CommandTimeout = 0
        .Open
    End With
    
    Set rs = CreateObject("ADODB.Recordset")
    rs.CursorLocation = 3 ' adUseClient (Õë¶ÔÑ­»·±ØÐë¿ªÆô)
    
    ' Debug.Print sql_query
    rs.Open sql_query, connection
    
    ' ´©Í¸ËùÓÐÁÙÊ±±íÓë WHILE ÓÎ±ê
    Do While rs.State = 0
        Set rs = rs.NextRecordset
        If rs Is Nothing Then Exit Do
    Loop
    
    ' °ó¶¨µ½¹¤×÷±í
    On Error Resume Next
    Set wsDetails = ThisWorkbook.Sheets("KNQ_OnHand_Details")
    Set wsSummary = ThisWorkbook.Sheets("KNQ_OnHand")
    If wsDetails Is Nothing Or wsSummary Is Nothing Then
        MsgBox "Î´ÕÒµ½ÃûÎª 'KNQ_OnHand_Details' »ò 'KNQ_OnHand' µÄ¹¤×÷±í£¬ÇëÈ·±£Á½ÕÅ±í¶¼ÒÑ´´½¨£¡", vbCritical
        GoTo Cleanup
    End If
    On Error GoTo 0
    
    ' ¡ï µÚ1²½£º´¦Àí Details ÏêÏ¸µ×¸å¹¤×÷±í ¡ï
    wsDetails.Cells.Clear
    
    ' ÑéÖ¤ÓÐÐ§ÐÔ
    If rs Is Nothing Or rs.State = 0 Then
        MsgBox "²éÑ¯ÖÐ¶Ï£¡Î´ÄÜ»ñÈ¡µ½ÓÐÐ§½á´æÕË²á¡£", vbCritical
        GoTo Cleanup
    End If
    
    ' ½«Ô½ÄÏÎÄ±íÍ·Ð´Èë Details ¹¤×÷±í
    fieldCount = rs.Fields.Count
    For i = 0 To fieldCount - 1
        wsDetails.Cells(1, i + 1).Value = rs.Fields(i).Name
    Next i
    
    If Not rs.EOF Then
        arr = rs.GetRows
        rowCount = UBound(arr, 2) + 1
        colCount = UBound(arr, 1) + 1
        
        ' ¾ØÕó×ªÖÃ£ºÓÃÓÚ¿ìËÙÐ´ÈëÊý×é
        ReDim arrT(1 To rowCount, 1 To colCount)
        For i = 1 To rowCount
            For j = 1 To colCount
                arrT(i, j) = arr(j - 1, i - 1)
            Next j
        Next i
        
        ' Ç¿¹Ìµ¥Ôª¸ñÊý¾Ý¸ñÊ½£¬·ÀÖ¹Ã÷Ï¸±íº£¹Ø±àºÅ¶ª0
        With wsDetails
            .Columns("B").NumberFormat = "@"           ' S? TK nh?p
            .Columns("C").NumberFormat = "yyyy-mm-dd"  ' Ng¨¤y TK
            .Columns("D").NumberFormat = "@"           ' S? PNK
            .Columns("E").NumberFormat = "yyyy-mm-dd"  ' Ng¨¤y NK
            .Columns("F").NumberFormat = "@"           ' S? h?p ??ng
            .Columns("G").NumberFormat = "yyyy-mm-dd"  ' Ng¨¤y h?p ??ng
            .Columns("H").NumberFormat = "@"           ' M? h¨¤ng
            .Columns("J").NumberFormat = "@"           ' ??nh danh h¨¤ng h¨®a
            .Columns("L").NumberFormat = "@"           ' M? HS
            .Columns("M").NumberFormat = "#,##0.00"    ' L??ng nh?p
            .Columns("N").NumberFormat = "#,##0.00"    ' ??n gi¨¢
            .Columns("P").NumberFormat = "#,##0.00"    ' L??ng xu?t
            .Columns("Q").NumberFormat = "#,##0.00"    ' SL T?n
            .Columns("R").NumberFormat = "#,##0.00"    ' Tr? Gi¨¢ T?n
            .Columns("T").NumberFormat = "yyyy-mm-dd"  ' Ng¨¤y nh?p
            .Columns("U").NumberFormat = "yyyy-mm-dd"  ' Ng¨¤y xu?t
            
            .Range("A2").Resize(rowCount, colCount).Value = arrT
            .Columns.AutoFit
            .Range("B1:C1").Interior.ColorIndex = 10
            .Range("B1:C1").Font.ColorIndex = 2
            .Range("M1:R1").Interior.ColorIndex = 46
            .Range("M1:R1").Font.ColorIndex = 2
        End With
        
        ' =========================================================================
        ' ¡ï µÚ2²½£ºÔÚÄÚ´æÖÐÊ¹ÓÃ Scripting.Dictionary Ö´ÐÐ»ùÓÚ Item µÄ¶þ´Î¾ÛºÏ ¡ï
        ' =========================================================================
        Dim dict As Object
        Set dict = CreateObject("Scripting.Dictionary")
        dict.CompareMode = 1 ' TextCompare (²»Çø·Ö´óÐ¡Ð´Æ¥Åä)
        
        Dim itemCode As String
        Dim impQty As Double, expQty As Double, onhQty As Double
        Dim tempArr As Variant
        
        For i = 1 To rowCount
            ' ÔÚÉú³ÉµÄ arrT ÖÐ£¬µÚ8ÁÐÊÇ MA_SP(M? h¨¤ng), µÚ13ÁÐÊÇ LUONG_NHAP(L??ng nh?p)
            ' µÚ16ÁÐÊÇ LUONG_XUAT(L??ng xu?t), µÚ17ÁÐÊÇ LUONG_TON(SL T?n)
            itemCode = CStr(arrT(i, 8))
            
            ' °²È«×ª»»Êý×Ö£¬·ÀÖ¹ Null ±¨´í
            impQty = 0: expQty = 0: onhQty = 0
            If Not IsEmpty(arrT(i, 13)) And Not IsNull(arrT(i, 13)) Then impQty = CDbl(arrT(i, 13))
            If Not IsEmpty(arrT(i, 16)) And Not IsNull(arrT(i, 16)) Then expQty = CDbl(arrT(i, 16))
            If Not IsEmpty(arrT(i, 17)) And Not IsNull(arrT(i, 17)) Then onhQty = CDbl(arrT(i, 17))
            
            If dict.exists(itemCode) Then
                ' Èç¹û¸ÃÁÏºÅÒÑ´æÔÚ£¬ÀÛ¼ÓÊýÁ¿
                tempArr = dict(itemCode)
                tempArr(0) = tempArr(0) + impQty
                tempArr(1) = tempArr(1) + expQty
                tempArr(2) = tempArr(2) + onhQty
                dict(itemCode) = tempArr
            Else
                ' Èç¹û¸ÃÁÏºÅµÚÒ»´Î³öÏÖ£¬¼ÓÈë×Öµä
                dict.Add itemCode, Array(impQty, expQty, onhQty)
            End If
        Next i
        
        ' ÌáÈ¡×ÖµäÄÚÈÝÖÁ»ã×ÜÊý×é
        Dim aggArr() As Variant
        ReDim aggArr(1 To dict.Count, 1 To 4)
        Dim k As Long
        k = 1
        
        Dim key As Variant
        For Each key In dict.keys
            aggArr(k, 1) = key
            aggArr(k, 2) = dict(key)(0) ' ImportedQty
            aggArr(k, 3) = dict(key)(1) ' ExportedQty
            aggArr(k, 4) = dict(key)(2) ' KNQ_ONHAND
            k = k + 1
        Next key
        
        ' =========================================================================
        ' ¡ï µÚ3²½£º½«¾ÛºÏºóµÄ¾«¼ò±¨±íÐ´Èë KNQ_OnHand ¹¤×÷±í ¡ï
        ' =========================================================================
        wsSummary.Cells.Clear
        ' Ð´Èë¾ÛºÏ±íÍ·
        wsSummary.Range("A1:D1").Value = Array("Item", "ImportedQty", "ExportedQty", "KNQ_ONHAND")
        
        With wsSummary
            .Columns("A").NumberFormat = "@"           ' Item ±£³ÖÎÄ±¾
            .Columns("B").NumberFormat = "#,##0.00"    ' Qty ÁÐ¸ñÊ½»¯
            .Columns("C").NumberFormat = "#,##0.00"
            .Columns("D").NumberFormat = "#,##0.00"
            
            ' ÇãÐº¾ÛºÏ½á¹ûÊý¾Ý
            .Range("A2").Resize(dict.Count, 4).Value = aggArr
            
            .Columns.AutoFit
            ' ÃÀ»¯±íÍ·
            .Range("A1:D1").Interior.ColorIndex = 5
            .Range("A1:D1").Font.ColorIndex = 2
            .Range("A1:D1").Font.Bold = True
        End With
        
'        MsgBox "³É¹¦Íê³É£¡" & vbCrLf & _
'               "ÒÑµ¼³ö " & rowCount & " ÐÐÃ÷Ï¸ÖÁ KNQ_OnHand_Details¡£" & vbCrLf & _
'               "ÒÑ¾ÛºÏ " & dict.Count & " Ïî Item Êý¾ÝÖÁ KNQ_OnHand¡£", vbInformation
    Else
'        MsgBox "ÅÌµãÍê³É£¬½ØÖÁ " & targetDateStr & " ¿âÄÚÃ»ÓÐ½á´æ×Ê²ú¡£", vbExclamation
    End If

Cleanup:
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

