/*
================================================================================
001_Metadata_Discovery.sql
??????Schema?????
================================================================================
????????EDW??????????????
???Schema?????????????????
================================================================================
*/

-- ============================================================================
-- 001.1 ??????? - dw_developer.tabledictionary
-- ============================================================================

-- [????]: ?????????
select * from dw_developer.tabledictionary where tpkCreated > '2025-05-01';

-- [????]: ?Schema?????
select distinct tpkSchemaName 
from dw_developer.tabledictionary 
order by tpkSchemaName;

-- [????]: ??????????????
select top 100 * 
from dw_developer.tabledictionary 
order by tpkRowCount desc;

-- [????]: ???????????
WITH RefreshRateMapping AS (
    SELECT 1 AS tpkRefreshRate, '? 8 ??' AS FrequencyDescription UNION ALL
    SELECT 2, '? 4 ??' UNION ALL
    SELECT 3, '? 3 ??' UNION ALL
    SELECT 4, '? 2 ??' UNION ALL
    SELECT 6, '???' UNION ALL
    SELECT 8, '? 30 ??' UNION ALL
    SELECT 12, '? 20 ??' UNION ALL
    SELECT 24, '? 15 ??' UNION ALL
    SELECT 26, '?? 1 ???????' UNION ALL
    SELECT 48, '?? 2 ?????' UNION ALL
    SELECT 72, '? 20 ?? (????)' UNION ALL
    SELECT 96, '? 15 ?? (????)' UNION ALL
    SELECT 9999, '?? / ????'
)
SELECT * FROM RefreshRateMapping;

-- ============================================================================
-- 001.2 Schema????
-- ============================================================================

-- [Schema??]: Distribution_Warehouse_Wholesale schema?????
select * from dw_developer.tabledictionary 
where tpkSchemaName like '%Distribution_Warehouse_Wholesale%'
order by tpkTableName;

-- [Schema??]: Manufacturing_Inventory_* schemas
select * from dw_developer.tabledictionary 
where tpkSchemaName like '%Manufacturing_Inventory%'
order by tpkSchemaName, tpkTableName;

-- [Schema??]: Manufacturing_ProductionPlanning_* schemas
select * from dw_developer.tabledictionary 
where tpkSchemaName like '%Manufacturing_ProductionPlanning%'
order by tpkSchemaName, tpkTableName;

-- [Schema??]: MasterData_* schemas
select * from dw_developer.tabledictionary 
where tpkSchemaName like '%MasterData%'
order by tpkSchemaName, tpkTableName;

-- [Schema??]: Wholesale_* schemas
select * from dw_developer.tabledictionary 
where tpkSchemaName like '%Wholesale%'
order by tpkSchemaName, tpkTableName;

-- [Schema??]: PowerBI_* schemas
select * from dw_developer.tabledictionary 
where tpkSchemaName like '%PowerBI%'
order by tpkSchemaName, tpkTableName;

-- [Schema??]: CostAccounting?SupplyChain schemas
select * from dw_developer.tabledictionary 
where tpkSchemaName like '%CostAccounting%' 
   or tpkSchemaName like '%SupplyChain%'
order by tpkSchemaName, tpkTableName;

-- ============================================================================
-- 001.3 ??????
-- ============================================================================

-- [???]: ??????? (TranLog)
select * from dw_developer.tabledictionary 
where tpktablename like '%tranlog%'
order by tpkSchemaName;

-- [???]: ??ASN???
select * from dw_developer.tabledictionary 
where tpktablename like '%asn%'
order by tpkRowCount desc;

-- [???]: ????????
select * from dw_developer.tabledictionary 
where tpktablename like '%ITMRVA%'
   or tpktablename like '%ITBEXT%'
   or tpktablename like '%ITMEXT%'
   or tpktablename like '%ITEMBL%'
order by tpkSchemaName, tpkTableName;

-- [???]: ??????? (IMHIST)
select * from dw_developer.tabledictionary 
where tpktablename like '%IMHIST%'
order by tpkSchemaName;

-- [???]: ???????
select * from dw_developer.tabledictionary 
where tpktablename like '%EMMSTR%'
   or tpktablename like '%PYREXPH%'
   or tpktablename like '%t_employee%'
order by tpkSchemaName;

-- [???]: ???????
select * from dw_developer.tabledictionary 
where tpktablename like '%WVCNT%'
   or tpktablename like '%container%'
order by tpkSchemaName;

-- [???]: ???????
select * from dw_developer.tabledictionary 
where tpktablename like '%invoice%'
order by tpkRowCount desc;

-- [???]: ??ATP?????
select * from dw_developer.tabledictionary 
where tpktablename like '%ATP%'
order by tpkSchemaName;

-- [???]: ???????
select * from dw_developer.tabledictionary 
where tpktablename like '%POMAST%'
   or tpktablename like '%PoDetail%'
   or tpktablename like '%po%'
order by tpkSchemaName;

-- [???]: ?????
select * from dw_developer.tabledictionary 
where tpktablename like '%order%'
order by tpkSchemaName;

-- [???]: ?????
select * from dw_developer.tabledictionary 
where tpktablename like '%location%'
   or tpktablename like '%t_location%'
order by tpkSchemaName;

-- [???]: ??Maximo?
select * from dw_developer.tabledictionary 
where tpkSchemaName like '%maximo%'
order by tpkRowCount desc;

-- ============================================================================
-- 001.4 ????
-- ============================================================================

-- [???]: ?? 'shipto' ??
SELECT TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE COLUMN_NAME LIKE '%shipto%'
ORDER BY TABLE_SCHEMA, TABLE_NAME;

