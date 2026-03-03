-- Sep.18.2024 Updated MIL and WNK damaged and defect transactions for BI report by new process -- JimShen
SELECT t1.wh_id,
       t1.tran_type,
       t1.description,
       t1.start_tran_date,
       CAST(t1.start_tran_time AS TIME(0)) AS star_tran_time,
       t1.end_tran_date,
       CAST(t1.end_tran_time AS TIME(0)) AS end_tran_time,
       t1.employee_id,
       t1.control_number,
       t1.line_number,
       t1.control_number_2 AS reference,
       t1.hu_id as LP#,
       t1.item_number,
       CAST(t1.lot_number AS VARCHAR(20)) AS SN,
       t1.tran_qty,
       t1.location_id AS 'FromLocation',
       t1.location_id_2 AS 'ToLocation',
       t1.employee_id_2,
       CASE
           WHEN t1.location_id_2 IN ('NG001UP1') AND t1.wh_id IN ('35') THEN 'WH UPH Damage'
           WHEN t1.location_id_2 IN ('NG001DC1') AND t1.wh_id IN ('35') THEN 'WH UPH Damage'
           WHEN t1.location_id_2 IN ('NG001EX1') AND t1.wh_id IN ('35') THEN 'Defective goods from the manufacturing department'
           WHEN t1.location_id_2 IN ('NG001IN1') AND t1.wh_id IN ('35') THEN 'Defective goods caused by WH'
           WHEN t1.location_id_2 IN ('NG001EX1') AND t1.wh_id IN ('33') THEN 'Defective goods from the manufacturing department'
           WHEN t1.location_id_2 IN ('NG001IN1') AND t1.wh_id IN ('33') THEN 'Defective goods caused by WH'
           WHEN t1.location_id_2 IN ('NG001UP1') AND t1.wh_id IN ('33') THEN 'WH UPH Damage'
           WHEN t1.location_id_2 IN ('SA4061UP1') AND t1.wh_id IN ('33') THEN 'Move to Showroom'
           WHEN t1.location_id_2 IN ('SA4061UP1') AND t1.wh_id IN ('35') THEN 'Move to Showroom'
           WHEN t1.location_id_2 IN ('QA001UP1') AND t1.wh_id IN ('33') THEN 'Move to OBQ - QC - TAT CHECK'
           WHEN t1.location_id_2 IN ('QA001UP1') AND t1.wh_id IN ('35') THEN 'Move to OBQ - QC - TAT CHECK'
           WHEN t1.location_id_2 IN ('QA001OBQ') AND t1.wh_id IN ('35') THEN 'Move to B1 ram OBQ'
           WHEN t1.location_id_2 IN ('QA004OBQ') AND t1.wh_id IN ('35') THEN 'Move to B4 ram OBQ'
           WHEN t1.location_id_2 IN ('DM001AA1') AND t1.wh_id IN ('51') THEN 'Total damaged or defect qty'
           WHEN t1.location_id_2 IN ('QC001AA2') AND t1.wh_id IN ('51') THEN 'Quality issue'
           WHEN t1.location_id_2 IN ('HUY001') AND t1.wh_id IN ('51') THEN 'Quality issue cannot rework'
           WHEN t1.location_id_2 IN ('NG001CG1') AND t1.wh_id IN ('51') THEN 'Damaged by WH'
           WHEN t1.location_id_2 IN ('NG001SC1') AND t1.wh_id IN ('51') THEN 'Scrapped Qty'
           WHEN t1.location_id_2 IN ('PL001AA1') AND t1.wh_id IN ('51') THEN 'OBQ'
           ELSE 'Check' END AS Transaction_Type,
       CASE
           WHEN t1.location_id_2 IN ('NG001UP1') AND t1.wh_id IN ('35') THEN 'WN3'
           WHEN t1.location_id_2 IN ('NG001DC1') AND t1.wh_id IN ('35') THEN 'BLOCK 13'
           WHEN t1.location_id_2 IN ('NG001EX1') AND t1.wh_id IN ('35') THEN 'WN3'
           WHEN t1.location_id_2 IN ('NG001IN1') AND t1.wh_id IN ('35') THEN 'WN3'
           WHEN t1.location_id_2 IN ('NG001EX1') AND t1.wh_id IN ('33') THEN 'WN2'
           WHEN t1.location_id_2 IN ('NG001IN1') AND t1.wh_id IN ('33') THEN 'WN2'
           WHEN t1.location_id_2 IN ('NG001UP1') AND t1.wh_id IN ('33') THEN 'WN2'
           WHEN t1.location_id_2 IN ('SA4061UP1') AND t1.wh_id IN ('33') THEN 'WN2'
           WHEN t1.location_id_2 IN ('SA4061UP1') AND t1.wh_id IN ('35') THEN 'WN3'
           WHEN t1.location_id_2 IN ('QA001UP1') AND t1.wh_id IN ('33') THEN 'WN2'
           WHEN t1.location_id_2 IN ('QA001UP1') AND t1.wh_id IN ('35') THEN 'WN3'
           WHEN t1.location_id_2 IN ('QA001OBQ') AND t1.wh_id IN ('35') THEN 'WN3'
           WHEN t1.location_id_2 IN ('QA004OBQ') AND t1.wh_id IN ('35') THEN 'WN3'
           WHEN t1.location_id_2 IN ('DM001AA1') AND t1.wh_id IN ('51') THEN 'MIL'
           WHEN t1.location_id_2 IN ('QC001AA2') AND t1.wh_id IN ('51') THEN 'MIL'
           WHEN t1.location_id_2 IN ('HUY001') AND t1.wh_id IN ('51') THEN 'MIL'
           WHEN t1.location_id_2 IN ('NG001CG1') AND t1.wh_id IN ('51') THEN 'MIL'
           WHEN t1.location_id_2 IN ('NG001SC1') AND t1.wh_id IN ('51') THEN 'MIL'
           WHEN t1.location_id_2 IN ('PL001AA1') AND t1.wh_id IN ('51') THEN 'MIL'
           ELSE 'Check' END AS Sites
