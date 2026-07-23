SELECT [control_type]
      ,[description]
      ,[wh_id]
      ,[f1]
  FROM [Distribution_Warehouse_Wholesale].[t_controlEqu]
  where [control_type] IN ('DYN_P_UPH_PLT_LIMIT','DYN_PICK_CUBE_LIMIT')
  and [wh_id] IN ('335','35')