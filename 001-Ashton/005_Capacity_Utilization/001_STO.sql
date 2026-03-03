-- BI Asthon Whse Capacity and Utilizatiaon on Dec.12.2024 by Jim,Shen
WITH sto AS
         (SELECT *
          FROM Distribution_Warehouse_Wholesale.t_stored_item AS a1
          WHERE a1.wh_id IN ('335')),
 itemmaster AS (SELECT i.ITNBR,
                       i.ITCLS,
                       i.ITDSC,
                       i.B2Z95S,
                       i.B2Z95S * 0.028317 as Unit_CBM,
--                        CASE
--                            WHEN i.ITCLS NOT LIKE 'Z%' THEN 'RP'
--                            WHEN i2.ITMCLSID LIKE 'UPH%' THEN 'UPH'
--                            WHEN i2.ITMCLSID LIKE 'PAL%' THEN 'CG'
--                            WHEN i2.ITMCLSID LIKE 'SMALL%' THEN 'CG'
--                            WHEN i2.ITMCLSID LIKE 'FLOOR%' THEN 'BULK'
--                            WHEN i2.ITMCLSID LIKE 'RUG%' THEN 'RUG'
--                            WHEN i2.ITMCLSID LIKE 'RAILS%' THEN 'RAIL'
--                            ELSE 'CHECK' END AS product,
                       CASE
                           WHEN i.ITCLS NOT LIKE 'Z%' THEN 'RP'
                           WHEN i2.ITMCLSID LIKE 'UPH%' THEN 'UPH'
                           WHEN i.ITDSC LIKE '%RUG%' THEN 'ACCESSORY'
                           WHEN i.ITDSC LIKE '%RECLI%' THEN 'UPH'
                           WHEN i.ITDSC LIKE '%SOFA%' AND i.ITDSC NOT LIKE '%SOFA%TABLE%' THEN 'UPH'
                           WHEN i.ITDSC LIKE '%LOVE%' THEN 'UPH'
                           WHEN i2.ITMCLSID LIKE 'PAL%' THEN 'CG'
                           WHEN i2.ITMCLSID LIKE 'SMALL%' THEN 'CG'
                           WHEN i2.ITMCLSID LIKE 'FLOOR%' THEN 'BULK'
                           WHEN i2.ITMCLSID LIKE 'RUG%' THEN 'ACCESSORY'
                           WHEN i2.ITMCLSID LIKE 'RAILS%' THEN 'RAILS'
                           WHEN i.ITNBR LIKE 'PA%' THEN 'UPH'
                           WHEN SUBSTRING(i.ITNBR, 1, 1) IN ('0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'U') THEN 'UPH'
                           WHEN SUBSTRING(i.ITNBR, 1, 1) IN ('A', 'D', 'E', 'H', 'L', 'M', 'P', 'Q', 'R', 'T', 'W','Z') THEN 'CG'
                           WHEN i2.PICKPUT in ('PALLT') THEN 'CG'
                           WHEN i2.PICKPUT in ('UPH') THEN 'UPH'
                        ELSE 'CHECK' END AS product,
--                     SOFA TABLE
                     i2.TIHIUNLD,
                     i2.PICKPUT,
                     i2.ITMCLSID,
                     i2.UNITSWIDE,
                     i2.UNITLAYERS,
                     i2.UNITSDEEP,
                     i2.SCOOPQTY,
                     i2.SKIDSIZE
                FROM (SELECT * FROM MasterData_ItemMaster_AFI.ITMRVA AS a1 WHERE a1.STID IN ('335')) AS i
                         LEFT JOIN (SELECT *
                                    FROM MasterData_ItemMaster_AFI.ITBEXT AS a2
                                    WHERE a2.HOUSE IN ('335')) as i2 ON i.ITNBR = i2.ITNBR
    ),
Loc AS (
    SELECT *
    FROM Distribution_Warehouse_Wholesale.t_location as a2
    WHERE a2.wh_id IN ('335')
)
SELECT
    s.sequence,s.item_number,s.actual_qty,s.unavailable_qty,s.status,s.wh_id,
    s.location_id,l.TypeDescription, s.fifo_date,s.expiration_date,s.reserved_for,
    s.lot_number,s.inspection_code,s.serial_number,s.type,s.put_away_location,
    SUBSTRING(s.item_number,1,1) AS first5,
    i.product,
    CASE WHEN s.location_id LIKE 'A3%' THEN 'In Racking Location' WHEN s.location_id LIKE 'RS%' THEN 'Receiving Stage' WHEN s.location_id LIKE 'S%' THEN 'Shipping Stage' ELSE 'Others' END as Loc_Type,
    'Phumy' as Phumy,
    i.Unit_CBM,
    i.ITMCLSID,
    CASE WHEN i.product = 'UPH' and i.Unit_CBM = 0 THEN  s.actual_qty* 46.828 * 0.028317    -- 46.828 is Phumy UPH average unit ft3
         WHEN i.product = 'RUG' and i.Unit_CBM = 0 THEN  s.actual_qty * 0.1          --  0.1 is Phumy accessory average unit CBM
         WHEN i.product = 'BULK' and i.Unit_CBM = 0 THEN  s.actual_qty * 0.8          --  0.1 is Phumy accessory average unit CBM
         WHEN i.product = 'CG' and i.Unit_CBM = 0 THEN  s.actual_qty * 8.592 * 0.028317     --  8.592 is Phumy CG average unit ft3
         WHEN i.product = 'RP' and i.Unit_CBM = 0 THEN  s.actual_qty * 0.001
         WHEN i.product = 'RAIL' and i.Unit_CBM = 0 THEN  s.actual_qty * 0.1
         WHEN i.product = 'CHECK' and i.Unit_CBM = 0 THEN  s.actual_qty * 0.001
         ELSE   i.Unit_CBM*s.actual_qty  END AS CBM,
    i.SCOOPQTY,
    CEILING(CASE
                WHEN i.SCOOPQTY = 0  THEN 0
                WHEN i.ITMCLSID = 'FLOOR' THEN 0
                ELSE s.actual_qty / i.SCOOPQTY END) AS actual_pallet_Qty

FROM sto as s
LEFT JOIN loc as l ON s.location_id = l.location_id AND s.wh_id = l.wh_id
LEFT JOIN itemmaster as i on s.item_number = i.ITNBR
ORDER BY s.location_id
    