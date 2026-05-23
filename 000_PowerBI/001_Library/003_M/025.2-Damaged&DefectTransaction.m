// let
//     Source = Sql.Database("ashley-edw.database.windows.net", "ASHLEY_EDW", [Query="SELECT t1.wh_id,#(lf)       t1.tran_type,#(lf)       t1.description,#(lf)       t1.start_tran_date,#(lf)       CAST(t1.start_tran_time AS TIME(0)) AS star_tran_time,#(lf)       t1.end_tran_date,#(lf)       CAST(t1.end_tran_time AS TIME(0)) AS end_tran_time,#(lf)       t1.employee_id,#(lf)       t1.control_number,#(lf)       t1.line_number,#(lf)       t1.control_number_2 AS reference,#(lf)       t1.hu_id as LP#,#(lf)       t1.item_number,#(lf)       CAST(t1.lot_number AS VARCHAR(20)) AS SN,#(lf)       t1.tran_qty,#(lf)       t1.location_id AS 'FromLocation',#(lf)       t1.location_id_2 AS 'ToLocation',#(lf)       t1.employee_id_2,#(lf)       CASE#(lf)           WHEN t1.location_id_2 IN ('DM001AA1') AND t1.control_number_2 LIKE 'RS%' THEN 'Inbound Vendor Damaged received qty'#(lf)           WHEN t1.location_id_2 IN ('SH001AA1') AND t1.control_number_2 LIKE 'RS%' THEN 'Inbound Vendor Shortage Shipment'#(lf)           WHEN t1.location_id_2 IN ('EX001AA1') AND t1.control_number_2 LIKE 'RS%' THEN 'Inbound Vendor Over Shipment'#(lf)           WHEN t1.location_id_2 IN ('DM001AA1') AND t1.control_number_2 LIKE 'A3%' THEN 'Whse Damaged qty'#(lf)           WHEN t1.location_id_2 IN ('NG001MT1') AND t1.control_number_2 LIKE 'A3%' THEN 'Checking Mattress (SN received over 150 days)'#(lf)           WHEN t1.location_id_2 LIKE 'A3%' AND t1.control_number_2 IN ('DM001AA1') THEN 'Inspected & Fixing okay qty'#(lf)           WHEN t1.location_id_2 LIKE 'A3%' AND t1.control_number_2 IN ('NG001CK3') THEN 'Inspected & Fixing okay qty'#(lf)           WHEN t1.location_id_2 IN ('NG001VD3') AND t1.control_number_2 IN ('VD001AA1') THEN 'Inbound Vendor Damaged retured to vendor qty'#(lf)           WHEN t1.location_id_2 IN ('NG001VD3') AND t1.control_number_2 IN ('NG001UP3') THEN 'Whse damaged UPH return to venodr fixing qty'#(lf)           WHEN t1.location_id_2 IN ('NG001VD3') AND t1.control_number_2 IN ('NG001CG3') THEN 'Whse damaged CG return to venodr fixing qty'#(lf)           WHEN t1.location_id_2 IN ('NG001CK3') AND t1.control_number_2 IN ('NG001CG3') THEN 'Ashton can fix it but lack materials qty'#(lf)           WHEN t1.location_id_2 LIKE 'A3%' AND t1.control_number_2 IN ('NG001VD3') THEN 'Vendor fix okay or swap qty'#(lf)           WHEN t1.location_id_2 IN ('NG001OP3') AND t1.control_number_2 IN ('EX001AA1') THEN 'Inbound vendor over shipment returned to vendor'#(lf)           WHEN t1.location_id_2 LIKE 'A3%' AND t1.control_number_2 IN ('SH001AA1') THEN 'Vendor delivered qty for short shipment'#(lf)           ELSE 'Check'#(lf)       END AS Transaction_type#(lf)FROM Distribution_Warehouse_Wholesale.TranLog AS t1#(lf)WHERE t1.wh_id IN ('335')#(lf)  AND t1.start_tran_date > '2024-01-01'#(lf)  AND t1.tran_type IN ('254', '202')#(lf)  AND (CASE#(lf)           WHEN t1.location_id_2 IN ('DM001AA1') AND t1.control_number_2 LIKE 'RS%' THEN 'Inbound Vendor Damaged received qty'#(lf)           WHEN t1.location_id_2 IN ('SH001AA1') AND t1.control_number_2 LIKE 'RS%' THEN 'Inbound Vendor Shortage Shipment'#(lf)           WHEN t1.location_id_2 IN ('EX001AA1') AND t1.control_number_2 LIKE 'RS%' THEN 'Inbound Vendor Over Shipment'#(lf)           WHEN t1.location_id_2 IN ('DM001AA1') AND t1.control_number_2 LIKE 'A3%' THEN 'Whse Damaged qty'#(lf)           WHEN t1.location_id_2 IN ('NG001MT1') AND t1.control_number_2 LIKE 'A3%' THEN 'Checking Mattress (SN received over 150 days)'#(lf)           WHEN t1.location_id_2 LIKE 'A3%' AND t1.control_number_2 IN ('DM001AA1') THEN 'Inspected & Fixing okay qty'#(lf)           WHEN t1.location_id_2 LIKE 'A3%' AND t1.control_number_2 IN ('NG001CK3') THEN 'Inspected & Fixing okay qty'#(lf)           WHEN t1.location_id_2 IN ('NG001VD3') AND t1.control_number_2 IN ('VD001AA1') THEN 'Inbound Vendor Damaged retured to vendor qty'#(lf)           WHEN t1.location_id_2 IN ('NG001VD3') AND t1.control_number_2 IN ('NG001UP3') THEN 'Whse damaged UPH return to venodr fixing qty'#(lf)           WHEN t1.location_id_2 IN ('NG001VD3') AND t1.control_number_2 IN ('NG001CG3') THEN 'Whse damaged CG return to venodr fixing qty'#(lf)           WHEN t1.location_id_2 IN ('NG001CK3') AND t1.control_number_2 IN ('NG001CG3') THEN 'Ashton can fix it but lack materials qty'#(lf)           WHEN t1.location_id_2 LIKE 'A3%' AND t1.control_number_2 IN ('NG001VD3') THEN 'Vendor fix okay or swap qty'#(lf)           WHEN t1.location_id_2 IN ('NG001OP3') AND t1.control_number_2 IN ('EX001AA1') THEN 'Inbound vendor over shipment returned to vendor'#(lf)           WHEN t1.location_id_2 LIKE 'A3%' AND t1.control_number_2 IN ('SH001AA1') THEN 'Vendor delivered qty for short shipment'#(lf)           ELSE 'Check'#(lf)       END) <> 'Check'#(lf)ORDER BY t1.lot_number, t1.start_tran_date, t1.start_tran_time#(lf)", CommandTimeout=#duration(0, 1, 0, 0)]),
//     #"Changed Type" = Table.TransformColumnTypes(Source,{{"start_tran_date", type date}, {"end_tran_date", type date}})
// in
//     #"Changed Type"


