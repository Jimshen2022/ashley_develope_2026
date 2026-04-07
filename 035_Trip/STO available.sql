/********************************************************************************
 *    Company         : Ashley Furniture Industries
 *    System          : HighJump
 *    Procedure       : usp_trip_available_sto (改写为直接查询，参数放顶部)
 *    Author          : Dolly Lv
 *    Date            : 10/24/2012
 *    Version         : 1.0
 *    Description     : Trip Available STO 报表查询
 *
 *    Modification Log: Date        Modified By   Description
 *                      2012-11-30  Jeson Ye      优化(变量表改为临时表)
 *                      2012-12-19  Grace Liu     增加MFG计划生产数量
 *                      2013-01-22  Grace Liu     修复可计费trip不含X,C
 *                      2014-01-17  Grace Liu     增加只显示负数项请求
 *                      2014-06-11  Annie Liu     增加FP过滤
 *                      2014/10/13  Sonia Xu      支持多仓库ID
 *                      2016/07/05  Grace Liu     增加汇总页
 *                      2016/08/26  Grace Liu     增加两列并调整影响trip数统计逻辑
 *                      2018/11/21  Lily Wei       DMND0134334 增加绑定仓库控制
 *                      2019/01/18  Lily Wei       移除绑定仓库，新增已确认调度参数
 *                      2019/07/03  Grace Liu     OMS load id变更
 *                      2021/09/01  Sathya        增加Location/Intransit/Product Quantity列，修正deficiency拼写
 ********************************************************************************/

/* ============================================================
   >>>  在此处修改查询参数  <<<
   ============================================================ */
DECLARE @in_vchWhID             NVARCHAR(10)  = '335'          -- 仓库ID
DECLARE @in_vchDispatchStartDate DATETIME     = '2026-04-01'    -- 调度开始日期
DECLARE @in_vchDispatchEndDate   DATETIME     = '2026-05-31'    -- 调度结束日期
DECLARE @in_vchType             NVARCHAR(20)  = 'ALL'           -- 类型: 'ALL' 或其他值(仅显示缺货项)
DECLARE @in_vchFWP              NVARCHAR(2)   = 'N'             -- 是否使用FWP大楼过滤: 'Y' 或 'N'
DECLARE @in_Report              VARCHAR(1)    = 'D'             -- 报表类型: 'D'=明细, 'S'=汇总
DECLARE @in_Confirmed           VARCHAR(1)    = 'A'             -- 已确认调度: 'A'=全部, 'Y'=已确认, 'N'=未确认
/* ============================================================ */

/* ---------- 内部变量 ---------- */
DECLARE @v_vchItemNumber  VARCHAR(30)
DECLARE @v_vchTripNumber  VARCHAR(10)
DECLARE @v_nQty           INT
DECLARE @v_nTripNeeded    INT
DECLARE @v_nTripPicked    INT
DECLARE @v_nNegativeQty   INT
DECLARE @v_nPreNegative   INT
DECLARE @v_nRowCount      INT
DECLARE @v_vchBuilding    VARCHAR(10)

SELECT
    @v_vchItemNumber = '',
    @v_vchTripNumber = '',
    @v_nQty          = 0,
    @v_nTripNeeded   = 0,
    @v_nTripPicked   = 0,
    @v_nRowCount     = 0

/* ---------- 获取转发拣货大楼 ---------- */
SELECT @v_vchBuilding = c1
FROM t_control (NOLOCK)
WHERE control_type = 'BLDG_FWD_PICK'

/* ============================================================
   临时表：清理
   ============================================================ */
IF OBJECT_ID('tempdb..#temp_demand')                  IS NOT NULL DROP TABLE #temp_demand
IF OBJECT_ID('tempdb..#temp_asn')                     IS NOT NULL DROP TABLE #temp_asn
IF OBJECT_ID('tempdb..#temp_sto')                     IS NOT NULL DROP TABLE #temp_sto
IF OBJECT_ID('tempdb..#temp_total')                   IS NOT NULL DROP TABLE #temp_total
IF OBJECT_ID('tempdb..#_overflow_building_location')  IS NOT NULL DROP TABLE #_overflow_building_location
IF OBJECT_ID('tempdb..#item')                         IS NOT NULL DROP TABLE #item
IF OBJECT_ID('tempdb..#temp_summary')                 IS NOT NULL DROP TABLE #temp_summary
IF OBJECT_ID('tempdb..#temp_trailer')                 IS NOT NULL DROP TABLE #temp_trailer
IF OBJECT_ID('tempdb..#update_trl')                   IS NOT NULL DROP TABLE #update_trl

