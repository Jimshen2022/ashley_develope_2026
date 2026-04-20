WITH PIECES AS(
SELECT loc.wh_id      AS WarehouseID 

   ,CASE WHEN loc.pick_area IN ('CASEGOOD','CASEUPPER','CASEOVRFL','LTCASE')   
   THEN 'CASEGOOD'   
   ELSE 'UPHOLSTERY'   
   END AS item_type 
   --,loc.building
    ,SUM(sto.actual_qty) AS Pieces  
  FROM [PowerBI_Distribution].[StoredItem] sto   
  JOIN [PowerBI_Distribution].[t_item_uom] itu ON sto.item_number = itu.item_number AND sto.wh_id = itu.wh_id  
  JOIN [PowerBI_Distribution].[ItemMaster] itm  ON sto.item_number = itm.item_number AND sto.wh_id = itm.wh_id  
  JOIN [PowerBI_Distribution].[WhseLocation] loc  ON sto.location_id = loc.location_id AND sto.wh_id = loc.wh_id  
  --JOIN Distribution_Warehouse_Wholesale.t_forward_pick fwd ON fwd.itemnumber = itm.item_number AND fwd.wh_id = itm.wh_id   
  WHERE sto.[type] = 'STORAGE'  

  AND  LEFT(itm.commodity_code,1) = 'Z' AND RIGHT(itm.commodity_code,1) <> 'K'  
  AND  loc.[typedescription] in ('I', 'M', 'X', 'Y','P','S','G','O','Q','SL','T','V','W','IG','D','F')  
  and loc.wh_id IN ('1','15','17','28','5','42','ECR','335')

  AND  itu.[priority]=1  
  and loc.pick_area IN ('CASEGOOD','CASEUPPER','CASEOVRFL','LTCASE','UPHOLSTERY')  
  GROUP BY loc.wh_id,loc.pick_area--,loc.building

),
CAPACITY AS
(
  SELECT 
    WarehouseID
	,PickAreaType
    ,SUM(capacity)  AS Capacity  
  FROM PowerBI_Distribution.UtilizationSetup B
  WHERE  BUILDING <> 'YARD'
  GROUP BY WarehouseID
          ,PickAreaType
		  )
SELECT
     PIECES. WarehouseID 
    ,PIECES.item_type 
    ,SUM(Pieces.PIECES) as PIECES
    ,CAPACITY.CAPACITY
	,(SUM(Pieces.PIECES)/CAPACITY.CAPACITY) AS [% UTILIZATION]
FROM PIECES
LEFT JOIN CAPACITY
  ON PIECES.WAREHOUSEID=CAPACITY.WAREHOUSEID
  AND CAPACITY.PICKAREATYPE=PIECES.ITEM_TYPE
  GROUP BY 
       PIECES. WarehouseID 
    ,PIECES.item_type 
	,CAPACITY.CAPACITY