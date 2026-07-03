
SELECT  *  FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME LIKE '%profile%'
SELECT  *  FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME LIKE '%t_put_profile%'
SELECT  *  FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME LIKE '%putaway%'
SELECT  *  FROM INFORMATION_SCHEMA.COLUMNS WHERE COLUMN_NAME LIKE '%rule%'


-- LOCATION CHECK
select  * from t_location where location_id like 'A3013EU1%'

select * from t_tran_log where item_number = 'T856-2'  and start_tran_date between '2026-06-30' and '2026-07-02' order by start_tran_date desc, start_tran_time desc
select * from t_tran_log where lot_number ='683811751479'
select * from t_tran_log where lot_number like '68381175%07'  order by start_tran_date desc, start_tran_time desc
select * from t_tran_log where lot_number like '68381175%07'  order by start_tran_date desc, start_tran_time desc
select * from t_tran_log where lot_number like '68381175%07'  order by start_tran_date desc, start_tran_time desc


select * from t_tran_log where lot_number = '683811751307'  order by start_tran_date desc, start_tran_time desc
select * from t_tran_log where lot_number = '683811755307'  order by start_tran_date desc, start_tran_time desc
select * from t_tran_log where lot_number = '683811751407'  order by start_tran_date desc, start_tran_time desc
select * from t_tran_log where lot_number = '683811751479'  order by start_tran_date desc, start_tran_time desc
select * from t_location where  type ='Q'


-- Pick rules:
select  * from t_pick_put_detail where type = 'PICK' and pick_put_id = 'PALLT' order by sequence 
select  * from t_pick_put_rules where type = 'PICK'

-- putaway rules
select  * from t_pick_put_detail where type = 'PUT' and pick_put_id = 'PALLT' order by sequence 
select  * from t_pick_put_detail where type = 'PICK' and pick_put_id = 'PALLT' order by sequence 

/* udpate putaway rules sequence 2026-06-30

update
t_pick_put_detail
set sequence = case sequence when 24 then 4 when 25 then 5 else sequence+2 end
where pick_put_id = 'PALLT' and type = 'PUT' and sequence between 4 and 25

*/


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
