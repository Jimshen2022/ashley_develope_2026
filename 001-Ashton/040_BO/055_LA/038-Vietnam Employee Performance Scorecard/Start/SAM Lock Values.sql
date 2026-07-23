SELECT [control_type]
      ,[description]
      ,[wh_id]
      ,[c1]
  FROM [Distribution_Warehouse_Wholesale].[t_controlEqu]
  where [wh_id] in ('335','35')
  and [control_type] in ('LA_OVER_SAM_BREAK','LA_OVER_SAM_LOADING','LA_OVER_SAM_LUNCH','LA_OVER_SAM_PICKING')