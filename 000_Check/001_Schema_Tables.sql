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
select * from dw_developer.tabledictionary where tpkSchemaName LIKE '%MIL%'
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
select * from dw_developer.tabledictionary where tpkSchemaName like '%Distribution_Warehouse_Wholesale%'  order by tpkTableName
select * from dw_developer.tabledictionary where tpkSchemaName like '%Wholesale_Invoicing_AFI%'  order by tpkSchemaName
Wholesale_Invoicing_AFI
select * from dw_developer.tabledictionary order by tpkRowCount Desc
ITMEXT
select * from dw_developer.tabledictionary where tpktablename like '%ITMEXT%'
select * from dw_developer.tabledictionary where tpktablename like '%ITMRVA%'
select * from dw_developer.tabledictionary where tpktablename like '%t_employee%'
select * from dw_developer.tabledictionary where tpktablename like '%COMAST%'
select * from dw_developer.tabledictionary where tpktablename like '%CVR%'
select * from dw_developer.tabledictionary where tpkSchemaName like '%ADS%'


tpkSchemaName	tpkTableName	tpkObjectType	tpkPrimaryKey
Wholesale_Invoicing_AFI	DW013EW1	Table	TRIPNO,DROPNO,ORDNO#,ITMSEQ,SERNBR,ITEMNO,CUSTNO,ADDDAT,ADDTIM,UCCNBR,CUSTID
Wholesale_Invoicing_AFI	MBF9REP	External	FEGGNB,FEHZNB
Wholesale_Invoicing_AFI	TSCMADJ	Table	CDHInvoiceNumber,CDHOrderNumber,CDHItemNumber,CDHItemSequence,CDHCommissionAdjustmentCode
Wholesale_Invoicing_AFI	TSCAIN	Table	CAHInvoiceNumber,CAHOrderNumber,CAHSalesOrderNumber,CAHSequence
Wholesale_Invoicing_AFI	TSITIN	Table	ITINVR,ITORNO,ITITNO,ITITSQ
Wholesale_Invoicing_AFI	INVORD	Table	INDATE,INTIME,INDRP#,INORD#,INREF#
Wholesale_Invoicing_AFI	TSDSCADJ	Table	DCHINVNBR,DCHORDNO,DCHDSCADJC,DCHITMSEQ,DCHITMNBR
Wholesale_Invoicing_AFI	TSESTR	Table	TSEINV,TSEORDER,TSEISEQ,TSEITEM,TSESEQ
Wholesale_Invoicing_AFI	TSSCIN	Table	SCINVR,SCORNO,SCSQNO
Wholesale_Invoicing_AFI	TSTXIN	External	TXINVR,TXORNO
Wholesale_Invoicing_AFI	TSININ	Table	ININVR,INORNO
Wholesale_Invoicing_AFI	TSINXN	Table	XNINVR,XNORNO
Wholesale_Invoicing_AFI	TSCIIN	Table	CIINVR,CIORNO,CIITNO,CIITSQ,CIICSQ
Wholesale_Invoicing_AFI	TSITXN	Table	XTINVR,XTORNO,XTITNO,XTITSQ
Wholesale_Invoicing_AFI	TSSSIN	Table	SSINVR,SSORNO
Wholesale_Invoicing_AFI	TSITZN	Table	HPOINVNO,HPOORDNO,HPOITEMNO,HPOITEMSQ,HPOCUSNO,HPOSERIAL
Wholesale_Invoicing_AFI	TSEXIN	Table	SHEInvoiceNumber,SHEOrderNumber,SHEItemequence,SHEFieldName
Wholesale_Invoicing_AFI	TSCOIN	Table	COINVR,COORNO,COOCSQ
Wholesale_Invoicing_AFI	TSSCXN	External	NULL
select * from dw_developer.tabledictionary where tpkSchemaName LIKE '%ADS%'
select * from dw_developer.tabledictionary where tpkSchemaName LIKE '%PowerBI%'
select * from dw_developer.tabledictionary where tpkSchemaName =[PowerBI_ADS]
Distribution_Warehouse_Wholesale
DISTLIBL.TAGINVD
AMFLIBL.REQMTS
LLUSAF.PC216WSCH
select * from dw_developer.tabledictionary where tpktablename LIKE '%employee%'
select * from dw_developer.tabledictionary where tpktablename LIKE '%invoice%'
select * from dw_developer.tabledictionary where tpktablename LIKE '%cdn%'
select * from dw_developer.tabledictionary where tpktablename LIKE '%WNK%'
select * from dw_developer.tabledictionary where tpkSchemaName LIKE '%MIL%'
select * from dw_developer.tabledictionary where tpkSchemaName LIKE '%WNK%'
select * from dw_developer.tabledictionary where tpktablename LIKE '%ITMEXT%'
select * from dw_developer.tabledictionary where tpktablename LIKE '%ITMRVA%'
select * from dw_developer.tabledictionary where tpktablename LIKE '%asn%' order by tpkRowCount DESC

select * from dw_developer.tabledictionary where tpkSchemaName = 'Manufacturing_ProductionPlanning_MIL' order by tpkTableName
select * from dw_developer.tabledictionary where tpkSchemaName= 'Manufacturing_ProductionPlanning_WNK' and tpktablename LIKE '%WVCNT%' order by tpkTableName 
select * from dw_developer.tabledictionary where tpkSchemaName LIKE '%PowerBI_Distribution%'
select * from dw_developer.tabledictionary where tpktablename LIKE '%tranlog%' order by tpkRowCount DESC
select * from dw_developer.tabledictionary where tpkSchemaName LIKE '%CODIS%' AND tpkPrimaryKey like '%customer%' order by tpkRowCount DESC
select * from dw_developer.tabledictionary where tpktablename LIKE '%serial%'
select * from dw_developer.tabledictionary where tpktablename LIKE '%ATP%'
select * from dw_developer.tabledictionary where tpktablename LIKE '%Manufacturing%'
select * from dw_developer.tabledictionary where tpktablename LIKE '%EXTORIT%'
select * from dw_developer.tabledictionary where tpkSchemaName LIKE '%Manufacturing_Maximo%'

select * from dw_developer.tabledictionary where tpkSchemaName LIKE '%Distribution%' order by tpkRowCount DESC
select * from dw_developer.tabledictionary where tpktablename LIKE '%vendor%' and tpkSchemaName like '%maximo%' order by tpkRowCount DESC
select * from dw_developer.tabledictionary where tpkSchemaName LIKE 'Manufacturing_Maximo%'  order by tpkRowCount DESC
select * from dw_developer.tabledictionary where tpkSchemaName LIKE 'Maximo_DW%'  order by tpkRowCount DESC
select * from dw_developer.tabledictionary where tpkSchemaName LIKE 'AFISales_Enh%'  order by tpkRowCount DESC
select * from dw_developer.tabledictionary where tpktablename LIKE 'Matrectrans%'  order by tpkRowCount DESC
select * from dw_developer.tabledictionary where tpktablename LIKE '%ITBEXT%'  order by tpkRowCount DESC
select * from dw_developer.tabledictionary where tpktablename LIKE '%item%master%'  order by tpkRowCount DESC
select * from dw_developer.tabledictionary where tpktablename LIKE '%ITBEXT%'  order by tpkRowCount DESC
select * from dw_developer.tabledictionary where tpktablename LIKE '%InvoiceDetail%'  order by tpkRowCount DESC
select * from dw_developer.tabledictionary where tpktablename LIKE '%ITEMBL%'  order by tpkRowCount DESC
select * from dw_developer.tabledictionary where tpktablename LIKE '%ATOFILEATOFILE%'  order by tpkRowCount DESC
select * from dw_developer.tabledictionary where tpktablename LIKE '%excep%'  order by tpkRowCount DESC
select * from dw_developer.tabledictionary where tpktablename LIKE '%tranLog%'  order by tpkRowCount DESC
select * from dw_developer.tabledictionary where tpktablename LIKE '%equipment%check%log%'  order by tpkRowCount DESC


select * from dw_developer.tabledictionary where tpktablename LIKE '%CostAccounting_Enh%'  order by tpkRowCount DESC
select * from dw_developer.tabledictionary where tpktablename LIKE '%PowerBI_Finance%'  order by tpkRowCount DESC
select * from dw_developer.tabledictionary where tpktablename LIKE '%serial%'  order by tpkRowCount DESC


SELECT  *  FROM INFORMATION_SCHEMA.COLUMNS WHERE COLUMN_NAME LIKE '%%'
SELECT  *  FROM INFORMATION_SCHEMA.COLUMNS WHERE COLUMN_NAME LIKE '%Ecommerce Invoicing%'
SELECT  *  FROM INFORMATION_SCHEMA.COLUMNS WHERE tpkSchemaName LIKE '%serial%'
SELECT  *  FROM INFORMATION_SCHEMA.COLUMNS WHERE tpkSchemaName LIKE '%equipment%log%'



SELECT top 10  *  FROM Distribution_Wrk.InvoicedUnitsDetails






-- 方法1: 查询系统视图(推荐)
SELECT 
    s.name AS SchemaName,
    t.name AS TableName,
    c.name AS ColumnName,
    ty.name AS DataType,
    c.max_length AS MaxLength
FROM sys.columns c
INNER JOIN sys.tables t ON c.object_id = t.object_id
INNER JOIN sys.schemas s ON t.schema_id = s.schema_id
INNER JOIN sys.types ty ON c.user_type_id = ty.user_type_id
WHERE c.name like '%plate%'  -- 替换为你要查找的字段名
ORDER BY s.name, t.name;


-- 方法2: 使用 INFORMATION_SCHEMA

SELECT 
    TABLE_SCHEMA,
    TABLE_NAME,
    COLUMN_NAME,
    DATA_TYPE,
    CHARACTER_MAXIMUM_LENGTH
FROM INFORMATION_SCHEMA.COLUMNS
WHERE COLUMN_NAME = 'ActualDate'  -- 替换为你要查找的字段名
ORDER BY TABLE_SCHEMA, TABLE_NAME;

*/

-- sn check by sites
select * from Distribution_Warehouse_Wholesale.t_serial_active where item_number = 'D954-50' AND po_number in  ('P2S3T23','P2S3T14','P2S3T20','P2TC102','P2TGQ80')



select top 10 * from AtScale_Inventory.DimPurchasingWeeklyPlanSummaryDetails


Select  * from Distribution_Warehouse_Wholesale.EquipmentCheckLog where wh_id = '335' and equipment_id like 'VS801%' and check_performed >= '2026-03-15' order by equipment_id, check_performed;

SELECT 
    curr.wh_id,
    curr.equipment_check_log_id,
    curr.equipment_id,
    curr.employee_id,
    curr.check_meter,
    curr.check_performed,
    
    -- 下一次check的信息
    next_rec.equipment_check_log_id    AS next_equipment_check_log_id,
    next_rec.employee_id               AS next_employee_id,
    next_rec.check_meter               AS next_check_meter,
    next_rec.check_performed           AS next_check_performed,
    
    -- check_meter 差值
    next_rec.check_meter - curr.check_meter AS meter_difference,
    
    -- 判断列
    CASE 
        WHEN next_rec.check_meter - curr.check_meter >= 0 THEN 'OK'
        WHEN next_rec.check_meter - curr.check_meter < 0  THEN 'PIV check issue'
        ELSE NULL
    END AS meter_check_status

FROM (
    -- 先去重：相同日期 + employee + equipment + check_meter，取 check_performed 最大值
    SELECT 
        wh_id,
        equipment_id,
        employee_id,
        check_meter,
        MAX(check_performed) AS check_performed,
        -- 取对应最大check_performed的 equipment_check_log_id
        MAX(equipment_check_log_id) AS equipment_check_log_id
    FROM Distribution_Warehouse_Wholesale.EquipmentCheckLog
    WHERE wh_id        = '335'
      AND equipment_id LIKE 'V%'
      AND check_performed >= '2026-03-15'  -- 可以根据需要调整时间范围
    GROUP BY
        wh_id,
        equipment_id,
        employee_id,
        check_meter,
        CAST(check_performed AS DATE)  -- 同一天
) AS curr

OUTER APPLY (
    SELECT TOP 1
        dedup.equipment_check_log_id,
        dedup.employee_id,
        dedup.check_meter,
        dedup.check_performed
    FROM (
        -- 下一条记录同样先去重
        SELECT 
            wh_id,
            equipment_id,
            employee_id,
            check_meter,
            MAX(check_performed) AS check_performed,
            MAX(equipment_check_log_id) AS equipment_check_log_id
        FROM Distribution_Warehouse_Wholesale.EquipmentCheckLog
        WHERE wh_id        = '335'
          AND equipment_id LIKE 'V801%'
          AND check_performed >= '2026-03-10'
        GROUP BY
            wh_id,
            equipment_id,
            employee_id,
            check_meter,
            CAST(check_performed AS DATE)
    ) AS dedup
    WHERE dedup.equipment_id   = curr.equipment_id
      AND dedup.wh_id          = curr.wh_id
      AND dedup.check_performed > curr.check_performed
    ORDER BY dedup.check_performed ASC
) AS next_rec

ORDER BY curr.equipment_id, curr.check_performed;


Select top 10 * from CostAccounting_Enh.DC_LaborRollups_BaseData
Select top 10 * from PowerBI_Finance.DC_LaborRollups_BaseData
Select top 10 * from PowerBI_Finance.DC_LaborRollups_RunChartData
Select top 10 * from CostAccounting.DC_LaborRollups_CalculatedData





-- raw data:

Select top 10 * from PowerBI_Distribution.InvoiceAmount_WarehouseLevel
Select top 10 * from Wholesale_DemandPlanning_AFI.SupplyPlanDetail
Select top 10 * from PowerBI_SupplyChain.TotalReceipts
Select top 10 * from PowerBI_Distribution.WhseTraffic
Select top 10 * from CostAccounting_Enh.DC_LaborRollups_BaseData
Select top 10 * from PowerBI_Distribution.InvoiceAmount_WarehouseLevel
Select top 10 * from PowerBI_Finance.DC_LaborRollups_BaseData
Select top 10 * from PowerBI_Finance.DC_LaborRollups_RunChartData
Select top 10 * from CostAccounting.DC_LaborRollups_CalculatedData




SELECT  *  FROM INFORMATION_SCHEMA.COLUMNS WHERE COLUMN_NAME LIKE '%PurchaseOrderPcs%'

-- maximo asset tables
SELECT * FROM dw_developer.tabledictionary WHERE tpktablename LIKE '%asset%' ORDER BY tpkRowCount DESC
Select top 10 * from Manufacturing_Maximo.asset where description like '%batt%'
Select top 10000 * from Manufacturing_Maximo.asset where siteid = 'VNM.ASPM'  order by assetnum
Select top 10000 * from Manufacturing_Maximo.asset where siteid = 'VNM.ASPM' and assetnum LIKE 'VB%' order by assetnum


Distribution_DW	MaximoAssetStatus
Distribution_Delivery_Wholesale	ASSETRELOCATIONLOG
Distribution_Delivery_Wholesale_wrk	ASSETRELOCATIONLOG
Distribution_TMWSuite	AssetAssignment
Distribution_TMWSuite_wrk	ASSETASSIGNMENT
Distribution_DW	AssetUtilizationTrailerSnapshot
Manufacturing_Maximo	Plustassetsthist
Distribution_DW	AssetUtilizationTractorSnapshot
Manufacturing_Maximo	AssetSpec
Manufacturing_Maximo	plustassetalias
Maximo_DW	DimMROAssetDetails

Distribution_DW	AssetUtilizationSnapshot
Manufacturing_Maximo	AssetMeter
Manufacturing_Maximo	Assetlocusercust
Manufacturing_Maximo	Plustwoasset
Manufacturing_Maximo	AssetAttribute
Manufacturing_DW	DimIOTAssetMachineDetails


-- tran log tables
Select top 10 * from Distribution_Warehouse_Wholesale.t_exception_tran_log where wh_id != '335'

•	Distribution_Warehouse_Wholesale.t_exception_tran_log
-- sn check
Select TOP 10 * from Distribution_Warehouse_Wholesale.tranlog
Select * from Distribution_Warehouse_Wholesale.ExceptionLog where wh_id = '335' and tran_type like '855%'  order by lot_number, exception_date
Select * from Distribution_Warehouse_Wholesale.tranlog where wh_id = '335' and employee_id = '50165' and start_tran_date > '2021-01-01' order by start_tran_date desc, start_tran_time desc
Select * from Distribution_Warehouse_Wholesale.tranlog where wh_id = '335' and tran_type = '855' and start_tran_date >= '2026-01-01' order by lot_number, start_tran_date, start_tran_time
Select * from Distribution_Warehouse_Wholesale.tranlog where wh_id = '335' and lot_number = '503952384062' and start_tran_date >= '2024-01-01' order by lot_number, start_tran_date, start_tran_time
Select * from Distribution_Warehouse_Wholesale.tranlog where wh_id = '335' and lot_number = '503952820543' and start_tran_date >= '2024-01-01' order by lot_number, start_tran_date, start_tran_time
Select * from Distribution_Warehouse_Wholesale.tranlog where wh_id = '335' and lot_number = '635930176074' and start_tran_date >= '2024-01-01' order by lot_number, start_tran_date, start_tran_time
Select * from Distribution_Warehouse_Wholesale.tranlog where wh_id = '335' and lot_number = '688075336774' and start_tran_date >= '2024-01-01' order by lot_number, start_tran_date, start_tran_time

Select * from Distribution_Warehouse_Wholesale.tranlog where wh_id = '335' and lot_number = '503950857188' and start_tran_date >= '2024-01-01' order by lot_number, start_tran_date, start_tran_time
Select * from Distribution_Warehouse_Wholesale.tranlog where wh_id = '335' and lot_number = '694370110319' and start_tran_date >= '2024-01-01' order by lot_number, start_tran_date, start_tran_time
Select * from Distribution_Warehouse_Wholesale.tranlog where wh_id = '335' and lot_number = '638920006379' and start_tran_date >= '2024-01-01' order by lot_number, start_tran_date, start_tran_time
Select * from Distribution_Warehouse_Wholesale.tranlog where wh_id = '335' and lot_number = '503952704823' and start_tran_date >= '2024-01-01' order by lot_number, start_tran_date, start_tran_time
Select * from Distribution_Warehouse_Wholesale.tranlog where wh_id = '335' and lot_number = '661420010313' and start_tran_date >= '2024-01-01' order by lot_number, start_tran_date, start_tran_time

--R407051
Select * from Distribution_Warehouse_Wholesale.tranlog where wh_id = '335' and lot_number = '661420009049' and start_tran_date >= '2024-01-01' order by lot_number, start_tran_date, start_tran_time
Select * from Distribution_Warehouse_Wholesale.tranlog where wh_id = '335' and lot_number = '661420010266' and start_tran_date >= '2024-01-01' order by lot_number, start_tran_date, start_tran_time
Select * from Distribution_Warehouse_Wholesale.tranlog where wh_id = '335' and lot_number = '661420010313' and start_tran_date >= '2024-01-01' order by lot_number, start_tran_date, start_tran_time
Select * from Distribution_Warehouse_Wholesale.tranlog where wh_id = '335' and lot_number = '661420010409' and start_tran_date >= '2024-01-01' order by lot_number, start_tran_date, start_tran_time
Select * from Distribution_Warehouse_Wholesale.tranlog where wh_id = '335' and lot_number = '661420068949' and start_tran_date >= '2024-01-01' order by lot_number, start_tran_date, start_tran_time





