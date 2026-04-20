SELECT
    t1.ITNBR,
    t2.ITDSC,
    t2.ITCLS,
    t1.HOUSE,
    t1.LLOCN,
    t1.LQNTY,
    t1.ORDNO,
    t1.LBHNO,
    CASE
        WHEN t2.ITCLS LIKE 'TAF%' THEN 'RP'
        WHEN t2.ITCLS IN ('PACS') THEN 'UnKits'
        WHEN t2.ITCLS LIKE 'Z%K' THEN 'UnKits'
        WHEN t2.ITCLS IN (
            'ZACM','ZASU','ZMLH','ZMLR','ZUSR','ZUSU','ZVUC','ZXUC','ZUSU','ZUMU',
            'ZAMU','ZASM','ZASR','ZDMA','ZMUC','ZSUS','ZUMS','ZUSM','ZVMA','ZVUS',
            'ZXLH','ZXLM','ZXLR','ZXMS','ZXMU'
        ) THEN 'UPH'
        WHEN t2.ITCLS IN ('ZDAA','ZDAY','ZVAA','ZDAB','ZDAW','ZDYB','ZDBC','ZABC','ZECD') THEN 'CG'
        WHEN t2.ITCLS IN ('ZKIS','ZAIS') THEN 'Bedding'
        WHEN t2.ITCLS IN ('WPLS') THEN 'Plastics'
        WHEN t2.ITCLS IN ('WVBC','WVCS') THEN 'Foundation'
        WHEN t2.ITCLS IN ('PANL') THEN 'Panel'
        WHEN t2.ITCLS IN ('ZKIZ') THEN 'ZipperCover'
        WHEN t2.ITCLS IN ('BBFR','WVHC') THEN 'Verona'
        WHEN t2.ITCLS NOT LIKE 'Z%' THEN 'Raw'
        ELSE 'Check'
    END AS Product
FROM Manufacturing_ProductionPlanning_MIL.SLQNTY t1
LEFT JOIN MasterData_ItemMaster_MIL.ITMRVA t2 ON t1.ITNBR = t2.ITNBR
WHERE
    t1.HOUSE IN ('51')
--     AND t1.LLOCN NOT IN (@str)  -- 替换 @str 为你要排除的位置
ORDER BY
    t1.ITNBR;