/* ============================================================
   #temp_demand：主需求表
   ============================================================ */
CREATE TABLE #temp_demand (
    wh_id            VARCHAR(10)   NOT NULL,
    dispatch_date    DATETIME      NOT NULL,
    dispatch_time    DATETIME      NOT NULL,
    item_number      VARCHAR(30)   NOT NULL,
    trip_number      VARCHAR(10)   NOT NULL,
    trip_needed      INT,
    trip_picked      INT,
    available_sto    INT,
    available_staged INT,
    yard_qty         INT,
    new_asn_qty      INT,
    po_number        VARCHAR(60),
    earliest_date    DATETIME,
    Stage_Qty        INT,
    NOMFG_qty        INT,
    negative_tot     INT,
    Mfg_schQty       INT,
    ldm_status       VARCHAR(1),
    overflow_qty     INT,
    offsite_qty      INT,
    carrier          VARCHAR(100),
    In_transit       INT,
    prod_qty         INT,
    location_id      VARCHAR(50)
)

/* ============================================================
   #_overflow_building_location：溢出大楼库位
   ============================================================ */
CREATE TABLE #_overflow_building_location (
    item_number VARCHAR(30),
    location_id VARCHAR(50),
    qty         INT
)

INSERT INTO #_overflow_building_location
SELECT
    sto.item_number,
    MIN(sto.location_id),
    sto.actual_qty
FROM t_stored_item sto (NOLOCK)
JOIN t_location loc (NOLOCK)
    ON loc.location_id = sto.location_id
    AND loc.type IN ('I','M','Y','X','P')
    AND loc.wh_id = sto.wh_id
JOIN t_control con (NOLOCK)
    ON con.c1 = loc.building
    AND con.control_type = 'BLDG_OVERFLOW'
JOIN t_item_master itm (NOLOCK)
    ON sto.item_number = itm.item_number
    AND itm.pick_put_id LIKE '%'
    AND sto.wh_id = itm.wh_id
INNER JOIN (
    SELECT s.item_number, MIN(s.actual_qty) AS actual_qty, s.wh_id
    FROM t_stored_item s (NOLOCK)
    JOIN t_location loc (NOLOCK)
        ON loc.location_id = s.location_id
        AND loc.type IN ('I','M','Y','X','P')
        AND loc.wh_id = s.wh_id
    JOIN t_control con (NOLOCK)
        ON con.c1 = loc.building
        AND con.control_type = 'BLDG_OVERFLOW'
    GROUP BY s.item_number, s.wh_id
) sto2
    ON sto.item_number = sto2.item_number
    AND sto.actual_qty = sto2.actual_qty
    AND sto.wh_id = sto2.wh_id
GROUP BY sto.item_number, sto.actual_qty
ORDER BY sto.item_number

/* ============================================================
   根据 @in_vchType 决定是否预筛缺货商品
   ============================================================ */
