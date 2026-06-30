select wh_id, 'A5UPHUPPER' as zone, location_id, '000' as pick_seq
from t_location
where building = 'A3' 
  and location_id like '[SD][0-9][0-9]%'
  and CAST(SUBSTRING(location_id,2,3) AS INT) between 54 and 229
  and CAST(SUBSTRING(location_id,2,3) AS INT) not between 138 and 145