FROM Distribution_Warehouse_Wholesale.TranLog AS t1
WHERE t1.wh_id IN ('51','35','31','33','34')
  AND t1.start_tran_date > '2024-01-01'
  AND t1.tran_type IN ('202')
  AND (CASE
           WHEN t1.location_id_2 IN ('NG001UP1') AND t1.wh_id IN ('35') THEN 'WH UPH Damage'
           WHEN t1.location_id_2 IN ('NG001DC1') AND t1.wh_id IN ('35') THEN 'WH UPH Damage'
           WHEN t1.location_id_2 IN ('NG001EX1') AND t1.wh_id IN ('35') THEN 'Defective goods from the manufacturing department'
           WHEN t1.location_id_2 IN ('NG001IN1') AND t1.wh_id IN ('35') THEN 'Defective goods caused by WH'
           WHEN t1.location_id_2 IN ('NG001EX1') AND t1.wh_id IN ('33') THEN 'Defective goods from the manufacturing department'
           WHEN t1.location_id_2 IN ('NG001IN1') AND t1.wh_id IN ('33') THEN 'Defective goods caused by WH'
           WHEN t1.location_id_2 IN ('NG001UP1') AND t1.wh_id IN ('33') THEN 'WH UPH Damage'
           WHEN t1.location_id_2 IN ('SA4061UP1') AND t1.wh_id IN ('33') THEN 'Move to Showroom'
           WHEN t1.location_id_2 IN ('SA4061UP1') AND t1.wh_id IN ('35') THEN 'Move to Showroom'
           WHEN t1.location_id_2 IN ('QA001UP1') AND t1.wh_id IN ('33') THEN 'Move to OBQ - QC - TAT CHECK'
           WHEN t1.location_id_2 IN ('QA001UP1') AND t1.wh_id IN ('35') THEN 'Move to OBQ - QC - TAT CHECK'
           WHEN t1.location_id_2 IN ('QA001OBQ') AND t1.wh_id IN ('35') THEN 'Move to B1 ram OBQ'
           WHEN t1.location_id_2 IN ('QA004OBQ') AND t1.wh_id IN ('35') THEN 'Move to B4 ram OBQ'
           WHEN t1.location_id_2 IN ('DM001AA1') AND t1.wh_id IN ('51') THEN 'Total damaged or defect qty'
           WHEN t1.location_id_2 IN ('QC001AA2') AND t1.wh_id IN ('51') THEN 'Quality issue'
           WHEN t1.location_id_2 IN ('HUY001') AND t1.wh_id IN ('51') THEN 'Quality issue cannot rework'
           WHEN t1.location_id_2 IN ('NG001CG1') AND t1.wh_id IN ('51') THEN 'Damaged by WH'
           WHEN t1.location_id_2 IN ('NG001SC1') AND t1.wh_id IN ('51') THEN 'Scrapped Qty'
           WHEN t1.location_id_2 IN ('PL001AA1') AND t1.wh_id IN ('51') THEN 'OBQ'
           ELSE 'Check' END) <> 'Check'
ORDER BY t1.wh_id,t1.lot_number, t1.start_tran_date, t1.start_tran_time