IF @in_vchType <> 'ALL'
BEGIN
    /* 仅筛选仍有缺口的商品 */
    SELECT a.item_number
    INTO #item
    FROM (
        SELECT orb.item_number, SUM(orb.qty) AS trip_needed
        FROM t_load_master ldm (NOLOCK)
        JOIN t_order orm (NOLOCK)
            ON ldm.wh_id = orm.wh_id AND ldm.load_id = orm.load_id
        JOIN t_order_detail_breakdown orb (NOLOCK)
            ON orb.wh_id = ldm.wh_id AND orb.order_number = orm.order_number
        LEFT JOIN t_load_dispatch ldd (NOLOCK)
            ON ldd.load_id = ldm.load_id AND ldd.wh_id = ldm.wh_id
        WHERE ldm.wh_id = @in_vchWhID
            AND ldm.dispatch_date + ldm.dispatch_time
                BETWEEN CONVERT(DATETIME, @in_vchDispatchStartDate)
                    AND CONVERT(DATETIME, @in_vchDispatchEndDate)
            AND ldm.status NOT IN ('S','X','C')
            AND ldm.load_type = 'B'
            AND (CASE WHEN @in_Confirmed = 'A' THEN @in_Confirmed ELSE ISNULL(ldd.dispatch_confirmed,'N') END) = @in_Confirmed
        GROUP BY orb.item_number
    ) a
    LEFT JOIN (
        SELECT pkd.item_number, SUM(pkd.picked_quantity) AS picked_qty
        FROM t_load_master ldm (NOLOCK)
        JOIN t_pick_detail pkd (NOLOCK)
            ON ldm.load_id = pkd.load_id AND ldm.wh_id = pkd.wh_id
        LEFT JOIN t_load_dispatch ldd (NOLOCK)
            ON ldd.load_id = ldm.load_id AND ldd.wh_id = ldm.wh_id
        WHERE ldm.wh_id = @in_vchWhID
            AND ldm.dispatch_date + ldm.dispatch_time
                BETWEEN CONVERT(DATETIME, @in_vchDispatchStartDate)
                    AND CONVERT(DATETIME, @in_vchDispatchEndDate)
            AND ldm.status NOT IN ('S','X','C')
            AND ldm.load_type = 'B'
            AND (CASE WHEN @in_Confirmed = 'A' THEN @in_Confirmed ELSE ISNULL(ldd.dispatch_confirmed,'N') END) = @in_Confirmed
        GROUP BY pkd.item_number
    ) b ON a.item_number = b.item_number
    LEFT JOIN (
        SELECT sto.item_number, SUM(sto.actual_qty) AS avaiable_qty
        FROM t_stored_item sto (NOLOCK)
        JOIN t_location loc (NOLOCK)
            ON sto.location_id = loc.location_id AND sto.wh_id = loc.wh_id
        WHERE sto.wh_id = @in_vchWhID
            AND sto.type = 'STORAGE'
            AND sto.actual_qty > 0
            AND loc.type IN ('I','M','P','X')
            AND loc.building = CASE WHEN @in_vchFWP = 'Y' THEN @v_vchBuilding ELSE loc.building END
            AND sto.status = 'A'
        GROUP BY sto.item_number
    ) c ON a.item_number = c.item_number
    WHERE a.trip_needed - ISNULL(b.picked_qty, 0) - ISNULL(c.avaiable_qty, 0) > 0

    /* 插入缺货商品的 trip 明细 */
    INSERT INTO #temp_demand
    SELECT
        a.wh_id, a.dispatch_date, a.dispatch_time, a.item_number, a.trip_number,
        a.trip_needed,
        SUM(ISNULL(pkd.picked_quantity, 0)) AS trip_picked,
        0, 0, 0, 0, '', '', 0, 0, 0, 0,
        a.status,
        c.overflow_qty,
        p.offsite_onhand_qty,
        a.carrier,
        (ISNULL(p.onhand_fwd_pick_bldg, 0) - ISNULL(p.onhand_fwd_pick_bldg_less_shtl, 0)) AS In_transit,
        0,
        ovr.location_id
    FROM (
        SELECT
            ldm.wh_id, ldm.dispatch_date, ldm.dispatch_time,
            orb.item_number, ldm.status,
            ISNULL(orm.carrier, ISNULL(c2.carrier_name,'')) AS carrier,
            ldm.load_id AS trip_number,
            SUM(orb.qty) AS trip_needed
        FROM t_load_master ldm (NOLOCK)
        JOIN t_order orm (NOLOCK)
            ON ldm.wh_id = orm.wh_id AND ldm.load_id = orm.load_id
        LEFT JOIN t_carrier c2 (NOLOCK) ON ldm.carrier_id = c2.carrier_id
        JOIN t_order_detail_breakdown orb (NOLOCK)
            ON orb.wh_id = ldm.wh_id AND orb.order_number = orm.order_number
        JOIN #item (NOLOCK) ON orb.item_number = #item.item_number
        LEFT JOIN t_load_dispatch ldd (NOLOCK)
            ON ldd.load_id = ldm.load_id AND ldd.wh_id = ldm.wh_id
        WHERE ldm.wh_id = @in_vchWhID
            AND ldm.dispatch_date + ldm.dispatch_time
                BETWEEN CONVERT(DATETIME, @in_vchDispatchStartDate)
                    AND CONVERT(DATETIME, @in_vchDispatchEndDate)
            AND ldm.status NOT IN ('S','X','C')
            AND ldm.load_type = 'B'
            AND (CASE WHEN @in_Confirmed = 'A' THEN @in_Confirmed ELSE ISNULL(ldd.dispatch_confirmed,'N') END) = @in_Confirmed
        GROUP BY
            ldm.wh_id, ldm.dispatch_date, ldm.dispatch_time,
            orb.item_number, ldm.status,
            ISNULL(orm.carrier, ISNULL(c2.carrier_name,'')),
            ldm.load_id
    ) a
    LEFT JOIN t_pick_detail pkd (NOLOCK)
        ON a.trip_number = pkd.load_id
        AND a.item_number = pkd.item_number
        AND ISNULL(pkd.picked_quantity, 0) > 0
        AND a.wh_id = pkd.wh_id
    LEFT JOIN (
        SELECT sto.wh_id, sto.item_number, SUM(sto.actual_qty) AS overflow_qty
        FROM t_stored_item sto (NOLOCK)
        JOIN t_location loc (NOLOCK)
            ON sto.wh_id = loc.wh_id AND sto.location_id = loc.location_id
        JOIN t_control con (NOLOCK)
            ON con.c1 = loc.building AND con.control_type = 'BLDG_OVERFLOW'
        JOIN #item (NOLOCK) ON sto.item_number = #item.item_number
        WHERE loc.type IN ('I','M','Y','X') AND sto.status = 'A' AND sto.actual_qty > 0
        GROUP BY sto.wh_id, sto.item_number
    ) c ON a.wh_id = c.wh_id AND a.item_number = c.item_number
    LEFT JOIN t_inventory_position p (NOLOCK)
        ON p.wh_id = a.wh_id AND p.item_number = a.item_number
    LEFT JOIN #_overflow_building_location ovr (NOLOCK)
        ON ovr.item_number = c.item_number
    GROUP BY
        a.wh_id, a.dispatch_date, a.dispatch_time, a.item_number, a.trip_number,
        a.trip_needed, a.status, c.overflow_qty, p.offsite_onhand_qty, a.carrier,
        (ISNULL(p.onhand_fwd_pick_bldg, 0) - ISNULL(p.onhand_fwd_pick_bldg_less_shtl, 0)),
        ovr.location_id
