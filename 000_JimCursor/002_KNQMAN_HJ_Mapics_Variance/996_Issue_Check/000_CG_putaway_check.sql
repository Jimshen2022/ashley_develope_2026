SELECT name FROM sys.tables WHERE name LIKE '%code%' OR name LIKE '%status%' OR name LIKE '%ref%'
select TOP 10 * from t_status where table_name = 't_hu_detail'
select TOP 10 * from t_code_promote_detail 

select TOP 10 * from t_hu_master where status = 'H' 
select TOP 10 * from t_hu_master where status = 'A' 
select TOP 10 * from t_hu_master where status = 'O' 
select TOP 10 * from t_hu_master where status = 'S'   -2552839 2558623
select TOP 10 * from t_loc_pallet_capacity  

select distinct type, status from t_hu_master

select TOP 10 * from t_hu_detail where status = 'A' 
select TOP 10 * from t_hu_detail where status = 'U' 
select TOP 10 * from t_hu_detail where status = 'P'   416675319 416704418
-- 查找状态定义表
select distinct status  from t_hu_detail



select TOP 10 * from t_hu_master 
select TOP 10 * from t_hu_detail 





select * from t_hu_master where location_id= 'A3010CG1' 
select * from t_hu_detail where hu_id in ('2553561','2555286','2555406') 
select * from t_work_q where work_q_id in ('416724551')



SELECT --@v_CurrentPalletCount = 1
*
FROM  t_hu_master hum (NOLOCK)             
JOIN  t_hu_detail hud (NOLOCK) ON hum.wh_id = hud.wh_id AND hum.hu_id = hud.hu_id              
JOIN  t_item_master itm (NOLOCK) ON hud.wh_id = itm.wh_id AND hud.item_number = itm.item_number               
WHERE  hum.location_id =  'A3010CG1'              
AND  hum.wh_id  = '335'               
AND  itm.pallet_id = '18'




SELECT -- @v_LocationCapacity = 2
ISNULL(capacity,0)    ,*                
FROM  dbo.t_loc_pallet_capacity(nolock)                  
WHERE location_id = 'A3010CG1'     AND pallet_id = '18';
SELECT --@v_CurrentPalletCount = 1
ISNULL(COUNT(DISTINCT hum.hu_id),0)  
FROM  t_hu_master hum (NOLOCK)             
JOIN  t_hu_detail hud (NOLOCK) ON hum.wh_id = hud.wh_id AND hum.hu_id = hud.hu_id              
JOIN  t_item_master itm (NOLOCK) ON hud.wh_id = itm.wh_id AND hud.item_number = itm.item_number               
WHERE  hum.location_id =  'A3010CG1'              
AND  hum.wh_id  = '335'               
AND  itm.pallet_id = '18'

select * from t_hu_master where location_id  LIKE 'A3011K[G]5'
SELECT --@v_CurrentPalletCount = 1
ISNULL(COUNT(DISTINCT hum.hu_id),0)  
FROM  t_hu_master hum (NOLOCK)             
JOIN  t_hu_detail hud (NOLOCK) ON hum.wh_id = hud.wh_id AND hum.hu_id = hud.hu_id              
JOIN  t_item_master itm (NOLOCK) ON hud.wh_id = itm.wh_id AND hud.item_number = itm.item_number               
WHERE  hum.location_id LIKE 'A3011K[G]5'           
AND  hum.wh_id  = '335'               
AND  itm.pallet_id = '18'


SELECT --@v_CurrentPalletCount = 1
*
FROM  t_hu_master hum (NOLOCK)             
JOIN  t_hu_detail hud (NOLOCK) ON hum.wh_id = hud.wh_id AND hum.hu_id = hud.hu_id              
JOIN  t_item_master itm (NOLOCK) ON hud.wh_id = itm.wh_id AND hud.item_number = itm.item_number               
WHERE  hum.location_id =  'A3010CG1'              
AND  hum.wh_id  = '335'               
AND  itm.pallet_id = '18'

select * from t_hu_master where hu_id in ('2552839','2558623') 
select * from t_hu_master where location_id= 'A3010CA1' 
select * from t_hu_detail where hu_id in ('2552839','2558623') 
select * from t_work_q where work_q_id in ('416704418','416675319')

select * from t_hu_master where location_id= 'A3010CG1' 
select * from t_hu_detail where hu_id in ('2553561','2555286','2555406') 


select * from t_hu_master where location_id  LIKE 'A3010C[ACDFGJKMNQ]%1'
SELECT --@v_CurrentPalletCount = 1
ISNULL(COUNT(DISTINCT hum.hu_id),0)  
FROM  t_hu_master hum (NOLOCK)             
JOIN  t_hu_detail hud (NOLOCK) ON hum.wh_id = hud.wh_id AND hum.hu_id = hud.hu_id              
JOIN  t_item_master itm (NOLOCK) ON hud.wh_id = itm.wh_id AND hud.item_number = itm.item_number               
WHERE  hum.location_id LIKE 'A3010C[ACDFGJKMNQ]%1'           
AND  hum.wh_id  = '335'               
AND  itm.pallet_id = '18'




select * from t_work_q where location_id  LIKE 'A3010C[ACDFGJKMNQ]%1'  and work_status <> 'C'
select * from t_work_q where location_id  LIKE 'A3011KG5%'  and work_status <> 'C'


SELECT -- @v_LocationCapacity = 2
ISNULL(capacity,0)    ,*                
FROM  dbo.t_loc_pallet_capacity(nolock)                  
WHERE location_id = 'A3011KG5'     AND pallet_id = '18';
 
SELECT --@v_CurrentPalletCount = 1
ISNULL(COUNT(DISTINCT hum.hu_id),0)  
FROM  t_hu_master hum (NOLOCK)             
JOIN  t_hu_detail hud (NOLOCK) ON hum.wh_id = hud.wh_id AND hum.hu_id = hud.hu_id              
JOIN  t_item_master itm (NOLOCK) ON hud.wh_id = itm.wh_id AND hud.item_number = itm.item_number               
WHERE  hum.location_id =  'A3011KG5'              
AND  hum.wh_id  = '335'               
AND  itm.pallet_id = '18'




SELECT -- @v_LocationCapacity = 2
ISNULL(capacity,0)    ,*                
FROM  dbo.t_loc_pallet_capacity(nolock)                  
WHERE location_id = 'A3011HT4'     AND pallet_id = '18';
 
SELECT --@v_CurrentPalletCount = 1
ISNULL(COUNT(DISTINCT hum.hu_id),0)  
FROM  t_hu_master hum (NOLOCK)             
JOIN  t_hu_detail hud (NOLOCK) ON hum.wh_id = hud.wh_id AND hum.hu_id = hud.hu_id              
JOIN  t_item_master itm (NOLOCK) ON hud.wh_id = itm.wh_id AND hud.item_number = itm.item_number               
WHERE  hum.location_id =  'A3011KG5'              
AND  hum.wh_id  = '335'               
AND  itm.pallet_id = '18'
 