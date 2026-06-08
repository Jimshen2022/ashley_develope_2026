-- This is partial query for Ashton Loading Sheet Automation - created by JimShen on 2024-06-17
-- ==============================================================================================
-- 1. 查询条件配置区 
-- ==============================================================================================
DECLARE @in_vchWhID             NVARCHAR(10)   = '335';             
DECLARE @in_vchLoadNumber       NVARCHAR(30)   = '%';   
DECLARE @in_dtThruDate          DATETIME       = '2038-12-31';    
DECLARE @in_vchLoadType         NVARCHAR(1)    = 'B';             
DECLARE @in_vchTripTypeC        NVARCHAR(5)    = 'C';
DECLARE @in_vchTripTypeF        NVARCHAR(5)    = 'F';
DECLARE @in_vchTripTypeP        NVARCHAR(5)    = 'P';
DECLARE @in_vchTripTypeR        NVARCHAR(5)    = 'R';
DECLARE @in_vchTripTypeT        NVARCHAR(5)    = 'T';
DECLARE @in_vchTripTypeU        NVARCHAR(5)    = 'U';
DECLARE @in_vchTripTypeY        NVARCHAR(5)    = 'Y';             
DECLARE @in_vchStatNew          NVARCHAR(5)    = 'N';             
DECLARE @in_vchStatComplete     NVARCHAR(5)    = 'C';             
DECLARE @in_vchStatHold         NVARCHAR(5)    = 'H';             
DECLARE @in_vchStatRelease      NVARCHAR(5)    = 'R';             
DECLARE @in_vchStatReverted     NVARCHAR(5)    = '99999';         
DECLARE @in_vchStatShipped      NVARCHAR(5)    = '99999';         
DECLARE @in_vchStatWait         NVARCHAR(5)    = 'W';             
DECLARE @in_vchStatCSModify     NVARCHAR(5)    = 'M';             
DECLARE @in_TripTypeHomestore   NVARCHAR(10)   = 'ALL';           
DECLARE @in_cg_percentage       FLOAT          = 0;               
DECLARE @in_uph_percentage      FLOAT          = 0;               
DECLARE @in_CG                  NVARCHAR(5)    = 'N';             
DECLARE @in_UPH                 NVARCHAR(5)    = 'N';             
DECLARE @in_user_id             NVARCHAR(MAX)  = 'SYSTEM_USER';   
DECLARE @out_vchDBMessage       NVARCHAR(80)   = '';              

-- ==============================================================================================
-- 2. 核心数据处理逻辑 
-- ==============================================================================================
SET NOCOUNT ON;
SET QUOTED_IDENTIFIER ON;

DECLARE @v_ntbflag              INT
       ,@v_bol_active           INT = 0
       ,@in_vchLoadType1        NVARCHAR(1)
       ,@v_tb_overflow_flag     NVARCHAR(1) = '0'
       ,@v_bil_overflow_flag    NVARCHAR(1) = '0'
       ,@v_tms_tfr_load         NVARCHAR(1) = '0';

SELECT @v_ntbflag = ISNULL(next_value,0) FROM dbo.t_control (NOLOCK) WHERE control_type = 'TB_REG_BILL_MODEL';
SELECT @v_bol_active = 1 FROM dbo.t_control(NOLOCK) WHERE control_type = 'BOL_ACTIVE' AND c1 = 'Y';
SELECT @v_tb_overflow_flag = next_value FROM dbo.t_control (NOLOCK) WHERE control_type = 'TB_RELS_OFLW_BLD';
SELECT @v_bil_overflow_flag = next_value FROM dbo.t_control (NOLOCK) WHERE control_type = 'BIL_RELS_OFLW_BLD';
SELECT @v_tms_tfr_load = next_value FROM dbo.t_control (NOLOCK) WHERE control_type = 'TMS_TFR_LOAD';

IF @in_vchLoadType ='B'
BEGIN
    SET @in_vchLoadType1 ='X';
END

IF @v_tms_tfr_load <> '1' AND (@in_vchLoadType = 'T' OR @in_vchLoadType = '%')
    SELECT @in_vchLoadType = '1';

IF ISNULL(@in_vchWhID, '') = '' BEGIN SET @out_vchDBMessage = 'Missing WH ID'; GOTO ExitLabel; END
IF ISNULL(@in_vchLoadNumber, '') = '' BEGIN SET @out_vchDBMessage = 'Missing Trip Number'; GOTO ExitLabel; END
IF ISNULL(@in_dtThruDate, '') = '' BEGIN SET @out_vchDBMessage = 'Missing Date'; GOTO ExitLabel; END
IF ISNULL(@in_vchLoadType, '') = '' BEGIN SET @out_vchDBMessage = 'Missing Load Type'; GOTO ExitLabel; END

IF OBJECT_ID('tempdb..#temp_csr') IS NOT NULL DROP TABLE #temp_csr;
IF OBJECT_ID('tempdb..#temp_ldm') IS NOT NULL DROP TABLE #temp_ldm;
IF OBJECT_ID('tempdb..#temp_comments') IS NOT NULL DROP TABLE #temp_comments;
IF OBJECT_ID('tempdb..#temp_trip_report') IS NOT NULL DROP TABLE #temp_trip_report;
IF OBJECT_ID('tempdb..#temp_cust_large_orders') IS NOT NULL DROP TABLE #temp_cust_large_orders;
IF OBJECT_ID('tempdb..#temp_odb') IS NOT NULL DROP TABLE #temp_odb;
IF OBJECT_ID('tempdb..#temp_pkd') IS NOT NULL DROP TABLE #temp_pkd;
IF OBJECT_ID('tempdb..#t_order') IS NOT NULL DROP TABLE #t_order;
IF OBJECT_ID('tempdb..#t_order_c_number') IS NOT NULL DROP TABLE #t_order_c_number;
IF OBJECT_ID('tempdb..#t_afo_load_view') IS NOT NULL DROP TABLE #t_afo_load_view;
IF OBJECT_ID('tempdb..#t_load_allocable_pct') IS NOT NULL DROP TABLE #t_load_allocable_pct;