select top 10 * from Distribution_Warehouse_Wholesale.t_items_on_hold where WhId = '335'
select * from Distribution_Warehouse_Wholesale.t_items_on_hold where WhId = '335'
select top 10 * from Distribution_Warehouse_Wholesale.maTranLog where tran_type = '151' and item_number = '113703C' AND hu_id like '%2385395%'
select * from Distribution_Warehouse_Wholesale.maTranLog where tran_type = '151' and item_number = '113703C' AND hu_id like '%2385395%'


--as400 transactions
--driver={iSeries Access ODBC Driver};system=AFIPROD;default collection=AMFLIBA,AFILELIB,DISTLIB,ASHLEYARC;ccsid=65535;translate=1
select top 10 * from Manufacturing_Inventory_AFI.IMHIST WHERE HOUSE = '335' AND TCODE = 'IA' AND UPDDT > '1260101'
select  * from Manufacturing_Inventory_AFI.IMHIST WHERE HOUSE = '335' AND TCODE = 'IA' AND UPDDT > '1260101'
select  * from Manufacturing_Inventory_MIL.IMHIST WHERE HOUSE = '51' AND TCODE = 'IA' AND UPDDT > '1260101'
select  * from Manufacturing_Inventory_WNK.IMHIST WHERE HOUSE IN ('31','33','35','34') AND TCODE = 'IA' AND UPDDT > '1260101'

SELECT t1.HOUSE, t1.TRMID, ITNBR, t1.upddt, t1.updtm, t1.trqty, t1.tramt, t1.stpcs, t1.entum, t1.REFNO, t1.REASN, t1.LLOCN, T2.ITDSC, T2.UNMSR, T2.ITCLS, T2.WEGHT, T2.B2Z95S 
FROM AMFLIBA.IMHIST t1 
LEFT JOIN AMFLIBA.ITMRVA t2 ON t1.ITNBR = t2.ITNBR 
LEFT JOIN AMFLIBA.WHSMST t3 ON t1.HOUSE = t3.WHID
WHERE t2.ITNBR = t1.ITNBR 
  AND t2.STID = t3.STID 
  AND t1.HOUSE = t3.WHID 
  AND t1.HOUSE = '335' 
  AND t1.UPDDT >= '1260101'
  AND t1.TRQTY <> 0
  AND T1.tcode in ('IA','IS','SS')

-- Trip shipped
SELECT 
    t.tran_type,  
    t.description, 
    t.start_tran_date, 
    t.control_number_2,
    -- 提取 '-' 之前的部分并转为整数以自动去除前导零
    CAST(LEFT(t.control_number_2, CHARINDEX('-', t.control_number_2 + '-') - 1) AS INT) AS clean_control_number,
    t.employee_id, 
    t.item_number, 
    SUM(t.tran_qty) AS tran_qty 
FROM Distribution_Warehouse_Wholesale.TranLog AS t
WHERE t.wh_id = '335' 
    AND t.start_tran_date > '2026-01-01'
    AND t.tran_type IN ('347')
    -- 过滤条件：确保包含连字符且截取后是数字格式（防止报错）
    AND (t.control_number_2 LIKE '%14173-%' or t.control_number_2 LIKE '%14173-%' )
GROUP BY 
    t.tran_type,  
    t.description, 
    t.start_tran_date, 
    t.control_number_2,
    CAST(LEFT(t.control_number_2, CHARINDEX('-', t.control_number_2 + '-') - 1) AS INT),
    t.employee_id, 
    t.item_number

select t.control_number_2, sum(t.tran_qty) as qty
FROM Distribution_Warehouse_Wholesale.TranLog AS t
WHERE t.wh_id = '335'
    AND t.start_tran_date > '2026-01-01'
    AND t.tran_type IN ('347')
    AND t.item_number = 'RP ORDER'
AND (t.control_number_2 LIKE '%14173-%' or t.control_number_2 LIKE '%14173-%' )
group by  t.control_number_2

-- Trip shipped by sn
select top 10 * FROM Distribution_Warehouse_Wholesale.TranLog where tran_type = '347'
SELECT 
    t.tran_type,  
    t.description, 
    t.start_tran_date, 
    t.control_number_2,
    -- 提取 '-' 之前的部分并转为整数以自动去除前导零
    CAST(LEFT(t.control_number_2, CHARINDEX('-', t.control_number_2 + '-') - 1) AS INT) AS clean_control_number,
    t.lot_number,
    t.employee_id, 
    t.item_number, 
    SUM(t.tran_qty) AS tran_qty 
FROM Distribution_Warehouse_Wholesale.TranLog AS t
WHERE t.wh_id = '335' 
    AND t.start_tran_date > '2025-01-01'
    AND t.tran_type IN ('347')
    -- 过滤条件：确保包含连字符且截取后是数字格式（防止报错）
    AND (t.control_number_2 LIKE '%89296-%' or t.control_number_2 LIKE '%90774-%' )
GROUP BY 
    t.tran_type,  
    t.description, 
    t.start_tran_date, 
    t.control_number_2,
    CAST(LEFT(t.control_number_2, CHARINDEX('-', t.control_number_2 + '-') - 1) AS INT),
     t.lot_number,
    t.employee_id, 
    t.item_number




SELECT * 
FROM Distribution_Warehouse_Wholesale.tranlog 
WHERE 
  -- wh_id = '335' 
  AND tran_type = '347'  
  AND start_tran_date > '2025-01-01' 
  AND CAST(SUBSTRING(control_number, 1, CHARINDEX('-', control_number) - 1) AS INT) IN (49363, 49366, 52379)
ORDER BY lot_number, start_tran_date, start_tran_time

-- trips loading 322 transactions
SELECT * 
FROM Distribution_Warehouse_Wholesale.tranlog 
WHERE 
  wh_id = '335' 
  and tran_type = '322'  
  AND start_tran_date > '2025-01-01' 
  AND CAST(SUBSTRING(control_number_2, 1, CHARINDEX('-', control_number) - 1) AS INT) IN (49363, 49366, 52379)
ORDER BY lot_number, start_tran_date, start_tran_time


SELECT * 
FROM Distribution_Warehouse_Wholesale.tranlog 
WHERE 
  -- wh_id = '335' 
  AND tran_type = '347'  
  AND start_tran_date > '2025-01-01' 
  AND CAST(SUBSTRING(control_number, 1, CHARINDEX('-', control_number) - 1) AS INT) IN (49363, 49366, 52379)
ORDER BY lot_number, start_tran_date, start_tran_time

-- exception log 855
Select top 10 * from Distribution_Warehouse_Wholesale.ExceptionLog where wh_id = '335' and tran_type like '855%'
Select distinct wh_id from Distribution_Warehouse_Wholesale.ExceptionLog 
Select * from Distribution_Warehouse_Wholesale.tranlog where wh_id = '335' and lot_number in (Select lot_number from Distribution_Warehouse_Wholesale.ExceptionLog where wh_id = '335' and tran_type like '855%' and exception_date > '2026-01-01') order by lot_number, start_tran_date, start_tran_time



Select TOP 10 * from [PowerBI_Distribution].[AshleycustomerMaster] WHERE CustomerNumber LIKE '109200'

Select TOP 10 * from Wholesale_CODIS.COMAST where ORDNO = 'D739656'
Select count(*) from Wholesale_CODIS.COMAST 
Select TOP 100 *  from Wholesale_CODIS.EXTORIT  where IORD = 'D568579'

-- tranlog
select  * from Distribution_Warehouse_Wholesale.TranLog where wh_id = '335' and tran_type in ('321','621') and control_number like '%82268%' order by start_tran_date desc
 
-- employee
select top 10 * from Distribution_Warehouse_Wholesale.t_employee where wh_id = '335'

-- item master
select top 10 * from MasterData_ItemMaster_AFI.ITMRVA as a WHERE STID = '335' AND ITNBR = '4890223'
select top 10 * from MasterData_ItemMaster_AFI.ITBEXT as a WHERE ITNBR = '4890223' AND HOUSE = '335'
select top 10 * from MasterData_ItemMaster_AFI.ITMEXT as a WHERE ITNBR = '4890223' 
left join MasterData_ItemMaster_AFI.ITBEXT as b on b.itnbr = a.itnbr and a.stid = b.house
where a.stid = '335'

select a.itnbr, a.itcls, b.pickput 
from MasterData_ItemMaster_AFI.ITMRVA as a
left join (SELECT * FROM MasterData_ItemMaster_AFI.ITBEXT  WHERE HOUSE = '335')as b on b.itnbr = a.itnbr and a.stid = b.house
where a.stid = '335' and a.itcls like 'Z%' and a.itcls not like 'Z%K'

select top 100 * from MasterData_ItemMaster_AFI.ITBEXT where house = '335'

-- Logistics planned order fulfillment
select * from Wholesale_DemandPlanning_AFI.SupplyPlanDetail where spdItem = '100-17' and spdWarehouse = '335' order by spdWeekEnding 

Wholesale_DemandPlanning_AFI.SupplyPlanDetail
SupplyChain_Enh	DailySupplyPlanDetail
Wholesale_ProductSourcing_AFI.SupplyChain_LogilityPlannedOrderFulfillment

select top 1000 * from Wholesale_ProductSourcing_AFI.SupplyChain_LogilityPlannedOrderFulfillment where item like '1700338%'

-- dispatch date
select top 10 * from Wholesale_CODIS.ATOFILE
select * from Wholesale_CODIS.ATOFILE where hous = '335' 

-- Invoice

select top 10 * from CostAccounting_Enh.ShippedHistoryCubeData where shcWarehouse = '335' and shcTripNumber = ''
select top 10 * from Wholesale_SalesHistory_AFI.InvoiceDetail


select top 1000 * from CostAccounting_Enh.ShippedHistoryCubeData where shcWarehouse = '335' and shcTripNumber = '97827'
select top 1000 * from Wholesale_SalesHistory_AFI.InvoiceDetail where   Warehouse = '335' and TripNumber = '97827' order by InvoiceDate desc
select  * from Wholesale_SalesHistory_AFI.InvoiceDetail where  OrderNumber = 'D739656'  and Warehouse = '335'
select top 10 * from Wholesale_SalesHistory_AFI.InvoiceDetail where Warehouse = '335' and CustomerNumber = '3223700' and TripNumber = '24436'
where ORDNO = 'D739656'

select top 10 * from AFISales_DW.DimInvoiceHeader 
select top 10 * from AFISales_DW.FactOnTimeDeliveryInvoiceDetail  

-- inventory history
select 
	t.shcInvoiceDate,
	t.shcWarehouse,
	t.shcCustomerNumber,
	t.shcShipToNumber,
	t.shcBusinessType,
	t.shcHomestoreFlag,
	t.shcBillToName,
	t.shcBillToCountry,
	t.shcShiptoCountry,
	Sum(t.shcGrossQuantityShipped) shcGrossQuantityShipped,
	Sum(t.shcGrossAmountShipped) shcGrossAmountShipped,
	Sum(t.shcNetQuantityShipped) shcNetQuantityShipped,
	Sum(t.shcNetAmountShipped) shcNetAmountShipped
from CostAccounting_Enh.ShippedHistoryCubeData t
where t.shcInvoiceDate >= '2023-01-01'
group by 
	t.shcInvoiceDate,
	t.shcWarehouse,
	t.shcCustomerNumber,
	t.shcShipToNumber,
	t.shcBusinessType,
	t.shcHomestoreFlag,
	t.shcBillToName,
	t.shcBillToCountry,
	t.shcShiptoCountry



-- uom

select top 10 * from Distribution_Warehouse_Wholesale.t_item_master where wh_id = '335' and item_number = 'R405102'
select top 10 * from Distribution_Warehouse_Wholesale.t_item_uom where wh_id = '335' and item_number = 'R405102'

SELECT
        a.item_number
        ,a.description
        ,a.uom
        ,a.inventory_type
        ,a.commodity_code
        ,a.wh_id
        ,a.unit_weight
        ,a.unit_volume
        ,a.length
        ,a.width
        ,a.height
        ,a.class_id
        ,a.pick_put_id
        ,b.units_per_layer
        ,b.layers_per_uom
        ,b.max_in_layer
        ,a.std_hand_qty
        ,a.pallet_id
        ,CASE
            WHEN a.commodity_code NOT LIKE 'Z%' THEN 'RP'
            WHEN a.pick_put_id = 'UPH' THEN 'UPH'
            WHEN a.pick_put_id = 'PALLT' THEN 'CG'
            ELSE 'CHECK'
        END AS product
    FROM (select * from Distribution_Warehouse_Wholesale.t_item_master where wh_id = '335') AS a
    left join (select item_number, class_id, pick_put_id, units_per_layer, layers_per_uom, max_in_layer, std_hand_qty, pallet_id  
               from Distribution_Warehouse_Wholesale.t_item_uom 
               where pick_put_id = 'SCOOP' and wh_id = '335') as b on b.item_number = a.item_number


-- maximo

select top 10 * from Manufacturing_Maximo.Matrectrans where ponum = 'PF001194'
select top 10 * from Manufacturing_Maximo.MatUseTrans

-- item master
select * from Distribution_Warehouse_Wholesale.t_item_master where item_number = 'T477-8'


-- po master
select top 10 * from Wholesale_ProductSourcing_AFI.PoMaster where pomordernum in ('P03RZ33','P04G407')
select top 10 * from Distribution_Warehouse_Wholesale.Vendor where VendorCode in ('603593')



---ASN tables
select top 10 * from Distribution_Warehouse_Wholesale.t_asn where Wh_id = '335'
select distinct status from Distribution_Warehouse_Wholesale.t_asn where Wh_id = '335'

-- Trailer
select top 10 * from Distribution_Warehouse_Wholesale.Trailer where Wh_id = '335'
select distinct status from Distribution_Warehouse_Wholesale.Trailer where Wh_id = '335'

-- ATP
select  TOP 10 * from Wholesale_Purchasing_AFI.NegativeAtpAdjustAudit
select  TOP 10 * from Wholesale_Purchasing_AFI.ATPSUP 
select   * from Wholesale_Purchasing_AFI.ATPSUP WHERE ASWAREHOUSE = '335' AND ASITEMNUMBER = 'D401-325'
select  TOP 10 * from Wholesale_SalesHistory_AFI.AtpAdjustAudit
select  TOP 10 * from Wholesale_Purchasing_AFI.ATPEXT 
select  TOP 10 * from SupplyChain_Enh.ATPSUP WHERE ASWAREHOUSE = '335' 
select  TOP 10 * from SupplyChain_Enh.ATPWeekEnding WHERE ASWAREHOUSE = '335' 
select  * from SupplyChain_Enh.ATPSUP WHERE ASWAREHOUSE = '335' AND ASITEMNUMBER = 'D401-325'



-- maximo tables
select top 10 * from Manufacturing_Maximo.vnpr
select top 10 * from Manufacturing_Maximo.vnprline
select top 10 * from Manufacturing_Maximo.WorkOrder
select top 10 * from Maximo_DW.DimMROPurchaseOrderDetails
select top 10 * from Maximo_DW.FactMROPurchaseOrder
select top 10 * from Manufacturing_Maximo.Po
select top 10 * from Manufacturing_Maximo.PoLine
select top 10 * from Manufacturing_Maximo.InvVendor
select top 10 * from Maximo_DW.DimMROVendorDetails

--maximo PR query
select * 
from Manufacturing_Maximo.vnpr  as t
join Manufacturing_Maximo.vnprline as t1 on t.vnprid = t1.vnprid
where t.siteid = 'VNM.ASPM' and t.status != 'CAN' AND t.reqnum = 'ASPM2852'
order by t.apprdate desc

--maximo PO query
select top 10 * from Manufacturing_Maximo.Po 
select top 10 * from Manufacturing_Maximo.PoLine

select top 10 * from Maximo_DW.DimMROPurchaseOrderDetails
select top 10 * from Maximo_DW.FactMROPurchaseOrder



-- orders
select top 10 * from Distribution_DW.DimTripDetail_Archive where Whse = '335'
select top 10 * from Distribution_Transportation.TripVariance
select top 10 * from Distribution_Warehouse_Wholesale.TripReport
select  * from Distribution_Warehouse_Wholesale.TripReport where WhID = '335'
select top 10 * from Distribution_DW.DimTripDetail where Whse = '335'
select top 10 * from Distribution_DW.TripDetailHourly where Whse = '335'
select * from Distribution_Warehouse_Wholesale.OrderDetail_breakdown_Snapshot where wh_id = '335' where 

--booking control system, BCS
select  top 10 * from Distribution_Warehouse_Wholesale.OrderDetail_breakdown_Snapshot
select   top 10 * from Distribution_Warehouse_Wholesale.LoadMaster
select  top 10 * from Distribution_Warehouse_Wholesale.Order_Detail where wh_id = '335'
select top 10 * from Wholesale_ProductSourcing_AFI.Bookings
select top 10 * from Distribution_Warehouse_Wholesale.YaTranLog
select top 10 * from Distribution_Warehouse_Wholesale.Trailer  
select top 10 * from Distribution_Warehouse_Wholesale.YaTranLog where Wh_id = '335' and tran_type in ('103') order by started
select  * from Distribution_Warehouse_Wholesale.LoadMaster where wh_id = '335' order by trip_create_date desc
select *  from Wholesale_ProductSourcing_AFI.Bookings WHERE BokWarehouse = '335' ORDER BY dtea DESC
select top 10 * from Wholesale_ProductSourcing_AFI.BookingActions


select  * from Distribution_Warehouse_Wholesale.LoadMaster where wh_id = '335' and order by trip_create_date desc

select top 10 * from Wholesale_ProductSourcing_AFI.BookingActions where BacTripNumBer ='63832'

select * from Distribution_Warehouse_Wholesale.t_serial_active where wh_id = '1' and item_number = 'P750-776' and serial_no_status = 'H'      

SELECT a2.ITNBR,a2.PICKPUT,a2.TIHIUNLD,a2.ITMCLSID,a2.UNITSWIDE,a2.UNITLAYERS,a2.UNITSDEEP,a2.SCOOPQTY,a2.SKIDSIZE 
select top 10 * FROM MasterData_ItemMaster_AFI.ITBEXT AS a2 
WHERE a2.HOUSE IN ('335') AND a2.ITNBR = 'A1000540' 



select top 10 * from Distribution_Warehouse_Wholesale.YaTranLog 

select top 10 * from Distribution_Warehouse_Wholesale.t_item_master

select top 10 * from Distribution_Warehouse_Wholesale.YaTranLog where Wh_id = '335' and tran_type in ('103') order by started
select top 100 * from Distribution_Warehouse_Wholesale.YaTranLog where Wh_id = '335' and carrier_trailer_number in ('YMMU625322') order by started
select top 100 * from Distribution_Warehouse_Wholesale.YaTranLog where Wh_id = '335' and carrier_trailer_number in ('GLDU9831032') order by started
select top 100 * from Distribution_Warehouse_Wholesale.t_trailer_asn where Wh_id = '335' and EquipmentId in ('GLDU9831032')
select top 100 * from Distribution_Warehouse_Wholesale.Trailer 
select top 100 * from Distribution_Warehouse_Wholesale.TrailerType 

With trailer_type AS (
    select t.carrier_trailer_number, t.trailer_type_id, t1.trailer_type_name, max(LoadDate) as max_LoadDate
    from Distribution_Warehouse_Wholesale.Trailer as t
    join (select wh_id, trailer_type_id, trailer_type_name from Distribution_Warehouse_Wholesale.TrailerType where wh_id = '335' group by wh_id, trailer_type_id, trailer_type_name ) as t1 on t.trailer_type_id = t1.trailer_type_id
    where t.wh_id = '335' 
    group by t.carrier_trailer_number, t.trailer_type_id, t1.trailer_type_name
)
select top 100 * 
from Distribution_Warehouse_Wholesale.YaTranLog 
where Wh_id = '335' 
    and carrier_trailer_number in ('YMMU625322') 
