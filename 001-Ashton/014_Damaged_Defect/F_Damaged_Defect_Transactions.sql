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
                            WHEN t1.location_id_2 IN ('DM001AA1') AND t1.control_number_2 LIKE 'RS%' THEN 'Inbound Vendor Damaged received qty'
                            WHEN t1.location_id_2 IN ('DM001AA1') AND t1.control_number_2 LIKE 'A3%' THEN 'Whse Damaged qty'
                            WHEN t1.location_id_2 LIKE 'A3%' AND t1.control_number_2 IN ('DM001AA1') THEN 'Inspected & Fixing okay qty'
                            WHEN t1.location_id_2 LIKE 'A3%' AND t1.control_number_2 IN ('NG001CK3') THEN 'Inspected & Fixing okay qty'
                                WHEN t1.location_id_2 IN ('NG001VD3') AND t1.control_number_2 IN ('NG001UP3') THEN 'Whse damaged return to venodr fixing qty'
                            WHEN t1.location_id_2 IN ('NG001VD3') AND t1.control_number_2 IN ('NG001CG3') THEN 'Whse damaged return to venodr fixing qty'
                            WHEN t1.location_id_2 IN ('NG001CK3') AND t1.control_number_2 IN ('NG001CG3') THEN 'Ashton can fix it but lack materials qty'
                            WHEN t1.location_id_2 LIKE 'A3%' AND t1.control_number_2 IN ('NG001VD3') THEN 'Vendor fixed okay or swapped qty'
                            ELSE 'Check'
                        END AS Transaction_type,
                        CASE 
                            WHEN substring(t1.item_number,1,4) LIKE '100-' THEN 'CG' 
                            WHEN substring(t1.item_number,1,1) IN ('1','2','3','4','5','6','7','8','9','U') then 'UPH'
                            WHEN substring(t1.item_number,1,1) IN ('A','B','D','E','G','H','L','M','P','R','T','W','Z') then 'CG'
                            ELSE 'Check' END AS Item_Type 
                FROM Distribution_Warehouse_Wholesale.TranLog AS t1
                WHERE t1.wh_id IN ('335')
                    AND t1.start_tran_date > '2024-01-01'
                    AND t1.tran_type IN ('254', '202')
                    AND (CASE
                            WHEN t1.location_id_2 IN ('DM001AA1') AND t1.control_number_2 LIKE 'RS%' THEN 'Inbound Vendor Damaged received qty'
                            WHEN t1.location_id_2 IN ('DM001AA1') AND t1.control_number_2 LIKE 'A3%' THEN 'Whse Damaged qty'
                            WHEN t1.location_id_2 LIKE 'A3%' AND t1.control_number_2 IN ('DM001AA1') THEN 'Inspected & Fixing okay qty'
                            WHEN t1.location_id_2 LIKE 'A3%' AND t1.control_number_2 IN ('NG001CK3') THEN 'Inspected & Fixing okay qty'
                            WHEN t1.location_id_2 IN ('NG001VD3') AND t1.control_number_2 IN ('NG001UP3') THEN 'Whse damaged return to venodr fixing qty'
                            WHEN t1.location_id_2 IN ('NG001VD3') AND t1.control_number_2 IN ('NG001CG3') THEN 'Whse damaged return to venodr fixing qty'
                            WHEN t1.location_id_2 IN ('NG001CK3') AND t1.control_number_2 IN ('NG001CG3') THEN 'Ashton can fix it but lack materials qty'
                            WHEN t1.location_id_2 LIKE 'A3%' AND t1.control_number_2 IN ('NG001VD3') THEN 'Vendor fixed okay or swapped qty'
                            ELSE 'Check'
                        END) <> 'Check'
                ORDER BY t1.lot_number, t1.start_tran_date, t1.start_tran_time