CREATE TABLE #t_load_allocable_pct (
    wh_id VARCHAR(10),
    load_id VARCHAR(30),
    allocable_pct INT
);

-- =================================================================================================
-- 【降级处理 1】注释掉计算存储过程，避免 EXECUTE 报错 (这会导致 allocable_pct 为 NULL，但不影响主体数据)
-- =================================================================================================
-- EXECUTE dbo.usp_calculate_allocablity_percent;

CREATE TABLE #temp_csr (order_number NVARCHAR(30), customer_service_rep NVARCHAR(35), load_id NVARCHAR(30));
CREATE TABLE #temp_comments (order_number NVARCHAR(30), comment NVARCHAR(70));
CREATE TABLE #temp_cust_large_orders (order_number NVARCHAR(30), customer_name NVARCHAR(100), load_id NVARCHAR(30));
CREATE TABLE #temp_odb (wh_id NVARCHAR(10), load_id NVARCHAR(30), total_pieces BIGINT, uph_need BIGINT, total_cube BIGINT);
CREATE TABLE #temp_pkd (wh_id NVARCHAR(10), load_id NVARCHAR(30), pkd_planned_quantity BIGINT, pdl_planned_quantity BIGINT, pdl_picked_quantity BIGINT, current_order NVARCHAR(30));

CREATE TABLE #temp_ldm (
    wh_id NVARCHAR(10), load_id NVARCHAR(30), stage_loc VARCHAR(50), door_loc VARCHAR(50), carrier_id INT, trailer_type_id INT,
    status VARCHAR(1), work_type CHAR(2), trailer_number VARCHAR(100), bill_number VARCHAR(100), live_load NVARCHAR(20), reference_number VARCHAR(100),
    shipment_status VARCHAR(30), equipment_id VARCHAR(50), load_date DATETIME, dispatch_date DATETIME, dispatch_time DATETIME,
    trip_type_id CHAR(1), load_type CHAR(1), trip_create_date DATETIME, trip_create_time DATETIME, cubes_of_fill INT, number_of_drops VARCHAR(2),
    load_id_8 NVARCHAR(30), load_id_ss_to_hyphen NVARCHAR(30), ya_work_52 NVARCHAR(30), overflow_flag NVARCHAR(30), transfer_wh_id VARCHAR(50)
);
CREATE UNIQUE INDEX ixtempldm ON #temp_ldm (wh_id, load_id);

CREATE TABLE #t_order (wh_id VARCHAR(10), order_number VARCHAR(30), type_id INT, customer_id CHAR(15), customer_name NVARCHAR(100), load_id VARCHAR(30), load_seq INT, bol_number CHAR(10), carrier NVARCHAR(60), order_date DATETIME, arrive_date DATETIME, status VARCHAR(20));
CREATE UNIQUE INDEX ixtemporder ON #t_order (wh_id, order_number);

CREATE TABLE #t_order_c_number (wh_id VARCHAR(10), c_number VARCHAR(30), customer_id CHAR(30), ship_to_code CHAR(15), ship_to_name NVARCHAR(60), bill_to_name NVARCHAR(60), ship_to_city NVARCHAR(30), ship_to_state NVARCHAR(6), customer_number VARCHAR(30), customer_service_rep NVARCHAR(50), order_number VARCHAR(30), internal_vendor NVARCHAR(60), customer_special_order_flag NVARCHAR(2), order_date DATETIME, shipping_instructions NVARCHAR(60));
CREATE UNIQUE INDEX ixtemporc ON #t_order_c_number (wh_id, order_number, c_number);
CREATE NONCLUSTERED INDEX nixtemporc ON #t_order_c_number (wh_id, order_number) INCLUDE ([customer_service_rep]);

CREATE TABLE #temp_trip_report (
    highlight NVARCHAR(MAX), wh_id NVARCHAR(10), customer_name NVARCHAR(100), load_id NVARCHAR(30), status NVARCHAR(100), dispatch_date DATETIME,
    carrier_name NVARCHAR(100), available_trailers NVARCHAR(10), trailer_number NVARCHAR(50), bill_number NVARCHAR(100), live_load NVARCHAR(20),
    equipment_name NVARCHAR(50), door_loc NVARCHAR(50), stage_loc NVARCHAR(50), total_pieces INT, uph_need INT, total_cube INT, number_of_drops NVARCHAR(3),
    special_ship_inst NVARCHAR(1), blank NVARCHAR(1), loadable_pct INT, replan_to_primary VARCHAR(50), allocable_percentage INT, loadable_percentage INT,
    first_drop_state NVARCHAR(30), customer_service_rep NVARCHAR(MAX), comment NVARCHAR(100), current_order NVARCHAR(30), pct_loaded INT, trip_type_id NVARCHAR(30),
    load_date DATETIME, reference_number NVARCHAR(100), description NVARCHAR(30), equipment_id NVARCHAR(50), equipment_scheduled NVARCHAR(10), needlist NVARCHAR(10),
    fill NVARCHAR(10), load_type NVARCHAR(5), order_number NVARCHAR(30), suggested_bldg NVARCHAR(10), BOL NVARCHAR(50), wildcard NVARCHAR(1), C NVARCHAR(1),
    H NVARCHAR(1), F NVARCHAR(1), R NVARCHAR(1), P NVARCHAR(1), nine NVARCHAR(5), N NVARCHAR(1), T NVARCHAR(1), W NVARCHAR(1), M NVARCHAR(1), Y NVARCHAR(1),
    S NVARCHAR(1), thru_date DATETIME, trip_create DATETIME, MESSAGE NVARCHAR(MAX), comment_2 NVARCHAR(100), batch_id NVARCHAR(50), cg_percent FLOAT, uph_percent FLOAT
);

