/*
================================================================================
002_Inventory_Management.sql
??????? - IMHIST, TAGINVD, t_stored_item
================================================================================
????????????????????
???????????????????
================================================================================
*/

-- ============================================================================
-- 002.1 ?????????????
-- ============================================================================

/*
TCODE ???? (??????)?
  'IA' = ???? (Inventory Adjustment)
  'IS' = ???? (Inventory Shift/Transfer)
  'SA' = ?? (Sales)
  'SS' = ?? (Scan/Spot Check)
  
HOUSE ?????
  '335' = Ashton (HJ???)
  '51'  = MIL (????)
  '31','33','34','35' = WNK ??????
  '3','35' = AFI??

???????
  TRQTY = ????
  TRAMT = ????
  STPCS = ????
  ENTUM = ????
*/

-- [????]: AFI?????????
select top 10 * 
from Manufacturing_Inventory_AFI.IMHIST 
where HOUSE = '335' 
  and TCODE = 'IA' 
  and UPDDT > '1260101'
order by UPDDT desc, UPDTM desc;

-- [????]: MIL?????????
select * 
from Manufacturing_Inventory_MIL.IMHIST 
where HOUSE = '51' 
  and TCODE = 'IA' 
  and UPDDT > '1260101'
order by UPDDT desc, UPDTM desc;

-- [????]: WNK?????????
select * 
from Manufacturing_Inventory_WNK.IMHIST 
where HOUSE IN ('31','33','35','34') 
  and TCODE IN ('IA','IS','SS')
  and UPDDT > '1260101'
order by HOUSE, UPDDT desc;

-- ============================================================================
-- 002.2 ???????????????
-- ============================================================================

-- [????]: AFI???????????
select 
    t1.HOUSE, 
    t1.TRMID, 
    t1.ITNBR, 
    t1.UPDDT, 
    t1.UPDTM, 
    t1.TRQTY, 
    t1.TRAMT, 
    t1.STPCS, 
    t1.ENTUM, 
    t1.REFNO, 
    t1.REASN, 
    t1.LLOCN,
    T2.ITDSC as ItemDescription,
    T2.UNMSR as UnitOfMeasure,
    T2.ITCLS as ItemClass,
    T2.WEGHT as Weight,
    T2.B2Z95S as UnitCube,
    T3.STNBR as StoreName
from AMFLIBA.IMHIST t1 
left join AMFLIBA.ITMRVA t2 on t1.ITNBR = t2.ITNBR 
left join AMFLIBA.WHSMST t3 on t1.HOUSE = t3.WHID
where t2.ITNBR = t1.ITNBR 
  and t2.STID = t3.STID 
  and t1.HOUSE = t3.WHID 
  and t1.HOUSE = '335' 
  and t1.UPDDT >= '1260101'
  and t1.TRQTY <> 0
  and T1.TCODE in ('IA','IS','SS')
order by t1.UPDDT desc, t1.UPDTM desc;

-- ============================================================================
-- 002.3 ?????? (t_stored_item)
-- ============================================================================

-- [????]: ???????????
select * 
from Distribution_Warehouse_Wholesale.t_stored_item 
where wh_id = '335'
order by item_number, location_id;

-- [????]: ???????
select * 
from Distribution_Warehouse_Wholesale.t_stored_item 
where wh_id = '335'
  and location_id like 'A3%'
order by item_number, actual_qty desc;

-- [????]: ?????????
select * 
from Distribution_Warehouse_Wholesale.t_stored_item 
where wh_id = '335'
  and item_number = 'B742-31'
order by location_id;

-- [????]: ?????????
select 
    item_number, 
    wh_id,
    sum(actual_qty) as TotalQty,
    count(distinct location_id) as LocationCount,
    sum(case when status = 'A' then actual_qty else 0 end) as ActiveQty,
    sum(case when status = 'H' then actual_qty else 0 end) as HeldQty
from Distribution_Warehouse_Wholesale.t_stored_item
where wh_id = '335'
group by item_number, wh_id
order by TotalQty desc;

