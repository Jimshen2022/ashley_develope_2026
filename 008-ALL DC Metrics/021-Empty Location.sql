Select
a.[DC]
,a.[pick area]
,count(a.[location]) as Total_locations
From
(
SELECT Distinct 
      [location_id] as [Location]
	  ,[wh_id] as [DC]
      ,[status] as [Status]
      ,[capacity_uom] as [Capacity UOM]
      ,[TypeDescription] as [Type]
      ,[cycle_count_class] as [Cycle Count Class]
      ,[last_count_date] as [Last Count Date]
      ,[last_physical_date] as [Last Physical Date]
      ,[length] as [Length]
      ,[width] as [Width]
      ,[height] as [Height]
      ,[pick_area] as [Pick Area]
      ,[allow_bulk_pick] as [Bulk Pick Allowed]
      ,[building] as [Building]
      ,[item_hu_indicator] as [Item HU Indicator]
      ,[location_aisle] as [Aisle]
      ,[location_tier] as [Tier]
      ,[location_barcode] as [Barcode]
  FROM [PowerBI_Distribution].[WhseLocation] l
  left join [PowerBI_Distribution].[LocationClass] c
  on   l.[wh_id]=c.[WhId]
  and  l.[location_id]=c.[LocationId]
  WHERE 
	 l.wh_id in ('1','5','15','17','28','42','ECR','335','35')
  and l.building in ('B2','B4','R2','R3','C1','W3','T2','N1','P3','F2','A1','A3','M3','V3')
  and l.[status]='E'
  and l.[TypeDescription] in ('I')
  and (c.[ClassId] like '%PAL5H%' or c.[ClassId] like 'UPH%')
  )a
  where a.[pick area] in ('Upholstery','Casegood','Caseupper')
  group by
  a.[DC]
  ,a.[pick area]