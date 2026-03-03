-- 015_Asia_Inventory_Age, Feb.17.2025 created by Jim,Shen
DECLARE @wh_id_list NVARCHAR(MAX) = '335,35,34,33,31,51';
DECLARE @StartDate DATETIME;
DECLARE @EndDate DATETIME;

SET @StartDate = DATEADD(DAY, -7, CAST(CAST(GETDATE() AS DATE) AS DATETIME)) + '07:00:00.000';
SET @EndDate = CAST(CAST(GETDATE() AS DATE) AS DATETIME) + '06:59:59.997';

WITH sn_born_date AS (
    SELECT
        t.wh_id,
        t.item_number,
        t.lot_number,
        MIN(t.start_tran_date) AS sn_received_date
    FROM Distribution_Warehouse_Wholesale.TranLog AS t
    WHERE t.wh_id IN ('335','51','35','34','33','31') AND t.lot_number IS NOT NULL
    GROUP BY t.wh_id,t.item_number, t.lot_number
),
item_master AS (
    SELECT
        a.item_number,
        a.description,
        a.uom,
        a.inventory_type,
        a.commodity_code,
        a.wh_id,
        a.class_id,
        a.unit_weight,
        a.unit_volume,
        a.nested_volume,
        a.pick_put_id,
        CASE
            WHEN a.wh_id IN ('31') AND a.commodity_code LIKE 'Z%' THEN 'UPH'
            WHEN a.wh_id IN ('31') AND a.commodity_code NOT LIKE 'Z%' THEN 'RP'
            WHEN a.wh_id = '335' AND a.commodity_code NOT LIKE 'Z%' THEN 'CG' -- RP
            WHEN a.wh_id = '335' AND a.class_id IN ('RPFG') THEN 'RP'
            WHEN a.wh_id = '335' AND a.class_id IN ('SMALL', 'PAL3H', 'PAL5H', 'RAILS', 'FLOOR', 'RPFG', 'FLOOROP', 'PAL5L', 'RUGS') THEN 'CG'
            WHEN a.wh_id = '335' AND a.class_id LIKE 'UPH%' THEN 'UPH'
            WHEN a.wh_id = '335' AND a.class_id IS NULL AND a.pick_put_id = 'UPH' THEN 'UPH'
            WHEN a.wh_id = '335' AND a.class_id IS NULL AND a.pick_put_id = 'PALLT' THEN 'CG'
            WHEN a.wh_id = '335' AND LEFT(a.item_number, 1) IN ('A', 'D', 'E', 'H', 'K', 'L', 'M', 'P', 'Q', 'R', 'T', 'W') THEN 'CG'
            WHEN a.wh_id = '335' AND LEN(a.item_number) > 7 THEN 'CG'
            WHEN a.wh_id = '335' AND LEFT(a.item_number, 1) IN ('1', '2', '3', '4', '5', '6', '7', '8', '9', 'U') THEN 'UPH'
            WHEN a.wh_id = '51' AND a.commodity_code LIKE 'TAF%' THEN 'RP'
            WHEN a.wh_id = '51' AND a.commodity_code IN ('MTA','CTA','FFR','MVN') THEN 'RP'
            WHEN a.wh_id = '51' AND a.commodity_code IN ('PACS','ZACM','WVVG') THEN 'UnKits'
            WHEN a.wh_id = '51' AND a.commodity_code LIKE 'Z%K' THEN 'UnKits'
            WHEN a.wh_id = '51' AND a.commodity_code IN ('ZDTP','ZKBP') THEN 'Pillow'
            WHEN a.wh_id = '51' AND a.commodity_code IN ('ZASU','ZMLH','ZMLR','ZUSR','ZUSU','ZVUC','ZXUC','ZUSU','ZUMU','ZAMU','ZASM','ZASR','ZDMA','ZMUC','ZSUS','ZUMS','ZUSM','ZVMA','ZVUS','ZXLH','ZXLM','ZXLR','ZXMS','ZXMU') THEN 'UPH'
            WHEN a.wh_id = '51' AND a.commodity_code IN ('ZDAA','ZDAE','ZDWC','ZDAY','ZVAA','ZDAB','ZDAW','ZDYB','ZDBC','ZABC','ZECD','ZEBR') THEN 'CG'
            WHEN a.wh_id = '51' AND a.commodity_code IN ('ZBMA','ZKIS','ZAIS','ZKBA','ZNFR','ZKBP','ZNFR','ZAIS') THEN 'Bedding'
            WHEN a.wh_id = '51' AND a.commodity_code LIKE 'Z%' AND LEN(a.item_number) = 6 and a.item_number like 'M%' THEN 'Bedding'
            WHEN a.wh_id = '51' AND a.commodity_code IN ('WPLS') THEN 'Plastics'
            WHEN a.wh_id = '51' AND a.commodity_code IN ('WVBC','WVCS') THEN 'Foundation'
            WHEN a.wh_id = '51' AND a.commodity_code IN ('PANL') THEN 'Panel'
            WHEN a.wh_id = '51' AND a.commodity_code IN ('ZKIZ','BBFR','WVHC') THEN 'ZipperCover'
            WHEN a.wh_id = '51' AND a.commodity_code NOT LIKE 'Z%' THEN 'RawMaterial'
            ELSE 'CHECK'
        END AS product,
        CASE
            WHEN a.wh_id IN ('335') THEN '335'
            WHEN a.wh_id IN ('51') THEN '51'
            WHEN a.wh_id2 IN ('35')  THEN '35'
            WHEN a.wh_id2 IN ('34')  THEN '34'
            WHEN a.wh_id2 IN ('33')  THEN '33'
            WHEN a.wh_id2 IN ('31')  THEN '31'
            WHEN a.wh_id2 IS NULL THEN a.wh_id
        ELSE 'Check' END as WhsID
    FROM Distribution_Warehouse_Wholesale.t_item_master AS a
    WHERE   (CASE
            WHEN a.wh_id IN ('335') THEN '335'
            WHEN a.wh_id IN ('51') THEN '51'
            WHEN a.wh_id2 IN ('35')  THEN '35'
            WHEN a.wh_id2 IN ('34')  THEN '34'
            WHEN a.wh_id2 IN ('33')  THEN '33'
            WHEN a.wh_id2 IN ('31')  THEN '31'
        ELSE 'Check' END) IN ('335','51','35','34','33','31')
),
wh_sn AS (
    SELECT
        t1.wh_id,
        t1.item_number,
        t1.location_id,
        t1.serial_number,
        t1.received_date,
        CONVERT(DATE, GETDATE()) as Data_collected_Date,
        ISNULL(t2.sn_received_date, t1.received_date) as sn_received_date
    FROM Distribution_Warehouse_Wholesale.t_serial_active AS t1
    LEFT JOIN sn_born_date as t2
        on t1.wh_id = t2.wh_id and t1.serial_number = t2.lot_number
    WHERE t1.wh_id IN ('335','51','35','34','33','31')
        AND t1.serial_no_status NOT IN ('O')
        AND t1.master_status NOT IN ('S')
)
------------------ main query -------------------
SELECT
    t1.*,
    t3.product,
    t3.description,
    t3.inventory_type,
    t3.commodity_code,
    t3.wh_id,
    t3.class_id,
    t3.pick_put_id,
    CASE
        WHEN DATEDIFF(DAY, t1.sn_received_date, GETDATE()) <= 30 THEN 'a. 0 ~ 1 Month'
        WHEN DATEDIFF(DAY, t1.sn_received_date, GETDATE()) <= 60 THEN 'b. 1 ~ 2 Months'
        WHEN DATEDIFF(DAY, t1.sn_received_date, GETDATE()) <= 90 THEN 'c. 2 ~ 3 Months'
        WHEN DATEDIFF(DAY, t1.sn_received_date, GETDATE()) <= 180 THEN 'd. 3 ~ 6 Months'
        WHEN DATEDIFF(DAY, t1.sn_received_date, GETDATE()) <= 365 THEN 'e. 6 ~ 12 Months'
        WHEN DATEDIFF(DAY, t1.sn_received_date, GETDATE()) <= 730 THEN 'f. 1 ~ 2 Years'
        WHEN DATEDIFF(DAY, t1.sn_received_date, GETDATE()) <= 1095 THEN 'g. 2 ~ 3 Years'
        ELSE 'h. 3+ Years'
    END AS age_range
FROM wh_sn AS t1
LEFT JOIN item_master AS t3
    ON t1.wh_id = t3.WhsID
    AND t1.item_number = t3.item_number
ORDER BY t1.wh_id, t1.item_number, t1.serial_number