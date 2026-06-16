/*
SELECT TOP 1000 *  FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME LIKE '%fwd%'
select  * from t_fwd_pick where location_id like 'A3%'
*/
WITH fwd as (
select  * from t_fwd_pick where location_id like 'A3%'
),
-- 添加窗口函数来计算每个location的hold状态统计
location_stats as (
    SELECT m.wh_id,
             a.serial_number,
             a.item_number,
             CASE
               WHEN a.serial_no_status = 'H' THEN 'Hold'
               WHEN ISNULL(a.serial_no_status, 'R') = 'R' THEN 'In Warehouse'
               WHEN a.serial_no_status = 'L' THEN 'Loaded'
               WHEN a.serial_no_status = 'S' THEN 'Shipped'
               WHEN a.serial_no_status = 'O' THEN 'Orphaned'
               ELSE NULL
             END AS serial_status,
             CASE
               WHEN m.serial_no_status = 'H' THEN 'Hold'
               WHEN ISNULL(m.serial_no_status, 'R') = 'R' THEN 'In Warehouse'
               WHEN m.serial_no_status = 'L' THEN 'Loaded'
               WHEN m.serial_no_status = 'S' THEN 'Shipped'
               WHEN m.serial_no_status = 'O' THEN 'Orphaned'
               ELSE NULL
             END AS master_status,
             CASE
               WHEN ISNULL(a.po_number, '') <> ISNULL(m.po_number, '') THEN ISNULL(a.po_number, '')
               ELSE ''
             END AS po_number,
             m.po_number   AS master_po_number,
             a.location_id AS location,
             a.hu_id       AS LP,
             a.received_date,
             a.trip_number,
             CASE
               WHEN CONVERT(VARCHAR(23), a.ship_date, 121) = '1900-01-01 00:00:00.000' THEN ''
              ELSE CONVERT(VARCHAR(23), a.ship_date, 121)
             END AS ship_date,
             m.born_on_date,
             CASE 
                 WHEN a.location_id = f.location_id THEN 'Y' 
                 ELSE 'N' 
             END as fwd_location,
             -- 计算每个location中Hold状态的数量
             COUNT(CASE WHEN a.serial_no_status = 'H' THEN 1 END) OVER (PARTITION BY a.location_id) as hold_count_in_location,
             -- 计算每个location中的总记录数
             COUNT(*) OVER (PARTITION BY a.location_id) as total_count_in_location
      FROM   dbo.t_serial_active a (nolock)
             JOIN dbo.t_item_master itm (nolock)
				ON itm.item_number = a.item_number
                AND itm.wh_id = a.wh_id
                AND ( itm.commodity_code LIKE 'Z%'
					OR itm.commodity_code = 'TA' )
             LEFT OUTER JOIN dbo.t_serial_master m (nolock)
                ON a.serial_number = m.serial_number
                AND a.item_number = m.item_number
                AND a.wh_id = m.wh_id
            LEFT JOIN fwd f
                ON a.item_number = f.item_number
    WHERE a.serial_no_status not in ('S','O','L')
        -- 添加条件：只包含那些location_id中至少有一个Hold状态的记录
        and EXISTS (
            SELECT 1 
            FROM dbo.t_serial_active a2 (nolock)
            JOIN dbo.t_item_master itm2 (nolock)
                ON itm2.item_number = a2.item_number
                AND itm2.wh_id = a2.wh_id
                AND ( itm2.commodity_code LIKE 'Z%'
                    OR itm2.commodity_code = 'TA' )
            WHERE a2.location_id = a.location_id
                and a2.serial_no_status = 'H'
        )
),
detailed_stats as (
    SELECT wh_id,
           serial_number,
           item_number,
           serial_status,
           master_status,
           po_number,
           master_po_number,
           location,
           LP,
           received_date,
           trip_number,
           ship_date,
           born_on_date,
           fwd_location,
           -- 添加新列：位置持有状态
           CASE 
               WHEN hold_count_in_location = total_count_in_location THEN 'SN in location all held'
               WHEN hold_count_in_location > 0 AND hold_count_in_location < total_count_in_location THEN 'SN in location partial hold'
               ELSE 'SN in location no hold'
           END AS location_hold_status
    FROM location_stats
)
-- 最终结果统计
SELECT 
    location_hold_status,
    location,
    fwd_location,
    -- Hold状态的数量
    COUNT(CASE WHEN serial_status = 'Hold' THEN 1 END) AS serial_status_Hold,
    -- In Warehouse状态的数量
    COUNT(CASE WHEN serial_status = 'In Warehouse' THEN 1 END) AS serial_status_In_Warehouse,
    -- Hold状态的serial_number拼接（使用子查询避免冲突）
    STUFF((
        SELECT ', ' + CAST(serial_number AS VARCHAR(MAX))
        FROM detailed_stats ds2
        WHERE ds2.location_hold_status = ds1.location_hold_status 
          AND ds2.location = ds1.location 
          AND ds2.fwd_location = ds1.fwd_location
          AND ds2.serial_status = 'Hold'
        ORDER BY ds2.serial_number
        FOR XML PATH('')
    ), 1, 2, '') AS Hold_Serial_Numbers,
    -- In Warehouse状态的serial_number拼接
    STUFF((
        SELECT ', ' + CAST(serial_number AS VARCHAR(MAX))
        FROM detailed_stats ds3
        WHERE ds3.location_hold_status = ds1.location_hold_status 
          AND ds3.location = ds1.location 
          AND ds3.fwd_location = ds1.fwd_location
          AND ds3.serial_status = 'In Warehouse'
        ORDER BY ds3.serial_number
        FOR XML PATH('')
    ), 1, 2, '') AS InWarehouse_Serial_Numbers
FROM detailed_stats ds1
GROUP BY 
    location_hold_status,
    location,
    fwd_location
ORDER BY 
    location_hold_status,
    location,
    fwd_location;