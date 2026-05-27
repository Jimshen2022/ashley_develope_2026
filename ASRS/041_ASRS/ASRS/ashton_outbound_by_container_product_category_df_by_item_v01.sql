WITH trailer_type AS (
    select t.carrier_trailer_number, t.trailer_type_id, t1.trailer_type_name, max(LoadDate) as max_LoadDate
    from Distribution_Warehouse_Wholesale.Trailer as t
    join (select wh_id, trailer_type_id, trailer_type_name from Distribution_Warehouse_Wholesale.TrailerType where wh_id = '335' group by wh_id, trailer_type_id, trailer_type_name ) as t1 on t.trailer_type_id = t1.trailer_type_id
    where t.wh_id = '335' 
    group by t.carrier_trailer_number, t.trailer_type_id, t1.trailer_type_name
),

itm AS (
        SELECT
            a.item_number
            ,a.description
            ,a.uom
            ,a.inventory_type
            ,a.commodity_code
            ,a.wh_id
            ,a.unit_weight
            ,a.unit_volume
            ,a.length AS [length(inch)]
            ,a.width AS [width(inch)]
            ,a.height AS [height(inch)]
            ,a.class_id
            ,a.pick_put_id
            ,b.units_per_layer
            ,b.layers_per_uom
            ,b.max_in_layer
            ,b.std_hand_qty
            ,a.pallet_id
            ,CASE
                WHEN a.commodity_code NOT LIKE 'Z%' THEN 'RP'
                WHEN a.pick_put_id = 'UPH' THEN 'UPH'
                WHEN a.pick_put_id = 'PALLT' THEN 'CG'
                ELSE 'CHECK'
            END AS product
        FROM (
            SELECT *
            FROM (
                SELECT *,
                       ROW_NUMBER() OVER (PARTITION BY item_number ORDER BY item_master_id DESC) AS rn
                FROM Distribution_Warehouse_Wholesale.t_item_master
                WHERE wh_id = '335'
            ) ranked
            WHERE rn = 1
        ) AS a
        LEFT JOIN (
            SELECT 
                item_number, 
                class_id, 
                pick_put_id, 
                units_per_layer, 
                layers_per_uom, 
                max_in_layer, 
                CASE 
                    WHEN pick_put_id = 'SCOOP' THEN std_hand_qty
                    WHEN pick_put_id = 'PALLT' THEN units_per_layer * layers_per_uom * max_in_layer
                    ELSE std_hand_qty
                END AS std_hand_qty,
                pallet_id
            FROM (
                SELECT *,
                       ROW_NUMBER() OVER (
                           PARTITION BY item_number 
                           ORDER BY 
                               CASE 
                                   WHEN pick_put_id = 'SCOOP' THEN 1
                                   WHEN pick_put_id = 'PALLT' THEN 2
                                   ELSE 3
                               END
                       ) AS rn
                FROM Distribution_Warehouse_Wholesale.t_item_uom 
                WHERE pick_put_id IN ('SCOOP', 'PALLT') AND wh_id = '335'
            ) ranked_uom
            WHERE rn = 1
        ) AS b ON b.item_number = a.item_number
),
trx_raw AS (
    SELECT
        t1.start_tran_date,
        t1.start_tran_time,
        
        -- 【新增列1：Shift_Date】
        -- 规则：00:00 - 06:59 算前一天，其余算当天
        CASE 
            WHEN CAST(t1.start_tran_time AS TIME) < '07:00:00' THEN DATEADD(DAY, -1, t1.start_tran_date)
            ELSE t1.start_tran_date 
        END AS Shift_Date,

        -- 【新增列2：Shift】
        -- 规则：07:00 - 20:00 为 D，其余为 N
        CASE 
            WHEN CAST(t1.start_tran_time AS TIME) >= '07:00:00' AND CAST(t1.start_tran_time AS TIME) <= '20:00:00' THEN 'D'
            ELSE 'N' 
        END AS Shift,

        DATEPART(YYYY, t1.start_tran_date) * 100 + FORMAT(DATEPART(ISO_WEEK, t1.start_tran_date), '00') AS YearWeek,
        DATEPART(YYYY, t1.start_tran_date) * 100 + DATEPART(MONTH, t1.start_tran_date) AS YearMonth,
        t1.item_number,
        i1.commodity_code,
        i1.product,
        t1.control_number_2, 
        
        'Outbound' AS Direction,

        -- Outbound 逻辑集装箱号
        CONCAT(LEFT(t1.control_number_2, CHARINDEX('-', t1.control_number_2 + '-') - 1)*1, '_', t1.routing_code) AS Container_nbr,
        
        -- Outbound 物理拖车号
        t1.routing_code AS Container_nbr_original,
        
        t1.tran_qty AS Adjusted_Qty,
        t1.tran_qty * i1.unit_volume AS Adjusted_Cubes,
        t1.tran_qty * i1.unit_weight AS Adjusted_Weight

    FROM (
        SELECT t.start_tran_date,t.start_tran_time, t.item_number, t.tran_type, t.description, t.control_number, t.control_number_2, t.hu_id_2, t.routing_code, sum(t.tran_qty) as tran_qty
        FROM Distribution_Warehouse_Wholesale.TranLog AS t 
        WHERE t.wh_id IN ('335') 
          -- 【修改时间】：从去年10月1日开始 (这里设为 2024-10-01)
          AND t.start_tran_date >= '2025-10-01'
          AND t.tran_type IN ('347') -- 只保留 Outbound
        GROUP BY t.start_tran_date,t.start_tran_time, t.item_number, t.tran_type, t.description, t.control_number, t.control_number_2, t.hu_id_2, t.routing_code
    ) AS t1
    LEFT JOIN itm AS i1 ON t1.item_number = i1.item_number
),

