let
    RangeStart = #datetime(2025, 1, 1, 7, 0, 0),
    RangeEnd = DateTime.From(Date.StartOfDay(DateTime.LocalNow())) + #duration(0,7,0,0),

    Source = Sql.Database(
        "ashley-edw.database.windows.net", 
        "ASHLEY_EDW", 
        [
            CommandTimeout = #duration(0, 10, 0, 0), 
            Query = "
            
DECLARE @wh_id_list AS VARCHAR(500);
DECLARE @tran_list AS VARCHAR(500);
DECLARE @StartDate DATETIME = '" & DateTime.ToText(RangeStart, "yyyy-MM-dd HH:mm:ss") & "';
DECLARE @EndDate DATETIME = '" & DateTime.ToText(RangeEnd, "yyyy-MM-dd HH:mm:ss") & "';

SET @wh_id_list = '335,335';
SET @tran_list = '151,183,951,321,363,372,347,252,254,262,202';

With itm as (
    select distinct
        t3.ITNBR as item_number,
        t1.wh_id,
        t1.description,
        t1.commodity_code,
        t4.PICKPUT as pick_put_id,
        t3.ITCLS,
        t3.B2Z95S,
        t3.B2Z95S * 0.028317 as Unit_CBM,
        CASE
            WHEN LEFT(t3.ITNBR, 4) = '100-'
                OR LEFT(t3.ITNBR, 1) IN ('A', 'B', 'D', 'H', 'L', 'Q', 'R', 'T', 'W', 'M', 'E')
                OR t3.ITNBR IN ('7340321', '9910160', '4400021', '4400022', '7390160',
                                '5920230', '1300021', '1660021', '6280260')
            THEN 'CG'
            ELSE 'UPH'
        END AS product,
        t4.TIHIUNLD,
        t4.ITMCLSID,
        t4.UNITSWIDE,
        t4.UNITLAYERS,
        t4.UNITSDEEP,
        t4.SCOOPQTY,
        t4.SKIDSIZE
    from (SELECT a1.ITNBR, a1.ITCLS, a1.B2Z95S FROM MasterData_ItemMaster_AFI.ITMRVA AS a1 WHERE a1.STID IN ('335')) as t3
    left join (select a1.item_number, a1.wh_id, a1.description, a1.commodity_code from Distribution_Warehouse_Wholesale.t_item_master as a1 where a1.wh_id = '335') as t1
        on t1.item_number = t3.ITNBR
    left join (SELECT a2.ITNBR,a2.PICKPUT,a2.TIHIUNLD,a2.ITMCLSID,a2.UNITSWIDE,a2.UNITLAYERS,a2.UNITSDEEP,a2.SCOOPQTY,a2.SKIDSIZE
                      FROM MasterData_ItemMaster_AFI.ITBEXT AS a2 WHERE a2.HOUSE IN ('335')) as t4
        ON t3.ITNBR = t4.ITNBR
),
trx AS (
    SELECT
        t1.item_number,
        i.commodity_code,
        i.pick_put_id,
        case when t1.lot_number is null then 'no_sn' else t1.lot_number end as lot_number,
        t1.wh_id as whse,
        t1.location_id as from_loc,
        t1.location_id_2 as to_loc,
        t1.control_number as wa_order,
        t1.control_number_2 as reference,
        t1.tran_qty,
        t1.tran_type,
        t1.start_tran_date,
        t1.start_tran_time,
        t1.end_tran_date,
        t1.end_tran_time,
        t1.elapsed_time,
        CAST(t1.start_tran_date AS DATETIME) + CAST(t1.start_tran_time AS DATETIME) AS trx_date_time,
        CASE
            WHEN CAST(t1.start_tran_time AS TIME) BETWEEN '07:00:00' AND '18:59:59' THEN 'D'
            ELSE 'N'
        END AS shift,
        CASE
            WHEN t1.tran_type in ('151','183','951') then 'Unloading'
            WHEN t1.tran_type in ('321') then 'Loading'
            WHEN t1.tran_type in ('363','372') then 'Picking'
            WHEN t1.tran_type in ('347') then 'Piece shipped'
            WHEN t1.tran_type in ('252','262') then 'Replenishment'
            WHEN t1.tran_type in ('254') then 'Put away'
            ELSE 'not_pph_trx'
        END AS pph_type
    FROM (
        SELECT *
        FROM Distribution_Warehouse_Wholesale.TranLog
        WHERE wh_id IN (SELECT TRIM(value) FROM STRING_SPLIT(@wh_id_list, ','))
            AND tran_type IN (SELECT TRIM(value) FROM STRING_SPLIT(@tran_list, ','))
            AND CAST(start_tran_date AS DATETIME) + CAST(start_tran_time AS DATETIME) >= @StartDate
            AND CAST(start_tran_date AS DATETIME) + CAST(start_tran_time AS DATETIME) < @EndDate
    ) AS t1
    LEFT JOIN itm as i on t1.item_number = i.item_number and t1.wh_id = i.wh_id
)
SELECT 
    t.*,
    CONCAT(CAST(t.start_tran_date AS VARCHAR(20)),'_',t.tran_type) as emp_date_job_string
FROM trx AS t
ORDER BY t.trx_date_time"
        ]
    )
in
    Source