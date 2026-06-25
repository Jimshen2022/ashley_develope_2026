
SELECT  *  FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME LIKE '%profile%'
SELECT  *  FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME LIKE '%t_put_profile%'
SELECT  *  FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME LIKE '%putaway%'
SELECT  *  FROM INFORMATION_SCHEMA.COLUMNS WHERE COLUMN_NAME LIKE '%rule%'


-- Pick rules:
select  * from t_pick_put_detail where type = 'PICK' and pick_put_id = 'PALLT' order by sequence 

-- putaway rules
select  * from t_pick_put_detail where type = 'PUT' and pick_put_id = 'PALLT' order by sequence 




-- HJ set up
SELECT *  FROM t_control WITH (NOLOCK) WHERE control_type IN ('PRIM_DEMAND_DAYS', 'SEC_DEMAND_DAYS', 'MIN_UOM_PCT');
-- demand setup
select top 10 * from t_control where control_type like '%PRIM_DEMAND_DAYS%'
select top 10 * from t_control where control_type like '%SEC_DEMAND_DAYS%'

-- location setup : box 
select top 10 * from t_location where location_id like 'A3%'

-- secondary
select top 10 * from t_control where control_type like '%SEC_DEMAND_DAYS%'


select * from t_item_forecast_daily where forecast_demand>0

select  * from t_lookup where source like '%t_location%' and locale_id = '1033' and wh_id = '335'
select  * from t_lookup where source like '%t_location%' and locale_id = '1033' and wh_id = '335'
select  * from t_lookup where source like '%t_location%' and locale_id = '1033' and wh_id = '335'
select top 10 * from t_control where control_type like '%PRIM_DEMAND_DAYS%'



-- control setup 
select top 10 * from t_control where control_type like '%SEC_LOC_TYP%' 
select top 10 * from t_whse_control where control_type like '%SEC_LOC_TYP%'



SELECT  *  FROM INFORMATION_SCHEMA.COLUMNS
SELECT  *  FROM INFORMATION_SCHEMA.COLUMNS WHERE COLUMN_NAME LIKE '%SEC_LOC_TYP%'
SELECT  table_name  FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME LIKE '%SEC_LOC_TYP%' group by table_name
