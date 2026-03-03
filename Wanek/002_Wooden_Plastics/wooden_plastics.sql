DROP TABLE IF EXISTS #wh_list;
CREATE TABLE #wh_list (wh_id NVARCHAR(20));

INSERT INTO #wh_list (wh_id)
SELECT DISTINCT wh_id
FROM (
    VALUES
        -- 原有数据
        ('S001'), ('S005'), ('S0102'), ('S012'), ('S015'),
        ('S017'), ('S018'), ('S020'), ('S021'), ('S0232'),
        ('S028'), ('S0335'), ('S042'), ('S049'), ('S050'),
        ('S060'), ('S070'), ('S101'), ('S0102'),
        ('S101'), ('S105'), ('S1102'), ('S112'), ('S115'),
        ('S117'), ('S118'), ('S120'), ('S121'), ('S1232'),
        ('S128'), ('S1335'), ('S142'), ('S149'), ('S150'),
        ('S160'), ('S170'), ('S101'), ('S1102'),
        ('S105'), ('S1102'), ('S115'), ('S117'), ('S118'),
        ('S120'), ('S121'), ('S1213'), ('S1215'), ('S1232'),
        ('S1242'), ('S128'), ('S1335'), ('S142')
) AS all_data(wh_id);

WITH itm as (
	select t.item_number, 
		min(t.unit_volume) as unit_volume
	from t_item_master as t
	where t.wh_id in ('35') and t.inventory_type <> 'RM'
	group by t.item_number
), 
sn as (
select *
from t_serial_active as t 
where t.serial_no_status not in ('O','S')
	AND t.wh_id in ('35','31','33')
	AND t.location_id in (SELECT * FROM #wh_list)
),
sn_sum as (
	select 
		t.wh_id,
		t.item_number,
		t.po_number as mo_nbr,
		t.location_id,
		COUNT(t.serial_number) as qty,
		COUNT(t.serial_number) *i.unit_volume as cubes
	from sn as t
	left join itm as i on t.item_number = i.item_number
	group by 
		t.wh_id,
		t.item_number,
		i.unit_volume,
		t.po_number,
		t.location_id
)
select *
from sn_sum as t1
order by t1.location_id
