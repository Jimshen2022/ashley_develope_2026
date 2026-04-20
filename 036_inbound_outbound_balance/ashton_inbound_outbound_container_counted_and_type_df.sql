/* ==================================================================================
   SQL 查询脚本：仓库集装箱分析 (V9 - 动态体积折算版)

   修改记录：
   1. Container_Counted 计数规则更新 (针对 Inbound):
      - 如果柜总体积 >= 1191: 计为 1。
      - 如果柜总体积 < 1191:  计为 (总体积 / 2650)，结果保留 1 位小数。
   2. Outbound 保持不变 (计 1)。
   =================================================================================
*/

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
        ,a.class_id
        ,a.unit_weight
        ,a.unit_volume
        ,a.pick_put_id
        ,CASE
            WHEN a.commodity_code NOT LIKE 'Z%' OR a.inventory_type = 'RM' THEN 'RP'
            WHEN a.pick_put_id = 'UPH' THEN 'UPH'
            WHEN a.pick_put_id = 'PALLT' THEN 'CG'
            ELSE 'CHECK'
        END AS product
    FROM Distribution_Warehouse_Wholesale.t_item_master AS a
    WHERE a.wh_id = '335'
),

trx_raw AS (
    SELECT
        t1.start_tran_date,
        t1.start_tran_time,
        DATEPART(YYYY, t1.start_tran_date) * 100 + FORMAT(DATEPART(ISO_WEEK, t1.start_tran_date), '00') AS YearWeek,
        DATEPART(YYYY, t1.start_tran_date) * 100 + DATEPART(MONTH, t1.start_tran_date) AS YearMonth,
        t1.item_number,
        i1.commodity_code,
        i1.product,
        t1.control_number_2,
        CASE
            WHEN t1.tran_type IN ('151', '951', '183') THEN 'Inbound'
            ELSE 'Outbound'
        END AS Direction,

        -- 逻辑集装箱号
        CASE
            WHEN t1.tran_type IN ('151', '183', '951') THEN CONCAT(t1.control_number,'_', t1.hu_id_2)
            WHEN t1.tran_type IN ('347') THEN CONCAT(LEFT(t1.control_number_2, CHARINDEX('-', t1.control_number_2 + '-') - 1)*1, '_', t1.routing_code)
            ELSE 'CHECK'
        END AS Container_nbr,

        -- 物理拖车号
        CASE
            WHEN t1.tran_type IN ('151', '183', '951') THEN t1.control_number
            WHEN t1.tran_type IN ('347') THEN t1.routing_code
            ELSE 'CHECK'
        END AS Container_nbr_original,

        CASE WHEN t1.tran_type = '951' THEN -t1.tran_qty ELSE t1.tran_qty END AS Adjusted_Qty,
        CASE WHEN t1.tran_type = '951' THEN -t1.tran_qty * i1.unit_volume ELSE t1.tran_qty * i1.unit_volume END AS Adjusted_Cubes,
        CASE WHEN t1.tran_type = '951' THEN -t1.tran_qty * i1.unit_weight ELSE t1.tran_qty * i1.unit_weight END AS Adjusted_Weight

    FROM (
        SELECT t.start_tran_date,t.start_tran_time, t.item_number, t.tran_type, t.description, t.control_number, t.control_number_2, t.hu_id_2, t.routing_code, sum(t.tran_qty) as tran_qty
        FROM Distribution_Warehouse_Wholesale.TranLog AS t
        WHERE t.wh_id IN ('335')
          AND t.start_tran_date >= '2025-01-01'
          AND t.tran_type IN ('347', '151', '183', '951')
        GROUP BY t.start_tran_date,t.start_tran_time, t.item_number, t.tran_type, t.description, t.control_number, t.control_number_2, t.hu_id_2, t.routing_code
    ) AS t1
    LEFT JOIN itm AS i1 ON t1.item_number = i1.item_number
),

/* 辅助数据准备 (Meta Data & Agg) */
Container_Meta_Data AS (
    SELECT
        Container_nbr,
        CASE WHEN COUNT(DISTINCT product) = 1 THEN MAX(product) ELSE 'Mixed' END AS Container_Type
    FROM trx_raw
    GROUP BY Container_nbr
),
-- 聚合每个 Container_nbr 对应的唯一 control_number_2 列表 (po与trip number）
Container_CN2_Agg AS (
    SELECT
        Container_nbr,
        STRING_AGG(Cleaned_CN2, '_ ') WITHIN GROUP (ORDER BY Cleaned_CN2) AS Unique_CN2_List
    FROM (
        SELECT DISTINCT
            Container_nbr,
            Direction,
            CASE
                WHEN Direction = 'Inbound' THEN control_number_2
                WHEN Direction = 'Outbound' THEN
                    SUBSTRING(
                        LEFT(control_number_2, 7),
                        PATINDEX('%[^0]%', LEFT(control_number_2, 7) + ' '),
                        LEN(LEFT(control_number_2, 7))
                    )
                ELSE ''
            END AS Cleaned_CN2
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

    /* 【关键更新：Container_Counted 计数规则】 */
    CASE
        WHEN ROW_NUMBER() OVER(
            PARTITION BY t1.Container_nbr
            ORDER BY t1.item_number, t1.start_tran_date
        ) = 1 THEN
            CASE
                -- 规则1: Outbound 计 1
                WHEN t1.Direction = 'Outbound' THEN 1.0

                -- 规则2: Inbound 逻辑更新
                WHEN t1.Direction = 'Inbound' THEN
                    CASE
                        -- 体积 = 0，计为 0
                        WHEN SUM(t1.Adjusted_Cubes) OVER(PARTITION BY t1.Container_nbr) = 0 THEN 0
                        -- 体积 >= 500，计为 1
                        WHEN SUM(t1.Adjusted_Cubes) OVER(PARTITION BY t1.Container_nbr) >= 500 THEN 1

                        -- 体积 < 500，用实际体积 / 2650，并保留1位小数
                        ELSE CAST(
                                SUM(t1.Adjusted_Cubes) OVER(PARTITION BY t1.Container_nbr) / 2650.0
                             AS DECIMAL(12, 1))
                    END

                ELSE 0
            END
        ELSE 0
    END AS Container_Counted,

    /* SKU_Count 计数 */
    CASE
        WHEN ROW_NUMBER() OVER(
            PARTITION BY t1.Container_nbr, t1.item_number
            ORDER BY t1.start_tran_date
        ) = 1 THEN 1
        ELSE 0
    END AS SKU_Count,

    t1.Adjusted_Qty AS Qty,
    CAST(t1.Adjusted_Cubes AS INT) AS Cubes,
    CAST(t1.Adjusted_Weight AS DECIMAL(12,2)) AS Weight

FROM trx_raw AS t1
LEFT JOIN Container_Meta_Data AS cm ON t1.Container_nbr = cm.Container_nbr
LEFT JOIN Container_CN2_Agg AS cn2 ON t1.Container_nbr = cn2.Container_nbr

ORDER BY t1.start_tran_date, t1.Direction, t1.Container_nbr, t1.item_number;