CREATE TABLE #t_afo_load_view (wh_id varchar(10) NOT NULL, load_id varchar(30) NOT NULL, priority varchar(10) NULL, loadable_pct int NULL, suggested_bldg varchar(10) NULL, current_order varchar(30) NULL, nbr_of_orders int NULL, pct_loaded int NULL, total_cube int NULL, cg_percentage float NULL, uph_percentage float NULL);

DECLARE @csr_string_table TABLE (cst_load_id NVARCHAR(30), cst_csr_string NVARCHAR(MAX), cst_csr_count INT);

INSERT INTO #temp_ldm
SELECT DISTINCT ldm.wh_id,ldm.load_id,ldm.stage_loc,ldm.door_loc,ldm.carrier_id,ldm.trailer_type_id,ldm.status,ldm.work_type
,ldm.trailer_number,ldm.bill_number,ldm.live_load,ldm.reference_number,ldm.shipment_status
,ldm.equipment_id,ldm.load_date,ldm.dispatch_date,ldm.dispatch_time,ldm.trip_type_id,ldm.load_type,ldm.trip_create_date,ldm.trip_create_time
,ldm.cubes_of_fill,ldm.number_of_drops ,CAST((LEFT(ldm.load_id, 8) + '%') AS VARCHAR(8)) AS load_id_8
,CAST(SUBSTRING(ldm.load_id,1,IIF(CHARINDEX('-',ldm.load_id) <= 0, 10, CHARINDEX('-',ldm.load_id)) -1)+'%' AS VARCHAR(30)) load_id_ss_to_hyphen
,w.load_id AS ya_work_52 ,ol.load_id AS overflow_flag, ISNULL(twh.name, ldm.transfer_wh_id) AS transfer_wh_id
FROM dbo.t_load_master ldm (NOLOCK)
LEFT JOIN (
    SELECT ldm.wh_id, ldm.load_id
    FROM dbo.t_load_master ldm (NOLOCK)
    INNER JOIN dbo.t_order orm (NOLOCK) ON ldm.load_id = orm.load_id AND ldm.wh_id = orm.wh_id
    INNER JOIN dbo.t_order_c_number ocn (NOLOCK) ON orm.order_number = ocn.order_number AND orm.wh_id = ocn.wh_id
    INNER JOIN dbo.t_customer c (NOLOCK) ON ocn.customer_id = c.customer_id AND ocn.wh_id = c.wh_id
    WHERE ldm.trip_type_id = 'Y' AND c.drop_ship_flag = 'Y'
    GROUP BY ldm.wh_id, ldm.load_id
) cdrop ON ldm.wh_id = cdrop.wh_id AND ldm.load_id = cdrop.load_id
LEFT JOIN (SELECT load_id FROM dbo.t_ya_work_q (NOLOCK) WHERE type = '52' AND status = 'UNASSIGNED' GROUP BY load_id) w ON w.load_id = ldm.load_id
LEFT JOIN dbo.t_overflow_allocated_loads ol (NOLOCK) ON ol.load_id = ldm.load_id AND ol.wh_id = ldm.wh_id AND ((ldm.load_type = 'B' AND @v_bil_overflow_flag = '1') OR (ldm.load_type='X' AND @v_tb_overflow_flag = '1')) AND ldm.status IN('R','W')
LEFT JOIN dbo.t_transfer_whse (NOLOCK) twh ON twh.wh_id = ldm.transfer_wh_id AND ldm.load_type = 'T'
WHERE 1 = CASE WHEN @in_vchTripTypeY = '2071' AND cdrop.load_id IS NULL AND ldm.trip_type_id = 'Y' THEN 0 ELSE 1 END
    AND ldm.wh_id LIKE @in_vchWhID
    AND ldm.load_id LIKE @in_vchLoadNumber
    AND (ldm.dispatch_date <= @in_dtThruDate OR (ldm.dispatch_date IS NULL AND ldm.dispatch_time IS NULL))
    AND (
        (@in_vchLoadType <> '%' AND (ldm.load_type LIKE @in_vchLoadType OR ldm.load_type LIKE @in_vchLoadType1))
        OR (@in_vchLoadType <> '%' AND (ldm.load_type IN (SUBSTRING(@in_vchLoadType, 1, 1),SUBSTRING(@in_vchLoadType, 3, 1))))
        OR (@in_vchLoadType = '%' AND ldm.load_type IN ('B','X','S','T'))
    )
    AND ((ldm.trip_type_id IN (@in_vchTripTypeC,@in_vchTripTypeF,@in_vchTripTypeP,@in_vchTripTypeR,@in_vchTripTypeT,@in_vchTripTypeU,CASE WHEN @in_vchTripTypeY = '2071' THEN 'Y' ELSE @in_vchTripTypeY END)) OR (ldm.load_type= 'T'))
    AND ldm.status IN (@in_vchStatNew,@in_vchStatComplete,@in_vchStatHold,@in_vchStatRelease,@in_vchStatReverted,@in_vchStatShipped,@in_vchStatWait,@in_vchStatCSModify)
    AND ((@in_TripTypeHomestore = 'Y' AND ISNULL(ldm.freight_terms, '') = 'HOMESTORE') OR (@in_TripTypeHomestore = 'N' AND ISNULL(ldm.freight_terms, '') <> 'HOMESTORE') OR (@in_TripTypeHomestore = 'ALL'));