order by started


Distribution_Warehouse_Wholesale.t_trailer_asn
SELECT TOP 10 *  FROM  t_trailer_asn 
SELECT TOP 10 *  FROM  t_trailer 
SELECT TOP 10 *  FROM  t_ya_location 


select * from dw_developer.tabledictionary where tpktablename LIKE '%asn%' order by tpkRowCount DESC
select top 10 * from Distribution_Warehouse_Wholesale.ASN_Detail where wh_id = '335'
select top 10 * from Distribution_Warehouse_Wholesale.HJ_t_asn_last_free_date where wh_id = '335' and asn_number = '5392021'
select top 10 * from Distribution_Warehouse_Wholesale.HJ_t_asn_last_free_date where wh_id = '335' and asn_number = '5392021'
select top 10 * from Distribution_Warehouse_Wholesale.ImportASN where wh_id = '335' and asn_number = '5392021'

select  * from t_tran_log where control_number_2 in  ('P2RJP89','P2RKC60') and start_tran_date >= '2026-01-01' order by start_tran_date, start_tran_time

select top 10 * from Distribution_Warehouse_Wholesale.t_trailer_asn

select top 10 * from Wholesale_ProductSourcing.ASNRegulatoryData
select top 10 * from Distribution_Warehouse_Wholesale.SearchAsn where WhID = '335' and AsnNumber = '5392021' order by ExpectedArrival 

select top 10 * from Distribution_Warehouse_Wholesale.t_asn where wh_id = '335' and asn_id = '5392021'
select top 10 * from Distribution_Warehouse_Wholesale.ASN_Detail where wh_id = '335' and asn_id = '5392021'

select count(*) from Distribution_Warehouse_Wholesale.t_asn where wh_id = '335' 
-- by sn 
SELECT  tran_type,description,start_tran_date,start_tran_time,employee_id,control_number,control_number_2,wh_id,location_id,hu_id,item_number,lot_number,tran_qty,location_id_2,employee_id_2
FROM  Distribution_Warehouse_Wholesale.TranLog as t 
WHERE t.wh_id = '335' and t.lot_number = '548800136605' 
order by start_tran_date, start_tran_time


SELECT T1.STID, T1.ITNBR, T1.ITCLS, T1.UNMSR, T1.WEGHT, T1.B2Z95S as Unit_Cube, T1.ITDSC
FROM MasterData_ItemMaster_AFI.ITMRVA AS T1
WHERE T1.STID IN ('335') and t1.ITNBR = 'D372-01'

SELECT * FROM PowerBI_Distribution.[DCMetrics]

select top 10 * from  MasterData_ItemMaster_WNK.ITMEXT where itnbr = '3950467'
select top 10 * from  MasterData_ItemMaster_WNK.ITMRVA where itnbr = '3950467'

-- MIL container audit
-- sn scanned into container 
select top 10 * from  Manufacturing_ProductionPlanning_MIL.WVCNTSDA order by WCSADDEDTIMESTAMP DESC
select top 10 * from  Manufacturing_ProductionPlanning_MIL.WVCNTSD order by WCSADDEDTIMESTAMP DESC
select top 10000 * from  Manufacturing_ProductionPlanning_MIL.ACTAUDT  where Serial = '555622167199' order by AddDate DESC, AddTime DESC


SELECT TOP 10 
    t.Serial, 
    MAX(t.AddDate) AS LastAddDate, 
    MAX(t.AddTime) AS LastAddTime, 
    MAX(CONCAT(t.ToArea, t.ToAisle, t.ToSection, t.ToTier)) AS location, 
    COUNT(*) AS ScanCount
FROM Manufacturing_ProductionPlanning_MIL.ACTAUDT AS t
WHERE t.Serial IS NOT NULL
GROUP BY t.Serial


-- container status:
select top 10 * from  Manufacturing_ProductionPlanning_MIL.WVCNTHDA
select top 10 * from  Manufacturing_ProductionPlanning_MIL.WVCNTIDA
select top 10 * from  Manufacturing_ProductionPlanning_MIL.TBLCONTAINERAUDITDW120RF
select top 10 * from  Manufacturing_ProductionPlanning_MIL.DWUPHSCND


select top 10 * from Manufacturing_ProductionPlanning_MIL.WVCNTHD
select top 10 * from Manufacturing_ProductionPlanning_MIL.WVCNTHDA
-- invoice header
select  * from Wholesale_SalesHistory_AFI.InvoiceHeader as t where t.[Warehouse] = '335' and t.[InvoiceDate] > '2025-01-01'

select top 10 * from CostAccounting_Enh.ShippedHistoryCubeData
select top 10 * from Manufacturing_MasterData.MFGTYPCDF

select * from dw_developer.tabledictionary where tpkSchemaName LIKE '%Wholesale_DemandPlanning_AFI%'
select * from dw_developer.tabledictionary where tpktablename LIKE '%PlanDetail%'

select top 100 * from SupplyChain_Enh.PlanDetailTimelineSnapshot as t1 where t1.PTLDATATYPE = 'SAFETY STK' AND T1.PTLWHSE = '335' order by t1.SnapShotDate DESC


CREATE NONCLUSTERED INDEX IX_PlanDetail_Optimized
ON SupplyChain_Enh.PlanDetailTimelineSnapshot (PTLDATATYPE, PTLWHSE, SnapShotDate DESC)
INCLUDE (/* 其他你需要SELECT的列 */)
WITH (ONLINE = ON, FILLFACTOR = 90);

SELECT TOP 100 * 
FROM SupplyChain_Enh.PlanDetailTimelineSnapshot WITH (NOLOCK, INDEX(IX_PlanDetail_Optimized))
WHERE PTLDATATYPE = 'SAFETY STK' 
  AND PTLWHSE = '335'
  AND SnapShotDate >= DATEFROMPARTS(YEAR(GETDATE()), 1, 1)
  AND SnapShotDate < DATEADD(DAY, 1, CAST(GETDATE() AS DATE))
  AND (DATEPART(WEEKDAY, SnapShotDate) = 7 
       OR DATEDIFF(DAY, 6, SnapShotDate) % 7 = 0)  -- 另一种周六判断方式
ORDER BY SnapShotDate DESC
OPTION (MAXDOP 4, RECOMPILE);  -- 根据你的CPU核心数调整

PlanDetailTimeline
Select top 10 * From  Wholesale_CODIS_WNK.BTITSCN

select * from dw_developer.tabledictionary where tpkSchemaName like '%Manufacturing_ProductionPlanning_MIL%' ORDER BY tpkTableName
Select top 10 * From  Manufacturing_ProductionPlanning_MIL.WVCNTSD ORDER BY WCSADDEDTIMESTAMP ASC
Select top 10 * From  Manufacturing_ProductionPlanning_MIL.WVCNTSDA ORDER BY WCSADDEDTIMESTAMP ASC

select t.WCSCONTAINERNUMBER	WCSORIGIN	WCSDESTINATION	WCSORDER	WCSITEMNUMBER	WCSSERIALNUMBER	WCSADDEDTIMESTAMP	WCSADDEDUSER	WCSADDEDPROGRAM	WCSARCHIVETIMESTAMP

Select top 10 * From [PowerBI_ADS].[CVRreport] order by POMDue ASC


--------- main-----------------------------------------------------------------
Select top 1000 * From  Manufacturing_ProductionPlanning_MIL.DWUPHSCND ORDER BY UDDDAT DESC
Select top 1000 * From Manufacturing_ProductionPlanning_MIL.DWSNDEXT

Select DISTINCT * From [PowerBI_ADS].[CVRreport] where POMWarehouse = '335' and POMOrderNum = 'P2PVZ21'


Select top 10 * From  Manufacturing_ProductionPlanning_MIL
Select top 10 * From MasterData_HR_ADS.DriverLicenses

select top 10 * from Distribution_Warehouse_Wholesale.t_employee where wh_id = '51'
select cast(t.emp_number as int) as emp_number,
    t.name,
        t.dept,
    t.wh_id,
    t.group_nbr,
    t.supervisor_nbr
from Distribution_Warehouse_Wholesale.t_employee as t
where t.wh_id = '51'

-- employee master
SELECT 
    t.Plant,
    t.EmployeeNumber,
    t.EmpReportName,
    t.GroupNumber,
    t.Schedule,
    t.HomeDepartment,
    t.TerminationDate
FROM Manufacturing_ProductionPlanning_MIL.EMMSTR as t
WHERE t.EmployeeNumber like '%51014%'


SELECT top 100 * FROM Manufacturing_ProductionPlanning_MIL.PYREXPH

SELECT top 1000 * FROM  Manufacturing_ProductionPlanning_MIL.EMMSTR as t
SELECT top 100 * FROM Manufacturing_ProductionPlanning_MIL.ACTAUDT WHERE Serial = '555636726090' order by AddDate, AddTime

-- Container loading file
SELECT top 10 * FROM Manufacturing_ProductionPlanning_MIL.WVCNTHDA ORDER BY WCHPOSTEDTIMESTAMP DESC

SELECT top 10 * FROM Manufacturing_ProductionPlanning_MIL.WVCNTIDA ORDER BY  WCHPOSTEDTIMESTAMP DESC
SELECT top 10 * FROM Manufacturing_ProductionPlanning_MIL.WVCNTSDA

SELECT top 10 * FROM Manufacturing_ProductionPlanning_MIL.WVCNTHD
SELECT top 10 * FROM Manufacturing_ProductionPlanning_MIL.WVCNTID
SELECT top 20 * FROM Manufacturing_ProductionPlanning_MIL.WVCNTSD WHERE WCSSERIALNUMBER ='555636726090'





    SELECT top 10 *,
        SUBSTRING(LEFT(t.transaction_string, 21), 12, 10) AS trip_nbr_2
    FROM Distribution_Warehouse_Wholesale.[t_import_WAORDER] AS t
    WHERE t.imported > DATEADD(DAY, -7, GETDATE())
        AND t.transaction_string LIKE 'L%'
        AND RIGHT(SUBSTRING(LEFT(t.transaction_string, 21), 12, 10),2) <> '00'
		AND t.transaction_string LIKE '%74674%'


select top 10 *  from Distribution_Warehouse_Wholesale.TranLog where wh_id ='335'  and start_tran_date > '2025-07-29' and  tran_type = '350' and control_number_2 like '%75973%'


SELECT 
	t.shcInvoiceNumber,
	t.shcOrderNumber,
	t.shcItemNumber,
	t.shcGrossQuantityShipped,
	t.shcInvoiceDate,
	t.shcWarehouse,
	t.shcCustomerPONumber,
	t.shcTripNumber,
	t.shcOrderType2,
	t.shcCustomerNumber,
	t.shcShipToNumber,
	t.shcShipToName,
	t.shcBusinessType,
	t.shcHomestoreFlag,
	t.shcBillToName,
	t.shcBillToCountry,
	t.shcShipToCountry,
	t.shcQuantityUnitOfMeasure,
	t.shcItemClass,
	t.shcItemClassDescription,
	t.shcItemDescription

	FROM  CostAccounting_Enh.ShippedHistoryCubeData as t
	WHERE t.shcWarehouse IN ('335') 
		and t.shcItemNumber like 'M%' 
		and t.shcInvoiceDate > '2025-01-01'



select * from dw_developer.tabledictionary where tpkSchemaName like '%SalesHistory%'
select * from dw_developer.tabledictionary where tpktablename like '%DW013EW1%'

SELECT top 1000 * FROM  Wholesale_Invoicing_AFI.DW013EW1 where WHSNO = '335'
SELECT top 10 * FROM  Wholesale_Invoicing_AFI.MBF9REP

select * FROM Distribution_Warehouse_Wholesale.t_stored_item where wh_id in  ('35','33','31')
select * FROM Distribution_Warehouse_Wholesale.t_stored_item where wh_id in  ('335')
SELECT top 100 * FROM   Wholesale_CODIS.WHFILRQ AS t where t.FLHOUSE = '335' order by t.FLTRIPNO, t.FLRDTE

SELECT
    t.FLTRIPNO,
    t.FLHOUSE,
    t.FLCUBES,
    t.FLPRCCUBES,
    t.FLCUSNO,
    t.FLSHPNO,
    t.FLRUSR,
    DATEADD(HOUR, 12, t.FLRDTE) AS FLRDTE_PLUS_12H,
    t.FLUSRP,
    DATEADD(HOUR, 12, t.FLPDTE) AS FLPDTE_PLUS_12H,
    t.FLPROC
FROM 
    Wholesale_CODIS.WHFILRQ AS t
WHERE 
    t.FLHOUSE = '335'
    AND DATEADD(HOUR, 12, t.FLRDTE) > DATEADD(DAY, -360, GETDATE())
ORDER BY 
    t.FLTRIPNO, t.FLRDTE;

t_item_master
SELECT top 10 * FROM   Manufacturing_Inventory_MIL.IMHIST
SELECT top 10 * FROM MasterData_ItemMaster_MIL.ITMRVA WHERE STID = '51' AND ITCLS LIKE 'Z%K' OR ITCLS = 'WVVG'



With itm as (
	SELECT t.ITNBR AS item_number,
		t.ITDSC AS description,
		t.BZCQCD AS uom,
		'FG' AS inventory_type,
		t.ITCLS AS commodity_code,
		t.STID as wh_id,
		'PAL5H' as class_id,
		t.WEGHT as unit_weight,
		t.B2Z95S as unit_volume,
		t.B2Z95S as nested_volume,
		'PALLT' as pick_put_id,
		'5x5' as pallet_id,
		 CASE 
			WHEN t.B2Z95S = 0 THEN ROUND(131.355 / 2.167,2)    -- 2.617 为平均Unkits体积
			ELSE ROUND(131.355 / t.B2Z95S, 2)     -- 5 x 5 x 5.25 = 131.355  ft³ (height is 1.6m)
			-- ELSE ROUND(131.355 / t.B2Z95S, 2)     --5 × 7 × 5.2493 = 183.725 ft³ (height is 1.6m) 
		  END AS std_hand_qty,
		'CG' AS product
	FROM MasterData_ItemMaster_MIL.ITMRVA as t WHERE STID = '51' AND ITCLS LIKE 'Z%K' OR ITCLS = 'WVVG'
	)

	SELECT t0.HOUSE AS wh_id,
		t0.TCODE as tran_type,
		'Shipment' as description,
		t0.UPDDT as start_tran_date,
		t0.ITNBR AS item_number,
		'CG' as product,
		'5x5' as pallet_id,
		sum(t0.TRQTY) AS qty
FROM   Manufacturing_Inventory_MIL.IMHIST as t0
LEFT JOIN itm  ON itm.item_number = t0.ITNBR
WHERE t0.HOUSE ='51' 
	AND t0.TCODE = 'SA'
	AND CAST(
    '20' + RIGHT(t0.UPDDT, 6) AS DATE
  ) >= CAST(GETDATE() - 90 AS DATE)
)
GROUP BY t0.HOUSE AS wh_id,
		t0.TCODE as tran_type,
		'Shipment' as description,
		t0.UPDDT as start_tran_date,
		t0.ITNBR AS item_number,
		'CG' as product,
		'5x5' as pallet_id


SELECT top 10 * 
FROM   Manufacturing_Inventory_MIL.IMHIST as t
LEFT JOIN itm as i ON i.item_number = t.ITNBR

SELECT top 10 * FROM  Wholesale_CODIS.WHFILRQ as t where t.FLHOUSE = '335'

SELECT top 10 * FROM  Distribution_DW.DimTripDetailSnapshot
SELECT top 100 * FROM  Distribution_DW.DimTripDetail 
SELECT *, 
        SUBSTRING(LEFT(t.transaction_string, 21), 12, 10) AS trip_nbr_2
    FROM Distribution_Warehouse_Wholesale.[t_import_WAORDER] AS t
    WHERE t.imported > DATEADD(DAY, -10, GETDATE())
        AND t.transaction_string LIKE 'L%' 
        AND RIGHT(SUBSTRING(LEFT(t.transaction_string, 21), 12, 10),2) <> '00'


select distinct tran_type, description  from Distribution_Warehouse_Wholesale.TranLog where wh_id ='51'  and start_tran_date > '2025-01-01' order by tran_type


SELECT * FROM AFISales_DW.FactShippedHistory where [Order Number] = 'D635686' and Warehouse in ('C','C35')

SELECT top 100 * FROM  Distribution_Warehouse_Wholesale.maTranLog as t WHERE t.wh_id = '51'  and line_number = 'IP'  order by start_tran_date desc
SELECT  top 1000 *
FROM  CostAccounting_Enh.ShippedHistoryCubeData as t
WHERE t.shcWarehouse IN ('C','C35') AND shcOrderNumber = 'D635686'

SELECT  top 1000 *
FROM  CostAccounting_Enh.ShippedHistoryCubeData as t
WHERE t.shcWarehouse IN ('C35') 


	and t.shcInvoiceDate between '2025-07-20' and '2025-07-22'
	and t.shcTripNumber <>0
	and t.shcCustomerNumber = '3824800'
	and t.shcShipToNumber = '17'

SELECT top 100 * FROM Wholesale_SalesHistory_AFI.OrderHistory
SELECT top 100 * FROM Wholesale_Purchasing_WNK.POMAST ORDER BY MDATE DESC
SELECT top 100 * FROM Wholesale_Purchasing_WNK.POITEM ORDER BY MDATE DESC


SELECT top 100 * 
FROM Manufacturing_ProductionPlanning_MIL.ACTAUDT 
WHERE ActivityCodeOne = 'CN'
	AND FromWhs = '51'
	AND ToWhs <> '51'
	AND ToRegion = 0
	AND FromArea = 'HJ'
order by AddDate, AddTime



WITH LatestBookings AS (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY BokTripNumBer ORDER BY BokTripCreateDate DESC) AS rn
    FROM [Wholesale_ProductSourcing_AFI].[Bookings]
    WHERE BokWarehouse = '335'
)
SELECT t.*, d.tpkModified
FROM LatestBookings AS t
CROSS JOIN (SELECT tpkModified FROM dw_developer.tabledictionary WHERE tpktablename LIKE 'Bookings') AS d
WHERE t.rn = 1
--AND t.BokTripStatusCode NOT IN ('P')
AND t.BokContainerNumBer IN ('OOLU899910','CSNU562396')
AND t.BokTripNumBer = '4259'
  AND t.BokTripCreateDate > DATEADD(DAY, -120, GETDATE())
ORDER BY t.BokTripNumBer, t.BokTripCreateDate;





SELECT top 10 * FROM Manufacturing_ProductionPlanning_MIL.WVCNTHDA ORDER BY WCHPOSTEDTIMESTAMP DESC
SELECT top 10 * FROM Manufacturing_ProductionPlanning_MIL.WVCNTHD ORDER BY WCHPOSTEDTIMESTAMP DESC





select top 10 * from [Manufacturing_ProductionPlanning_WNK].[EMMSTR]
select top 10 * from [Manufacturing_ProductionPlanning_WNK].[PYREXPH] WHERE TransactionDate ='2024-07-16'
select top 1000 * from [Manufacturing_ProductionPlanning_MIL].[EMMSTR] where HomeDepartment IN ('2751', '8123') AND (TerminationDate IS NULL or TerminationDate <= CAST('1900-01-01' AS DATE))
select top 10 * from [Manufacturing_ProductionPlanning_MIL].[PYREXPH]

select * from dw_developer.tabledictionary where tpktablename like '%t_import_WAORDER%'
=======
>>>>>>> 2c2f8f067236ebe3b666e941b4b7c41371b10ed3


