/*
ashley-edw.database.windows.net
ASHLEY_EDW

select * from dw_developer.tabledictionary where tpkCreated > '2025-05-01'
-- 临时刷新频率映射表（建议你先用 # 临时表测试）
WITH RefreshRateMapping AS (
    SELECT 1 AS tpkRefreshRate, '每 8 小时' AS FrequencyDescription UNION ALL
    SELECT 2, '每 4 小时' UNION ALL
    SELECT 3, '每 3 小时' UNION ALL
    SELECT 4, '每 2 小时' UNION ALL
    SELECT 6, '每小时' UNION ALL
    SELECT 8, '每 30 分钟' UNION ALL
    SELECT 12, '每 20 分钟' UNION ALL
    SELECT 24, '每 15 分钟' UNION ALL

    SELECT 26, '每天 1 次（成本核算）' UNION ALL
    SELECT 48, '每天 2 次（早晚）' UNION ALL
    SELECT 72, '每 20 分钟 (特殊调度)' UNION ALL
    SELECT 96, '每 15 分钟 (快速刷新)' UNION ALL
    SELECT 9999, '未知 / 手动触发'
)


SELECT TOP 10 *  
TABLE_SCHEMA,
TABLE_NAME,
COLUMN_NAME,
DATA_TYPE,
CHARACTER_MAXIMUM_LENGTH
FROM INFORMATION_SCHEMA.COLUMNS
WHERE COLUMN_NAME LIKE '$%'
ORDER BY TABLE_NAME, ORDINAL_POSITION;




SELECT top 10 * FROM INFORMATION_SCHEMA.TABLES as t WHERE t.table_schema ='Distribution_Warehouse_Wholesale' and t.TABLE_NAME LIKE '%tran%'

SELECT TOP 10* FROM MasterData_IT.PowerBIUsage AS t
Select * from dw_developer.tabledictionary where tpkSchemaName = 'MasterData_IT'
Select * from dw_developer.tabledictionary where tpkSchemaName like '%codis%'

select * from dw_developer.tabledictionary where tpktablename like '%PowerBIUsage%'
select * from dw_developer.tabledictionary where tpktablename like '%asn%'
select * from dw_developer.tabledictionary where tpktablename = 't_asn'
select * from dw_developer.tabledictionary where tpktablename = 'ASN_Detail'
select * from dw_developer.tabledictionary where tpktablename = 'Trailer'
select * from dw_developer.tabledictionary where tpktablename = 't_trailer_asn'
select * from dw_developer.tabledictionary where tpktablename = 'YaLocation'
select * from dw_developer.tabledictionary where tpktablename = 't_po_master'
select top 10 * from dw_developer.tabledictionary where tpkSchemaName like '%t_serial%'
select top 10 * from dw_developer.tabledictionary where tpkTableName like '%ATPDIT%'
select  * from dw_developer.tabledictionary where tpkTableName like '%not%invoice%'
select  * from dw_developer.tabledictionary where tpkTableName like '%t_stored%'          2025-05-19 19:26:01.000
select  * from dw_developer.tabledictionary where tpkTableName like '%TripAvailableSTO%'    2025-05-19 18:18:51.613
select  * from dw_developer.tabledictionary where tpkTableName like '%TripAvailableSTO%'    2025-05-19 18:18:51.613
select  * from dw_developer.tabledictionary where tpkTableName like '%TripAvailableSTO%'    2025-05-19 18:18:51.613
select * from dw_developer.tabledictionary where tpktablename like '%TripAvailableSTO%'
select top 10 * from dw_developer.tabledictionary where tpktablename like '%ARPHEDR%'
SELECT top 10 * FROM INFORMATION_SCHEMA.TABLES as t WHERE t.table_schema ='PowerBI_Distribution' and t.TABLE_NAME LIKE '%ship%'

select * from dw_developer.tabledictionary where tpktablename like '%DW120RF%' 

select top 10 * from dw_developer.tabledictionary  where tpktablename like '%ShippedHistoryCubeData%'


select * from dw_developer.tabledictionary where tpktablename like '%PC228RPF%'
select * from dw_developer.tabledictionary where tpktablename LIKE 't[_]%'
select * from dw_developer.tabledictionary where tpktablename like '%vnpr%'
select top 10 * from dw_developer.tabledictionary where tpktablename like '%t_items_on_hold%'
t_items_on_hold

SELECT  * FROM ASHLEY_EDW.INFORMATION_SCHEMA.COLUMNS WHERE COLUMN_NAME LIKE '%shipto%'
select * from dw_developer.tabledictionary where tpkCreated > '2025-05-01'
select * from dw_developer.tabledictionary where tpktablename like '%transfer%'
select * from dw_developer.tabledictionary where tpktablename like '%TransferOrderDetails_TrippedFrom%'
select * from dw_developer.tabledictionary where tpktablename like '%TransferOrderDetails_TrippedTO%'
select * from dw_developer.tabledictionary where tpktablename like '%TransferOrderDetails_UnTrippedTO%'
select * from dw_developer.tabledictionary where tpktablename like '%t_stored_item%'

select * from dw_developer.tabledictionary where tpktablename like '%tranlog%'
select * from dw_developer.tabledictionary where tpktablename like '%t_item_master%'
select * from dw_developer.tabledictionary where tpktablename like '%order%' order by tpkSchemaName
select * from dw_developer.tabledictionary where tpktablename like '%t_import_WAORDER%'
select * from dw_developer.tabledictionary where tpktablename like '%MENU%'
select * from dw_developer.tabledictionary where tpktablename like '%DW010%'
select * from dw_developer.tabledictionary where tpktablename like '%tranlog%'
select * from dw_developer.tabledictionary where tpktablename like '%ATP%'
select * from dw_developer.tabledictionary where tpktablename like '%ITBEXT%'
select * from dw_developer.tabledictionary where tpktablename like '%EMMSTR%'   ----------- employ master
select * from dw_developer.tabledictionary where tpktablename like '%PYREXPH%'  ----------- CICO
select * from dw_developer.tabledictionary where tpkSchemaName like '%mil%'  order by tpkSchemaName
select * from dw_developer.tabledictionary where tpkSchemaName like '%WNK%'  order by tpkSchemaName
select * from dw_developer.tabledictionary where tpktablename like '%ItemMaster%'  order by tpkSchemaName
select * from dw_developer.tabledictionary where tpktablename like '%ITMRVA%'
select * from dw_developer.tabledictionary where tpktablename like '%%'tpkSchemaName
select * from dw_developer.tabledictionary where tpkSchemaName LIKE '%MIL%'
select * from dw_developer.tabledictionary where tpktablename like '%IMHIST%'
select * from dw_developer.tabledictionary where tpktablename like '%SLQNTY%'
select * from dw_developer.tabledictionary where tpktablename like '%WHSMST%'
select * from dw_developer.tabledictionary where tpktablename like '%LOCMST%' 
select * from dw_developer.tabledictionary where tpktablename like '%DWHOLDITM1%'  --- hold items
select * from dw_developer.tabledictionary where tpktablename like '%MBCDRESM%' 
select * from dw_developer.tabledictionary where tpktablename like '%SIMLBP%' 
select * from dw_developer.tabledictionary where tpktablename like '%REQMTS%'  ------- MIL Raw materials demand forecast
select * from dw_developer.tabledictionary where tpkSchemaName LIKE '%WNK%'
select * from dw_developer.tabledictionary where tpkSchemaName LIKE '%MIL%' and tpktablename like '%CNT%'
select * from dw_developer.tabledictionary where  tpktablename like '%ITMRVAL0%'
select * from dw_developer.tabledictionary where tpkSchemaName LIKE '%MIL%' and tpktablename like '%MOMAST%'
select * from dw_developer.tabledictionary where tpkSchemaName LIKE '%MIL%' and tpktablename like '%PC216WSCH%'
select * from dw_developer.tabledictionary where tpkSchemaName LIKE '%MIL%' and tpktablename like '%PC228RPF%'
select * from dw_developer.tabledictionary where tpkSchemaName LIKE '%MIL%' and tpktablename like '%MOHMST%'
select * from dw_developer.tabledictionary where tpktablename like '%TAGINV%' 
select * from dw_developer.tabledictionary where tpktablename like '%ACTAUDT%'
select * from dw_developer.tabledictionary where tpktablename like '%WVCNT%'
select * from dw_developer.tabledictionary where tpktablename like '%CubeData%'
select * from dw_developer.tabledictionary where tpktablename like '%POMAST%'
select * from dw_developer.tabledictionary where tpktablename like '%Bookings%'
select * from dw_developer.tabledictionary where tpkSchemaName like '%CODIS%' ORDER BY tpkRowCount DESC
select * from dw_developer.tabledictionary where tpktablename like '%invoice%'
select * from dw_developer.tabledictionary where tpkSchemaName like '%SalesHistory%'
select * from dw_developer.tabledictionary where tpktablename like '%t_item_master%'
select * from dw_developer.tabledictionary where tpktablename like '%whfilrq%'
select * from dw_developer.tabledictionary where tpktablename like '%t_stored_item%'
DISTLIBL.TAGINVD
AMFLIBL.REQMTS
LLUSAF.PC216WSCH
*/sto
--------- main-----------------------------------------------------------------

select * FROM Distribution_Warehouse_Wholesale.t_stored_item where wh_id in  ('51')