-- [???]: ?? 'plate' ????????
SELECT s.name AS SchemaName, t.name AS TableName, c.name AS ColumnName, ty.name AS DataType
FROM sys.columns c
INNER JOIN sys.tables t ON c.object_id = t.object_id
INNER JOIN sys.schemas s ON t.schema_id = s.schema_id
INNER JOIN sys.types ty ON c.user_type_id = ty.user_type_id
WHERE c.name like '%plate%'
ORDER BY s.name, t.name;

-- [???]: ???????????
SELECT TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE COLUMN_NAME = 'ActualDate'
ORDER BY TABLE_SCHEMA, TABLE_NAME;

-- ============================================================================
-- 001.5 INFORMATION_SCHEMA????
-- ============================================================================

-- [????]: Distribution_Warehouse_Wholesale???'tran'??
SELECT top 10 * FROM INFORMATION_SCHEMA.TABLES 
WHERE table_schema = 'Distribution_Warehouse_Wholesale' 
  AND TABLE_NAME LIKE '%tran%';

-- [????]: PowerBI_Distribution???'ship'??
SELECT top 10 * FROM INFORMATION_SCHEMA.TABLES 
WHERE table_schema = 'PowerBI_Distribution' 
  AND TABLE_NAME LIKE '%ship%';

-- [????]: ???????????
SELECT TOP 10 TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, DATA_TYPE, CHARACTER_MAXIMUM_LENGTH
FROM INFORMATION_SCHEMA.COLUMNS
WHERE COLUMN_NAME LIKE '$%'
ORDER BY TABLE_NAME, ORDINAL_POSITION;

-- ============================================================================
-- 001.6 ????????
-- ============================================================================

-- [????]: t_asn???
select * from dw_developer.tabledictionary where tpktablename = 't_asn';

-- [????]: ASN_Detail???
select * from dw_developer.tabledictionary where tpktablename = 'ASN_Detail';

-- [????]: Trailer???
select * from dw_developer.tabledictionary where tpktablename = 'Trailer';

-- [????]: t_trailer_asn???
select * from dw_developer.tabledictionary where tpktablename = 't_trailer_asn';

-- [????]: YaLocation???
select * from dw_developer.tabledictionary where tpktablename = 'YaLocation';

-- [????]: t_po_master???
select * from dw_developer.tabledictionary where tpktablename = 't_po_master';

-- [????]: t_item_master???
select * from dw_developer.tabledictionary where tpktablename = 't_item_master';

-- [????]: t_stored_item???
select * from dw_developer.tabledictionary where tpktablename = 't_stored_item';

-- [????]: TranLog???
select * from dw_developer.tabledictionary 
where tpktablename like '%TranLog%'
order by tpkSchemaName;

-- [????]: ShippedHistoryCubeData???
select * from dw_developer.tabledictionary 
where tpktablename like '%ShippedHistoryCubeData%';

-- [????]: TripAvailableSTO???
select * from dw_developer.tabledictionary 
where tpktablename like '%TripAvailableSTO%';

-- ============================================================================
-- 001.7 ???????
-- ============================================================================

-- [????]: ?Schema????
select tpkSchemaName, count(*) as TableCount, sum(tpkRowCount) as TotalRows
from dw_developer.tabledictionary
group by tpkSchemaName
order by TableCount desc;

-- [????]: ????????
select tpkObjectType, count(*) as Count
from dw_developer.tabledictionary
group by tpkObjectType
order by Count desc;

-- [????]: ????
select top 20 tpkSchemaName, tpkTableName, tpkRowCount, tpkCreateDate
from dw_developer.tabledictionary
order by tpkRowCount desc;

-- [????]: ??????
select top 20 tpkSchemaName, tpkTableName, tpkModified, tpkRowCount
from dw_developer.tabledictionary
order by tpkModified desc;

-- ============================================================================
-- 001.8 ????
-- ============================================================================

-- [????]: ????????
select tpkSchemaName, tpkTableName, tpkObjectType, tpkPrimaryKey
from dw_developer.tabledictionary
where tpkPrimaryKey is not null 
  and tpkPrimaryKey like '%customer%'
order by tpkRowCount desc;

-- [????]: ??"t_"????
select * from dw_developer.tabledictionary
where tpktablename LIKE 't[_]%'
order by tpkSchemaName, tpktablename;

-- [????]: MIL?WNK??????
select * from dw_developer.tabledictionary
where tpkSchemaName like '%MIL%'
   or tpkSchemaName like '%WNK%'
order by tpkSchemaName, tpkTableName;

-- [????]: CODIS??????
select * from dw_developer.tabledictionary
where tpkSchemaName like '%CODIS%'
order by tpkRowCount desc;

-- [????]: ADS??????
select * from dw_developer.tabledictionary
where tpkSchemaName like '%ADS%'
order by tpkSchemaName;

-- ============================================================================
-- 001.9 ????????
-- ============================================================================

-- [????]: ?????????????
select tpkSchemaName, tpkTableName, tpkRefreshRate, tpkJobName, 
       tpkUpdateMethod, tpkCreateDate, tpkModified
from dw_developer.tabledictionary
where tpkRefreshRate is not null
order by tpkSchemaName, tpktablename;

-- [????]: ????Schema??????
-- ???Distribution_Warehouse_Wholesale
select * from dw_developer.tabledictionary
where tpkSchemaName = 'Distribution_Warehouse_Wholesale'
  and tpkRefreshRate is not null
order by tpkTableName;

================================================================================
EOF - End of Metadata Discovery Queries
================================================================================
*/