-- 列出有重复值的location
SELECT location_id, COUNT(*) AS cnt
FROM Distribution_Warehouse_Wholesale.t_location
WHERE wh_id = '51' AND location_id LIKE 'US%'
GROUP BY location_id
HAVING COUNT(*) > 1


SELECT top 100 * FROM   Distribution_Warehouse_Wholesale.t_location WHERE wh_id = '51' and location_id LIKE 'US%'

SELECT top 10 * FROM Distribution_Warehouse_Wholesale.t_item_master t1 where t1.item_number = 'EW0267-268'
SELECT top 10 * FROM Distribution_Warehouse_Wholesale.t_item_master t1 where t1.item_number = 'EW0267-268'
SELECT top 10 * FROM MasterData_ItemMaster_MIL.ITBEXT t1 where t1.ITNBR = 'EW0267-268'


FROM (select * from MasterData_ItemMaster_MIL.ITMRVA as t0 where t0.STID = '51') as t3
LEFT JOIN Distribution_Warehouse_Wholesale.t_item_master t1
    ON t1.item_number = t3.ITNBR AND t1.wh_id = '51'
LEFT JOIN MasterData_ItemMaster_MIL.ITBEXT t4
    ON t3.ITNBR = t4.ITNBR AND t4.HOUSE = '51'


select distinct tran_type, description  from Distribution_Warehouse_Wholesale.TranLog where wh_id ='51'  and start_tran_date > '2025-01-01' order by tran_type


SELECT top 10 * FROM Manufacturing_ProductionPlanning_MIL.ACTAUDT as t  order by t.AddDate Desc, t.AddTime Desc

SELECT top 10 * FROM Manufacturing_Inventory_AFI.TAGINVD WHERE TDWHSE = '51'

-- MIL Container loading scan tablea
SELECT top 10 * FROM Manufacturing_ProductionPlanning_MIL.WVCNTHDA
SELECT top 10 * FROM Manufacturing_ProductionPlanning_MIL.WVCNTSDA
SELECT top 10 * FROM Manufacturing_ProductionPlanning_MIL.WVCNTIDA
SELECT top 10 * FROM Manufacturing_ProductionPlanning_MIL.WVCNTHD
SELECT top 10 * FROM Manufacturing_ProductionPlanning_MIL.WVCNTID
SELECT top 10 * FROM Manufacturing_ProductionPlanning_MIL.WVCNTSD


SELECT top 10 * FROM Manufacturing_ProductionPlanning_MIL.SIMLBP
SELECT top 10 * FROM MasterData_ItemMaster_AFI.DWHOLDITM1
SELECT top 10 * FROM MasterData_IT_MIL.AS400SysTablesandColumns
SELECT * FROM Wholesale_Purchasing_MIL.WHSMST
SELECT * FROM Wholesale_CODIS.LOCMST WHERE Whse# = '335' and Area like 'A3%'


Manufacturing_Inventory_MIL.IMHIST
SELECT top 10 * FROM [Manufacturing_ProductionPlanning_AFI].[SLQNTY_Snapshot_AFI]   --scheduled to run weekly on Sundays at 7:00 AM UTC / 2:00 AM CST, as requested.
SELECT top 10* FROM [Manufacturing_ProductionPlanning_MIL].[SLQNTY_Snapshot_MIL]    --scheduled to run weekly on Sundays at 7:00 AM UTC / 2:00 AM CST, as requested.
SELECT top 10* FROM [Manufacturing_ProductionPlanning_WNK].[SLQNTY_Snapshot_WNK]   --scheduled to run weekly on Sundays at 7:00 AM UTC / 2:00 AM CST, as requested.


SELECT TOP 10 * FROM Manufacturing_Inventory_MIL.IMHIST
SELECT TOP 10 * FROM Manufacturing_ProductionPlanning_MIL.SLQNTY

 SELECT TOP 10 t.ITNBR, 
	t.CUBES,
	t.CRTLIN,
	t.CRTWIN,
	t.CRTHIN,
	t.ITMWEGHT
    FROM MasterData_ItemMaster_AFI.ITMEXT as t
UNION ALL
    SELECT TOP 10 t.ITNBR, 
	t.CUBES,
	t.CRTLIN,
	t.CRTWIN,
	t.CRTHIN,
	t.ITMWEGHT
    FROM MasterData_ItemMaster_WNK.ITMEXT as t  where t.itnbr = 'A3000602'
UNION ALL
    SELECT TOP 10 t.ITNBR, 
	t.CUBES,
	t.CRTLIN,
	t.CRTWIN,
	t.CRTHIN,
	t.ITMWEGHT
    FROM MasterData_ItemMaster_MIL.ITMEXT as t


select top 10 *  from Manufacturing_ProductionPlanning_MIL.WVCNTIDA  ORDER BY WCILASTMAINTENANCETIMESTAMP desc

select Category,MaterialType, StyleType  from Manufacturing_ProductionPlanning_MIL.ItemMaster group by Category,MaterialType, StyleType
select Category,MaterialType, StyleType  from Manufacturing_ProductionPlanning_WNK.ItemMaster group by Category,MaterialType, StyleType
select Category,MaterialType, StyleType  from Manufacturing_ProductionPlanning_AFI.ItemMaster group by Category,MaterialType, StyleType ORDER BY Category

select top 1000 *  from Manufacturing_ProductionPlanning_MIL.ItemMaster
select top 1000 *  from Manufacturing_ProductionPlanning_WNK.ItemMaster
select top 1000 *  from Manufacturing_ProductionPlanning_AFI.ItemMaster

select top 10 *  from Manufacturing_ProductionPlanning_MIL.WVCNTHD ORDER BY WCHPOSTEDTIMESTAMP desc
select top 10 *  from Manufacturing_ProductionPlanning_MIL.WVCNTSD ORDER BY WCSADDEDTIMESTAMP desc

select top 10 *  from Manufacturing_ProductionPlanning_MIL.WVCNTHDA ORDER BY WCHPOSTEDTIMESTAMP desc


select top 10 *  from Wholesale_ProductSourcing_WNK.ContainerLoadingDetail
select top 10 *  from Manufacturing_ProductionPlanning_WNK.DWUPHSCND
select top 10 *  from Manufacturing_ProductionPlanning_WNK.PC216WSCH
select top 10 *  from Wholesale_DemandPlanning_WNK.SUPPLY_DEMAND_COLS
select top 1000 *  from Manufacturing_ProductionPlanning_MIL.DWUPHSCND ORDER BY UDDDAT DESC

select top 10 *  from MasterData_IT_MIL.AS400SysTablesandColumns
select top 10 *  from MasterData_HR_WVF.EMMSTR
select top 10 *  from MasterData_ItemMaster_MIL.PC323AF
select top 10 *  from MasterData_HR_MIL.CUREMM6
select top 10000 *  from Manufacturing_ProductionPlanning_MIL.PC228RPF where LoadDate > '2025-01-01' order by LoadDate DESC
select top 10 *  from Distribution_Warehouse_Wholesale.TranLog where wh_id ='51'  and start_tran_date > '2025-01-01'

select top 10 *  from Distribution_Warehouse_Wholesale.TranLog where wh_id ='51'  and start_tran_date > '2025-01-01'

select top 1000 *  from Distribution_Warehouse_Wholesale.TranLog where wh_id ='51'  and start_tran_date > '2025-01-01' and lot_number = '501605115201'



order by start_tran_date desc, start_tran_time desc

select top 10 * from Manufacturing_ProductionPlanning_MIL.ACTAUDT order by AddDate Desc, AddTime Desc

select top 10 * from   MasterData_ItemMaster_MIL.ITBEXT

select * from SupplyChain_Enh.ATPSUP as t where t.ASWAREHOUSE = '335'  AND t.ASITEMNUMBER = 'B5169-196' 
	AND t.SnapShotDate in ( select max(t0.SnapShotDate) as SnapShotDate 
							from SupplyChain_Enh.ATPSUP  as t0
							where t0.ASWAREHOUSE = '335' and t0.ASITEMNUMBER = 'B5169-196'
							group by t0.ASITEMNUMBER) 

	ORDER BY t.ASWEEKDEMDATE Desc



select top 10 * from  Wholesale_Purchasing_AFI.ATPSUM AS t  where t.APHOUS = '335'
select * from  Wholesale_Purchasing_AFI.ATPSUM AS t  where t.APHOUS = '335' and t.APITNB = 'B5169-196'

select * from dw_developer.tabledictionary where tpkSchemaName = 'Distribution_Warehouse_Wholesale' and tpktablename = 'TranLog' 

select top 10 * from Distribution_Warehouse_Wholesale.TranLog where wh_id ='335' order by start_tran_date desc, start_tran_time desc


select * from dw_developer.tabledictionary where tpktablename like '%ITBEXT%'

select * from dw_developer.tabledictionary where tpktablename like '%MENU%'
SELECT  * FROM Distribution_Warehouse_Wholesale.Menu AS t where t.wh_id = '335' and t.locale_id = '1033' and t.menu_level LIKE '%WHSSUPVSOR'

SELECT *  
FROM Distribution_Warehouse_Wholesale.t_item_master AS t 
WHERE t.wh_id = '335' 
  AND t.item_number LIKE 'R%'
  AND EXISTS (
        SELECT 1 
        FROM (
            SELECT a.item_number
            FROM Distribution_Warehouse_Wholesale.t_stored_item AS a 
            WHERE a.wh_id = '335'
              AND a.item_number LIKE 'R%'
              AND a.location_id NOT LIKE 'RP%'
              AND a.actual_qty > 0 
              AND a.type = 'STORAGE'
            GROUP BY a.item_number
        ) AS a1
        WHERE a1.item_number = t.item_number
    )
  AND t.description LIKE '%RUG%'
  AND t.class_id <> 'RUGS';




SELECT TOP 10 * FROM MasterData_ItemMaster_MIL.ITMRVA t3
SELECT TOP 10 * FROM  MasterData_ItemMaster_MIL.ITBEXT where HOUSE = '51'
SELECT COUNT(*) FROM  MasterData_ItemMaster_MIL.ITBEXT where HOUSE = '51'
SELECT TOP 10 * FROM Distribution_Warehouse_Wholesale.t_item_master t1 where t1.wh_id = '51'

SELECT TOP 10 * FROM Distribution_Warehouse_Wholesale.t_import_WAORDER ORDER BY imported desc

SELECT TOP 1000 * FROM Distribution_Warehouse_Wholesale.t_import_WAORDER 
where imported>'2025/07/01' and transaction_string like 'L%0063353%'
order by import_id

SELECT *
FROM Distribution_Warehouse_Wholesale.TranLog AS t1
WHERE t1.wh_id = '335'
    AND t1.start_tran_date > '2025-01-13'
    AND t1.tran_type IN ('350')
	AND t1.control_number_2 LIKE '%0040042%'
ORDER BY t1.start_tran_date desc


SELECT TOP 1000 * FROM Distribution_Warehouse_Wholesale.t_import_WAORDER 
where imported>'2025/01/01' and transaction_string like 'L%0047848%'
order by import_id

SELECT * FROM Distribution_Warehouse_Wholesale.TranLog AS t1 WHERE t1.wh_id = '335' AND t1.start_tran_date > '2025-06-13'
    AND t1.tran_type IN ('350')
	AND t1.control_number_2 LIKE '%0056667%'
ORDER BY t1.start_tran_date desc

0056667-00
0040042

SELECT TOP 10 * FROM Wholesale_CODIS.BTTRIPH

select * from dw_developer.tabledictionary where tpktablename like '%order%' order by tpkSchemaName


SELECT TOP 10 * FROM Distribution_Warehouse_Wholesale.t_order where wh_id = '335' and load_id like '%46064%'  --- 3h fresh
SELECT TOP 1000 * FROM Distribution_Warehouse_Wholesale.OrderDetail where wh_id = '335' and order_number  like '%46064%'   --- 2h fresh 
SELECT TOP 50 * FROM Distribution_Warehouse_Wholesale.OrderDetail where wh_id = '335' order by priority_change_date   --- 2h fresh 

SELECT TOP 10 * FROM Distribution_Warehouse_Wholesale.t_order where wh_id = '335' and load_id like '%82149%'  --- 3h fresh
SELECT TOP 1000 * FROM Distribution_Warehouse_Wholesale.OrderDetail where wh_id = '335' and order_number  like '%82149%'   --- 2h fresh 
SELECT TOP 1000 * FROM Distribution_Warehouse_Wholesale.Order_Detail where wh_id = '335' and order_number  like '%82149%'   --- 2h fresh 

SELECT LEFT(t.order_number,10) AS trip,
	t.line_type,
	SUM(t.qty) AS trip_qty,
	SUM(t.qty_shipped) AS trip_qty_shipped,
	SUM(t.unit_volume * t.qty) AS trip_cubes,
	SUM(t.unit_volume * t.qty_shipped) AS trip_shipped_cubes
FROM Distribution_Warehouse_Wholesale.Order_Detail AS t
WHERE t.wh_id = '335'
GROUP BY LEFT(t.order_number,10),
		 t.line_type


SELECT TOP 10 * FROM Distribution_Warehouse_Wholesale.Order_Detail    --- daily fresh 

SELECT TOP 10 * FROM Distribution_Warehouse_Wholesale.OrderCNumber    --- 2h fresh 
SELECT TOP 1000 * FROM Distribution_Warehouse_Wholesale.t_import_WAORDER  where transaction_string like 'L%'order by imported desc  --- 3h fresh


SELECT TOP 10 * FROM Distribution_Warehouse_Wholesale.t_inbound_order_state

SELECT TOP 10 * FROM Distribution_Warehouse_Wholesale.OrderDetail_breakdown_Snapshot
SELECT TOP 10 * FROM Distribution_Warehouse_Wholesale.OrderNumberComment
SELECT TOP 10 * FROM Distribution_Warehouse_Wholesale.ExpressOrderReport
SELECT TOP 10 * FROM Distribution_Warehouse_Wholesale.MdcrdcWaveOrderDetail


WITH WA AS (
-- Trip imported into HJ records:
SELECT *, 
    SUBSTRING(LEFT(t.transaction_string, 21), 12, 10) AS trip_nbr_2,
	LEN(SUBSTRING(LEFT(t.transaction_string, 21), 12, 10)) as characters
FROM Distribution_Warehouse_Wholesale.[t_import_WAORDER] AS t
WHERE t.imported > '2025-06-01' 
    AND t.transaction_string LIKE 'L%' 
	AND RIGHT(SUBSTRING(LEFT(t.transaction_string, 21), 12, 10),2) <>'00'
)
SELECT  *, 
	CAST(LEFT(t1.trip_nbr_2,7) AS INT) AS trip_nbr
FROM WA AS t1
ORDER BY  CAST(LEFT(t1.trip_nbr_2,7) AS INT),
	SUBSTRING(LEFT(t1.transaction_string, 21), 12, 10)


WITH 


tran_with_datetime AS (
    SELECT 
        t1.tran_type,
        t1.description,
        t1.employee_id,
        t1.control_number_2,
        t1.start_tran_date,
        t1.start_tran_time,
        t1.tran_qty,
        CAST(CAST(t1.start_tran_date AS DATETIME) + CAST(t1.start_tran_time AS DATETIME) AS DATETIME) AS start_tran_datetime
    FROM Distribution_Warehouse_Wholesale.TranLog AS t1
    WHERE t1.wh_id = '335'
        AND t1.start_tran_date > '2025-01-01'
        AND t1.tran_type IN ('350')
		AND t1.control_number_2 LIKE '%46064%'
),
ranked_tran AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY tran_type, description, employee_id, control_number_2
            ORDER BY start_tran_datetime
        ) AS rn
    FROM tran_with_datetime
)
SELECT 
    tran_type,
    description,
    employee_id,
    control_number_2,
    start_tran_date,
    start_tran_time,
    start_tran_datetime,
    tran_qty
FROM ranked_tran
WHERE rn = 1;


-- where imported >'2025-01-01' and transaction_string like 'L335%0004259%'



-- Tranlog
SELECT * 
FROM Distribution_Warehouse_Wholesale.TranLog AS t1 
WHERE t1.wh_id = '335' 
	AND t1.start_tran_date > '2025-01-01'
	AND t1.tran_type IN ('322')
	AND t1.control_number_2 LIKE '0004259%' 
	AND t1.item_number = 'RP ORDER'

SELECT TOP 100 * FROM Distribution_Warehouse_Wholesale.maTranLog
SELECT TOP 100 * FROM Distribution_Warehouse_Wholesale.matranlog_Archive
SELECT TOP 100 * FROM Distribution_Warehouse_Retail.TranLog
SELECT TOP 100 * FROM Distribution_Warehouse_Wholesale.YaTranLog
SELECT TOP 100 * FROM Distribution_Warehouse_Wholesale.TranLog
SELECT TOP 100 * FROM Distribution_Warehouse_Wholesale.t_item_master where wh_id= '335'

-- trip report
SELECT top 10 * 
FROM Distribution_Warehouse_Wholesale.TripReport  as t  
WHERE t.WhID = '335' 
	--AND t.TripStatus NOT IN ('S','X') 
	--AND right(t.loadID,2) <> '00' 
	AND t.LoadID like '0015130%'

WITH itm AS (
SELECT t.item_number,
	t.description,
	t.commodity_code,
	t.
FROM Distribution_Warehouse_Wholesale.t_item_master  AS t 
WHERE t.wh_id = '335'
)
SELECT TOP 100 * Distribution_Warehouse_Wholesale.TranLog

SELECT TOP 10 * FROM Distribution_Warehouse_Wholesale.t_asn as t WHERE t.wh_id = '335'
SELECT TOP 10 * FROM Distribution_Warehouse_Wholesale.ASN_Detail AS a2 where a2.wh_id = '335'
SELECT TOP 10 * FROM Distribution_Warehouse_Wholesale.t_trailer_asn as a3 WHERE a3.Wh_id = '335'
SELECT TOP 10 * FROM Distribution_Warehouse_Wholesale.Trailer AS a4 WHERE a4.wh_id = '335' 

SELECT top 10 * from  Distribution_Warehouse_Wholesale_History.t_stored_item_Holding_Ashton
SELECT top 10 * from Wholesale_CODIS_AFI.TransferOrderDetails_TrippedFrom as t1 where t1.HTFRNO = 'TM28581'
SELECT * from Wholesale_CODIS_AFI.TransferOrderDetails_TrippedTO
SELECT count(*) from Wholesale_CODIS_AFI.TransferOrderDetails_UnTrippedFrom
SELECT count(*) from Wholesale_CODIS_AFI.TransferOrderDetails_UnTrippedTO



SELECT * from Manufacturing_Maximo.vnprline AS t WHERE t.siteid = 'VNM.ASPM'
SELECT  * from Manufacturing_Maximo.vnpr AS t WHERE t.siteid = 'VNM.ASPM'

SELECT TOP 10 * from Distribution_Warehouse_Wholesale.t_forward_pick as t1 WHERE t1.wh_id = '335' AND t1.LocationId like 'A3%'
SELECT top 10* FROM Distribution_Warehouse_Wholesale.t_stored_item sto  WHERE sto.wh_id = '335' AND sto.type = 'STORAGE' AND sto.location_id LIKE 'A3%'

SELECT sto.wh_id, actual sum FROM Distribution_Warehouse_Wholesale.t_stored_item sto 

SELECT TOP 10 * from  Distribution_Warehouse_Wholesale.t_location AS t1 WHERE t1.wh_id = '335'


