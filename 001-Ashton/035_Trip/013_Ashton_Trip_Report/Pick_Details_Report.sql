SELECT LEFT(t.load_id,7) AS Trip_number,
	CASE 
		WHEN t.pick_area = 'UPHOLSTERY' THEN 'UPH'
		ELSE 'CG' END AS Product, 
	SUM(t.planned_quantity) AS planned_quantity , 
	SUM(t.picked_quantity) AS picked_quantity,
	SUM(t. staged_quantity) AS staged_quantity, 
	SUM(t.loaded_quantity) AS loaded_quantity,
	ROUND(SUM(t.picked_quantity) * 1.0 / SUM(t.planned_quantity), 2) AS 'Picked%',
	ROUND(SUM(t.staged_quantity) * 1.0 / SUM(t.planned_quantity), 2) AS 'Staged%',
	ROUND(SUM(t.loaded_quantity) * 1.0 / SUM(t.planned_quantity), 2) AS 'Loaded%'
FROM  Distribution_Warehouse_Wholesale.PickDetail AS t 
Where t.wh_id = '335' and t.status <>'SHIPPED' 
GROUP BY LEFT(t.load_id,7), 	CASE 
		WHEN t.pick_area = 'UPHOLSTERY' THEN 'UPH'
		ELSE 'CG' END
ORDER BY LEFT(t.load_id,7)	  