-- [????]: ??????????
select 
    loc.TypeDescription,
    sto.wh_id,
    count(distinct sto.location_id) as LocationCount,
    sum(sto.actual_qty) as TotalQty
from Distribution_Warehouse_Wholesale.t_stored_item sto
join Distribution_Warehouse_Wholesale.t_location loc 
    on sto.location_id = loc.location_id
    and sto.wh_id = loc.wh_id
where sto.wh_id = '335'
group by loc.TypeDescription, sto.wh_id
order by TotalQty desc;

-- ============================================================================
-- 002.4 ??????
-- ============================================================================

-- [????]: Ashton?????????
select top 100 * 
from Distribution_Warehouse_Wholesale.t_location 
where wh_id = '335'
order by location_id;

-- [????]: MIL?????????
select location_id, COUNT(*) as cnt
from Distribution_Warehouse_Wholesale.t_location
where wh_id = '51' 
  and location_id like 'US%'
group by location_id
having COUNT(*) > 1;

-- [????]: ????????
/*
TypeDescription ?????
  'I' = ??? (Inbound)
  'M' = ?? (Middle/Mixed)
  'P' = ??? (Pick)
  'X' = ???? (eXclude)
  'S' = ??? (Storage)
  'D' = ??? (Disabled/Drop)
  'V' = ?? (oVer-head)
*/

select distinct 
    wh_id,
    TypeDescription,
    count(*) as LocationCount
from Distribution_Warehouse_Wholesale.t_location
group by wh_id, TypeDescription
order by wh_id, TypeDescription;

-- ============================================================================
-- 002.5 ?????? (TAGINVD)
-- ============================================================================

-- [????]: ?????????
select top 10 * 
from Manufacturing_Inventory_AFI.TAGINVD 
where TDWHSE = '51'
order by TDDATE desc;

-- [????]: ??????
select 
    TDWHSE,
    count(*) as TagCount,
    sum(TDQTY) as TotalQty
from Manufacturing_Inventory_AFI.TAGINVD
group by TDWHSE
order by TotalQty desc;

-- ============================================================================
-- 002.6 ??????
-- ============================================================================

-- [????]: ????????????
select 
    HOUSE,
    TCODE,
    count(*) as TransactionCount,
    sum(TRQTY) as TotalQty,
    sum(TRAMT) as TotalAmount,
    max(UPDDT) as LastDate
from Manufacturing_Inventory_AFI.IMHIST
where HOUSE = '335'
  and UPDDT > '1260101'
group by HOUSE, TCODE
order by TransactionCount desc;

-- [????]: ????????????
select 
    CAST('20' + SUBSTR(CAST(t1.UPDDT AS VARCHAR(5)), 1, 2) + '-' +
         SUBSTR(CAST(t1.UPDDT AS VARCHAR(5)), 3, 2) + '-' +
         SUBSTR(CAST(t1.UPDDT AS VARCHAR(5)), 5, 2) AS DATE) as TransactionDate,
    t1.TCODE,
    count(*) as TransactionCount,
    sum(t1.TRQTY) as TotalQty
from Manufacturing_Inventory_MIL.IMHIST t1
where t1.HOUSE = '51'
  and t1.UPDDT >= '1260101'
group by CAST('20' + SUBSTR(CAST(t1.UPDDT AS VARCHAR(5)), 1, 2) + '-' +
             SUBSTR(CAST(t1.UPDDT AS VARCHAR(5)), 3, 2) + '-' +
             SUBSTR(CAST(t1.UPDDT AS VARCHAR(5)), 5, 2) AS DATE),
        t1.TCODE
order by TransactionDate desc, t1.TCODE;

-- ============================================================================
-- 002.7 ???????
-- ============================================================================

-- [????]: ????ACTIVE vs HELD??
select 
    wh_id,
    status,
    count(*) as LocationCount,
    sum(actual_qty) as TotalQty,
    avg(actual_qty) as AvgQty
from Distribution_Warehouse_Wholesale.t_stored_item
where wh_id = '335'
group by wh_id, status
order by TotalQty desc;

-- [????]: ?????????????
select * 
from Distribution_Warehouse_Wholesale.t_stored_item
where wh_id = '335'
  and actual_qty = 0
  and status = 'A'
