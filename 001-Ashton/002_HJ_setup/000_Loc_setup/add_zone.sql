select * from t_zone
select  * from t_zone_loca
select  * from t_class_loca where class_id = 'FLOOR' and location_id like 'A3%1'




-- 1. 验证要添加的locations
select location_id, zone 
from t_location 
where location_id like 'RS%' 
   or location_id like 'A3%1' 
   or location_id like 'S%' 
   or location_id like 'D%'
order by location_id;

-- 2. 查看当前A4DPGROUND zone的信息
select wh_id, zone from t_zone where zone = 'A4DPGROUND';

-- 3. 插入新的zone-location关联 (A4DPGROUND zone)
insert into t_zone_loca (wh_id, zone, location_id, pick_seq)
select distinct 
    tl.wh_id,
    'A4DPGROUND' as zone,
    tl.location_id,
    999 as pick_seq  -- 可根据实际调整
from t_location tl
where (tl.location_id like 'RS%' 
   or tl.location_id like 'A3%1' 
   or tl.location_id like 'S%' 
   or tl.location_id like 'D%')
and not exists (
    select 1 from t_zone_loca tzl 
    where tzl.location_id = tl.location_id 
    and tzl.zone = 'A4DPGROUND'
);

-- 4. 验证插入结果
select wh_id, zone, location_id, pick_seq 
from t_zone_loca 
where zone like 'A4%'
order by location_id;


select wh_id, 'A4DPGROUND',location_id,'000'  
from t_location where location_id like 'RS%' and building ='A3'

