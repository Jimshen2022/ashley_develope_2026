WITH im AS (
    SELECT DISTINCT
        m.item_number,
        m.description,
        m.wh_id,
        m.commodity_code,
        m.class_id,
        m.pick_put_id
    FROM Distribution_Warehouse_Wholesale.t_item_master AS m
    WHERE m.wh_id = '335'
),
i AS (
    SELECT
        t0.ITNBR,
        t0.STID,
        t0.ITCLS,
        t0.B2Z95S,
        t0.ITDSC,
        im.pick_put_id,
        im.commodity_code,
        im.class_id
    FROM MasterData_ItemMaster_AFI.ITMRVA AS t0
    LEFT JOIN im ON im.item_number = t0.ITNBR
    WHERE t0.STID = '335'
)
    SELECT  *, t3.tran_qty * i.B2Z95S as BO_Cubes, t3.tran_qty as bo_qty
    FROM [Distribution_Warehouse_Wholesale].[TranLog] AS t3
    LEFT JOIN i ON i.ITNBR = t3.item_number
    WHERE t3.wh_id = '335' 
        AND t3.tran_type = '340' 
        AND t3.start_tran_date > DATEADD(DAY, -60, GETDATE())


-- SELECT [tran_type]
--       ,[description]
--       ,[start_tran_date]
--       ,[start_tran_time]
--       ,[end_tran_date]
--       ,[end_tran_time]
--       ,[employee_id]
--       ,[control_number]
--       ,[line_number]
--       ,[control_number_2]
--       ,[outside_id]
--       ,[wh_id]
--       ,[location_id]
--       ,[hu_id]
--       ,[num_items]
--       ,[item_number]
--       ,[lot_number]
--       ,[uom]
--       ,[tran_qty]
--       ,[wh_id_2]
--       ,[location_id_2]
--       ,[verify_status]
--       ,[employee_id_2]
--       ,[routing_code]
--       ,[hu_id_2]
--       ,[return_disposition]
-- 	  ,case when [return_disposition] is null then [location_id_2] else [return_disposition] end as [return_dispostion2]
--       ,[elapsed_time]
--       ,[log_id]
--       ,[group_id]
--       ,[afi_package_rate]
--       ,[Wh_id_3]

--   FROM [PowerBI_Distribution].[TranLog] a
--   where tran_type='340' 
--   and start_tran_date > DATEADD(DAY, -180, GETDATE())
--   and a.[wh_id] in ('335')
--   ORDER BY
--        [start_tran_date]
--       ,[start_tran_time]