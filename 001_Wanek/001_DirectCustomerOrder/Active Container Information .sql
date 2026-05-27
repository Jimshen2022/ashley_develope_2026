-- 设置参数值
DECLARE @in_vchWhID      NVARCHAR(10) = '35,33,31,34,36',
        @in_vch_Load_ID  NVARCHAR(30) = '335',
        @in_equipment_id NVARCHAR(20) = ''

-- 第一个临时表：活动容器信息
;WITH t_active_container AS (
    SELECT 
        ldm.load_id,
        ldm.equipment_id,
        pkd.item_count AS item_count,
        CASE
            WHEN EXISTS (
                SELECT TOP 1 1
                FROM t_order tor (NOLOCK) 
                JOIN t_order_c_number tocn (NOLOCK) 
                    ON tocn.order_number = tor.order_number 
                    AND tor.wh_id = tocn.wh_id
                JOIN t_pick_detail pkd (NOLOCK) 
                    ON tor.wh_id = pkd.wh_id
                    AND tor.order_number = pkd.order_number
                    AND pkd.load_id = ldm.load_id
                    AND pkd.wh_id = ldm.wh_id
                JOIN t_special_shipping_instructions tssi (NOLOCK) 
                    ON tssi.customer_number = tocn.customer_number
            ) THEN 'Y'

            WHEN EXISTS (
                SELECT TOP 1 1
                FROM t_special_shipping_instructions tssi (NOLOCK)
                JOIN t_order_c_number tocn (NOLOCK) 
                    ON tssi.customer_number = tocn.customer_number
                JOIN t_order tor (NOLOCK) 
                    ON tocn.order_number = tor.order_number 
                    AND tor.wh_id = tocn.wh_id
                    AND ldm.transfer_wh_id = tor.load_id
                    AND ldm.transfer_wh_id IN ('CNW', 'C')
            ) THEN 'Y'

            ELSE ''
        END AS special_ship_inst,

        pkd.loaded_qty,
        pkd.loaded_cubes,
        pkd.loaded_weight,
        ldm.door_loc,
        ldm.transfer_wh_id,
        CONVERT(VARCHAR(10), ldm.trip_create_date, 23) AS create_date,
        ldm.wh_id,
        trl.location_id,
        ldm.status

    FROM t_load_master ldm (NOLOCK)
    JOIN t_trailer trl (NOLOCK) 
        ON ldm.equipment_id = trl.equipment_id
    JOIN t_ya_location yad (NOLOCK) 
        ON trl.location_id = yad.location_id 
        AND ldm.door_loc = yad.location_name
    LEFT JOIN (
        SELECT 
            load_id,
            pkd.wh_id,
            COUNT(DISTINCT pkd.item_number) AS item_count,
            SUM(loaded_quantity) AS loaded_qty,
            CAST(SUM(pkd.loaded_quantity * ISNULL(NULLIF(itm.nested_volume, 0), itm.unit_volume)) AS DECIMAL(7,2)) AS loaded_cubes,
            CAST(SUM(pkd.loaded_quantity * ISNULL(itu.uom_weight, 0)) AS DECIMAL(7,2)) AS loaded_weight
        FROM t_pick_detail pkd (NOLOCK)
        JOIN t_item_master itm (NOLOCK) 
            ON pkd.wh_id = itm.wh_id 
            AND pkd.item_number = itm.item_number
        JOIN t_item_uom itu (NOLOCK)
            ON pkd.item_number = itu.item_number 
            AND pkd.wh_id = itu.wh_id 
            AND itm.uom = itu.uom
        WHERE pkd.status = 'LOADED'
        GROUP BY pkd.wh_id, load_id
    ) pkd 
        ON pkd.load_id = ldm.load_id 
        AND pkd.wh_id = ldm.wh_id
    LEFT JOIN (
        SELECT text AS TRSFWHID,
               description + '(' + text + ')' AS TRSFWHName, 
               wh_id 
        FROM t_lookup (NOLOCK) 
        WHERE source = 't_load_master'
              AND lookup_type = 'TRSFWHID'
              AND locale_id = '1033' 
    ) TRSFWH
        ON ldm.wh_id = TRSFWH.wh_id 
        AND ldm.transfer_wh_id = TRSFWH.TRSFWHID 
    WHERE ldm.load_type = 'H'
          AND ldm.status <> 'S'
          AND trl.status <> 'HISTORY'
          AND ldm.wh_id in (SELECT value FROM STRING_SPLIT(@in_vchWhID, ','))   
          AND ldm.transfer_wh_id LIKE @in_vch_Load_ID
          AND ldm.equipment_id LIKE @in_equipment_id + '%'
),
-- 第二个临时表：活动订单信息
t_active_order AS (
    SELECT 
        equipment_id,
        MAX(CASE WHEN Week = '1' THEN order_number END) AS Week_1,
        MAX(CASE WHEN Week = '2' THEN order_number END) AS Week_2
    FROM (
        SELECT 
            ldm.equipment_id,
            orm.order_number,
            CAST(
                CASE 
                    WHEN DATEDIFF(WEEK, GETDATE(), orm.arrive_date) = 0 THEN '1'
                    WHEN DATEDIFF(WEEK, GETDATE(), orm.arrive_date) = 1 THEN '2'
                    ELSE ''
                END AS CHAR(4)
            ) AS Week
        FROM t_hotloading_stage (NOLOCK) hot
        JOIN t_load_master (NOLOCK) ldm 
            ON hot.wh_id = ldm.wh_id 
            AND hot.load_id = ldm.load_id
        JOIN t_order (NOLOCK) orm 
            ON ldm.wh_id = orm.wh_id 
            AND hot.order_number = orm.order_number
        WHERE ldm.status <> 'S'
              AND ldm.load_type = 'H'
              AND hot.stage_loc <> ''
              AND orm.arrive_date >= DATEADD(DAY, -7, GETDATE())
    ) AS raw
    GROUP BY equipment_id
)
-- 最终查询结果
SELECT DISTINCT
    CASE
        WHEN special_ship_inst = 'Y' 
             AND hstg.load_id = tmp.load_id 
             AND tmp.transfer_wh_id = 'C' 
             AND orc.customer_number IN (
                SELECT ssi.customer_number 
                FROM t_special_shipping_instructions ssi (NOLOCK)
             ) THEN '{{BGCOLOR=#FFFF33}}'

        WHEN special_ship_inst = 'Y' 
             AND tmp.transfer_wh_id = 'CNW' 
             AND orc.customer_number IN (
                SELECT ssi.customer_number 
                FROM t_special_shipping_instructions ssi (NOLOCK)
             ) THEN '{{BGCOLOR=#FFFF33}}'

        WHEN special_ship_inst = 'Y' 
             AND tmp.transfer_wh_id NOT IN ('CNW', 'C') 
             THEN '{{BGCOLOR=#FFFF33}}'
    END AS color,

    tmp.load_id,
    tmp.equipment_id,

    CASE
        WHEN hstg.load_id = tmp.load_id 
             AND tmp.transfer_wh_id = 'C' 
             AND orc.customer_number IN (
                SELECT ssi.customer_number 
                FROM t_special_shipping_instructions ssi (NOLOCK)
             ) THEN special_ship_inst

        WHEN tmp.transfer_wh_id = 'CNW' 
             AND orc.customer_number IN (
                SELECT ssi.customer_number 
                FROM t_special_shipping_instructions ssi (NOLOCK)
             ) THEN special_ship_inst

        WHEN tmp.transfer_wh_id NOT IN ('C', 'CNW') 
             THEN special_ship_inst

        ELSE ''
    END AS special_ship_inst,

    loaded_qty,
    item_count AS Loaded_Item,
    loaded_cubes,
    loaded_weight,
    tmp.door_loc,
    tmp.transfer_wh_id,
    create_date,
    tmp.wh_id,
    location_id,
    Week_1,
    Week_2

FROM t_active_container tmp
LEFT JOIN t_hotloading_stage hstg (NOLOCK)
    ON hstg.load_id = tmp.load_id 
    AND hstg.wh_id = tmp.wh_id
LEFT JOIN t_order_c_number orc (NOLOCK)
    ON orc.wh_id = hstg.wh_id 
    AND orc.order_number = hstg.order_number
LEFT JOIN t_active_order aor
    ON aor.equipment_id = tmp.equipment_id