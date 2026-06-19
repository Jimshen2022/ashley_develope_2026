   SELECT *,
		CAST(LEFT(t.LoadID, CHARINDEX('-',t.LoadID)-1) AS INT) AS trip_nbr
   FROM    Distribution_Warehouse_Wholesale.TripReport as t where t.WhID = '335'


