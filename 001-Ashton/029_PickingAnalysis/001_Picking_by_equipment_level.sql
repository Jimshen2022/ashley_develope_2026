
--- picking by equipment
select cast(t1.start_tran_date as date) as Date, t1.location_id, t1.location_id_2, t1.equipment_zone, t1.tran_type,  
        CASE 
            --WHEN t1.tran_type IN ('151','183','951') THEN 'Unloading'
            --WHEN t1.tran_type IN ('321') THEN 'Loading'
            WHEN t1.tran_type = '363' 
                 AND (t1.location_id_2 LIKE 'VR%' OR t1.location_id_2 LIKE 'VF%')
                 AND t1.hu_id IS NOT NULL THEN 'Picking-SCOOP'
            WHEN t1.tran_type IN ('363','372') THEN 'Picking'
            --WHEN t1.tran_type = '347' THEN 'Piece shipped'
            --WHEN t1.tran_type IN ('252','262') THEN 'Replenishment'
            --WHEN t1.tran_type = '254' AND t1.location_id_2 <> 'RP998XL3' THEN 'Put away'
            --WHEN t1.control_number_2 LIKE 'RS%' AND t1.location_id_2 LIKE 'A%' THEN 'Put away'
            --WHEN t1.control_number_2 LIKE 'RS%' AND t1.location_id_2 LIKE 'DR%' THEN 'Put away'
            --WHEN t1.tran_type = '202' AND t1.control_number_2 LIKE 'CN%' AND t1.location_id_2 LIKE 'A%' THEN 'Unloading'
            --WHEN t1.tran_type = '202' AND t1.control_number_2 LIKE 'UL%' AND t1.location_id_2 LIKE 'A%' THEN 'Put away'
            ELSE 'not_pph_trx'
        END AS pph_type,
        left(t1.location_id_2,2) as equpment_type,
        right(t1.location_id,1) as picked_level,
        sum(t1.tran_qty) as tran_qty
from t_tran_log as t1
where t1.tran_type in ('363','372') 
  and t1.start_tran_date >= '2025-10-01'
group by cast(t1.start_tran_date as date), t1.location_id, t1.location_id_2, t1.equipment_zone, t1.tran_type,  
        CASE 
            --WHEN t1.tran_type IN ('151','183','951') THEN 'Unloading'
            --WHEN t1.tran_type IN ('321') THEN 'Loading'
            WHEN t1.tran_type = '363' 
                 AND (t1.location_id_2 LIKE 'VR%' OR t1.location_id_2 LIKE 'VF%')
                 AND t1.hu_id IS NOT NULL THEN 'Picking-SCOOP'
            WHEN t1.tran_type IN ('363','372') THEN 'Picking'
            --WHEN t1.tran_type = '347' THEN 'Piece shipped'
            --WHEN t1.tran_type IN ('252','262') THEN 'Replenishment'
            --WHEN t1.tran_type = '254' AND t1.location_id_2 <> 'RP998XL3' THEN 'Put away'
            --WHEN t1.control_number_2 LIKE 'RS%' AND t1.location_id_2 LIKE 'A%' THEN 'Put away'
            --WHEN t1.control_number_2 LIKE 'RS%' AND t1.location_id_2 LIKE 'DR%' THEN 'Put away'
            --WHEN t1.tran_type = '202' AND t1.control_number_2 LIKE 'CN%' AND t1.location_id_2 LIKE 'A%' THEN 'Unloading'
            --WHEN t1.tran_type = '202' AND t1.control_number_2 LIKE 'UL%' AND t1.location_id_2 LIKE 'A%' THEN 'Put away'
            ELSE 'not_pph_trx'
        END,
        left(t1.location_id_2,2),
         right(t1.location_id,1)