Select top 10 * from Manufacturing_ProductionPlanning_MIL.ACTAUDT
Select count(*) from Manufacturing_ProductionPlanning_MIL.ACTAUDT
select top 10 * from  Distribution_Warehouse_Wholesale.[t_import_WAORDER] AS t ORDER BY t.imported desc 

select * from  Distribution_Warehouse_Wholesale.[t_import_WAORDER] AS t where t.transimprt_transaction_id = '0015689524521' order by t.transimprt_sequence

select * from  Distribution_Warehouse_Wholesale.[t_import_WAORDER] AS t where t.transimprt_transaction_id = '0015689524521' order by t.transimprt_sequence


select count(*)  from  Distribution_Warehouse_Wholesale.[t_import_WAORDER]  
select count(*)  from [Manufacturing_ProductionPlanning_MIL].[TBL_RPLABEL_ARCFILE_PC228RPFA]
select count(*)  from [Manufacturing_ProductionPlanning_MIL].[PC228RPF]




select top 10 * from [Manufacturing_ProductionPlanning_MIL].[PC228RPF]

-- ASN
SELECT top 10 * FROM  Distribution_Warehouse_Wholesale.t_inbound_order_state


SELECT top 10 * FROM  Distribution_Warehouse_Wholesale.OrderDetail
SELECT top 10 * FROM  Distribution_Warehouse_Wholesale.Order_Detail

SELECT  * FROM  Distribution_Warehouse_Wholesale.LoadMaster AS t where t.wh_id = '335' AND t.load_id like '%53265%'



SELECT top 10 * FROM  Distribution_Warehouse_Wholesale.ImportASN WHERE whid = '335'

SELECT top 10 * FROM Distribution_Warehouse_Wholesale.YaLocation as a5 WHERE a5.area_id in ('335')
SELECT * FROM Distribution_Warehouse_Wholesale.t_po_master as t where t.wh_id = '335'

-- plate section
SELECT TOP 10 * FROM Distribution_Warehouse_Wholesale.t_item_plate_section


SELECT TOP 10 * FROM  Manufacturing_ProductionPlanning_WNK.UPH_KIND

-- Transactions
SELECT t3.tran_type,
    t3.description,
    CAST(LEFT(t3.control_number_2,7) AS INT) AS trip_nbr,
    t3.location_id,
    SUM(t3.tran_qty) as fill_request_cubes,
    MIN(TRY_CAST(CONCAT(t3.start_tran_date, ' ', FORMAT(TRY_CAST(t3.start_tran_time AS DATETIME), 'HH:mm:ss')) AS DATETIME)) AS Earliest_request_fill_time
FROM [PowerBI_Distribution].[TranLog] AS t3
WHERE t3.wh_id = '335'
    AND t3.tran_type = '350'
    AND t3.start_tran_date > '2025-03-01'
    AND TRY_CAST(t3.start_tran_time AS DATETIME) IS NOT NULL  -- Filter out invalid time values
GROUP BY t3.tran_type,
    t3.description,
    CAST(LEFT(t3.control_number_2,7) AS INT), 
    t3.location_id
ORDER BY  CAST(LEFT(t3.control_number_2,7) AS INT),
	MIN(TRY_CAST(CONCAT(t3.start_tran_date, ' ', FORMAT(TRY_CAST(t3.start_tran_time AS DATETIME), 'HH:mm:ss')) AS DATETIME)) 



-- Diagnostic query to find problematic date/time values
SELECT TOP 100
    start_tran_date,
    start_tran_time,
    CONCAT(start_tran_date, ' ', start_tran_time) AS concatenated_datetime,
    TRY_CAST(CONCAT(start_tran_date, ' ', start_tran_time) AS DATETIME) AS converted_datetime,
    CASE 
        WHEN TRY_CAST(CONCAT(start_tran_date, ' ', start_tran_time) AS DATETIME) IS NULL 
        THEN 'INVALID' 
        ELSE 'VALID' 
    END AS conversion_status
FROM [PowerBI_Distribution].[TranLog]
WHERE wh_id = '335'
    AND tran_type = '350'
    AND start_tran_date > '2025-01-01'
ORDER BY conversion_status DESC, start_tran_date, start_tran_time;

















-- MIL container loading
SELECT TOP 10 * FROM Manufacturing_ProductionPlanning_MIL.WVCNTIDA
SELECT TOP 10 * FROM Manufacturing_ProductionPlanning_MIL.WVCNTID
SELECT TOP 10 * FROM Manufacturing_ProductionPlanning_MIL.WVCNTSD
SELECT TOP 10 * FROM Manufacturing_ProductionPlanning_MIL.WVCNTSDA
SELECT TOP 10 * FROM Manufacturing_ProductionPlanning_MIL.WVCNTHD
SELECT TOP 10 * FROM Manufacturing_ProductionPlanning_MIL.WVCNTHDA

SELECT TOP 10 * FROM Manufacturing_ProductionPlanning_MIL.WVCNTSD as t where t.WCSITEMNUMBER LIKE '10002105%'
SELECT TOP 10 * FROM Manufacturing_ProductionPlanning_MIL.WVCNTID as t where t.WCIITEMNUMBER LIKE '10002105%'

SELECT TOP 10 * FROM Distribution_Warehouse_Wholesale.ACTAUDT AS t where t.aatwhs = '51'


SELECT top 10 * FROM RGNFILL.TBL_CONTAINER_AUDIT_DW120RF t WHERE t.

SELECT *  FROM Manufacturing_ProductionPlanning_MIL.TBLCONTAINERAUDITDW120RF as t WHERE t.ContainerNumber = 'FCIU9009312' ORDER BY t.RowNumber

WITH mo AS (
SELECT t1.item_number, 
	t1.lot_number, 
	t1.control_number_2 as mo_nbr,
	MIN(t1.start_tran_date) as start_tran_date
FROM [PowerBI_Distribution].[TranLog] AS t1 
WHERE t1.wh_id in ('35','34','31','33') 
	AND t1.tran_type = '111'
	AND t1.start_tran_date > DATEADD(DAY, - 720, GETDATE())
group by t1.item_number, 
	t1.lot_number, 
	t1.control_number_2	
),
trx as (
SELECT 
	MAX(t3.start_tran_date) AS start_tran_date ,
	t3.wh_id,  
    t3.control_number_2 AS destination,
    t3.item_number,
    t3.control_number as order_nbr,
	t3.lot_number,
	mo.mo_nbr
FROM [PowerBI_Distribution].[TranLog] AS t3
LEFT JOIN mo ON mo.item_number = t3.item_number and mo.lot_number = t3.lot_number
WHERE t3.wh_id in ('35','34','31','33')                          -- 可替换为你自己的仓库 ID
  AND t3.tran_type = '374'                     -- 可替换为你需要的交易类型
  AND t3.start_tran_date > DATEADD(DAY, -21, GETDATE())
GROUP BY
	t3.wh_id,  
    t3.control_number_2,
    t3.item_number,
    t3.control_number,
	t3.lot_number,
	mo.mo_nbr
)
SELECT  t.wh_id,
	t.destination,
	t.item_number,
	t.order_nbr,
	t.mo_nbr,
	COUNT(t.lot_number) as Qty,
	MAX(t.start_tran_date) as start_tran_date
FROM trx as t 
GROUP by 
	t.wh_id,
	t.destination,
	t.item_number,
	t.order_nbr,
	t.mo_nbr


SELECT COUNT(*)  FROM Manufacturing_ProductionPlanning_MIL.TBLCONTAINERAUDITDW120RF


CREATE VIEW dbo.vw_po_summary AS
SELECT
    [podwarehouse],
    [podordernum],
    [podvendornum],
    [podMfrName],
    [podMfrCountry],
    [podstatuscode],
    [podduedate],
    SUM([podqtyordered]) AS qtyordered
FROM [Wholesale_ProductSourcing_AFI].[PoDetail]
WHERE
    podwarehouse = '335'
    AND podMfrName IS NOT NULL
    AND LTRIM(RTRIM(podMfrName)) <> ''
GROUP BY 
    [podwarehouse],
    [podordernum],
    [podvendornum],
    [podMfrName],
    [podMfrCountry],
    [podstatuscode],
    [podduedate];




SELECT  * FROM Distribution_Warehouse_Wholesale_History.t_stored_item as t where t.wh_id='335' and t.item_number = 'B742-31' order by t.SnapshotDatetime desc

-- STO
SELECT  * FROM  Distribution_Warehouse_Wholesale.t_stored_item as t where t.item_number ='B742-31'  and t.wh_id = '335'


SELECT TOP 10* FROM MasterData_IT.PowerBIUsage AS t


SELECT  
    t3.tran_type,
    t3.description,
    t3.start_tran_date,
    t3.item_number,
	t3.control_number,
    t3.control_number_2,
    DATEPART(HOUR, t3.start_tran_time) AS TRAN_HOUR,
    SUM(t3.tran_qty) AS qty
FROM [PowerBI_Distribution].[TranLog] AS t3
WHERE t3.wh_id = '35'
    AND t3.item_number = '9140689'
    AND t3.tran_type = '374'
    AND t3.control_number_2 = '17'
    AND t3.start_tran_date = '2025-05-21'
GROUP BY  
    t3.tran_type,
    t3.description,
    t3.start_tran_date,
    t3.item_number,
	t3.control_number,
    t3.control_number_2,
    DATEPART(HOUR, t3.start_tran_time)
ORDER BY 
    TRAN_HOUR



SELECT
    t3.control_number_2 as trip_nbr,
    t3.item_number,
    t3.control_number,
    SUM(CASE WHEN t3.start_tran_date = '2025-05-18' THEN t3.tran_qty ELSE 0 END) AS [2025-05-18],
    SUM(CASE WHEN t3.start_tran_date = '2025-05-19' THEN t3.tran_qty ELSE 0 END) AS [2025-05-19],
    SUM(CASE WHEN t3.start_tran_date = '2025-05-20' THEN t3.tran_qty ELSE 0 END) AS [2025-05-20],
    SUM(CASE WHEN t3.start_tran_date = '2025-05-21' THEN t3.tran_qty ELSE 0 END) AS [2025-05-21],
    SUM(CASE WHEN t3.start_tran_date = '2025-05-22' THEN t3.tran_qty ELSE 0 END) AS [2025-05-22],
    SUM(CASE WHEN t3.start_tran_date = '2025-05-23' THEN t3.tran_qty ELSE 0 END) AS [2025-05-23]
FROM [PowerBI_Distribution].[TranLog] AS t3
WHERE t3.wh_id = '35'
  AND t3.item_number = '9140689'
  AND t3.tran_type = '374'
  AND t3.start_tran_date BETWEEN '2025-05-18' AND '2025-05-23'
GROUP BY
    t3.control_number_2,
    t3.item_number,
    t3.control_number
ORDER BY
    trip_nbr, control_number;



    SELECT
	    t3.start_tran_date,
        t3.control_number_2 as trip_nbr,
        t3.item_number, t3.control_number,
        SUM(t3.tran_qty) AS bo_tran_qty
        --SUM(t3.tran_qty * i.B2Z95S) AS bo_tran_cube	
    FROM [PowerBI_Distribution].[TranLog] AS t3
    WHERE t3.wh_id = '35'
		AND t3.item_number = '9140689'
        AND t3.tran_type = '374'
        AND t3.start_tran_date between '2025-05-18' and  '2025-05-23'
    GROUP BY
		t3.start_tran_date,
        t3.control_number_2,
        t3.item_number, t3.control_number
	order by start_tran_date,control_number


SELECT  * FROM Wholesale_DemandPlanning_AFI.PlanDetailTimeline AS T1 WHERE T1.ptlitnbr = 'B060-122' AND T1.PTLWHSE = '335'





SELECT 
        sto.item_number, 
        sto.actual_qty, 
        sto.status, 
        sto.wh_id, 
        sto.location_id, 
        loc.TypeDescription, 
        sto.type
    FROM Distribution_Warehouse_Wholesale.t_stored_item sto
    JOIN Distribution_Warehouse_Wholesale.t_location loc 
        ON sto.location_id = loc.location_id
        AND sto.wh_id = loc.wh_id 
    JOIN Distribution_Warehouse_Wholesale.t_item_master itm 
        ON sto.item_number = itm.item_number
        AND sto.wh_id = itm.wh_id  
    WHERE 
        sto.wh_id = '335' 
        AND loc.TypeDescription IN ('I', 'M', 'P', 'X', 'S', 'D', 'V') 
        AND sto.status = 'A'
		AND sto.item_number = 'R80121'


SELECT a4.trailer_id, a4.carrier_id, a4.equipment_id, a4.wh_id, a4.entered_yard, a4.exited_yard, a4.status, a4.location_id
select  *
FROM Distribution_Warehouse_Wholesale.Trailer  AS a4
WHERE a4.Wh_id = '335' 
and a4.equipment_id in ('MEDU9519068')
order by a4.entered_yard

SELECT * FROM Distribution_Warehouse_Wholesale.YaLocation as a5 WHERE a5.area_id in ('335')


--ASN YARD
SELECT top 10 * FROM Distribution_Warehouse_Wholesale.t_asn as a1  where a1.wh_id = '335'
SELECT * FROM Distribution_Warehouse_Wholesale.ASN_Detail AS a2 where a2.wh_id = '335' and a2.customer_po_number in ('P2LGS98')
SELECT top 10  * FROM Distribution_Warehouse_Wholesale.t_trailer_asn as a3 WHERE a3.Wh_id = '335'
SELECT top 10 * FROM Distribution_Warehouse_Wholesale.Trailer  AS a4
SELECT top 10 * FROM Distribution_Warehouse_Wholesale.YaLocation as a5 WHERE a5.area_id in ('335')
SELECT * FROM Distribution_Warehouse_Wholesale.t_po_master as t where t.wh_id = '335'


SELECT *
FROM Distribution_Warehouse_Wholesale.t_asn as a1 
LEFT JOIN (SELECT * FROM Distribution_Warehouse_Wholesale.ASN_Detail AS a2 where a2.wh_id = '335') AS t2  ON a1.asn_id = t2.asn_id and a1.wh_id = t2. wh_id
WHERE a1.wh_id = '335' 
	and a1.status in ('NEW','CHECKED IN')



    SELECT top 10 
        t0.ITNBR,
        t0.STID,
        t0.ITCLS,
        t0.B2Z95S,
        t0.ITDSC
    FROM MasterData_ItemMaster_AFI.ITMRVA AS t0
    WHERE t0.STID = '335'

SELECT top 10 * FROM MasterData_ItemMaster_AFI.ITMRVA AS t0 WHERE t0.STID = '335' and t0.ITNBR LIKE 'B%'
SELECT top 10 * FROM MasterData_ItemMaster_AFI.ITBEXT as t WHERE t.HOUSE = '335'
SELECT top 10 * FROM MasterData_ItemMaster_AFI.ITMEXT as t WHERE t.HOUSE = '335'
SELECT top 10 * FROM MasterData_ItemMaster_AFI.ITMEXT as t WHERE t.HOUSE = '335'


SELECT top 10 *
FROM AFISales_DW.FactShippedHistory as t 
where t.Warehouse = '335' and t.[invoice date] >= '2025-07-01' 

PowerBI_Distribution

SELECT * FROM  CostAccounting_Enh.ShippedHistoryCubeData as t where t.shcWarehouse = '335' and t.shcInvoiceDate = '2025-04-30'
SELECT TOP 10* FROM  CostAccounting_Enh.ShippedHistoryCubeDataStatic_Discounts
SELECT TOP 10* FROM  CostAccounting_Enh.ShippedHistoryCubeData_SpecialCharges
SELECT TOP 10* FROM  CostAccounting_Enh.GrossMarginCubeData

SELECT TOP 10* FROM  AFISales_DW.FactShippedHistory as t where t.Warehouse = '335' and t.[invoice date] = '2025-04-30' 
SELECT TOP 10* FROM  AFISales_DW.FactShippedHistory_Type2 as t where t.Warehouse = '335' and t.[invoice date] = '2025-04-30' 
SELECT * FROM  PowerBI_Distribution.FactShippedHistory as t where t.Warehouse = '335' and t.[invoice date] > '2025-04-20'  and t.[Trip Number] ='25531'


SELECT TOP 10* FROM  [PowerBI_Distribution].FactShippedHistory as t where t.Warehouse = '335' and t.[invoice date] = '2025-04-30' 
SELECT TOP 10* FROM AFISales_DW.FactShippedHistory as t where t.Warehouse = '335' and t.[invoice date] = '2025-04-30' 

SELECT  t.Warehouse, SUM(t.[Quantity Shipped]) as shipped_quantity, SUM(t.[Contract Price Amount]) AS shipped_amount 
FROM  [PowerBI_Distribution].FactShippedHistory as t 
where t.Warehouse = '335' and t.[invoice date] = '2025-04-30' 
Group by t.Warehouse
order by t.[Trip Number]

SELECT *
FROM AFISales_DW.FactShippedHistory as t 
where t.Warehouse = '335' and t.[invoice date] >= '2025-04-30' 


SELECT t.[Trip Number], SUM(t.[Quantity Shipped]) as shipped_quantity, SUM(t.[Contract Price Amount]) AS contract_price_amount 
FROM AFISales_DW.FactShippedHistory as t 
where t.Warehouse = '335' and t.[invoice date] >= '2025-04-30'  
Group by t.[Trip Number]
order by t.[Trip Number]
TABLE_NAME
SELECT TOP 10* FROM  [PowerBI_Distribution].DimShipmentDetails
SELECT TOP 10* FROM  [PowerBI_Distribution].ExpressShipmentsbyDC
SELECT TOP 10* FROM  [PowerBI_Distribution].FactShipment
SELECT TOP 10* FROM  [PowerBI_Distribution].FactShippedHistory
SELECT TOP 10* FROM  [PowerBI_Distribution].VendorShipmentDetails

SELECT TOP 10* FROM  [PowerBI_Distribution].WhseOrderType_OrderedVsShipped as t1 WHERE t1.Warehouse = '335' AND t1.Date = '2025-04-30'

SELECT t1.item_number, t1.location_id, t1.po_number,'In_Racking' as 'Type', COUNT(t1.serial_number) AS Racking_Qty
select top 10 *
FROM Distribution_Warehouse_Wholesale.t_serial_active AS t1
WHERE t1.wh_id IN ('335') AND t1.serial_no_status NOT IN ('O') AND t1.master_status NOT IN ('S')


select top 10 *
from  CostAccounting_Enh.ShippedHistoryCubeData as t
WHERE t.shcWarehouse = '335'
	and t.shcInvoiceDate > '2025-04-28'
	and t.shcTripNumber <>0


SELECT TOP 10* FROM  [PowerBI_Distribution].[VendorShipmentDetails] t WHERE t.[Warehouse ID] = '51'

SELECT TOP 10* FROM  [Wholesale_ProductSourcing_AFI].[PoDetail]

