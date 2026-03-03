/* ASIA WHSE YARD_MANAGEMENT: 
SCOOP: WH335,35,51 
Purpose: to prevent invalid container# in yard over yard capacity.
Version:
-- Mar.12.2024 Created  --  JimShen   
-- Aug.01.2024 Excluded few containers have two status ('HISTORY' AND 'IN YARD CHASSIS') -- JimShen

*/
With o1 as 
-- excluded few few container have two status at same time ('HISTORY' AND 'IN YARD CHASSIS'), get rid of 'HISTORY'
(SELECT CONCAT(a2.wh_id2,'_', a2.EquipmentId) as wh_eq
FROM
(select a1.wh_id2, a1.EquipmentId, a1.Status, MAX(a1.EnteredYard) AS EnteredYard
From Distribution_Warehouse_Wholesale.t_trailer AS a1 
Where a1.wh_id2 IN ('31','335','51') AND a1.Status IN ('HISTORY','IB SHUTTLE','LOST') 
GROUP BY a1.wh_id2,a1.EquipmentId, a1.Status 
) AS a2)
-- MAIN --
select t1.areaid as "area_id"
	, t1.equipmentid as "Equipment ID"
	, t1.status as "Status"
	, t1.state as "State"
	, t2.location_name as "Location Name"
	, t3.trailer_type_name as "Trailer Type"
	, t1.carrierid
	, t4.carrier_name as "Carrier Name"
	, t1.owner as "Scheduled By"
	, t1.locationid
	, t1.enteredyard as "Entered Yard"
from 
(select *
from Distribution_Warehouse_Wholesale.t_trailer a
where a.wh_id2 IN ('31','335','51') and a.Status not in ('HISTORY','IB SHUTTLE','LOST')
and CONCAT(a.wh_id2,'_',a.EquipmentId) NOT IN (SELECT o1.wh_eq FROM o1) AND LEN(a.EquipmentId) >4
) as t1
left join 
(select * from Distribution_Warehouse_Wholesale.YaLocation as b where b.area_id in ('31','35','34','33','335','51')) as t2 
on t1.locationid = t2.location_id and t1.areaid = t2.area_id
left join  
(select * from Distribution_Warehouse_Wholesale.TrailerType c where c.wh_id in ('31','335','51')) as t3 
on t1.wh_id2 = t3.wh_id and t1.TrailerTypeId = t3.trailer_type_id
left join 
(select * from Distribution_Warehouse_Wholesale.Carrier d where d.wh_id in ('335','31','51')) as t4 
on t1.wh_id2 = t4.wh_id and t1.carrierid = t4.carrier_id
where t1.enteredyard > '2024-01-01'