END
ELSE
BEGIN
    /* 全量 trip 明细 */
    INSERT INTO #temp_demand
    SELECT
        a.wh_id, a.dispatch_date, a.dispatch_time, a.item_number, a.trip_number,
        a.trip_needed,
        SUM(ISNULL(pkd.picked_quantity, 0)) AS trip_picked,
        0, 0, 0, 0, '', '', 0, 0, 0, 0,
        a.status,
        c.overflow_qty,
        p.offsite_onhand_qty,
        a.carrier,
        (ISNULL(p.onhand_fwd_pick_bldg, 0) - ISNULL(p.onhand_fwd_pick_bldg_less_shtl, 0)) AS In_transit,
        0,
        ovr.location_id
    FROM (
        SELECT
            ldm.wh_id, ldm.dispatch_date, ldm.dispatch_time,
            orb.item_number, ldm.status,
            ISNULL(orm.carrier, ISNULL(c2.carrier_name,'')) AS carrier,
            ldm.load_id AS trip_number,
            SUM(orb.qty) AS trip_needed
        FROM t_load_master ldm (NOLOCK)
        JOIN t_order orm (NOLOCK)
            ON ldm.wh_id = orm.wh_id AND ldm.load_id = orm.load_id
        LEFT JOIN t_carrier c2 (NOLOCK) ON ldm.carrier_id = c2.carrier_id
        JOIN t_order_detail_breakdown orb (NOLOCK)
            ON orb.wh_id = ldm.wh_id AND orb.order_number = orm.order_number
        LEFT JOIN t_load_dispatch ldd (NOLOCK)
            ON ldd.load_id = ldm.load_id AND ldd.wh_id = ldm.wh_id
        WHERE ldm.wh_id = @in_vchWhID
            AND ldm.dispatch_date + ldm.dispatch_time
                BETWEEN CONVERT(DATETIME, @in_vchDispatchStartDate)
                    AND CONVERT(DATETIME, @in_vchDispatchEndDate)
            AND ldm.status NOT IN ('S','X','C')
            AND ldm.load_type = 'B'
            AND (CASE WHEN @in_Confirmed = 'A' THEN @in_Confirmed ELSE ISNULL(ldd.dispatch_confirmed,'N') END) = @in_Confirmed
        GROUP BY
            ldm.wh_id, ldm.dispatch_date, ldm.dispatch_time,
            orb.item_number, ldm.status,
            ISNULL(orm.carrier, ISNULL(c2.carrier_name,'')),
            ldm.load_id
    ) a
    LEFT JOIN t_pick_detail pkd (NOLOCK)
        ON a.trip_number = pkd.load_id
        AND a.item_number = pkd.item_number
        AND ISNULL(pkd.picked_quantity, 0) > 0
        AND a.wh_id = pkd.wh_id
    LEFT JOIN (
        SELECT sto.wh_id, sto.item_number, SUM(sto.actual_qty) AS overflow_qty
        FROM t_stored_item sto (NOLOCK)
        JOIN t_location loc (NOLOCK)
            ON sto.wh_id = loc.wh_id AND sto.location_id = loc.location_id
        JOIN t_control con (NOLOCK)
            ON con.c1 = loc.building AND con.control_type = 'BLDG_OVERFLOW'
        WHERE loc.type IN ('I','M','Y','X') AND sto.status = 'A' AND sto.actual_qty > 0
        GROUP BY sto.wh_id, sto.item_number
    ) c ON a.wh_id = c.wh_id AND a.item_number = c.item_number
    LEFT JOIN t_inventory_position p (NOLOCK)
        ON p.wh_id = a.wh_id AND p.item_number = a.item_number
    LEFT JOIN #_overflow_building_location ovr (NOLOCK)
        ON ovr.item_number = c.item_number
    GROUP BY
        a.wh_id, a.dispatch_date, a.dispatch_time, a.item_number, a.trip_number,
        a.trip_needed, a.status, c.overflow_qty, p.offsite_onhand_qty, a.carrier,
        (ISNULL(p.onhand_fwd_pick_bldg, 0) - ISNULL(p.onhand_fwd_pick_bldg_less_shtl, 0)),
        ovr.location_id
