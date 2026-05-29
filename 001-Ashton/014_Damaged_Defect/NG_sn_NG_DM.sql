select * from t_serial_active a
left join t_serial_master b on a.wh_id = b.wh_id and a.serial_number = b.serial_number
where a.wh_id = '335' and (a.location_id like 'NG%' or a.location_id like 'DM%') and a.serial_no_status not in ('O') and b.serial_no_status not in ('S')