DELETE ldm FROM #temp_ldm ldm
LEFT JOIN dbo.t_load_dispatch_tms tms (NOLOCK) ON tms.load_id = ldm.load_id AND tms.wh_id = ldm.wh_id
WHERE ldm.load_type = 'T' AND tms.load_id IS NULL or (LEN(ldm.load_id)<=3 and ldm.load_type in('T','M','S'));

INSERT INTO #t_order
SELECT orm.wh_id,orm.order_number,orm.type_id,orm.customer_id,orm.customer_name,orm.load_id,orm.load_seq,orm.bol_number,orm.carrier,orm.order_date,orm.arrive_date,orm.status
FROM #temp_ldm ldm
INNER JOIN dbo.t_order orm (NOLOCK) ON ldm.load_id = orm.load_id AND ldm.wh_id = orm.wh_id;

INSERT INTO #t_order_c_number
SELECT orc.wh_id,orc.c_number,orc.customer_id,orc.ship_to_code,orc.ship_to_name,orc.bill_to_name,orc.ship_to_city,orc.ship_to_state,orc.customer_number,orc.customer_service_rep,orc.order_number,orc.internal_vendor,orc.customer_special_order_flag,orc.order_date,orc.shipping_instructions
FROM #temp_ldm ldm
INNER JOIN #t_order orm ON orm.load_id = ldm.load_id AND ldm.wh_id = orm.wh_id
INNER JOIN dbo.t_order_c_number orc (NOLOCK) ON orm.order_number = orc.order_number AND orm.wh_id = orc.wh_id;

INSERT INTO #temp_csr (order_number, customer_service_rep, load_id)
SELECT ocn.order_number, ocn.customer_service_rep, ldm.load_id
FROM #t_order_c_number ocn (NOLOCK)
JOIN #temp_ldm ldm ON ocn.order_number = ldm.load_id + ':' + ldm.number_of_drops AND ldm.wh_id = ocn.wh_id
GROUP BY ocn.order_number, ocn.customer_service_rep, ldm.load_id;