order by location_id;

-- [????]: ???????
select 
    sto.item_number,
    sto.location_id,
    sto.actual_qty,
    itm.unit_weight,
    itm.unit_volume,
    itm.commodity_code,
    loc.TypeDescription,
    sto.actual_qty * itm.unit_weight as WeightValue,
    sto.actual_qty * itm.unit_volume as CubeValue
from Distribution_Warehouse_Wholesale.t_stored_item sto
join Distribution_Warehouse_Wholesale.t_item_master itm 
    on sto.item_number = itm.item_number
    and sto.wh_id = itm.wh_id
join Distribution_Warehouse_Wholesale.t_location loc
    on sto.location_id = loc.location_id
    and sto.wh_id = loc.wh_id
where sto.wh_id = '335'
  and sto.actual_qty > 0
order by CubeValue desc;

-- ============================================================================
-- 002.8 ???????????
-- ============================================================================

-- [????]: ?????????????
select * 
from Distribution_Warehouse_Wholesale_History.t_stored_item
where wh_id = '335'
  and item_number = 'B742-31'
order by SnapshotDatetime desc;

-- [????]: ??????
select 
    item_number,
    wh_id,
    cast(SnapshotDatetime as date) as SnapshotDate,
    sum(actual_qty) as TotalQty,
    count(distinct location_id) as LocationCount
from Distribution_Warehouse_Wholesale_History.t_stored_item
where wh_id = '335'
  and item_number = 'B742-31'
group by item_number, wh_id, cast(SnapshotDatetime as date)
order by SnapshotDate desc;

-- ============================================================================
-- 002.9 ???????
-- ============================================================================

-- [????]: ???????????
select 
    t1.start_tran_date,
    t1.item_number,
    t1.control_number_2,
    sum(t1.tran_qty) as qty
from Distribution_Warehouse_Wholesale.TranLog t1
where t1.wh_id = '335'
  and t1.tran_type = '347'
  and t1.start_tran_date >= '2025-04-06'
  and t1.item_number = '5200323'
group by t1.start_tran_date, t1.item_number, t1.control_number_2
order by t1.start_tran_date desc;

-- [????]: ???????????
select 
    t1.start_tran_date,
    t1.item_number,
    t1.control_number_2,
    sum(t1.tran_qty) as qty
from Distribution_Warehouse_Wholesale.TranLog t1
where t1.wh_id = '335'
  and t1.tran_type in ('151','951')
  and t1.start_tran_date >= '2025-04-06'
  and t1.item_number = '5200323'
group by t1.start_tran_date, t1.item_number, t1.control_number_2
order by t1.start_tran_date desc;

-- ============================================================================
-- 002.10 ????????????
-- ============================================================================

-- [????]: ?????????
select 
    sto.item_number,
    sto.location_id,
    sto.actual_qty,
    sto.status,
    itm.description,
    itm.commodity_code,
    itm.class_id,
    itm.unit_weight,
    itm.unit_volume,
    itm.pick_put_id,
    loc.TypeDescription
from Distribution_Warehouse_Wholesale.t_stored_item sto
join Distribution_Warehouse_Wholesale.t_item_master itm
    on sto.item_number = itm.item_number
    and sto.wh_id = itm.wh_id
join Distribution_Warehouse_Wholesale.t_location loc
    on sto.location_id = loc.location_id
    and sto.wh_id = loc.wh_id
where sto.wh_id = '335'
  and sto.item_number = 'R80121'
  and sto.status = 'A'
order by sto.location_id;

-- [????]: ??????????
select 
    itm.commodity_code,
    itm.class_id,
    count(distinct sto.location_id) as LocationCount,
    sum(sto.actual_qty) as TotalQty
from Distribution_Warehouse_Wholesale.t_stored_item sto
join Distribution_Warehouse_Wholesale.t_item_master itm
    on sto.item_number = itm.item_number
    and sto.wh_id = itm.wh_id
where sto.wh_id = '335'
group by itm.commodity_code, itm.class_id
order by TotalQty desc;

================================================================================
EOF - Inventory Management Queries Complete
================================================================================
*/
