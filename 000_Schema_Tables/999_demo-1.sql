SELECT
    t1.HOUSE,
    t1.TCODE,
    t1.ORDNO,
    t1.ITNBR,
    t2.ITCLS,
    t1.UPDDT,
    t1.UPDTM,
    t1.TRQTY,
    t1.ENTUM,
    t1.VNDNR,
    t1.REFNO,
    t1.LLOCN,
    t1.NLLOC,
    t1.BATCH,
    t1.TRMID,

    -- 拼接并转换为 DATETIME 类型
    TRY_CAST(
        CONCAT(
            '20',
            SUBSTRING(CAST(t1.UPDDT AS VARCHAR), 2, 2),
            '-',
            SUBSTRING(CAST(t1.UPDDT AS VARCHAR), 4, 2),
            '-',
            SUBSTRING(CAST(t1.UPDDT AS VARCHAR), 6, 2),
            ' ',
            STUFF(STUFF(RIGHT(CONCAT('000000', CAST(t1.UPDTM AS VARCHAR(6))), 6), 3, 0, ':'), 6, 0, ':')
        ) AS DATETIME
    ) AS TrxTime,

    -- 提取小时
    CAST(LEFT(RIGHT(CONCAT('000000', CAST(t1.UPDTM AS VARCHAR(6))), 6), 2) AS INT) AS HOUR,

    -- 产品分类
    CASE
        WHEN t2.ITCLS LIKE 'TAF%' THEN 'RP'
        WHEN t2.ITCLS IN ('PACS') THEN 'UnKits'
        WHEN t2.ITCLS LIKE 'Z%K' THEN 'UnKits'
        WHEN t2.ITCLS IN (
            'ZACM','ZASU','ZMLH','ZMLR','ZUSR','ZUSU','ZVUC','ZXUC','ZUMU',
            'ZAMU','ZASM','ZASR','ZDMA','ZMUC','ZSUS','ZUMS','ZUSM','ZVMA',
            'ZVUS','ZXLH','ZXLM','ZXLR','ZXMS','ZXMU'
        ) THEN 'UPH'
        WHEN t2.ITCLS IN ('ZDAA','ZDAY','ZVAA','ZDAB','ZDAW','ZDYB','ZDBC','ZABC','ZECD') THEN 'CG'
        WHEN t2.ITCLS IN ('ZKIS','ZAIS') THEN 'Bedding'
        WHEN t2.ITCLS IN ('WPLS') THEN 'Plastics'
        WHEN t2.ITCLS IN ('WVBC','WVCS') THEN 'Foundation'
        WHEN t2.ITCLS IN ('PANL') THEN 'Panel'
        WHEN t2.ITCLS IN ('ZKIZ') THEN 'ZC'
        WHEN t2.ITCLS IN ('BBFR','WVHC') THEN 'Verona'
        WHEN t2.ITCLS NOT LIKE 'Z%' THEN 'Raw'
        ELSE 'Check'
    END AS Product

FROM Manufacturing_Inventory_MIL.IMHIST t1
JOIN MasterData_ItemMaster_MIL.ITMRVA t2 ON t1.ITNBR = t2.ITNBR

-- 只查 TCODE = 'TW' 且时间在近 90 天内
WHERE t1.TCODE = 'TW'
AND TRY_CAST(
    CONCAT(
        '20',
        SUBSTRING(CAST(t1.UPDDT AS VARCHAR), 2, 2),
        '-',
        SUBSTRING(CAST(t1.UPDDT AS VARCHAR), 4, 2),
        '-',
        SUBSTRING(CAST(t1.UPDDT AS VARCHAR), 6, 2),
        ' ',
        STUFF(STUFF(RIGHT(CONCAT('000000', CAST(t1.UPDTM AS VARCHAR(6))), 6), 3, 0, ':'), 6, 0, ':')
    ) AS DATETIME
) BETWEEN DATEADD(DAY, -365, GETDATE()) AND GETDATE()