IF EXISTS (SELECT TOP 1 1 FROM #temp_csr)
BEGIN
    INSERT INTO @csr_string_table
    SELECT load_id, cst_csr_string = STUFF((SELECT ',' + customer_service_rep FROM #temp_csr x WHERE x.load_id = y.load_id AND x.order_number = y.order_number FOR XML PATH('')), 1, 1, ''), COUNT(DISTINCT customer_service_rep)
    FROM #temp_csr y
    GROUP BY load_id, order_number;
END

INSERT INTO #temp_comments (order_number, comment)
SELECT com.order_number, com.comment
FROM #temp_ldm ldm
JOIN dbo.t_order_c_number_comment com (NOLOCK) ON com.order_number = ldm.load_id + ':' + ldm.number_of_drops AND com.wh_id = ldm.wh_id AND CHARINDEX('DOCK', UPPER(com.comment)) > 0
GROUP BY com.order_number, com.comment;

INSERT INTO #temp_cust_large_orders (order_number, customer_name, load_id)
SELECT DISTINCT ocn.order_number, COALESCE(ocn.bill_to_name, ocn.ship_to_name) + ' - ' + ISNULL(ocn.ship_to_city,'') AS customer_name, ldm.load_id
FROM #temp_ldm ldm
INNER JOIN #t_order orm ON orm.load_id = ldm.load_id AND ldm.wh_id = orm.wh_id
INNER JOIN #t_order_c_number ocn ON ocn.order_number = orm.order_number AND ocn.wh_id = orm.wh_id
WHERE ldm.load_type='X';

INSERT INTO #temp_odb (wh_id, load_id, total_pieces, uph_need, total_cube)
SELECT ldm.wh_id, ldm.load_id, SUM(odb.qty) AS total_pieces, ISNULL(SUM(CASE WHEN itm.pick_put_id = 'UPH' THEN odb.qty ELSE 0 END), 0) AS uph_need, ISNULL(CAST(ROUND(SUM(odb.unit_volume), 0) AS INT), 0) AS total_cube
FROM #temp_ldm ldm
JOIN #t_order orm ON orm.load_id = ldm.load_id AND orm.wh_id = ldm.wh_id
JOIN dbo.t_order_detail_breakdown odb (NOLOCK) ON odb.order_number = orm.order_number AND odb.wh_id = orm.wh_id
JOIN dbo.t_item_master itm (NOLOCK) ON odb.item_number = itm.item_number AND odb.wh_id = itm.wh_id
WHERE (odb.ship_status NOT IN ('BACKORDER','B') OR odb.ship_status IS NULL) AND odb.wh_id LIKE @in_vchWhID
GROUP BY ldm.wh_id, ldm.load_id;

INSERT INTO #temp_pkd (wh_id, load_id, pkd_planned_quantity, pdl_planned_quantity, pdl_picked_quantity, current_order)
SELECT pkd.wh_id, pkd.load_id, SUM(CASE WHEN pkd.status = 'HOLD' THEN planned_quantity ELSE 0 END), SUM(CASE WHEN pick_area = 'UPHOLSTERY' THEN planned_quantity ELSE 0 END), SUM(CASE WHEN pick_area = 'UPHOLSTERY' THEN picked_quantity ELSE 0 END), RIGHT(MAX(CASE WHEN loaded_quantity > 0 THEN order_number END), 2)
FROM dbo.t_pick_detail (NOLOCK) pkd
JOIN #temp_ldm ldm ON ldm.wh_id = pkd.wh_id AND ldm.load_id = pkd.load_id
GROUP BY pkd.wh_id, pkd.load_id;

IF @in_vchTripTypeY = '2071'
BEGIN
    DELETE tmp FROM #temp_ldm tmp
    WHERE tmp.trip_type_id = 'Y' AND NOT EXISTS (
        SELECT TOP 1 1 FROM #t_order orm
        INNER JOIN #t_order_c_number ocn ON orm.order_number = ocn.order_number AND orm.wh_id = ocn.wh_id
        INNER JOIN dbo.t_customer c (NOLOCK) ON ocn.customer_id = c.customer_id AND ocn.wh_id = c.wh_id
        WHERE tmp.trip_type_id = 'Y' AND c.drop_ship_flag = 'Y'
    );
END

IF (@in_CG = 'N' AND @in_UPH ='N')
BEGIN
    SET @in_cg_percentage = 0;
    SET @in_uph_percentage = 0;
    GOTO AFOINSERT;
END

IF (@in_CG = 'Y' AND @in_UPH ='Y') GOTO AFOINSERT;

IF (@in_CG = 'Y' AND @in_UPH ='N')
BEGIN
    -- 【降级处理 5】屏蔽跨库视图，避免 916 错误 (这里原为: INSERT INTO #t_afo_load_view SELECT ... FROM t_afo_load_view)
    GOTO REMOVEBATCH;
END

IF (@in_CG = 'N' AND @in_UPH ='Y')
BEGIN
    -- 【降级处理 5】屏蔽跨库视图，避免 916 错误
    GOTO REMOVEBATCH;
END

AFOINSERT:
-- 【降级处理 5】屏蔽跨库视图，避免 916 错误
-- INSERT INTO #t_afo_load_view
-- SELECT wh_id, load_id, priority, loadable_pct, suggested_bldg, current_order, nbr_of_orders, pct_loaded, total_cube, cg_percentage, uph_percentage 
-- FROM t_afo_load_view(NOLOCK) afo
-- WHERE ISNULL(afo.cg_percentage ,0) >= @in_cg_percentage OR ISNULL(afo.uph_percentage ,0) >= @in_uph_percentage;

REMOVEBATCH:
-- =================================================================================================
-- 【降级处理 2】注释掉 DELETE 语句，规避权限报错。跳过此清理逻辑不影响主查询结果。
-- =================================================================================================
-- DELETE FROM t_load_master_batch WHERE status = 'N' AND ww_username = @in_user_id;

INSERT INTO #temp_trip_report
SELECT 
    CASE 
        WHEN ldm.load_type ='X' THEN '{{BGCOLOR=#98B0D8}}'
        WHEN EXISTS(SELECT TOP 1 1 FROM #t_order tor1 (NOLOCK) INNER JOIN (SELECT internal_vendor,order_number,wh_id FROM #t_order_c_number GROUP BY internal_vendor,order_number,wh_id) ocn1 ON tor1.order_number=ocn1.order_number AND tor1.wh_id=ocn1.wh_id WHERE ISNULL(ocn1.internal_vendor,'')='PSDQN' AND ldm.load_type='B' AND tor1.load_id LIKE ldm.load_id_ss_to_hyphen) THEN '{{BGCOLOR=#C8F295}}'
        
        -- =================================================================================================
        -- 【降级处理 4】屏蔽跨库函数 udf_fill_trips 的调用，避免 916 错误
        -- =================================================================================================
        -- WHEN (SELECT COUNT(1) FROM dbo.udf_fill_trips(@in_vchWhID) WHERE load_id LIKE ldm.load_id_ss_to_hyphen) = 1 THEN '{{BGCOLOR=RED}}'
        
        WHEN (SELECT COUNT(1) FROM dbo.t_load_master tlm (NOLOCK) WHERE load_type = @in_vchLoadType AND load_id LIKE ldm.load_id_ss_to_hyphen) > 1 THEN '{{BGCOLOR=ORANGE}}'
        ELSE (SELECT TOP 1 '{{BGCOLOR=' + COALESCE(display_color, 'WHITE') + '}}' FROM #t_order tor JOIN #t_order_c_number tocn ON tocn.order_number = tor.order_number AND tor.wh_id = tocn.wh_id JOIN dbo.t_special_shipping_instructions tssi(NOLOCK) ON tssi.customer_number = tocn.customer_number WHERE tor.load_id = ldm.load_id AND tor.wh_id LIKE @in_vchWhID)
    END AS highlight
    ,ldm.wh_id
    ,CASE WHEN ldm.load_type ='X' THEN customer_name WHEN ldm.load_type = 'T' THEN ldm.transfer_wh_id ELSE NULL END AS customer_name
    ,ldm.load_id
    ,CASE ldm.status
        WHEN 'W' THEN CASE ldm.shipment_status WHEN 'Needlist' THEN '<a style="color: #000000" title="Wait Need List">W-NL</a>' WHEN 'Fill' THEN '<a style="color: #000000" title="Wait Requested Fill">W-RF</a>' WHEN 'Both' THEN '<a style="color: #000000" title="Wait Both Need List AND Requested Fill">W-B</a>' WHEN 'Pending' THEN '<a style="color: #000000" title="Wait Pending">W</a>' END
        WHEN 'N' THEN '<a style="color: #000000" title="New">N</a>'
        WHEN 'H' THEN '<a style="color: #000000" title="Held">H</a>'
        WHEN 'R' THEN '<a style="color: #000000" title="Released">R</a>'
        WHEN 'C' THEN '<a style="color: #000000" title="Complete">C</a>'
        WHEN 'S' THEN '<a style="color: #000000" title="Shipped">S</a>'
        WHEN 'M' THEN '<a style="color: #000000" title="Customer Svc:' + ISNULL((SELECT TOP 1 ocn.customer_service_rep FROM #t_order_c_number ocn WHERE LEFT(ocn.order_number, 10) = ldm.load_id ORDER BY order_date DESC),'') + '">M</a>'
        ELSE '<a style="color: #000000" title="Unknown">' + ldm.status + '</a>'
    END AS status
    ,(ISNULL(ldm.dispatch_date, '') + ' ' + RIGHT(ISNULL(ldm.dispatch_time, ''), 8)) AS dispatch_date
    ,CASE WHEN ldm.trip_type_id IN ('P','Y') THEN (SELECT TOP 1 carrier FROM #t_order WHERE carrier IS NOT NULL AND load_id = ldm.load_id AND wh_id LIKE @in_vchWhID) ELSE car.carrier_name END AS carrier_name
    
    -- =================================================================================================
    -- 【降级处理 3】因无权调用标量函数 udf_check_available_trailers，将输出硬编码为 'N/A' 占位
    -- =================================================================================================
    ,CAST('N/A' AS NVARCHAR(10)) AS available_trailers 

    ,ldm.trailer_number AS 'Trailer Type'
    ,ISNULL(ldm.bill_number, ' ') AS bill_number
    ,ldm.live_load AS live_load
    ,CASE WHEN (ldm.equipment_id IS NULL) OR (ldm.equipment_id = 'NULL') THEN CASE WHEN ldm.ya_work_52 IS NOT NULL THEN (SELECT TOP 1 c.carrier_name + ' ' + LEFT(tp.trailer_type_name, 5) FROM dbo.t_ya_work_q w (NOLOCK) INNER JOIN dbo.t_carrier c (NOLOCK) ON c.carrier_id = w.carrier_id INNER JOIN dbo.t_trailer_type tp (NOLOCK) ON tp.trailer_type_id = w.trailer_type_id WHERE w.type = '52' AND w.load_id = ldm.load_id AND w.status = 'UNASSIGNED' ORDER BY work_q_id DESC) ELSE 'Not Assigned' END ELSE ldm.equipment_id END AS equipment_name
    ,ldm.door_loc
    ,ldm.stage_loc
    ,CASE WHEN (ISNULL(ldm.load_type,'')='X' AND ldm.status='N') OR ldm.load_type = 'T' THEN NULL ELSE ISNULL(odb.total_pieces, 0) END AS total_pieces
    ,CASE WHEN (ISNULL(ldm.load_type,'')='X' AND ldm.status='N') OR ldm.load_type = 'T' THEN 0 WHEN ldm.status IN ('N','M') THEN ISNULL(odb.uph_need, 0) ELSE ISNULL(tpkdh.pdl_planned_quantity, 0) END AS UPH_Need
    ,CASE WHEN (ISNULL(ldm.load_type,'')='X' AND ldm.status='N') OR ldm.load_type = 'T' THEN NULL ELSE ISNULL(odb.total_cube, 0) END AS total_cube
    ,CASE WHEN ldm.load_type = 'T' THEN 0 ELSE ldm.number_of_drops END AS nbr_of_orders
    ,CASE WHEN EXISTS (SELECT TOP 1 1 FROM #t_order tor JOIN #t_order_c_number tocn ON tocn.order_number = tor.order_number AND tor.wh_id = tocn.wh_id JOIN dbo.t_special_shipping_instructions tssi(NOLOCK) ON tssi.customer_number = tocn.customer_number WHERE tor.load_id = ldm.load_id AND tor.wh_id LIKE @in_vchWhID) THEN 'Y' ELSE '' END AS special_ship_inst
    ,'' AS blank
    ,alv.loadable_pct
    ,CASE WHEN ldm.overflow_flag IS NOT NULL THEN 'Replan to Primary building' ELSE NULL END AS replan_to_primary
    ,CASE WHEN ldm.load_type = 'T' THEN NULL ELSE alp.allocable_percentage END AS allocable_percentage
    ,CASE WHEN ldm.load_type = 'T' THEN NULL ELSE alp.loadable_percentage END AS loadable_percentage
    ,(SELECT TOP 1 ocn.ship_to_state FROM #t_order_c_number ocn WHERE ocn.order_number LIKE ldm.load_id + '%' AND ocn.wh_id LIKE @in_vchWhID ORDER BY ocn.order_number DESC) AS first_drop_state
    ,(SELECT CASE WHEN cst_csr_count > 1 THEN '<marquee loop="-1" scrollamount="4" width="100%">' + cst_csr_string + '</marquee>' ELSE cst_csr_string END FROM @csr_string_table WHERE cst_load_id = ldm.load_id) AS customer_service_rep
    ,ISNULL(#temp_comments.comment, '') AS comment
    ,CASE WHEN ldm.load_type = 'T' THEN NULL ELSE tpkdh.current_order END AS current_order
    ,CASE WHEN (ISNULL(ldm.load_type,'')='X' AND ldm.status='N') OR ldm.load_type = 'T' THEN NULL ELSE alv.pct_loaded END AS pct_loaded
    ,ldm.trip_type_id
    ,CONVERT(VARCHAR(8), ldm.load_date, 1) AS load_date
    ,CASE WHEN tms.load_id IS NOT NULL THEN NULL ELSE ldm.reference_number END AS 'loading_held'
    ,CASE WHEN ldm.load_type='T' THEN tms.tms_load_id ELSE twt.description END AS description
    ,ISNULL(ldm.equipment_id, 'NULL') AS equipment_id
    ,CASE WHEN (ldm.equipment_id IS NULL) OR (ldm.equipment_id = 'NULL') THEN CASE WHEN ldm.ya_work_52 IS NOT NULL THEN '*' ELSE '' END ELSE CASE WHEN EXISTS(SELECT TOP 1 1 FROM dbo.t_trailer t (NOLOCK) INNER JOIN dbo.t_ya_location loc (NOLOCK) ON t.area_id = loc.area_id AND t.location_id = loc.location_id WHERE t.equipment_id = ldm.equipment_id AND t.status NOT IN ('HISTORY','LOST') AND loc.location_name = ldm.door_loc) THEN 'D' ELSE CASE WHEN EXISTS (SELECT TOP 1 1 FROM dbo.t_ya_work_q w (NOLOCK) INNER JOIN dbo.t_trailer t (NOLOCK) ON w.area_id = t.area_id AND w.trailer_id = t.trailer_id WHERE w.type = '52' AND w.status = 'UNASSIGNED' AND t.status NOT IN ('HISTORY','LOST') AND t.equipment_id = ldm.equipment_id) THEN '*' ELSE '' END END END AS equipment_scheduled
    ,CASE WHEN pkd_planned_quantity > 0 THEN 'N' END AS pkd_needlist
    ,CASE WHEN cubes_of_fill > 0 THEN 'F' END AS fill
    ,ldm.load_type
    ,ldm.load_id AS order_number
    ,alv.suggested_bldg
    ,CASE WHEN ldm.status = 'S' THEN CASE WHEN @v_bol_active = 1 THEN 'PRINT BOL' + ' ' + LEFT(ldm.load_id, 7) ELSE '' END ELSE '' END AS BOL
    ,'%' AS wildcard, 'C' AS C, 'H' AS H, 'F' AS F, 'R' AS R, 'P' AS P, '99999' AS nine, 'N' AS N, 'T' AS T, 'W' AS W, 'M' AS M, 'Y' AS Y, 'S' AS S
    ,@in_dtThruDate AS thru_date
    ,(ldm.trip_create_date + ' ' + RIGHT(ldm.trip_create_time, 8)) AS trip_create
    ,@out_vchDBMessage AS MESSAGE
    ,ISNULL(tlc.comment, '')
    ,ISNULL(ldmb.batch_id,'') AS batch_id
    ,ISNULL(alv.cg_percentage,0) AS cg_percent
    ,ISNULL(alv.uph_percentage,0) AS uph_percent
FROM #temp_ldm ldm
LEFT JOIN dbo.t_work_types twt (NOLOCK) ON ldm.work_type = twt.work_type AND ldm.wh_id = twt.wh_id
LEFT JOIN #temp_odb odb ON odb.load_id = ldm.load_id AND odb.wh_id = ldm.wh_id
LEFT JOIN dbo.t_carrier car (NOLOCK) ON car.carrier_id = ldm.carrier_id
LEFT JOIN #t_afo_load_view alv (NOLOCK) ON alv.wh_id = ldm.wh_id AND alv.load_id = ldm.load_id AND ldm.load_type <> 'T'
LEFT JOIN dbo.t_ovflo_alloc_load_view alp (NOLOCK) ON alp.load_id = ldm.load_id AND alp.wh_id = ldm.wh_id
LEFT JOIN #temp_pkd tpkdh ON tpkdh.load_id = ldm.load_id AND tpkdh.wh_id = ldm.wh_id
LEFT JOIN @csr_string_table ON cst_load_id = ldm.load_id
LEFT JOIN #temp_comments ON #temp_comments.order_number = ldm.load_id + ':' + ldm.number_of_drops
LEFT JOIN dbo.t_load_comment tlc (NOLOCK) ON ldm.wh_id = tlc.wh_id AND ldm.load_id = tlc.load_id
LEFT JOIN #temp_cust_large_orders clo ON clo.load_id = ldm.load_id
LEFT JOIN t_load_master_batch ldmb(NOLOCK) ON ldm.load_id = ldmb.load_id
LEFT JOIN dbo.t_load_dispatch_tms tms (NOLOCK) ON ldm.load_id = tms.load_id AND ldm.wh_id = tms.wh_id AND ldm.load_type = 'T' AND tms.load_type IS NULL;

IF(@in_CG = 'Y' OR @in_UPH = 'Y')
BEGIN
    GOTO CGANDUPH;
END

SELECT
    CASE WHEN (r1.highlight='{{BGCOLOR=#98B0D8}}' AND @v_ntbflag=0) THEN r1.highlight+'{{NOLINKS}}' ELSE r1.highlight END AS highlight
    ,r1.wh_id, ISNULL(r1.customer_name,'') AS customer_name, r1.batch_id, r1.load_id, r1.status, r1.cg_percent, r1.uph_percent
    ,FORMAT(r1.dispatch_date,'MM/dd/yyyy hh:mm:ss tt') AS dispatch_date, r1.carrier_name, r1.available_trailers, r1.trailer_number, r1.bill_number, r1.live_load
    ,equipment_name=CASE WHEN (SELECT COUNT(0) FROM dbo.t_load_master(NOLOCK) WHERE work_type='35' AND status='N' AND load_id=r1.load_id)>0 THEN '' ELSE r1.equipment_name END
    ,r1.door_loc, r1.stage_loc, r1.total_pieces, r1.uph_need, r1.total_cube, r1.number_of_drops, r1.special_ship_inst, r1.blank, ap.allocable_pct, r1.loadable_pct, r1.replan_to_primary, r1.allocable_percentage, r1.loadable_percentage, r1.first_drop_state, r1.customer_service_rep, LTRIM(RTRIM(ISNULL(r1.comment, ''))) + ' ' + LTRIM(RTRIM(ISNULL(r1.comment_2, ''))) AS comment, r1.current_order, r1.pct_loaded, r1.trip_type_id, r1.load_date, r1.reference_number, r1.description, r1.equipment_id, r1.equipment_scheduled, r1.needlist, r1.fill, r1.load_type, r1.order_number, r1.suggested_bldg, r1.BOL, r1.wildcard, r1.C, r1.H, r1.F, r1.R, r1.P, r1.nine, r1.N, r1.T, r1.W, r1.M, r1.Y, r1.S, r1.thru_date, r1.trip_create, ISNULL(ldd.dispatch_confirmed, 'N') AS dispatch_confirmed
    ,@in_vchTripTypeC AS trip_type_c, @in_vchTripTypeF AS trip_type_f, @in_vchTripTypeP AS trip_type_p, @in_vchTripTypeR AS trip_type_r, @in_vchTripTypeT AS trip_type_t, @in_vchTripTypeU AS trip_type_u, @in_vchTripTypeY AS trip_type_y, @in_vchStatHold AS stat_hold, @in_vchStatRelease AS stat_release, @in_vchStatReverted AS stat_reverted, @in_vchStatShipped AS stat_shipped, @in_vchStatWait AS stat_wait, @in_vchStatCSModify AS stat_csmodify, @in_vchStatNew AS stat_new, @in_vchStatComplete AS stat_complete, @in_TripTypeHomestore AS trip_type_homestore, @in_vchLoadNumber AS load_number, @in_cg_percentage AS cg_percentage, @in_uph_percentage AS uph_percentage, @in_CG AS CG, @in_UPH AS UPH, MESSAGE
    ,CAST(LEFT(r1.load_id, CHARINDEX('-', r1.load_id) - 1) AS INT) AS trip_nbr
FROM #temp_trip_report r1
LEFT JOIN dbo.t_load_dispatch ldd(NOLOCK) ON ldd.load_id LIKE (LEFT(r1.load_id, 7) + '%') AND ldd.wh_id = r1.wh_id
LEFT JOIN #t_load_allocable_pct ap ON ap.wh_id=r1.wh_id AND r1.load_id = ap.load_id
ORDER BY r1.batch_id, r1.dispatch_date;

GOTO ExitLabel;

CGANDUPH:
SELECT
    CASE WHEN (r1.highlight='{{BGCOLOR=#98B0D8}}' AND @v_ntbflag=0) THEN r1.highlight+'{{NOLINKS}}' ELSE r1.highlight END AS highlight
    ,r1.wh_id, ISNULL(r1.customer_name,'') AS customer_name, r1.batch_id, r1.load_id, r1.status, afo.cg_percentage AS cg_percent, afo.uph_percentage AS uph_percent
    ,FORMAT(r1.dispatch_date,'MM/dd/yyyy hh:mm:ss tt') AS dispatch_date, r1.carrier_name, r1.available_trailers, r1.trailer_number, r1.bill_number, r1.live_load
    ,equipment_name=CASE WHEN (SELECT COUNT(0) FROM dbo.t_load_master(NOLOCK) WHERE work_type='35' AND status='N' AND load_id=r1.load_id)>0 THEN '' ELSE r1.equipment_name END
    ,r1.door_loc, r1.stage_loc, r1.total_pieces, r1.uph_need, r1.total_cube, r1.number_of_drops, r1.special_ship_inst, r1.blank, ap.allocable_pct, r1.loadable_pct, r1.replan_to_primary, r1.allocable_percentage, r1.loadable_percentage, r1.first_drop_state, r1.customer_service_rep, LTRIM(RTRIM(ISNULL(r1.comment, ''))) + ' ' + LTRIM(RTRIM(ISNULL(r1.comment_2, ''))) AS comment, r1.current_order, r1.pct_loaded, r1.trip_type_id, r1.load_date, r1.reference_number, r1.description, r1.equipment_id, r1.equipment_scheduled, r1.needlist, r1.fill, r1.load_type, r1.order_number, r1.suggested_bldg, r1.BOL, r1.wildcard, r1.C, r1.H, r1.F, r1.R, r1.P, r1.nine, r1.N, r1.T, r1.W, r1.M, r1.Y, r1.S, r1.thru_date, r1.trip_create, ISNULL(ldd.dispatch_confirmed, 'N') AS dispatch_confirmed
    ,@in_vchTripTypeC AS trip_type_c, @in_vchTripTypeF AS trip_type_f, @in_vchTripTypeP AS trip_type_p, @in_vchTripTypeR AS trip_type_r, @in_vchTripTypeT AS trip_type_t, @in_vchTripTypeU AS trip_type_u, @in_vchTripTypeY AS trip_type_y, @in_vchStatHold AS stat_hold, @in_vchStatRelease AS stat_release, @in_vchStatReverted AS stat_reverted, @in_vchStatShipped AS stat_shipped, @in_vchStatWait AS stat_wait, @in_vchStatCSModify AS stat_csmodify, @in_vchStatNew AS stat_new, @in_vchStatComplete AS stat_complete, @in_TripTypeHomestore AS trip_type_homestore, @in_vchLoadNumber AS load_number, @in_cg_percentage AS cg_percentage, @in_uph_percentage AS uph_percentage, @in_CG AS CG, @in_UPH AS UPH, MESSAGE
    ,CAST(LEFT(r1.load_id, CHARINDEX('-', r1.load_id) - 1) AS INT) AS trip_nbr
FROM #t_afo_load_view afo
LEFT JOIN #temp_trip_report r1 (NOLOCK) ON afo.load_id = r1.load_id AND afo.wh_id = r1.wh_id
LEFT JOIN #t_load_allocable_pct ap ON afo.wh_id = ap.wh_id AND afo.load_id = ap.load_id
LEFT JOIN dbo.t_load_dispatch ldd (NOLOCK) ON ldd.load_id LIKE (LEFT(r1.load_id, 7) + '%') AND ldd.wh_id = r1.wh_id
WHERE r1.load_id IS NOT NULL
ORDER BY r1.batch_id DESC, r1.dispatch_date;

ExitLabel:
SET NOCOUNT OFF;

IF @out_vchDBMessage IS NOT NULL AND @out_vchDBMessage <> ''
BEGIN
    SELECT @out_vchDBMessage AS MESSAGE;
END