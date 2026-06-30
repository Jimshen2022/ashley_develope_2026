-- 同一个bay, 第一与第四位available, 第二与三位lock

select
    t.*,
    case
        when charindex(substring(t.location_id, 7, 1), 'ABCDEFGHJKLMNPQRSTUVWXYZ') = 0 then null
        when ((charindex(substring(t.location_id, 7, 1), 'ABCDEFGHJKLMNPQRSTUVWXYZ') - 1) % 4) in (0, 3)
            then 'available'
        else 'Lock'
    end as bay_location_status
from t_location t
where t.location_id like 'A30[3-4]%'



-- 同一个bay, 第一与第四位available only 

select
    t.location_id
from t_location t
where t.location_id like 'A30[3-4]%'
  and ((charindex(substring(t.location_id, 7, 1), 'ABCDEFGHJKLMNPQRSTUVWXYZ') - 1) % 4) in (0, 3)
group by  t.location_id