let
    Source = Sql.Database("ashley-edw.database.windows.net", "ASHLEY_EDW", [
        Query = "SELECT t1.wh_id,
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
                            WHEN t1.location_id_2 IN ('SH001AA1') AND t1.control_number_2 LIKE 'RS%' THEN 'Inbound Vendor Shortage Shipment'
                            WHEN t1.location_id_2 IN ('EX001AA1') AND t1.control_number_2 LIKE 'RS%' THEN 'Inbound Vendor Over Shipment'
                            WHEN t1.location_id_2 IN ('DM001AA1') AND t1.control_number_2 LIKE 'A3%' THEN 'Whse Damaged qty'
                            WHEN t1.location_id_2 IN ('NG001MT1') AND t1.control_number_2 LIKE 'A3%' THEN 'Checking Mattress (SN received over 150 days)'
                            WHEN t1.location_id_2 LIKE 'A3%' AND t1.control_number_2 IN ('DM001AA1') THEN 'Inspected & Fixing okay qty'
                            WHEN t1.location_id_2 LIKE 'A3%' AND t1.control_number_2 IN ('NG001CK3') THEN 'Inspected & Fixing okay qty'
                            WHEN t1.location_id_2 IN ('NG001VD3') AND t1.control_number_2 IN ('VD001AA1') THEN 'Inbound Vendor Damaged retured to vendor qty'
                            WHEN t1.location_id_2 IN ('NG001VD3') AND t1.control_number_2 IN ('NG001UP3') THEN 'Whse damaged UPH return to venodr fixing qty'
                            WHEN t1.location_id_2 IN ('NG001VD3') AND t1.control_number_2 IN ('NG001CG3') THEN 'Whse damaged CG return to venodr fixing qty'
                            WHEN t1.location_id_2 IN ('NG001CK3') AND t1.control_number_2 IN ('NG001CG3') THEN 'Ashton can fix it but lack materials qty'
                            WHEN t1.location_id_2 LIKE 'A3%' AND t1.control_number_2 IN ('NG001VD3') THEN 'Vendor fix okay or swap qty'
                            WHEN t1.location_id_2 IN ('NG001OP3') AND t1.control_number_2 IN ('EX001AA1') THEN 'Inbound vendor over shipment returned to vendor'
                            WHEN t1.location_id_2 LIKE 'A3%' AND t1.control_number_2 IN ('SH001AA1') THEN 'Vendor delivered qty for short shipment'
                            ELSE 'Check'
                        END AS Transaction_type,
                        CASE 
                            WHEN substring(t1.item_number,1,4) LIKE '100-' THEN 'CG' 
                            WHEN substring(t1.item_number,1,1) IN ('1','2','3','4','5','6','7','8','9','U') then 'UPH'
                            WHEN substring(t1.item_number,1,1) IN ('A','B','D','E','G','H','L','M','P','W','Z') then 'CG'
                            ELSE 'Check' END AS Item_Type 
                FROM Distribution_Warehouse_Wholesale.TranLog AS t1
                WHERE t1.wh_id IN ('335')
                    AND t1.start_tran_date > '2024-01-01'
                    AND t1.tran_type IN ('254', '202')
                    AND (CASE
                            WHEN t1.location_id_2 IN ('DM001AA1') AND t1.control_number_2 LIKE 'RS%' THEN 'Inbound Vendor Damaged received qty'
                            WHEN t1.location_id_2 IN ('SH001AA1') AND t1.control_number_2 LIKE 'RS%' THEN 'Inbound Vendor Shortage Shipment'
                            WHEN t1.location_id_2 IN ('EX001AA1') AND t1.control_number_2 LIKE 'RS%' THEN 'Inbound Vendor Over Shipment'
                            WHEN t1.location_id_2 IN ('DM001AA1') AND t1.control_number_2 LIKE 'A3%' THEN 'Whse Damaged qty'
                            WHEN t1.location_id_2 IN ('NG001MT1') AND t1.control_number_2 LIKE 'A3%' THEN 'Checking Mattress (SN received over 150 days)'
                            WHEN t1.location_id_2 LIKE 'A3%' AND t1.control_number_2 IN ('DM001AA1') THEN 'Inspected & Fixing okay qty'
                            WHEN t1.location_id_2 LIKE 'A3%' AND t1.control_number_2 IN ('NG001CK3') THEN 'Inspected & Fixing okay qty'
                            WHEN t1.location_id_2 IN ('NG001VD3') AND t1.control_number_2 IN ('VD001AA1') THEN 'Inbound Vendor Damaged retured to vendor qty'
                            WHEN t1.location_id_2 IN ('NG001VD3') AND t1.control_number_2 IN ('NG001UP3') THEN 'Whse damaged UPH return to venodr fixing qty'
                            WHEN t1.location_id_2 IN ('NG001VD3') AND t1.control_number_2 IN ('NG001CG3') THEN 'Whse damaged CG return to venodr fixing qty'
                            WHEN t1.location_id_2 IN ('NG001CK3') AND t1.control_number_2 IN ('NG001CG3') THEN 'Ashton can fix it but lack materials qty'
                            WHEN t1.location_id_2 LIKE 'A3%' AND t1.control_number_2 IN ('NG001VD3') THEN 'Vendor fix okay or swap qty'
                            WHEN t1.location_id_2 IN ('NG001OP3') AND t1.control_number_2 IN ('EX001AA1') THEN 'Inbound vendor over shipment returned to vendor'
                            WHEN t1.location_id_2 LIKE 'A3%' AND t1.control_number_2 IN ('SH001AA1') THEN 'Vendor delivered qty for short shipment'
                            ELSE 'Check'
                        END) <> 'Check'
                ORDER BY t1.lot_number, t1.start_tran_date, t1.start_tran_time",
        CommandTimeout = #duration(0, 1, 0, 0)
    ]),
    #"Changed Type" = Table.TransformColumnTypes(Source, {
        {"start_tran_date", type date},
        {"end_tran_date", type date}
    })
in
    #"Changed Type"