SELECT TOP 10* FROM Distribution_Warehouse_Wholesale.TripReport as t where t.WhID = '17' and t.LoadID like '%33853%'







 SELECT TOP 10* FROM Distribution_Warehouse_Wholesale.Trailer AS t WHERE t.Wh_id = '335' and t.equipment_id like 'WHSU648004%'
 
  SELECT TOP 10* FROM  Distribution_Warehouse_Wholesale.TrailerType

   SELECT TOP 10* FROM Distribution_Warehouse_Wholesale.LoadMaster AS t WHERE t.Wh_id = '335' and t.load_id like '%21272%' order by t.dispatch_date desc


   SELECT TOP 10* FROM Distribution_Warehouse_Wholesale.YaTranLog AS t WHERE t.Wh_id = '335'  and t.trailer_id <>0
	and t.carrier_trailer_number like 'WHSU648004%'

   SELECT TOP 10* FROM Distribution_Warehouse_Wholesale.YaTranLog AS t WHERE t.Wh_id = '335'  and t.trailer_id <>0
	and t.carrier_trailer_number like 'WHSU648004%'




   SELECT TOP 10* FROM Distribution_Warehouse_Wholesale.Trailer
   SELECT TOP 10* FROM Distribution_Warehouse_Wholesale.MissingSerials
   SELECT TOP 10* FROM Distribution_Warehouse_Wholesale.OnHoldDemandDeficiency


   SELECT TOP 10* FROM  Distribution_Warehouse_Wholesale.Orders  as t where wh_id = '335'


   SELECT TOP 10* FROM Distribution_Warehouse_Wholesale.OrderDetail_breakdown
   SELECT TOP 10* FROM Distribution_Warehouse_Wholesale.OrderDetail_breakdown_CDC
   SELECT TOP 10* FROM Distribution_Warehouse_Wholesale.OrderDetail_breakdown_Snapshot
   SELECT TOP 10* FROM Distribution_Warehouse_Wholesale.OrderNumberComment


  SELECT * FROM Distribution_Warehouse_Wholesale.LoadMaster as t where wh_id = '335' and t.load_id like '%20648%'
  SELECT * FROM Distribution_Warehouse_Wholesale.OrderDetail_breakdown as t where wh_id = '335' and t.order_number like '%20648%'

   SELECT TOP 10* FROM Distribution_Warehouse_Wholesale.Order_Detail as t where wh_id = '335'
   SELECT TOP 10* FROM Distribution_Warehouse_Wholesale.orderCNumber as t where wh_id = '335'

   SELECT TOP 10* FROM Distribution_Warehouse_Wholesale.Trailer as t where wh_id = '335'
   SELECT TOP 10* FROM    Distribution_Warehouse_Wholesale.TripReport as t where t.WhID = '335'
   SELECT TOP 10* FROM Distribution_Warehouse_Wholesale.Orders as t where t.wh_id = '335'
   SELECT *,
		CAST(LEFT(t.LoadID, CHARINDEX('-',t.LoadID)-1) AS INT) AS trip_nbr 
   FROM    Distribution_Warehouse_Wholesale.TripReport as t where t.WhID = '335' 



-- 340 BO  , routing_code is C number
    SELECT TOP 10* 
    FROM [PowerBI_Distribution].[TranLog] AS t3
    WHERE t3.wh_id = '335'
        AND t3.tran_type = '340'
        AND t3.start_tran_date > DATEADD(DAY, -10, GETDATE())

-- 321 BO  , routing_code is C number
    SELECT TOP 10* 
    FROM [PowerBI_Distribution].[TranLog] AS t3
    WHERE t3.wh_id = '335'
        AND t3.tran_type = '321'
        AND t3.start_tran_date > DATEADD(DAY, -10, GETDATE())





    SELECT
        CAST(LEFT(t3.control_number_2, CHARINDEX('-', t3.control_number_2) - 1) AS INT) AS trip_nbr,
        t3.item_number,
        SUM(t3.tran_qty) AS bo_tran_qty
        --SUM(t3.tran_qty * i.B2Z95S) AS bo_tran_cube	
    FROM [PowerBI_Distribution].[TranLog] AS t3
    WHERE t3.wh_id = '335'
        AND t3.tran_type = '340'
        AND t3.start_tran_date > DATEADD(DAY, -10, GETDATE())
    GROUP BY
        CAST(LEFT(t3.control_number_2, CHARINDEX('-', t3.control_number_2) - 1) AS INT),
        t3.item_number


-- Orphaned SN current status
 SELECT * 
 FROM Distribution_Warehouse_Wholesale.t_serial_active AS t   
 where t.wh_id = '335'
    AND t.serial_number IN ('624090044488','624090044490','624090044491','833500804748','689330479071','503950023383','623820380088','503950000167','610450513593','672617734958','672617734959','625640335336','625640335531','625640336885','526403986477','526403986478','526403986479','526403986480')
order by t.status_change

-- SN trx
SELECT *
FROM Distribution_Warehouse_Wholesale.TranLog AS t1
WHERE t1.wh_id = '335'
    AND t1.lot_number IN ('610450513593')
    AND t1.start_tran_date >= '2025-01-01'
order by t1.item_number, t1.start_tran_date


SELECT *
FROM Distribution_Warehouse_Wholesale.TranLog AS t1
WHERE 
	t1.wh_id = '1'
    AND t1.item_number IN ('R73155')
    AND t1.start_tran_date >= '2025-05-01'
order by t1.item_number, t1.start_tran_date

-- SA shipped by item
SELECT t1.start_tran_date,t1.item_number,t1.control_number_2, sum(t1.tran_qty) as qty
FROM Distribution_Warehouse_Wholesale.TranLog AS t1
WHERE t1.wh_id = '335'
	AND t1.tran_type = '347'
-- 	AND t1.control_number_2 like '0039312%'
    AND t1.item_number IN ('5200323')
    AND t1.start_tran_date >= '2025-04-06'
GROUP by  t1.start_tran_date,t1.item_number,t1.control_number_2
order by t1.item_number, t1.start_tran_date


-- RP received by item
SELECT t1.start_tran_date,t1.item_number,t1.control_number_2, sum(t1.tran_qty) as qty
FROM Distribution_Warehouse_Wholesale.TranLog AS t1
WHERE t1.wh_id = '335'
	AND t1.tran_type in ('151','951')
-- 	AND t1.control_number_2 like '0039312%'
    AND t1.item_number IN ('5200323')
    AND t1.start_tran_date >= '2025-04-06'
GROUP by  t1.start_tran_date,t1.item_number,t1.control_number_2
order by t1.item_number, t1.start_tran_date



-- 820 ORPHANED DATE
SELECT t1.item_number, t1.lot_number, max(t1.start_tran_date) as date
FROM Distribution_Warehouse_Wholesale.TranLog AS t1
WHERE t1.wh_id = '335'
	AND t1.tran_type in ('820')
    AND t1.lot_number IN ('624090044488','624090044490','624090044491','833500804748','689330479071','503950023383','623820380088','503950000167','610450513593','672617734958','672617734959','625640335336','625640335531','625640336885','526403986477','526403986478','526403986479','526403986480')
    AND t1.start_tran_date >= '2025-01-01'
group by t1.item_number,t1.lot_number
order by t1.item_number,  max(t1.start_tran_date)



--  by Trip# to query transactions
SELECT
    CAST(t1.[start_tran_date] AS DATETIME) + CAST(t1.[start_tran_time] AS DATETIME) AS [combined_datetime]
    ,*
FROM Distribution_Warehouse_Wholesale.TranLog AS t1
WHERE t1.wh_id = '335'
    AND t1.start_tran_date > '2024-01-01'
    AND t1.lot_number in ('639721157638')
ORDER BY  CAST(t1.[start_tran_date] AS DATETIME) + CAST(t1.[start_tran_time] AS DATETIME)


-- by item transactions all
SELECT CAST(t1.[start_tran_date] AS DATE) AS Transaction_Date
	, t1.control_number_2
	, t1.control_number as Reference
	, t1.item_number
	, t1.tran_type
	, t1.description
    , t1.tran_qty
	, t1.lot_number
FROM (SELECT * FROM Distribution_Warehouse_Wholesale.TranLog AS a WHERE a.wh_id = '335') AS t1
WHERE t1.start_tran_date > '2024-09-01'
AND t1.item_number IN ('H821-17')
ORDER BY  CAST(t1.[start_tran_date] AS DATE)


-- HJ_SN_IN_WAREHOUSE+LOADED+HOLD
SELECT *
FROM Distribution_Warehouse_Wholesale.t_serial_active AS t1
WHERE t1.wh_id = '335'
 --   AND t1.item_number = 'H821-44'
     AND t1.serial_no_status IN ('R', 'L','H')


-- HJ_SN_IN_EX001AA1_Vendor_Over_Shipment
SELECT t1.item_number, t1.location_id, CAST(t1.serial_number AS CHAR) as SN
FROM Distribution_Warehouse_Wholesale.t_serial_active  AS t1
WHERE  t1.wh_id  IN ('335')
  AND t1.serial_no_status IN ('R', 'L','H')
  AND T1.location_id LIKE 'EX001AA1%'
  AND t1.serial_no_status NOT IN ('O')
  AND t1.master_status NOT IN ('S')



-- HJ_SN_IN_WAREHOUSE+LOADED+HOLD ORIGINAL ONE -------???????
SELECT *
FROM Distribution_Warehouse_Wholesale.t_serial_active AS t2
WHERE t2.wh_id = '335'
  AND t2.serial_no_status IN ('R', 'L','H')
  AND t2.serial_no_status NOT IN ('O')
  AND t2.master_status NOT IN ('S')

-- HJ SN ORPHANED
SELECT *
FROM Distribution_Warehouse_Wholesale.t_serial_active AS t2
WHERE t2.wh_id = '335'
     AND t2.serial_no_status IN ('O')

-- Ashton SN InWarehouse
SELECT t1.item_number, t1.location_id, CAST(t1.serial_number AS CHAR) as SN
FROM Distribution_Warehouse_Wholesale.t_serial_active  AS t1
WHERE  t1.wh_id  IN ('335')
  AND t1.serial_no_status NOT IN ('O')
  AND t1.master_status NOT IN ('S')

-- 两表差异 NOT EXISTS 可以用来找到在 t1 中没有出现在 t2 中的记录

SELECT *
FROM Distribution_Warehouse_Wholesale.t_serial_active AS t1
WHERE t1.wh_id = '335'
  AND t1.serial_no_status NOT IN ('O')
  AND t1.master_status NOT IN ('S')
  AND NOT EXISTS (
    SELECT 1
    FROM Distribution_Warehouse_Wholesale.t_serial_active AS t2
    WHERE t2.wh_id = '335'
      AND t2.serial_no_status IN ('R', 'L','H')
      AND t1.serial_number = t2.serial_number -- 假设serial_no是唯一标识字段
  );


-- NOT EXISTS 可以用来找到在 t2 中没有出现在 t1 中的记录
SELECT *
FROM Distribution_Warehouse_Wholesale.t_serial_active AS t2
WHERE t2.wh_id = '335'
  AND t2.serial_no_status IN ('R', 'L','H')
  AND NOT EXISTS (
    SELECT 1
    FROM Distribution_Warehouse_Wholesale.t_serial_active AS t1
    WHERE t1.wh_id = '335'
      AND t1.serial_no_status NOT IN ('O')
      AND t1.master_status NOT IN ('S')
      AND t2.serial_number = t1.serial_number -- 假设serial_no是唯一标识字段
  );


-- racking onhand
SELECT t1.item_number, t1.location_id, COUNT(t1.serial_number) as OnHand
FROM Distribution_Warehouse_Wholesale.t_serial_active  AS T1
WHERE  t1.wh_id  IN ('335') AND T1.location_id LIKE 'A3%' AND t1.serial_no_status NOT IN ('O') and t1.master_status NOT IN ('S')
GROUP BY t1.item_number, t1.location_id


--- HJ Transactions main
SELECT CAST(t1.[start_tran_date] AS DATETIME) as start_tran_date,
       t1.lot_number,
       t1.item_number,
       CASE
           WHEN t1.lot_number not in (select distinct  a.lot_number
                                  from Distribution_Warehouse_Wholesale.TranLog as a
                                  where a.wh_id = '335'
                                    and a.tran_type = '151'
                                    and a.start_tran_date > '2024-01-01'
                                    ) Then 'No_151_trx'
           ELSE  '151 received' END as received_check
FROM Distribution_Warehouse_Wholesale.TranLog AS t1
WHERE t1.wh_id = '335'
  AND t1.item_number IN ('B980-93')
  AND t1.start_tran_date > '2024-01-01'
  AND t1.tran_type IN ('165')
ORDER BY  CAST(t1.[start_tran_date] AS DATETIME) + CAST(t1.[start_tran_time] AS DATETIME)





--  by serial number to query transactions
SELECT
    CAST(t1.[start_tran_date] AS DATETIME) + CAST(t1.[start_tran_time] AS DATETIME) AS [combined_datetime]
    ,*
FROM Distribution_Warehouse_Wholesale.TranLog AS t1
WHERE t1.wh_id = '335'
    AND t1.start_tran_date > '2024-01-01'
    AND t1.lot_number in ('639721157638')
ORDER BY  CAST(t1.[start_tran_date] AS DATETIME) + CAST(t1.[start_tran_time] AS DATETIME)


-- item without 151 received transaction
SELECT CAST(t1.[start_tran_date] AS DATETIME) as start_tran_date,
       t1.lot_number,
       t1.item_number,
       CASE
           WHEN t1.lot_number not in (select distinct  a.lot_number
                                  from Distribution_Warehouse_Wholesale.TranLog as a
                                  where a.wh_id = '335'
                                    and a.tran_type = '151'
                                    and a.start_tran_date > '2024-10-06') Then 'No_151_trx'
           ELSE  '151 received' END as received_check
FROM Distribution_Warehouse_Wholesale.TranLog AS t1
WHERE t1.wh_id = '335'
  AND t1.item_number IN ('A4000325')
  AND t1.start_tran_date > '2024-10-01'
  --AND t1.tran_type IN ('165')
ORDER BY  CAST(t1.[start_tran_date] AS DATETIME) + CAST(t1.[start_tran_time] AS DATETIME)


-- undo lp transaction
SELECT
      CAST(t1.[start_tran_date] AS DATETIME) as start_tran_date, *
FROM Distribution_Warehouse_Wholesale.TranLog AS t1
WHERE t1.wh_id = '335'
  AND t1.item_number IN ('4480228')
  AND t1.start_tran_date > '2024-09-06'
  AND t1.tran_type IN ('151','951')
  AND t1.control_number_2 IN ('P2GX272')
ORDER BY  CAST(t1.[start_tran_date] AS DATETIME) + CAST(t1.[start_tran_time] AS DATETIME)


-- EX001AA1
SELECT top 10 *,
              CAST(t1.[start_tran_date] AS DATETIME) as start_tran_date
FROM Distribution_Warehouse_Wholesale.TranLog AS t1
WHERE t1.wh_id = '335'
    and t1.item_number = 'A4000325'
    and t1.location_id = 'EX001AA1'

 SELECT TOP 10 * FROM Distribution_Warehouse_Wholesale.t_serial_active AS t   where t.wh_id = '335'

    SELECT 
        t0.ITNBR,
        t0.STID,
        t0.ITCLS,
        t0.B2Z95S,
        t0.ITDSC
    FROM MasterData_ItemMaster_AFI.ITMRVA AS t0
    WHERE t0.STID = '335'

select m.item_number,
        m.description,
        m.wh_id,
        m.commodity_code,
        m.class_id,
        m.pick_put_id
 from Distribution_Warehouse_Wholesale.t_item_master as m
    where m.wh_id = '335' and m.item_number = 'B687-31'
group by m.item_number,
        m.description,
        m.wh_id,
        m.commodity_code,
        m.class_id,
        m.pick_put_id


SELECT m.item_number,
        m.description,
        m.wh_id,
        m.commodity_code,
        m.class_id,
        m.pick_put_id
 from Distribution_Warehouse_Wholesale.t_item_master as m
    where m.wh_id = '335' and m.item_number = 'B687-31'

SELECT top 10 * from Distribution_Warehouse_Wholesale.t_item_master as t 


- Joined on item_number and wh_id

t_employee:
- Joined on employee_id (as id)

t_department:
- Joined on dept (as department) and wh_id

t_item_uom:
- Joined on item_number, uom, and wh_id

t_location:
- Used in subqueries for location type lookups
- Joined on location_id and wh_id

t_reason:
- Joined on reason_id = return_disposition/location_id_2
- Additional condition: type = 'BACKORDER' and locale_id = @in_ww_userlcid

t_serial_master:
- Joined on wh_id and lot_number (as serial_number)




select * from  CostAccounting_Enh.ShippedHistoryCubeData as t 
WHERE t.shcWarehouse = '335' 
	and t.shcInvoiceDate >'2025-04-01'
	and t.shcTripNumber <>0
ORDER BY t.shcInvoicedate Desc


SELECT *
FROM Distribution_Warehouse_Wholesale.TripAvailableSTO as t
where t.SearchType = 'All Items'
     AND t.WhID = '335'
	 AND t.ItemNumber = 'B742-31'
order by t.ItemNumber, t.DispatchDate, t.TripNumber


schema.file
select top 10 * from  CostAccounting_Enh.AFI_ADH_OutBill_CurrentNotInvoiced where Warehouse = '335'
select top 10 * from  CostAccounting_Enh.AFI_ADH_OutBill_PreviousWeek
select top 10 * from  CostAccounting_Enh.AFI_ADH_OutBill_PreviousWeek_Historical
select top 10 * from  CostAccounting_Enh.DC_LaborRollups_BaseData
select top 10 * from  CostAccounting_Enh.EnterpriseOvertimeHours
select top 10 * from  CostAccounting_Enh.FinVis_ChinaKitPriceVsWanekPrice
select top 10 * from  CostAccounting_Enh.GrossMarginCubeData
select top 10 * from  CostAccounting_Enh.GrossMarginSerialLevelCosted
select top 10 * from  CostAccounting_Enh.IntlSalesCosting
select top 10 * from  CostAccounting_Enh.InvoicedSerials_Costed
select top 10*  from  CostAccounting_Enh.RetailInventoryReconciliation
select top 10* from CostAccounting_Enh.ShippedHistoryCubeData
select top 10 * from CostAccounting_Enh.ShippedHistoryCubeData_Discounts
select top 10* from CostAccounting_Enh.ShippedHistoryCubeData_SpecialCharges
select top 10* from CostAccounting_Enh.ShippedHistoryCubeDataStatic_Discounts
select top 10* from CostAccounting_Enh.TradeAgreementDeltas_Analysis

select top 1000 * from Wholesale_ProductSourcing_AFI.InvoicedSales as t


select top 10 * from PowerBI_Finance.invoicedetail
select top 10 * from PowerBI_Wholesale.InvoiceHistory
select top 10 * from Wholesale_SalesHistory_AFI.InvoiceDetail

select top 10 * from PowerBI_Finance.invoicedetail

select top 10 * from Wholesale_ProductSourcing_AFI.PoDetail



shcTripNumber
0

select top 10 * from  Wholesale_SalesHistory_AFI.InvoiceDetail
select top 10 * from  Wholesale_SalesHistory_AFI.InvoiceDetailProperties
select top 10 * from  Wholesale_SalesHistory_AFI.InvoiceHeader


select top 10 * 
from dw_developer.tabledictionary
--where tpktablename like '%TripAvailableSTO%'
where tpkSchemaName like '%Distribution_Warehouse_Wholesale%'

select top 10 * from Wholesale_ProductSourcing_AFI.PoDetail

select top 10 * from Wholesale_SalesHistory_AFI.InvoiceDetail



select top 10 * from dw_developer.tabledictionary
where tpktablename like '%TripAvailableSTO%'

SELECT 
    ROUTINE_CATALOG AS [Database],
    ROUTINE_SCHEMA AS [Schema],
    ROUTINE_NAME AS [ProcedureName]
FROM INFORMATION_SCHEMA.ROUTINES
WHERE ROUTINE_NAME = 'usp_Refresh_TripAvailableSTO';

USE ASHLEY_EDW;
GO

EXEC Distribution_Warehouse_Wholesale.usp_Refresh_TripAvailableSTO;

-- Step 1: 获取 schema 下的所有表
WITH TablesInSchema AS (
    SELECT 
        TABLE_SCHEMA AS SchemaName,
        TABLE_NAME AS TableName
    FROM 
        ASHLEY_EDW.INFORMATION_SCHEMA.TABLES
    WHERE 
        TABLE_SCHEMA = 'Distribution_Warehouse_Wholesale'
)