/* 辅助数据准备 */
Container_Meta_Data AS (
    SELECT 
        Container_nbr,
        CASE WHEN COUNT(DISTINCT product) = 1 THEN MAX(product) ELSE 'Mixed' END AS Container_Type
    FROM trx_raw
    GROUP BY Container_nbr
),

Container_CN2_Agg AS (
    SELECT 
        Container_nbr,
        STRING_AGG(Cleaned_CN2, '_ ') WITHIN GROUP (ORDER BY Cleaned_CN2) AS Unique_CN2_List
    FROM (
        SELECT DISTINCT 
            Container_nbr, 
            SUBSTRING(
                LEFT(control_number_2, 7), 
                PATINDEX('%[^0]%', LEFT(control_number_2, 7) + ' '), 
                LEN(LEFT(control_number_2, 7))
            ) AS Cleaned_CN2
        FROM trx_raw
        WHERE control_number_2 IS NOT NULL 
          AND control_number_2 <> ''
    ) AS distinct_sub
    GROUP BY Container_nbr
)

/* ==================================================================================
   最终查询输出
   ==================================================================================
*/
SELECT 
    t1.start_tran_date,
    -- 【输出新增的列】
    t1.Shift_Date,
    t1.Shift,    
    t1.YearMonth,
    DATEADD(DAY, 7 - DATEPART(WEEKDAY, t1.start_tran_date), t1.start_tran_date) AS saturday_date,
    t1.Direction,
    t1.Container_nbr,
    t1.Container_nbr_original,    
    cn2.Unique_CN2_List,
    cm.Container_Type,
    t1.item_number,
    t1.commodity_code,
    t1.product,
    
    /* Outbound 计数逻辑 */
    CASE 
        WHEN ROW_NUMBER() OVER(
            PARTITION BY t1.Container_nbr 
            ORDER BY t1.item_number, t1.start_tran_date
        ) = 1 THEN 1.0
        ELSE 0 
    END AS Container_Counted,

    CASE 
        WHEN ROW_NUMBER() OVER(
            PARTITION BY t1.Container_nbr, t1.item_number 
            ORDER BY t1.start_tran_date
        ) = 1 THEN 1 
        ELSE 0 
    END AS SKU_Count,

    t1.Adjusted_Qty AS Qty,
    CAST(t1.Adjusted_Cubes AS INT) AS Cubes,
    CAST(t1.Adjusted_Weight AS DECIMAL(12,2)) AS Weight,
    i.unit_weight AS [unit_weight(lbs)],
    i.unit_volume AS [unit_volume(cubic_foot)],
    i.[length(inch)],
    i.[width(inch)],
    i.[height(inch)],
    i.class_id,
    i.pick_put_id,
    i.units_per_layer,
    i.layers_per_uom,
    i.max_in_layer,
    i.std_hand_qty,
    i.pallet_id,
    
    -- 【新增列：pallet_type】
    CASE 
        WHEN i.class_id = 'FLOOR' THEN 'Bulk'
        WHEN i.pallet_id IN ('1', '4') THEN '5X5'
        WHEN i.pallet_id IN ('3', '5' ,'18') THEN '5X8'
        WHEN i.pick_put_id = 'UPH' THEN 'no_skid'
        WHEN t1.product = 'RP' THEN 'no_skid'
        ELSE NULL
    END AS pallet_type,
    
    -- 【新增列：Pallet_count】
    CASE 
        WHEN i.class_id = 'FLOOR' THEN 0
        WHEN i.class_id LIKE 'UPH%' THEN 0
        WHEN i.class_id like 'RUGS%' THEN 0
        WHEN i.std_hand_qty IS NULL OR i.std_hand_qty = 0 THEN NULL
        ELSE CAST(t1.Adjusted_Qty / i.std_hand_qty AS DECIMAL(18,4))
    END AS Pallet_count,

    -- 【新增列：Picking_Type】
    CASE 
        WHEN i.std_hand_qty IS NULL OR i.std_hand_qty = 0 THEN NULL
        WHEN t1.Adjusted_Qty >= i.std_hand_qty AND (t1.Adjusted_Qty / i.std_hand_qty) >= 1 THEN 'SCOOP_picking'
        ELSE 'partial_picking'
    END AS Picking_Type
    
FROM trx_raw AS t1
LEFT JOIN Container_Meta_Data AS cm ON t1.Container_nbr = cm.Container_nbr
LEFT JOIN Container_CN2_Agg AS cn2 ON t1.Container_nbr = cn2.Container_nbr
LEFT JOIN itm as i on i.item_number = t1.item_number
--WHERE t1.product = 'CG'
ORDER BY t1.start_tran_date, t1.Direction, t1.Container_nbr, t1.item_number;