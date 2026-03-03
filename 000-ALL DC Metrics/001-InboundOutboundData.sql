--Start Hour
Declare @STH as VarChar(100) = '4'
--Start Time
Declare @ST as VarChar(100) = '04:00:00.000'
--End Time
Declare @ST2 as VarChar(100) = '15:00:00.000'
--Warehouse
Declare @WHS as VarChar(500);
--Start Date
Declare @SD as VarChar(100) = /*'2024-03-18 00:00:00.000' */ DATEADD(YEAR,-3,GETDATE())
--End Date
Declare @ED as VarChar(100) = /*'2024-03-18 00:00:00.000'*/ Getdate()

Set @WHS = '5, 42, 17, 15, 1, ECR, 28,335';


Select
	 t1.*
	,t2.total_inbound
	,t2.PO_Inbound
	,t2.TO_Inbound
	From
		(
			SELECT 
                   t.wh_id
				  ,case when datepart(hour,[start_tran_time]) < @STH then dateadd(dd,-1,[start_tran_date]) else cast([start_tran_date]as date) end as Workday
				  ,datename(dw,min(case when datepart(hour,[start_tran_time]) < @STH then dateadd(dd,-1,[start_tran_date]) else [start_tran_date] end)) as Day_1
				  ,datepart(dw,min(case when datepart(hour,[start_tran_time]) < @STH then dateadd(dd,-1,[start_tran_date]) else [start_tran_date] end)) as Day_Nbr_1
				  ,datepart(hour,[start_tran_time]) as Hour
				  ,min(case when Cast([start_tran_time] as Time) >= @ST and Cast([start_tran_time] as Time) < @ST2 then 1 else 2 end) as Shift
				  ,sum(case when t.[description]='Ship Billable - Serial Number' then 1 else 0 end) as Shipped_Billable_Volume
				  ,sum(case when t.[description]='Ship Billable - Serial Number' then i.unit_volume else 0 end) as Shipped_Billable_Cube
				  ,sum(case when t.[description] IN ('Loading - Pick/Load (put)','Loading - Billable (pick)') and t.[location_id] not like 'D%a' and t.[location_id] not like 'D%b' then 1 else 0 end) as Billable_Volume
				  ,sum(case when t.[description] IN ('Loading - Pick/Load (put)','Loading - Billable (pick)') and t.[location_id] not like 'D%a' and t.[location_id] not like 'D%b' and i.[pick_put_id] = 'UPH' then 1 else 0 end) as Loaded_UPH
				  ,sum(case when t.[description] IN ('Loading - Pick/Load (put)','Loading - Billable (pick)') and t.[location_id] not like 'D%a' and t.[location_id] not like 'D%b' and i.[pick_put_id] <> 'UPH' then 1 else 0 end) as Loaded_CSG
				  ,sum(case when t.[description]='Picking - Load (pick)' then 1 else 0 end) as Billable_Picked
				  ,sum(case when t.[description]='Picking - Load (pick)' and right([location_id], 1) = '1' then 1 else 0 end) as Picked_Ground
				  ,sum(case when t.[description]='Picking - Load (pick)' and right([location_id], 1) <> '1' then 1 else 0 end) as Picked_Air
				  ,sum(case when t.[description]='Ship Trip' then 1 else 0 end) as Billable_Trips_Shipped
				  ,count(distinct case when t.[description]='Ship Billable - Serial Number' then t.item_number else NULL end) / nullif(sum(case when t.[description]='Ship Trip' then 1 else 0 end),0)  as 'SKUs Per Trip'
				  ,sum(case when t.[description]='Loading - Express (put)' then 1 else 0 end) as Ecommerce_Volume
				  ,sum(case when t.[description]='Express - Order Pick (Pick)' then 1 else 0 end) as Ecommerce_Picked
				  ,sum(case when t.[description]='XPS (Put)' or t.[description]='XPTL - Batch Print' or t.[description]='XPTL - LP Label Print' then 1 else 0 end) as Ecommerce_Sort
				  ,sum(case when t.[description]='Ship Trailer/Checkout' then 1 else 0 end) as Ecommerce_Trailers_Shipped
				  ,sum(case when t.[description]='Loading - Billable (put)' then 1 else 0 end) + sum(case when t.[description]='Loading - Express (put)' then 1 else 0 end) as Outbound_Volume
				  ,sum(case when t.[description]='Loading - Transfer (put)' then 1 else 0 end) + sum(case when t.[description]='Pick to Load - Transfer (put)' then 1 else 0 end) as Trans_Volume
				  ,sum(case when t.[description]='Loading - Transfer (put)' then i.unit_volume else 0 end) + sum(case when t.[description]='Pick to Load - Transfer (put)'then i.unit_volume else 0 end) as Trans_Cube
                  ,SUM(case when t.[description]= 'Loading - Transfer (put)' and t.[wh_id_2] IN ('R3ARC','r32archot','red2arc','red2archot','spa2arc','tac2arc', 'ECR2RKD',  'ECR2RKDHOT',  'ETNA2RKD',  'LEE2ARC', 'LEE2ARCHOT',  'N1TOARC', 'N1TOARCHOT',  'T2TOARC',  'T2TOARCHOT') then 1 else 0 end)  as 'To Arcadia Transfer Volume'
				  ,sum(case when t.[description]= 'Loading - Transfer (put)' and t.[wh_id_2] IN ('R3ARC','r32archot','red2arc','red2archot','spa2arc','tac2arc', 'ECR2RKD',  'ECR2RKDHOT',  'ETNA2RKD',  'LEE2ARC', 'LEE2ARCHOT',  'N1TOARC', 'N1TOARCHOT',  'T2TOARC',  'T2TOARCHOT') then i.unit_volume else 0 end)  as 'To Arcadia Transfer Cube'
				  ,sum(case when t.[description]= 'Loading - Transfer (put)' and t.[wh_id_2] IN ('B2NC',  'B2NCHOT',  'B4NC',  'B4NCHOT',  'ECR2NC',  'ECR2NCHOT',  'ETNA2NC',  'LEE2NC',  'R32NC',  'R32NCHOT',  'RED2NC',  'RED2NCHOT',  'SPA2ADV',  'T2TOADV',  'T2TOADVHOT',  'TAC2ADV') then 1 else 0 end)  as 'To Advance Transfer Volume'
				  ,sum(case when t.[description]= 'Loading - Transfer (put)' and t.[wh_id_2] IN ('B2NC',  'B2NCHOT',  'B4NC',  'B4NCHOT',  'ECR2NC',  'ECR2NCHOT',  'ETNA2NC',  'LEE2NC',  'R32NC',  'R32NCHOT',  'RED2NC',  'RED2NCHOT',  'SPA2ADV',  'T2TOADV',  'T2TOADVHOT',  'TAC2ADV')  then i.unit_volume else 0 end)  as 'To Advance Transfer Cube'
				  ,sum(case when t.[description]= 'Loading - Transfer (put)' and t.[wh_id_2] IN ('B2T','B4T','B2THOT', 'B4THOT',  'ECR2TEX',  'ECR2TEXHOT',  'ETNA2TEX',  'LEE2TEX',  'N1TOTEX',  'N1TOTEXHOT',  'R32TX',  'R32TXHOT',  'RED2TEX',  'RED2TEXHOT',  'SPA2MSQ',  'TAC2MSQ') then 1 else 0 end)  as 'To Mesquite Transfer Volume'
				  ,sum(case when t.[description]= 'Loading - Transfer (put)' and t.[wh_id_2] IN ('B2T','B4T','B2THOT', 'B4THOT',  'ECR2TEX',  'ECR2TEXHOT',  'ETNA2TEX',  'LEE2TEX',  'N1TOTEX',  'N1TOTEXHOT',  'R32TX',  'R32TXHOT',  'RED2TEX',  'RED2TEXHOT',  'SPA2MSQ',  'TAC2MSQ') then i.unit_volume else 0 end)  as 'To Mesquite Transfer Cube'
				  ,sum(case when t.[description]= 'Loading - Transfer (put)' and t.[wh_id_2] IN ('B4L','B2L','B2LHOT',  'B4LHOT',  'ECR2PA',  'ECR2PAHOT',  'ETNA2LEES',  'N1TOLEE',  'N1TOLEEHOT',  'N2TOLEEHOT',  'R32LEE',  'R32LEEHOT',  'RED2LEE',  'RED2LEEHOT',  'SPA2LEE',  'T2TOLEE',  'T2TOLEEHOT',  'TAC2LEE') then 1 else 0 end) as 'To Leesport Transfer Volume'
				  ,sum(case when t.[description]= 'Loading - Transfer (put)' and t.[wh_id_2] IN ('B4L','B2L','B2LHOT',  'B4LHOT',  'ECR2PA',  'ECR2PAHOT',  'ETNA2LEES',  'N1TOLEE',  'N1TOLEEHOT',  'N2TOLEEHOT',  'R32LEE',  'R32LEEHOT',  'RED2LEE',  'RED2LEEHOT',  'SPA2LEE',  'T2TOLEE',  'T2TOLEEHOT',  'TAC2LEE') then i.unit_volume else 0 end)  as 'To Leesport Transfer Cube'
				  ,sum(case when t.[description]= 'Loading - Transfer (put)' and t.[wh_id_2] IN ('B2E','B4E','B2EHOT',  'B4EHOT',  'ETNA2ECRU',  'LEE2ECR',  'N1TOECR',  'N1TOECRHOT',  'N2TOECR',  'R32ECR',  'R32ECRHOT',  'RED2ECR',  'RED2ECRHOT',  'SPA2ECR',  'T2TOECR',  'T2TOECRHOT',  'TAC2ECR',  'TEX2ECR',  'TEX2ECRHOT') then 1 else 0 end)  as 'To Ecru Transfer Volume'
				  ,sum(case when t.[description]= 'Loading - Transfer (put)' and t.[wh_id_2] IN ('B2E','B4E','B2EHOT',  'B4EHOT',  'ETNA2ECRU',  'LEE2ECR',  'N1TOECR',  'N1TOECRHOT',  'N2TOECR',  'R32ECR',  'R32ECRHOT',  'RED2ECR',  'RED2ECRHOT',  'SPA2ECR',  'T2TOECR',  'T2TOECRHOT',  'TAC2ECR',  'TEX2ECR',  'TEX2ECRHOT') then i.unit_volume else 0 end)  as 'To Ecru Transfer Cube'
				  ,sum(case when t.[description]= 'Loading - Transfer (put)' and t.[wh_id_2] IN ('B2T','B4T','B2TAC',  'B4TAC',  'ECR2TAC',  'ETNA2TAC',  'LEE2TAC',  'N1TOTAC',  'N1TOTACHOT',  'R32TAC',  'RED2TAC',  'T2TOTAC') then 1 else 0 end)  as 'To Spanaway Transfer Volume'
				  ,sum(case when t.[description]= 'Loading - Transfer (put)' and t.[wh_id_2] IN ('B2T','B4T','B2TAC',  'B4TAC',  'ECR2TAC',  'ETNA2TAC',  'LEE2TAC',  'N1TOTAC',  'N1TOTACHOT',  'R32TAC',  'RED2TAC',  'T2TOTAC') then i.unit_volume else 0 end)  as 'To Spanaway Transfer Cube'
				  ,sum(case when t.[description]= 'Loading - Transfer (put)' and t.[wh_id_2] IN ('B2ETNA',  'B4ETNA',  'ECR2ETNA',  'LEE2ETNA',  'N1TOETNA',  'R32ETNA',  'RED2ETNA',  'SPA2ETN',  'T2TOETNA',  'TAC2ETNA') then 1 else 0 end)  as 'To Etna Transfer Volume'
				  ,sum(case when t.[description]= 'Loading - Transfer (put)' and t.[wh_id_2] IN ('B2ETNA',  'B4ETNA',  'ECR2ETNA',  'LEE2ETNA',  'N1TOETNA',  'R32ETNA',  'RED2ETNA',  'SPA2ETN',  'T2TOETNA',  'TAC2ETNA') then i.unit_volume else 0 end) as 'To Etna Transfer Cube'
				  ,sum(case when t.[description]= 'Loading - Transfer (put)' and t.[wh_id_2] IN ('B2C', 'B4C','B4R','B2R', 'B2CHOT',  'B2RHOT',  'B4CHOT',  'ECR2COL',  'ECR2COLHOT',  'ETNA2COL',  'LEE2COL',  'LEE2COLHOT',  'N1TOCOL',  'SPA2RED',  'T2TORED',  'T2TOREDHOT',  'TAC2RED',  'TAC2REDHOT',  'TEX2RED',  'TEX2REDHOT') then 1 else 0 end)  as 'To Redlands Transfer Volume'
				  ,sum(case when t.[description]= 'Loading - Transfer (put)' and t.[wh_id_2] IN ('B2C', 'B4C', 'B4R','B2R','B2CHOT',  'B2RHOT',  'B4CHOT',  'ECR2COL',  'ECR2COLHOT',  'ETNA2COL',  'LEE2COL',  'LEE2COLHOT',  'N1TOCOL',  'SPA2RED',  'T2TORED',  'T2TOREDHOT',  'TAC2RED',  'TAC2REDHOT',  'TEX2RED',  'TEX2REDHOT') then i.unit_volume else 0 end) as 'To Redlands Transfer Cube'
				  ,count(distinct(case when t.[description] = 'Ship Trip - Transfer' then t.[control_number_2] end)) as Trans_Trips_Shipped
				  ,sum(case when t.[description]= 'Vendor Receipt (rcpt)' and i.[pick_put_id]<>'UPH' then 1 else 0 end) as CSG_Volume
				  ,sum(case when t.[description]= 'Vendor Receipt (rcpt)' and i.[pick_put_id]='UPH' then 1 else 0 end) as UPH_Volume
				  ,sum(case when t.[description]= 'Vendor Receipt (rcpt)' then 1 else 0 end) as Inbound_Volume
				  ,sum(case when t.[description]= 'Vendor Receipt (rcpt)' and isnumeric(left([hu_id_2],1)) ='1' then 1 else 0 end) as PO_Volume
				  ,sum(case when t.[description]= 'Vendor Receipt (rcpt)' and isnumeric(left([hu_id_2],1)) ='0' then 1 else 0 end) as TO_Volume
				  ,sum(case when t.[description]= 'Vendor Receipt (rcpt)' and isnumeric(left([hu_id_2],1)) ='1' and i.[pick_put_id]<>'UPH' then 1 else 0 end) as CSG_PO_Volume
				  ,sum(case when t.[description]= 'Vendor Receipt (rcpt)' and isnumeric(left([hu_id_2],1)) ='1' and i.[pick_put_id]='UPH' then 1 else 0 end) as UPH_PO_Volume
				  ,sum(case when t.[description]= 'Vendor Receipt (rcpt)' and isnumeric(left([hu_id_2],1)) ='0' and i.[pick_put_id]<>'UPH' then 1 else 0 end) as CSG_TO_Volume
				  ,sum(case when t.[description]= 'Vendor Receipt (rcpt)' and isnumeric(left([hu_id_2],1)) ='0' and i.[pick_put_id]='UPH' then 1 else 0 end) as UPH_TO_Volume
				  ,(sum(case when t.[description]= 'Confirm Close' and t.[hu_id] = 'Purchase Orders' then 1 else 0 end)) as PO_Closed
				  ,sum(case when t.[description]= 'Confirm Close' and t.[hu_id] = 'Transfer Orders' then 1 else 0 end) as TO_Closed
				  ,sum(case when t.[description]= 'Confirm Close' and (t.[hu_id] = 'Purchase Orders' or t.[hu_id] = 'Transfer Orders') then 1 else 0 end) as Total_Inbound_Closed
				  ,sum(case when t.[description]= 'Confirm Close' and t.[hu_id]= 'Shuttle Orders'  then 1 else 0 end) as Shuttle_Closed
				  ,sum(case when t.[description]= 'Build Shuttle (Put)'  then 1 else 0 end) as Shuttle_Volume 
				  ,sum(case when t.[description]= 'Build Shuttle (Put)' and i.[pick_put_id]<>'UPH' then 1 else 0 end) as CSG_Shuttle_Volume 
				  ,sum(case when t.[description]= 'Build Shuttle (Put)' and i.[pick_put_id]='UPH' then 1 else 0 end) as UPH_Shuttle_Volume 
				  ,sum(t.[tran_qty]) as Total_Volume

			  FROM [PowerBI_Distribution].[TranLog] t
			  left join [PowerBI_Distribution].[ItemMaster] i on t.[item_number]=i.[item_number] and t.[wh_id]=i.[wh_id]
			  where t.[wh_id] IN  (
                      SELECT trim(value)FROM string_split(@WHS, ',')
              
                  )
				  and [start_tran_date] >= @SD and [start_tran_date] <= @ED
			  group by 
			     t.wh_id
				,case when datepart(hour,[start_tran_time]) < @STH then dateadd(dd,-1,[start_tran_date]) else cast([start_tran_date]as date) end
				 ,datepart(hour,[start_tran_time])
				 )t1
	left join
		(
		  SELECT wh_id
			  ,case when datepart(hour,y.[started]) < 4 then dateadd(dd,-1,[started]) else cast([started] as date) end as Workday
			  ,min(case when datepart(hour,y.[started]) < 4 then y.[started] - 1 else y.[started] end) as Day
			  ,min(case when datepart(hour,y.[started]) < 4 then datepart(dw,y.[started] - 1 ) else datepart(dw,y.[started] )end ) as Day_Nbr
			  ,datepart(hour,y.[started] ) as Hour
			  ,count(distinct case when description = 'Check In (PO, TO, Shuttle)'  then y.[control_number] else NULL end) as Total_inbound
			  ,count(distinct case when y.[description]= 'Check In (PO, TO, Shuttle)' and isnumeric(left(y.[control_number],1)) = '1' then y.[control_number] else NULL end) as PO_Inbound
			  ,count(distinct case when y.[description]= 'Check In (PO, TO, Shuttle)' and isnumeric(left(y.[control_number],1)) = '0' then y.[control_number] else NULL end) as TO_Inbound
		  FROM [PowerBI_Distribution].[YaTranLog] y
		  where y.[wh_id] IN (
                      SELECT trim(value)FROM string_split(@WHS, ',')
              
                  )
		  and  [started] >= @SD and  [started] <= @ED
		  group by [wh_id]
			  ,case when datepart(hour,y.[started]) < 4 then dateadd(dd,-1,[started]) else cast([started] as date) end
			  ,datename(dw,[started] )
			  ,datepart(dw,[started] )
			 ,datepart(Hour,[started] ) 
		

			 ) t2 on  t1.workday = t2.workday  and t1.hour = t2.hour and t1.wh_id=t2.wh_id