-- Step 2: 关联元数据表，获取刷新频率
SELECT 
    t.SchemaName,
    t.TableName,
    m.tpkRefreshRate,
    m.tpkJobName,
    m.tpkSourceObject,
    m.tpkUpdateMethod,
    m.tpkRowCount,
    m.tpkCreateDate
FROM 
    TablesInSchema t
LEFT JOIN 
    ASHLEY_EDW.dbo.Table_Profiling_Key m  -- 替换为真实元数据表
    ON t.SchemaName = m.tpkSchemaName AND t.TableName = m.tpkTableName
ORDER BY 
    m.tpkRefreshRate, t.TableName;







SELECT top 10 * FROM Distribution_Warehouse_Wholesale.TripAvailableSTO as t where t.SearchType = 'All Items' and t.WhID = '335'

select top 10 * FROM PowerBI_Distribution.InvoiceAmount_WarehouseLevel as t Where t.Warehouse = '335' order by t.Invoice_Date DESC


select top 10 * FROM Wholesale_DemandPlanning_AFI.PlanDetailTimeline AS T1 where T1.PTLWHSE = '335'

SELECT T1.PTLITNBR, SUM(T1.PTLWEEK1) AS 'Safety Stock Target'
    FROM Wholesale_DemandPlanning_AFI.PlanDetailTimeline AS T1
    WHERE t1.PTLDATATYPE = 'SAFETY STK' AND T1.PTLWHSE = '335'  AND T1.PTLWEEK1>0
    GROUP BY T1.PTLITNBR

	SELECT top 10  T1.PTLITNBR, SUM(T1.PTLWEEK1) AS 'Safety Stock Target'
    FROM Wholesale_DemandPlanning_AFI.PlanDetailTimeline AS T1
    WHERE t1.PTLDATATYPE = 'SAFETY STK' AND T1.PTLWHSE = '335'  AND T1.PTLWEEK1>0
    GROUP BY T1.PTLITNBR




SELECT TOP 10 * FROM [PowerBI_Distribution].[TranLog] AS t3 

SELECT sum(t3.tran_qty) as Shipped_QTY 
FROM [PowerBI_Distribution].[TranLog] AS t3 
WHERE t3.wh_id = '335' 
	and t3.tran_type='347' 
	and t3.start_tran_date > '2025-01-01' 
	and t3.item_number = 'RP ORDER'
GROUP BY t3.lot_number





SELECT * FROM [PowerBI_Distribution].[TripAvailableSTO] as t
WHERE t.WhID = '335'

SELECT TOP 10 * FROM Distribution_Warehouse_Wholesale.TripAvailableSTO AS T


<<<<<<< HEAD
SELECT *
FROM [PowerBI_Distribution].[TranLog] AS t
JOIN (
    SELECT DISTINCT t3.location_id, MIN(t3.start_tran_date) AS earliest_trx_date 
    FROM [PowerBI_Distribution].[TranLog] AS t3 
    WHERE t3.wh_id = '335' 
        AND t3.tran_type = '363' 
        AND t3.start_tran_date > '2023-01-01' 
        AND t3.location_id IN ('RP043AA1','RP043AB1','RP043AC1','RP043AC2',
                               'RP043AE2','RP043AE1','RP043AF1','RP043AE5')
    GROUP BY t3.location_id
) AS t2 
ON t.location_id = t2.location_id 
AND t.start_tran_date = t2.earliest_trx_date
order by t.start_tran_date



SELECT TOP 10 * FROM [PowerBI_Distribution].[TranLog] AS t3 
WHERE t3.wh_id = '335' 
	and t3.tran_type='347' 
	and t3.start_tran_date > '2023-01-01' 
	AND  t3.location_id in ('RP043AA1','RP043AB1','RP043AC1','RP043AC2','RP043AE2','RP043AE1','RP043AF1','RP043AE5')


SELECT TOP 10 * FROM [PowerBI_Distribution].[TranLog] AS t3  WHERE t3.wh_id = '335' and t3.tran_type='363' and t3.start_tran_date > '2025-03-20'



SELECT TOP 100 *
FROM [PowerBI_Distribution].[TranLog] AS t3 
WHERE t3.wh_id = '335' and t3.tran_type='340' and t3.start_tran_date > '2025-03-20' and t3.item_number <>'RP ORDER'

WITH i AS
(SELECT t0.ITNBR,
		t0.STID,
		t0.ITCLS,
		t0.B2Z95S,
		t0.ITDSC
	FROM MasterData_ItemMaster_AFI.ITMRVA as t0
	WHERE t0.STID = '335'
)
SELECT  t3.tran_type,
        CAST(LEFT(t3.control_number_2, CHARINDEX('-', t3.control_number_2) - 1) AS INT) AS trip_nbr,
		t3.return_disposition as bo_reason_code,
        t3.item_number,
        sum(t3.tran_qty) as bo_tran_qty,
        sum(t3.tran_qty * i.B2Z95S) as bo_tran_cube            
FROM [PowerBI_Distribution].[TranLog] AS t3 
LEFT JOIN i on i.ITNBR = t3.item_number
WHERE t3.wh_id = '335' and t3.tran_type='340' and t3.start_tran_date > '2025-01-01'
GROUP BY  t3.tran_type,
		  CAST(LEFT(t3.control_number_2, CHARINDEX('-', t3.control_number_2) - 1) AS INT),
		  t3.return_disposition,
		  t3.item_number
order by trip_nbr, item_number




SELECT distinct t1.BHTRPS FROM Wholesale_CODIS.BTTRIPH as t1 WHERE t1.BHTRPS = 'D'
--BHTRPS
--D
--A
--P
--X
--H
--R

SELECT TOP 10 * FROM Wholesale_CODIS.BTTRIPH as t1 WHERE t1.BHTRPS = 'D' AND T1.BHWHS# = '335'

SELECT top 10 *  FROM Wholesale_CODIS.BTTRIPH as t1 WHERE t1.BHWHS# = '335' order by t1.BHCDAT
SELECT  t2.*  FROM Wholesale_CODIS.BTTRIPD as t2 WHERE t2.BDTRP# = '71' order by t2.BDISEQ


SELECT DISTINCT T2.bdcusr
FROM Wholesale_CODIS.BTTRIPH as t1, Wholesale_CODIS.BTTRIPD as t2
WHERE t1.BHWHS# = '335' 
	AND t1.BHTRP# = t2.BDTRP# 


SELECT TOP 10 * FROM Wholesale_CODIS.BTTRIPH as t1 WHERE t1.BHTRPS = 'D' AND T1.BHWHS# = '335'

SELECT top 10 *  FROM Wholesale_CODIS.BTTRIPH as t1 WHERE t1.BHWHS# = '335' order by t1.BHCDAT
SELECT t2.*  FROM Wholesale_CODIS.BTTRIPD as t2 WHERE t2.BDTRP# = '85110' and t2.BDCUSR like '%335%' order by bdiseq 


80357
83660
85110


 SELECT  top 100 * FROM [PowerBI_Distribution].[TranLog] AS t  WHERE t.wh_id = '335' and t.tran_type='347' and t.start_tran_date = '2025-01-01'

=======
SELECT TOP 10 * FROM  MasterData_ItemMaster_MIL.ITBEXT
SELECT count(*) FROM  MasterData_ItemMaster_MIL.ITBEXT
>>>>>>> d1b733de8c42d1241133462d3a9652a8c3b27f6c
SELECT TOP 10 * FROM CustomerProfile.CustomerMaster



SELECT a4.trailer_id, a4.carrier_id, a4.equipment_id, a4.wh_id, a4.entered_yard, a4.location_id, a5.location_name
         FROM Distribution_Warehouse_Wholesale.Trailer  AS a4
		 LEFT JOIN (SELECT * FROM Distribution_Warehouse_Wholesale.YaLocation as t WHERE t.area_id = '335') as a5 
		 			ON a4.location_id = a5.location_id and a4.area_id = a5.area_id
         WHERE a4.Wh_id = '335' and a4.status in ('IN DOOR','IN YARD CHASSIS') and a4.equipment_id = 'AMFU8580681'
         Group by a4.trailer_id, a4.carrier_id, a4.equipment_id, a4.wh_id, a4.entered_yard, a4.location_id, a5.location_name
		 order by a4.entered_yard desc


select TOP 1000 * from Distribution_Warehouse_Wholesale.Trailer 
select TOP 1000 * from Distribution_Warehouse_Wholesale.t_trailer as t where t.AreaId = '335' and t.LocationId not in ('571','572')
select TOP 1000 * from Distribution_Warehouse_Wholesale.YaLocation as t where t.area_id = '335'
SELECT TOP 10 * FROM Distribution_Warehouse_Wholesale.ASN_Detail AS a2 where a2.wh_id = '335'
SELECT TOP 10 * FROM Distribution_Warehouse_Wholesale_WRK.t_asn_detail AS a2 where a2.wh_id = '335'
SELECT  
    t2.WHOSE, 
    t2.CUSNO, 
    t3.CUSNM, 
    t2.RPKEY, 
    t2.ENTDAT, 
    t2.SHPDAT, 
    t2.TRIP#, 
    MAX(t1.PCKDTE) AS PackDate, 
    SUM(t1.QTY) AS QTY 
FROM 
    AFILELIB.dbo.ARPDETL t1
    JOIN AFILELIB.dbo.ARPHEDR t2 ON t2.RPKEY = t1.RPKEY
    JOIN AMFLIBA.dbo.CUSMAS t3 ON t2.CUSNO = t3.CUSNO
WHERE 
    t2.ACTCOD = 'S' 
    AND t2.ENTDAT BETWEEN '2021-01-01' AND '2029-12-31'
    AND t2.WHOSE = '335'
GROUP BY 
    t2.WHOSE, 
    t2.CUSNO, 
    t3.CUSNM, 
    t2.RPKEY, 
    t2.ENTDAT, 
    t2.SHPDAT, 
    t2.TRIP#
ORDER BY  
    t2.RPKEY, 
    t2.ENTDAT;










SELECT 
    t.name AS TableName,
    c.name AS ColumnName,
    p.value AS ColumnDescription
FROM 
    sys.tables t
INNER JOIN 
    sys.columns c ON c.object_id = t.object_id
LEFT JOIN 
    sys.extended_properties p ON p.major_id = t.object_id AND p.minor_id = c.column_id AND p.name = 'MS_Description'
WHERE 
    SCHEMA_NAME(t.schema_id) = 'dw_developer'
ORDER BY 
    t.name, c.column_id;

select * from dw_developer.TableDictionary_Bob

TableDictionary_Bob

-- lack whse51
select distinct t.Warehouse from PowerBI_Distribution.ITBEXT as t order by t.Warehouse
select TOP 10 * from PowerBI_Distribution.ITBEXT



select TOP 10 * from Distribution_Warehouse_Wholesale.inventory_position as t where t.wh_id = '335'


select TOP 10 * from Distribution_Warehouse_Wholesale.t_control where wh_id = '335'
select TOP 10 * from Distribution_Warehouse_Wholesale.LoadMaster where wh_id = '335'
select TOP 10 * from Wholesale_Purchasing_AFI.ATPSUM AS t  where t.APHOUS = '335'


select TOP 10 * from [PowerBI_Distribution].[ContainerHdr_MIL]
select TOP 10 * from [PowerBI_Distribution].[ContainerDtlItem_MIL] order by LastMaintenanceTimestamp 
select TOP 10 * from [PowerBI_Distribution].[ContainerDtlSer_MIL] order by AddedTimeStamp desc
select TOP 10 * from [PowerBI_Distribution].[ContainerDtlSerA_MIL] order by AddedTimeStamp 
select TOP 10 * from [PowerBI_Distribution].[ContainerDtlItem_WNK]
select TOP 10 * from [PowerBI_Distribution].[ContainerDtlItemA_MIL]
select TOP 10 * from [PowerBI_Distribution].[ContainerDtlItemA_WNK]
select TOP 10 * from [PowerBI_Distribution].[ContainerDtlSer_MIL]
select TOP 10 * from [PowerBI_Distribution].[ContainerDtlSer_WNK]
select TOP 10 * from [PowerBI_Distribution].[ContainerDtlSerA_MIL]
select TOP 10 * from [PowerBI_Distribution].[ContainerDtlSerA_WNK]
select TOP 10 * from [PowerBI_Distribution].[ContainerHdr_MIL]
select TOP 10 * from [PowerBI_Distribution].[ContainerHdr_WNK]
select TOP 10 * from [PowerBI_Distribution].[ContainerHdrA_MIL]
select TOP 10 * from [PowerBI_Distribution].[ContainerHdrA_WNK]



SELECT *, CAST(t1.PerformedAt AS DATE) AS Performed_Date
     FROM [PowerBI_Distribution].[OSHAPreOperationalChecklist] AS t1
     WHERE t1.WarehouseID IN ('31','33','35') AND CAST(t1.PerformedAt AS DATE) BETWEEN CAST(DATEADD(DAY, -10, GETDATE()) AS DATE) AND CAST(GETDATE() AS DATE)

select TOP 10 * from Manufacturing_Maximo.invbalances as t1
where t1.siteid = 'VNM.ASPM'
    AND t1.Location = 'MROSTORE'
    AND t1.itemnum = '1000-6398'

select TOP 10 * from Manufacturing_Maximo.inventory as t1
WHERE location = 'MROSTORE'
    AND siteid = 'VNM.ASPM'
    AND t1.itemnum = '1000-6398'

select  top 10 * from Manufacturing_Maximo.MatUseTrans as t
WHERE
     t.itemnum = '1000-6398'
  and t.storeloc = 'MROSTORE'

 select  top 1000 * from  Manufacturing_Maximo.Matrectrans as t
 where t.itemnum = '1000-6398'

  select  top 1000 * from  Manufacturing_Maximo.Masterpm




WITH LatestSnapshot AS (
    SELECT *, 
           ROW_NUMBER() OVER (PARTITION BY location, siteid,itemnum, binnum  ORDER BY SnapshotDate DESC) AS rn
    FROM Manufacturing_Maximo.invbalances
    WHERE location = 'MROSTORE' 
      AND curbal > 0 
      AND siteid = 'VNM.ASPM'
)
SELECT * 
FROM LatestSnapshot
WHERE rn = 1 and itemnum in ('1004-3094','102-2105')
order by itemnum;


select  TOP 10 * from Manufacturing_Maximo.invbalances
select  TOP 10 * from Manufacturing_Maximo.invcost


SELECT DISTINCT t.BokBookingStatus
FROM  [Wholesale_ProductSourcing_AFI].[Bookings] as t 
where t.BokWarehouse = '335' 

--BokBookingStatus
--Completed
--NewCode
--Planned
--LoadedTruckerDispatched
--Accepted
--Requested
--Cancelled



select top 100 * from dw_developer.tabledictionary
where tpktablename like 'Bookings'

SELECT  * FROM  [Wholesale_ProductSourcing_AFI].[BookingActions] as t where t.BacWarehouse = '335' and t.BacTripNumBer in ('3430','98317')
order by t.BacTripNumBer, t.dtea

SELECT * FROM  [Wholesale_ProductSourcing_AFI].[Bookings] as t where t.BokWarehouse = '335' and t.BokTripNumBer in ('3430','98317')
order by t.BokTripNumBer, t.BokTripCreateDate


SELECT top 10 * FROM PowerBI_QTIL.ContainerBooking AS T


SELECT top 10 * FROM  Wholesale_ProductSourcing.ContainerDirectBookingDetail 


SELECT *FROM  Distribution_Warehouse_Wholesale.PickDetail AS t 
Where t.wh_id = '335' and t.status <>'SHIPPED' and t.load_id like '0085711%'
order by t.line_number

SELECT LEFT(t.load_id,7) AS Trip_number,
	CASE 
		WHEN t.pick_area = 'UPHOLSTERY' THEN 'UPH'
		ELSE 'CG' END AS Product, 
	SUM(t.planned_quantity) AS planned_quantity , 
	SUM(t.picked_quantity) AS picked_quantity,
	SUM(t. staged_quantity) AS staged_quantity, 
	SUM(t.loaded_quantity) AS loaded_quantity,
	ROUND(SUM(t.picked_quantity) * 1.0 / SUM(t.planned_quantity), 2) AS 'Picked%',
	ROUND(SUM(t.staged_quantity) * 1.0 / SUM(t.planned_quantity), 2) AS 'Staged%',
	ROUND(SUM(t.loaded_quantity) * 1.0 / SUM(t.planned_quantity), 2) AS 'Loaded%'
FROM  Distribution_Warehouse_Wholesale.PickDetail AS t 
Where t.wh_id = '335' and t.status <>'SHIPPED' 
GROUP BY LEFT(t.load_id,7), 	CASE 
		WHEN t.pick_area = 'UPHOLSTERY' THEN 'UPH'
		ELSE 'CG' END
ORDER BY LEFT(t.load_id,7)	  


and t.load_id = '0086442-00'


SELECT * FROM  Distribution_Warehouse_Wholesale.PickDetail AS t 
Where t.wh_id = '335' and t.status <>'SHIPPED' and t.load_id = '0086442-00'



SELECT *, CAST(LEFT(LoadID, 7) AS INT) AS trip_nbr FROM Distribution_Warehouse_Wholesale.AfoLoadView where WhId = '335'
order by PctLoaded DESC


SELECT *, CAST(LEFT(LoadID, 7) AS INT) AS trip_nbr FROM Distribution_Warehouse_Wholesale.AfoLoadView where WhId = '335'


SELECT TOP 10 * FROM PowerBI_QTIL.AvailableInventory


SELECT 
    t.HOUSE, 
    t.ITNBR, 
    t.MOHTQ AS "OnHand", 
    t.MPUPQ AS "On order purchase quantity",
    t.PLREQ AS "Pick list requirements", 
    t.LDQOH AS "Last date affecting quantity on hand",
    CASE 
        WHEN t.LDQOH > 0 THEN 
            CONVERT(DATE, 
                    SUBSTRING(CAST(t.LDQOH AS VARCHAR(7)), 2, 2) + '-' +
                    SUBSTRING(CAST(t.LDQOH AS VARCHAR(7)), 4, 2) + '-' +
                    SUBSTRING(CAST(t.LDQOH AS VARCHAR(7)), 6, 2), 
                    2) -- 2 表示以 'YY-MM-DD' 形式解析日期
        ELSE NULL 
    END AS "Formatted Last date affecting quantity on hand",
    
    t.DOFLS AS "Date of last sale",
    CASE 
        WHEN t.DOFLS > 0 THEN 
            CONVERT(DATE, 
                    SUBSTRING(CAST(t.DOFLS AS VARCHAR(7)), 2, 2) + '-' +
                    SUBSTRING(CAST(t.DOFLS AS VARCHAR(7)), 4, 2) + '-' +
                    SUBSTRING(CAST(t.DOFLS AS VARCHAR(7)), 6, 2), 
                    2) 
        ELSE NULL 
    END AS "Formatted Date of last sale"

FROM MasterData_ItemMaster_AFI.ITEMBL AS t
WHERE t.HOUSE = '335';



SELECT TOP 10 * FROM MasterData_ItemMaster_AFI.ITEMBL AS t

SELECT TOP 10 * FROM  Distribution_Warehouse_Wholesale.t_eol_billable_door_displayDetail
SELECT TOP 10 * FROM  Distribution_Warehouse_Wholesale.LoadMaster where wh_id = '335'
SELECT * FROM  Distribution_Warehouse_Wholesale.LoadMaster where wh_id = '335' and shipment_status  in ('Pending') order by LoadDate desc