END

/* ============================================================
   后续更新与计算（仅在有数据时执行）
   ============================================================ */
SELECT @v_nRowCount = COUNT(1) FROM #temp_demand (NOLOCK)

IF @v_nRowCount > 0
BEGIN
    /* --- 汇总合计表 --- */
    SELECT wh_id, item_number,
        SUM(trip_needed)  AS trip_needed,
        SUM(trip_picked)  AS trip_picked,
        0 AS available_sto, 0 AS available_staged,
        0 AS Stage_Qty,     0 AS yard_qty,
        0 AS new_asn_qty,   0 AS negative_qty
    INTO #temp_total
    FROM #temp_demand
    GROUP BY wh_id, item_number

    /* --- 更新已暂存数量（RS/DZ/DEFUPHDROP_LOC） --- */
    UPDATE #temp_demand
    SET available_staged = avaiable_stage.qty
    FROM (
        SELECT sto.item_number, SUM(sto.actual_qty) AS qty
        FROM t_stored_item sto (NOLOCK)
        WHERE sto.type = 'STORAGE'
            AND sto.wh_id = @in_vchWhID
            AND sto.actual_qty > 0
            AND (
                sto.location_id LIKE 'RS%'
                OR sto.location_id LIKE 'DZ%'
                OR sto.location_id IN (
                    SELECT ISNULL(c1,'FL001AA1')
                    FROM t_control (NOLOCK)
                    WHERE control_type = 'DEFUPHDROP_LOC'
                )
            )
        GROUP BY sto.item_number
    ) avaiable_stage
    JOIN #temp_demand demand ON demand.item_number = avaiable_stage.item_number

    /* --- 更新MFG计划生产数量 --- */
    UPDATE #temp_demand
    SET Mfg_schQty = s.qty
    FROM (
        SELECT sch.item_number, SUM(sch.qty_produced) AS qty
        FROM t_mfg_schedule_stage sch (NOLOCK)
        WHERE sch.wh_id = @in_vchWhID
        GROUP BY sch.item_number
    ) s
    JOIN #temp_demand demand ON demand.item_number = s.item_number

    /* --- 更新MFG已生产但未收货数量 --- */
    UPDATE #temp_demand
    SET NOMFG_qty = mfg.qty
    FROM (
        SELECT pru.item_number, COUNT(1) AS qty
        FROM t_prod_receipt_upholstery pru (NOLOCK)
        WHERE pru.wh_id = @in_vchWhID
            AND eol_scanned = 'Y'
            AND received = 'N'
        GROUP BY pru.item_number
    ) mfg
    JOIN #temp_demand demand ON demand.item_number = mfg.item_number

    /* --- 更新Q类型库位暂存数量 --- */
    UPDATE #temp_demand
    SET Stage_Qty = q_stage.qty
    FROM (
        SELECT sto.item_number, SUM(sto.actual_qty) AS qty
        FROM t_stored_item sto (NOLOCK)
        JOIN t_location loc (NOLOCK)
            ON sto.location_id = loc.location_id AND sto.wh_id = loc.wh_id
        WHERE sto.type = 'STORAGE'
            AND sto.actual_qty > 0
            AND loc.type = 'Q'
            AND sto.wh_id = @in_vchWhID
        GROUP BY sto.item_number
    ) q_stage
    JOIN #temp_demand demand ON demand.item_number = q_stage.item_number

    /* --- 更新已签到ASN（yard）数量 --- */
    UPDATE #temp_demand
    SET yard_qty = yard_asn.qty
    FROM (
        SELECT asd.item_number,
            SUM(asd.quantity_shipped - asd.quantity_received) AS qty
        FROM t_asn asn (NOLOCK)
        JOIN t_asn_detail asd (NOLOCK) ON asn.asn_id = asd.asn_id
        WHERE asn.status = 'CHECKED IN'
        GROUP BY asd.item_number
        HAVING SUM(asd.quantity_shipped) > SUM(asd.quantity_received)
    ) yard_asn
    JOIN #temp_demand demand ON demand.item_number = yard_asn.item_number

    /* --- 更新产品数量（Work type 55 + 软包） --- */
    UPDATE #temp_demand
    SET prod_qty = prod.qty
    FROM (
        SELECT mfg.item_number,
            SUM(mfg.qty_expected - mfg.qty_received) AS qty
        FROM t_mfg_receipt mfg (NOLOCK)
        JOIN t_work_q wkq (NOLOCK)
            ON mfg.license_number = wkq.pick_ref_number AND mfg.wh_id = wkq.wh_id
        JOIN t_hu_master hud (NOLOCK)
            ON mfg.license_number = hud.hu_id AND mfg.wh_id = hud.wh_id
        WHERE mfg.status = 'U'
            AND received = 'N'
            AND wkq.work_type = '55'
            AND wkq.work_status <> 'C'
            AND mfg.qty_expected - mfg.qty_received > 0
        GROUP BY mfg.item_number
        UNION
        SELECT pru.item_number, ISNULL(COUNT(1), 0) AS qty
        FROM t_prod_receipt_upholstery pru (NOLOCK)
        WHERE eol_scanned = 'Y' AND received = 'N'
        GROUP BY pru.item_number
    ) prod
    JOIN #temp_demand demand ON prod.item_number = demand.item_number

    /* --- 获取新ASN（状态NEW）待签到数量 --- */
    SELECT
        asd.asn_id,
        asd.item_number,
        asn.expected_arrival,
        SUM(asd.quantity_shipped - asd.quantity_received) AS qty,
        CAST('0' AS VARCHAR(60)) AS po_number
    INTO #temp_asn
    FROM t_asn asn (NOLOCK)
    JOIN t_asn_detail asd (NOLOCK) ON asn.asn_id = asd.asn_id
    WHERE asn.status = 'NEW'
        AND asd.quantity_shipped > asd.quantity_received
        AND asd.item_number IN (SELECT item_number FROM #temp_demand)
    GROUP BY asd.asn_id, asd.item_number, asn.expected_arrival

    UPDATE #temp_asn
    SET po_number = y.customer_po_number
    FROM (
        SELECT TOP 1 asd.asn_id, asd.customer_po_number
        FROM t_asn_detail asd (NOLOCK)
        JOIN #temp_asn x (NOLOCK) ON x.asn_id = asd.asn_id
    ) y

    UPDATE #temp_demand
    SET new_asn_qty   = new_asn.qty,
        po_number     = new_asn.po_number,
        earliest_date = new_asn.expected_arrival
    FROM #temp_asn new_asn (NOLOCK)
    JOIN #temp_demand demand ON demand.item_number = new_asn.item_number

    DROP TABLE #temp_asn

    /* --- 按调度日期顺序分配可用STO --- */
    SELECT sto.item_number,
        SUM(sto.actual_qty) AS qty,
        'N' AS flag
    INTO #temp_sto
    FROM t_stored_item sto (NOLOCK)
    JOIN t_location loc (NOLOCK)
        ON sto.location_id = loc.location_id AND sto.wh_id = loc.wh_id
    WHERE sto.type = 'STORAGE'
        AND sto.wh_id = @in_vchWhID
        AND sto.actual_qty > 0
        AND loc.type IN ('I','M','P','X')
        AND loc.building = CASE WHEN @in_vchFWP = 'Y' THEN @v_vchBuilding ELSE loc.building END
        AND sto.status = 'A'
        AND sto.item_number IN (SELECT item_number FROM #temp_demand)
    GROUP BY sto.item_number

    CREATE CLUSTERED INDEX IDX_TEMP_DISPATCH ON #temp_demand (dispatch_date, dispatch_time, trip_number)
    CREATE INDEX IDX_ITEM ON #temp_demand (item_number)

    /* 循环：按trip顺序分配STO库存 */
    LOOPITEM:
        SELECT TOP 1
            @v_vchItemNumber = item_number,
            @v_nQty          = qty
        FROM #temp_sto (NOLOCK)
        WHERE flag = 'N'

        IF @@ROWCOUNT > 0
        BEGIN
            LOOPITEMQTY:
                SELECT TOP 1
                    @v_vchTripNumber = trip_number,
                    @v_nTripNeeded   = trip_needed,
                    @v_nTripPicked   = trip_picked
                FROM #temp_demand
                WHERE item_number = @v_vchItemNumber
                    AND available_sto = 0

                IF @@ROWCOUNT > 0
                BEGIN
                    UPDATE #temp_demand
                    SET available_sto = @v_nQty
                    WHERE item_number = @v_vchItemNumber
                        AND trip_number = @v_vchTripNumber

                    IF @v_nQty - (@v_nTripNeeded - @v_nTripPicked) > 0
                    BEGIN
                        SELECT @v_nQty = @v_nQty - (@v_nTripNeeded - @v_nTripPicked)
                        GOTO LOOPITEMQTY
                    END
                    ELSE
                    BEGIN
                        UPDATE #temp_sto SET flag = 'Y' WHERE item_number = @v_vchItemNumber
                        GOTO LOOPITEM
                    END
                END

            UPDATE #temp_sto SET flag = 'Y' WHERE item_number = @v_vchItemNumber
            GOTO LOOPITEM
        END

    DROP TABLE #temp_sto

    /* 循环：累计各商品负数合计 */
    SELECT DISTINCT item_number, 'N' AS flag
    INTO #temp_item
    FROM #temp_demand
    WHERE available_sto - (trip_needed - trip_picked) < 0

    LOOPITEMAGAIN:
        SELECT TOP 1 @v_vchItemNumber = item_number
        FROM #temp_item (NOLOCK)
        WHERE flag = 'N'

        IF @@ROWCOUNT > 0
        BEGIN
            SELECT @v_nNegativeQty = 0, @v_nPreNegative = 0

            SELECT
                item_number, trip_number,
                CASE
                    WHEN available_sto - (trip_needed - trip_picked) < 0
                    THEN available_sto - (trip_needed - trip_picked)
                    ELSE 0
                END AS negative_qty,
                'N' AS flag,
                negative_tot
            INTO #temp_negative
            FROM #temp_demand
            WHERE item_number = @v_vchItemNumber
                AND available_sto - (trip_needed - trip_picked) < 0

            LOOPQTY:
                SELECT TOP 1
                    @v_vchTripNumber = trip_number,
                    @v_nNegativeQty  = negative_qty
                FROM #temp_negative (NOLOCK)
                WHERE flag = 'N'

                IF @@ROWCOUNT > 0
                BEGIN
                    UPDATE #temp_demand
                    SET negative_tot = @v_nNegativeQty + @v_nPreNegative
                    WHERE item_number = @v_vchItemNumber
                        AND trip_number = @v_vchTripNumber

                    UPDATE #temp_negative
                    SET flag = 'Y'
                    WHERE item_number = @v_vchItemNumber
                        AND trip_number = @v_vchTripNumber

                    SELECT @v_nPreNegative = @v_nPreNegative + @v_nNegativeQty
                    GOTO LOOPQTY
                END

            DROP TABLE #temp_negative

            UPDATE #temp_item SET flag = 'Y' WHERE item_number = @v_vchItemNumber
            GOTO LOOPITEMAGAIN
        END

    DROP TABLE #temp_item

    /* ============================================================
       最终输出
       ============================================================ */
    IF @in_Report <> 'S'  /* 明细报表 */
    BEGIN
        SELECT
            wh_id,
            CONVERT(CHAR(10), dispatch_date, 111) + ' '
                + CONVERT(CHAR(8), dispatch_time, 108)  AS dispatch_date,
            item_number,
            trip_number,
            ldm_status,
            trip_needed,
            trip_picked,
            available_sto,
            available_staged,
            Stage_Qty,
            NOMFG_qty                                   AS No_Received_Qty,
            yard_qty,
            new_asn_qty,
            CASE
                WHEN CONVERT(CHAR(10), earliest_date, 111) = '1900/01/01' THEN ''
                ELSE CONVERT(CHAR(10), earliest_date, 111)
            END                                          AS earliest_date,
            CASE
                WHEN available_sto - (trip_needed - trip_picked) < 0
                THEN available_sto - (trip_needed - trip_picked)
                ELSE 0
            END                                          AS negative_qty,
            negative_tot,
            Mfg_schQty                                   AS MFG_Schedule_Qty,
            overflow_qty                                 AS Overflow_Qty,
            offsite_qty,
            carrier,
            In_transit,
            prod_qty,
            location_id
        FROM #temp_demand
    END
    ELSE  /* 汇总报表 */
    BEGIN
        CREATE TABLE #temp_summary (
            wh_id            VARCHAR(10),
            item_number      VARCHAR(30),
            trip_count       INT,
            deficiency       INT,
            min_disp_date    VARCHAR(30),
            max_disp_date    VARCHAR(30),
            equipment        VARCHAR(200),
            door             VARCHAR(100),
            door_qty         VARCHAR(100),
            available_staged INT,
            yard_qty         INT,
            overflow_qty     INT,
            offsite_qty      INT,
            In_transit       INT,
            prod_qty         INT,
            location_id      VARCHAR(50)
        )

        INSERT INTO #temp_summary (
            wh_id, item_number, trip_count, deficiency,
            min_disp_date, max_disp_date,
            available_staged, yard_qty, overflow_qty, offsite_qty,
            In_transit, prod_qty, location_id
        )
        SELECT
            m.wh_id, m.item_number,
            (
                SELECT COUNT(DISTINCT trip_number)
                FROM #temp_demand d
                WHERE d.negative_tot < 0 AND d.item_number = m.item_number
            ),
            MIN(m.negative_tot),
            MIN(CONVERT(CHAR(10), m.dispatch_date, 111) + ' ' + CONVERT(CHAR(8), m.dispatch_time, 108)),
            MAX(CONVERT(CHAR(10), m.dispatch_date, 111) + ' ' + CONVERT(CHAR(8), m.dispatch_time, 108)),
            m.available_staged, m.yard_qty, m.overflow_qty, m.offsite_qty,
            m.In_transit, m.prod_qty, m.location_id
        FROM #temp_demand m
        GROUP BY
            m.wh_id, m.item_number, m.available_staged, m.yard_qty,
            m.overflow_qty, m.offsite_qty, m.In_transit, m.prod_qty, m.location_id

        SELECT
            asn.equipment_id,
            yoc.location_name,
            asd.item_number,
            SUM(asd.quantity_shipped - asd.quantity_received) AS open_qty
        INTO #temp_trailer
        FROM t_asn asn (NOLOCK)
        JOIN t_asn_detail asd (NOLOCK) ON asn.asn_id = asd.asn_id
        JOIN t_trailer_asn tra (NOLOCK) ON asn.asn_id = tra.asn_id
        JOIN t_trailer trl (NOLOCK) ON tra.trailer_id = trl.trailer_id
        JOIN t_ya_location yoc (NOLOCK) ON yoc.location_id = trl.location_id
        JOIN (SELECT DISTINCT item_number FROM #temp_demand) d ON asd.item_number = d.item_number
        WHERE asn.status = 'CHECKED IN' AND trl.status = 'IN DOOR'
        GROUP BY asn.equipment_id, yoc.location_name, asd.item_number
        HAVING SUM(asd.quantity_shipped - asd.quantity_received) > 0

        IF (SELECT COUNT(1) FROM #temp_trailer) > 0
        BEGIN
            SELECT
                m.item_number,
                (SELECT equipment_id + ';' FROM #temp_trailer d WHERE d.item_number = m.item_number FOR XML PATH('')) AS equipment,
                (SELECT location_name + ';' FROM #temp_trailer d WHERE d.item_number = m.item_number FOR XML PATH('')) AS location,
                (SELECT CAST(open_qty AS VARCHAR(4)) + ';' FROM #temp_trailer d WHERE d.item_number = m.item_number FOR XML PATH('')) AS qty
            INTO #update_trl
            FROM #temp_summary m

            UPDATE #temp_summary
            SET equipment = LEFT(d.equipment, LEN(d.equipment) - 1),
                door      = LEFT(d.location,  LEN(d.location)  - 1),
                door_qty  = LEFT(d.qty,        LEN(d.qty)       - 1)
            FROM #update_trl d
            JOIN #temp_summary m ON d.item_number = m.item_number

            DROP TABLE #update_trl
        END

        SELECT * FROM #temp_summary ORDER BY trip_count DESC

        DROP TABLE #temp_trailer
        DROP TABLE #temp_summary
    END

    DROP TABLE #temp_total
    DROP TABLE #temp_demand
END