SELECT TOP 10 * FROM Distribution_Warehouse_Wholesale.TripReport  as t  
WHERE t.WhID = '335' AND t.LoadID like '0004022%'
AND t.TripStatus  NOT IN ('S','X')

SELECT TOP 10 * FROM MasterData_IT_WNK.MBCDRESM


SELECT TOP 10 * FROM Manufacturing_ProductionPlanning_WNK.PC216WSCH

SELECT TOP 10 * FROM Manufacturing_ProductionPlanning_WNK.PCF216FS


SELECT COUNT(*)FROM Manufacturing_ProductionPlanning_WNK.WVCNTHD
SELECT COUNT(*) FROM Manufacturing_ProductionPlanning_WNK.WVCNTHDA
SELECT COUNT(*) FROM Manufacturing_ProductionPlanning_WNK.WVCNTID
SELECT COUNT(*) FROM Manufacturing_ProductionPlanning_WNK.WVCNTIDA
SELECT COUNT(*) FROM Manufacturing_ProductionPlanning_WNK.WVCNTSD
SELECT COUNT(*) FROM Manufacturing_ProductionPlanning_WNK.WVCNTSDA


SELECT TOP 10 * FROM Wholesale_DemandPlanning.AISHLI_inventory_allocation_v2


SELECT top 10 t.ITNBR, t.PLREQ 
FROM MasterData_ItemMaster_AFI.ITEMBL t 
where t.HOUSE ='335' and t.plreq>0


SELECT top 10 *
FROM MasterData_ItemMaster_WNK.ITEMBL t 
where t.HOUSE ='35' and t.plreq>0


SELECT * FROM  Wholesale_Purchasing_AFI.ATPSUM as t WHERE t.APHOUS = '335' ORDER BY 


SELECT TOP 10 * FROM MasterData_ItemMaster_AFI.ITEMBL t where t.HOUSE ='335'
SELECT TOP 10 * FROM MasterData_ItemMaster_AFI_Wrk.ITEMBL
SELECT TOP 10 * FROM MasterData_ItemMaster_MIL.ITEMBL
SELECT TOP 10 * FROM MasterData_ItemMaster_WNK.ITEMBL
SELECT TOP 10 * FROM MasterData_ItemMaster_WVF.ITEMBL




SELECT TOP 10 * FROM MasterData_ItemMaster_AFI.ITEMBL

SELECT TOP 10 * FROM MasterData_ItemMaster_MIL.ITEMBL
SELECT TOP 10 * FROM MasterData_ItemMaster_WNK.ITEMBL
SELECT TOP 10 * FROM MasterData_ItemMaster_WVF.ITEMBL t where t.MOHTQ>0 



SELECT distinct t.Warehouse  FROM PowerBI_Distribution.ITEMBL AS t
SELECT TOP 10 * FROM PowerBI_Wholesale.ITEMBL AS t
SELECT distinct t.HOUSE  FROM PowerBI_Wholesale.ITEMBL AS t

SELECT * 
FROM SupplyChain_Enh.ATPWeekEnding AS t
WHERE t.Warehouse = '335'
	AND t.ItemSKU = 'A4000679'
	--AND t.APNQ<0
    AND t.InsertedDate = (
        SELECT MAX(InsertedDate) 
        FROM SupplyChain_Enh.ATPWeekEnding 
        WHERE Warehouse = '335'
    )
ORDER BY t.WeekEnding
	;


SELECT TOP 10 * FROM  Wholesale_CODIS.BTTRIPH  as t
WHERE t.bhwhs# = '335' AND t.BHTRP# like '%74766%'

SELECT TOP 10 * FROM Distribution_Warehouse_Wholesale.TripReport  as t  
WHERE t.WhID = '335' AND t.LoadID like '%74766%'


select top 10 * from SupplyChain_Enh.ATPSUP as t WHERE t.asatpquantity<0 and t.aswarehouse = '335' 


select top 10 * from SupplyChain_Enh.ATPSUP as t WHERE t.assupplydays >0 and t.asatpquantity>0 and t.ascurrmnthforecast >0 and t.asnextmnthforecast>0

select top 10 * from PowerBI_Wholesale.SupplychainATPSUP21days

select top 10 * from PowerBI_Wholesale.SupplychainATPSUP28days
select top 10 * from PowerBI_Wholesale.SupplychainATPSUPThisweek


SELECT top 10 T1.PTLITNBR, SUM(T1.PTLWEEK1) AS 'Safety Stock Target'
    FROM Wholesale_DemandPlanning_AFI.PlanDetailTimeline AS T1
    WHERE t1.PTLDATATYPE = 'SAFETY STK' AND T1.PTLWHSE = '335'  AND T1.PTLWEEK1>0
    GROUP BY T1.PTLITNBR

select top 10 * from Manufacturing_Maximo.MatUseTrans as t  WHERE t.siteid = 'VNM.ASPM' order by t.transdate desc 

select DISTINCT t.storeloc from Manufacturing_Maximo.MatUseTrans as t  where t.storeloc like 'AS_%'


select * from Manufacturing_Maximo.invbalances WHERE binnum like 'MR%' AND LOCATION LIKE 'AS_%'

select top 10 * from  Manufacturing_Maximo.Invuseline as t


select  distinct t.itemsetid  from Manufacturing_Maximo.item as t
select  * from Manufacturing_Maximo.item as t where t.itemsetid = 'VNMSET' ORDER BY t.itemnum

select top 10 * from Manufacturing_Maximo.inventory as t1 

select top 10 * from  Manufacturing_Maximo.invbalances as t 

select customer_id,customer_number,ship_to_code,bill_to_name,* from Distribution_Warehouse_Wholesale.orderCNumber (nolock) where order_number like '0074271%' and wh_id = '335'

select top 10 * from Manufacturing_Maximo.labtrans
select top 10 * from Manufacturing_Maximo.Matrectrans
select top 10 * from Manufacturing_Maximo.MatUseTrans
select top 10 * from Manufacturing_Maximo.Servrectrans
 
 SELECT  top 100 * FROM [PowerBI_Distribution].[TranLog] AS t  WHERE t.wh_id = '335' and t.tran_type='363' and t.start_tran_date = '2024-02-16'

  SELECT TOP 10 * FROM   Inventory_DW.DimComponentTurnsDetails AS t where t.[Warehouse Code]='335'
  SELECT TOP 10 * FROM  Inventory_DW.DimEndItemInventoryTurnsDetail AS t where t.[Warehouse Code]='335'

  -- inventory turns 
  SELECT TOP 10 * FROM  Inventory_Enh.TurnsDetail AS t1 where t1.[Warehouse]='335' AND t1.WeekEnded in (select MAX(t.WeekEnded) from  Inventory_Enh.TurnsDetail as t where t.[Warehouse]='335')

  SELECT TOP 10 * FROM  IMHIST_DW.FactInventoryTransactions

  SELECT TOP 10 * FROM  Distribution_Warehouse_Wholesale_WRK.ACTAUDT

 SELECT TOP 10 * FROM Distribution_DW.FactLoad
 SELECT TOP 10 * FROM Distribution_Warehouse_Wholesale.Receiving_PPH AS t where t.wh_id = '335'

 SELECT TOP 10 * FROM AFISales_DW.DimInvoiceHeader
  SELECT TOP 10 * FROM AtScale_AFISales.DimAshleyWarehouseMaster

 SELECT * FROM Distribution_Warehouse_Wholesale.LoadDispatch AS t where t.WhId = '335'
 SELECT * FROM  Distribution_Warehouse_Wholesale.AfoLoadView where WhId = '335'

SELECT LoadId, COUNT(*) AS 重复次数
FROM Distribution_Warehouse_Wholesale.AfoLoadView where WhId = '335' 
GROUP BY LoadId
HAVING COUNT(*) > 1
ORDER BY COUNT(*) DESC


SELECT LoadId, COUNT(*) AS 重复次数
FROM Distribution_Warehouse_Wholesale.LoadDispatch where WhId = '335' 
GROUP BY LoadId
HAVING COUNT(*) > 1
ORDER BY COUNT(*) DESC

 SELECT * FROM Distribution_Warehouse_Wholesale.LoadDispatch AS t where t.WhId = '335' and t.LoadId = '0060698'
 SELECT * FROM Distribution_Warehouse_Wholesale.LoadDispatch AS t where t.WhId = '335'
 SELECT TOP 10 * FROM Distribution_Warehouse_Wholesale.t_serial_active AS t   where t.wh_id = '51'

SELECT TOP 10 * FROM Distribution_Warehouse_Wholesale.t_item_master AS t  where t.wh_id IN ('31') and t.item_number ='2780149'

SELECT item_number, wh_id, wh_id2 
FROM Distribution_Warehouse_Wholesale.t_item_master
WHERE item_number in ('3070638','3070635','3070620','2550438','2000635','2000535')

SELECT TOP 10 * FROM  PowerBI_Distribution.ItemMaster AS t WHERE t.wh_id IN ('335') AND  t.item_number in ('3070638','3070635','3070620','2550438','2000635','2000535')

SELECT TOP 1000 * FROM Distribution_Warehouse_Wholesale.t_item_master AS t WHERE t.wh_id IN ('335') AND  t.item_number in ('3070638','3070635','3070620','2550438','2000635','2000535')

SELECT TOP 1000 * FROM Wholesale_ProductSourcing_AFI.Container as t where t.concontainer in ('') 

SELECT TOP 10 * FROM PowerBI_QTIL.ContainerBooking
SELECT TOP 10 * FROM Wholesale_ProductSourcing_AFI.ContainerDirectInquiry
SELECT TOP 10 * FROM Wholesale_ProductSourcing_AFI.ContainerLoadingDetail
SELECT TOP 1000 * FROM Wholesale_ProductSourcing.ContainerDirectBookingDetail
SELECT TOP 10 * FROM Wholesale_ProductSourcing_AFI.SupplyChain_LogilityPlannedOrderFulfillment
SELECT count(*) FROM  PowerBI_Wholesale.CODIS_OrderFulfillment AS t where t.Warehouse = '335'
SELECT * FROM  PowerBI_Wholesale.CODIS_OrderFulfillment AS t where t.Warehouse = '335'



SELECT TOP 10 * FROM [PowerBI_Distribution].[Orders] as t  WHERE t.wh_id = '335'
SELECT TOP 10 * FROM [PowerBI_Distribution].[OrderCNumber] as t  WHERE t.wh_id = '335'

SELECT TOP 10 * FROM Distribution_Warehouse_Wholesale.[Orders] as t  WHERE t.wh_id = '335' and t.load_id ='0077861-01'
SELECT * FROM  [PowerBI_Distribution].[Orders] t where t.wh_id = '335'  and t.load_id ='0077861-01'



SELECT * FROM  [PowerBI_Distribution].[Orders] t where t.wh_id = '335'  AND t.status  IN ('R','N') and t.load_id ='0077861-01'
SELECT COUNT(*)  FROM [PowerBI_Distribution].[Orders] as t  WHERE t.wh_id = '335' AND t.status in ('LOADING','R','N')
SELECT *   FROM [PowerBI_Distribution].[Orders] as t  WHERE t.wh_id = '335' 
SELECT DISTINCT t.status FROM [PowerBI_Distribution].[Orders] as t  WHERE t.wh_id = '335'
SELECT TOP 10 * FROM Distribution_Warehouse_Wholesale.[t_order] as t  WHERE t.wh_id = '335'
SELECT DISTINCT t.status FROM Distribution_Warehouse_Wholesale.[t_order] as t  WHERE t.wh_id = '335'

SELECT TOP 10 * FROM Distribution_Warehouse_Wholesale.TripReport  as t  WHERE t.WhID = '335' AND t.TripStatus NOT IN ('S')



SELECT DISTINCT t.TripStatus FROM Distribution_Warehouse_Wholesale.TripReport as t  WHERE t.WhID = '335'

SELECT TOP 10 * FROM Distribution_Warehouse_Wholesale.TripReport  as t  WHERE t.WhID = '335' AND t.TripStatus NOT IN ('S','X') and t.LoadID like  '0077866-%'  -- trip report

SELECT TOP 10 * FROM Distribution_Warehouse_Wholesale.[Orders] as t  WHERE t.wh_id = '335' and t.order_number like '0068017-%'
SELECT TOP 10  * FROM  Distribution_Warehouse_Wholesale.orderCNumber as t  WHERE t.wh_id = '335' and t.order_number like '0068017-%'


SELECT TOP 10  * FROM  Distribution_Warehouse_Wholesale.LoadMaster as ldm WHERE ldm.wh_id = '335' and  ldm.load_type = 'T' AND tms.load_id IS NULL or (LEN(ldm.load_id)<=3 and ldm.load_type in('T','M','S'))
SELECT distinct ldm.status, ldm.shipment_status FROM  Distribution_Warehouse_Wholesale.LoadMaster as ldm WHERE ldm.wh_id = '335' AND ldm.status not in ('S')
and  ldm.load_type = 'T' AND tms.load_id IS NULL or (LEN(ldm.load_id)<=3 and ldm.load_type in('T','M','S'))


select top 10 * from Distribution_Warehouse_Wholesale.LoadMaster  ldm
join Distribution_Warehouse_Wholesale.t_order_c_number  orn
on ldm.load_id = left(orn.order_number,10) and ldm.wh_id = orn.wh_id
where ldm.status <>'S' and ldm.wh_id = '335'
order by ldm.load_id

select top 10 *  FROM PowerBI_Distribution.Dimcustomers as t  where t.[Customer Name] = 'ANGELICA ORDONEZ OLMOS'




SELECT TOP 10 * FROM Distribution_Warehouse_Wholesale.Customer as t where t.Whid = '335' and t.CustomerId like '%4044500%'
SELECT TOP 10 * FROM Wholesale_CODIS.ATOFILE AS t


SELECT TOP 10 * FROM Distribution_Warehouse_Wholesale.TripReport  as t  WHERE t.WhID = '335' AND t.TripStatus NOT IN ('S','X') and t.LoadID like  '0077866-%'  -- trip report





SELECT TOP 10 *
from Distribution_Warehouse_Wholesale.ProcessReportDetail as t1
from Distribution_Warehouse_Wholesale.ProcessReportDetail as t1

FROM Distribution_Warehouse_Wholesale.t_serial_active AS t1

SELECT top 1000 *
FROM Distribution_Warehouse_Wholesale.t_item_uom as t1
where t1.wh_id in ('335')
order by t1.item_number

SELECT top 10 *
FROM Distribution_Warehouse_Wholesale.t_item_master as t1
where t1.wh_id in ('335')
    and t1.class_id in ('FLOOR')

SELECT TOP 10 *
FROM DW_Developer.SharepointList AS T1

SELECT TOP 10 *
FROM  Distribution_Warehouse_Wholesale.TranLog AS t1
Where
  t1.wh_id in ('335')
  and t1.location_id in ('A3013GG2','A3013GG3','A3025GG3')


--STO_REPORT
SELECT TOP 10 * FROM Distribution_Warehouse_Wholesale.t_stored_item sto

-- orders
WITH ord as (
SELECT t.order_number, t.customer_id, t.arrive_date 
FROM Distribution_Warehouse_Wholesale.[t_order] as t  
WHERE t.wh_id in ('31','35','33','34')
AND t.customer_id = '335'
)
--STO
SELECT 
    sto.item_number, 
    sto.actual_qty, 
    sto.status, 
    sto.wh_id, 
    sto.location_id, 
    loc.TypeDescription, 
    sto.type
FROM (select * from Distribution_Warehouse_Wholesale.t_stored_item  as t where t.wh_id in ('31','35','33','34')) as sto
JOIN ( select * from Distribution_Warehouse_Wholesale.t_location  as t1 where t1.wh_id in ('31','35','33','34')) as loc
    ON sto.location_id = loc.location_id
    AND sto.wh_id = loc.wh_id 
Where sto.type IN ( SELECT t3.order_number FROM ord as t3)
    --WHERE 
    --    sto.wh_id = '31' 
    --    AND loc.TypeDescription IN ('I', 'M', 'P', 'X', 'S', 'D', 'V') 
    --    AND sto.status = 'A'

SELECT * FROM Distribution_Warehouse_Wholesale.[t_order] as t  WHERE t.wh_id in ('31','35','33','34')

/*



SELECT TOP 10 *
FROM Wholesale_CODIS_WNK.BTITSCN AS T1
WHERE T1.concontainer IN ('MEDU4752251')



SELECT  *,CAST(t1.PerformedAt AS DATE) AS Performed_Date
     FROM [PowerBI_Distribution].[OSHAPreOperationalChecklist] AS t1
     WHERE t1.WarehouseID IN ('335') AND CAST(t1.PerformedAt AS DATE) BETWEEN CAST(DATEADD(DAY, -10, GETDATE()) AS DATE) AND CAST(GETDATE() AS DATE)
    
SELECT TOP 10 *
FROM Wholesale_DemandPlanning_AFI.PlanDetailTimeline AS T1
WHERE t1.PTLDATATYPE = 'SAFETY STK' AND T1.PTLWHSE = '335'  AND T1.PTLWEEK1>0

SELECT top 100 *
FROM SupplyChain_Enh.ContainerPerDiem as t1
WHERE t1.PomWarehouse in ('335')

SELECT  top 10 *
FROM Distribution_Warehouse_Wholesale.TrailerType as t1
Where t1.wh_id in ('335')

SELECT  top 100 *
FROM Distribution_Warehouse_Wholesale.Trailer as t1
WHERE t1.wh_id in ('35') AND t1.entered_yard >= DATEADD(DAY,-60, GETDATE())
AND t1.equipment_id in ('MEDU4752251')

WITH RankedData AS (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY Item ORDER BY WeekEnding DESC) AS rn
    FROM your_table
)
SELECT *
FROM RankedData
WHERE rn = 1;


SELECT TOP 10 *
FROM PowerBI_Distribution.Billing AS T1

SELECT TOP 10 *
FROM PowerBI_SupplyChain.Containers AS T1

SELECT t1.Item, MAX(T1.WeekEnding) OVER (PARTITION BY T1.Item ORDER BY T1.FileDate Desc)
FROM SupplyChain_Enh.DemandFulfillment_LogilityContainer AS T1
WHERE T1.Whse in ('335') AND T1.Item IN ('6720618') 
ORDER BY T1.WeekEnding Desc

/*开窗函数 PARTITION */  ROW NUMBER 递增序号
WITH RankedData AS (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY Item ORDER BY CAST(t1.WeekEnding AS DATE)  DESC) AS rn
FROM SupplyChain_Enh.DemandFulfillment_LogilityContainer AS T1
WHERE T1.Whse in ('335') 
)
SELECT *
FROM RankedData
WHERE rn = 1;

-- 排除多列为空或0的行
SELECT *
FROM your_table
WHERE NOT (COALESCE(column1, 0) = 0 AND COALESCE(column2, 0) = 0 AND COALESCE(column3, 0) = 0);


-- 方法2 排除多列为空或0的行
DECLARE @sql NVARCHAR(MAX);

-- Generate SQL to check each column
SET @sql = 'SELECT * FROM your_table WHERE NOT (' +
           STUFF((
               SELECT ' AND ' + COLUMN_NAME + ' = 0'
               FROM INFORMATION_SCHEMA.COLUMNS
               WHERE TABLE_NAME = 'your_table'
               AND COLUMN_NAME NOT IN ('column_to_exclude')  -- Exclude specific columns if needed
               FOR XML PATH('')
           ), 1, 5, '') + ');';

-- Execute the dynamic SQL
EXEC sp_executesql @sql;
*/

