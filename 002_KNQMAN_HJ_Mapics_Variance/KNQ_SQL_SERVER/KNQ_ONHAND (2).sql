SELECT 
    -- 1. 基础信息格式化
    ROW_NUMBER() OVER (ORDER BY P.NGAY_PHIEU DESC)  AS N'STT',
    LTRIM(RTRIM(CAST(P.SOTK AS VARCHAR(50))))       AS N'Số TK nhập',
    CONVERT(VARCHAR(10), P.NGAY_DK, 103)            AS N'Ngày TK',
    P.SO_PHIEU                                      AS N'Số PNK',
    CONVERT(VARCHAR(10), P.NGAY_PHIEU, 103)         AS N'Ngày NK',
    P.SO_HD                                         AS N'Số hợp đồng',
    CONVERT(VARCHAR(10), P.NGAY_HD, 103)            AS N'Ngày hợp đồng',
    H.MA_SP                                         AS N'Mã hàng',
    H.TEN_SP                                        AS N'Tên hàng',

    -- 2. 商品标识码生成
    ISNULL(NULLIF(LTRIM(RTRIM(H.DINH_DANH_HANG_HOA)), ''),
           RIGHT(CAST(YEAR(ISNULL(P.NGAY_DK, P.NGAY_PHIEU)) AS VARCHAR(4)), 2)
           + ISNULL(CAST(P.SOTK AS VARCHAR(50)), '')
           + '-'
           + RIGHT('00' + CAST(ISNULL(H.STTHANG, 1) AS VARCHAR(10)), 2)
    )                                               AS N'Định danh hàng hóa',

    -- 3. 产地与单价 (APPLY 确保不翻倍)
    M.MA_NUOC AS N'Xuất xứ',
    M.MA_HS AS N'Mã HS',
    H.SO_LUONG AS N'Lượng',
    M.DON_GIA AS N'Đơn giá',
    M.MA_DVT AS N'Đơn vị tính',

    -- 4. 结存计算
    ISNULL(X.LUONG_XUAT, 0)                         AS N'Lượng xuất',
    ROUND(H.SO_LUONG - ISNULL(X.LUONG_XUAT, 0), 3)  AS N'SL Tồn',
    ROUND((H.SO_LUONG - ISNULL(X.LUONG_XUAT, 0)) * M.DON_GIA, 2) AS N'Trị Giá Tồn',
    
    P.MA_NT AS N'Mã NT',
    CONVERT(VARCHAR(10), P.NGAY_PHIEU, 103)         AS N'Ngày nhập',
    CONVERT(VARCHAR(10), X.NGAY_XUAT_CUOI, 103)     AS N'Ngày xuất',
    DATEDIFF(day, P.NGAY_PHIEU, GETDATE())          AS N'Số ngày tồn',
    H.GHI_CHU AS N'Ghi chú'

FROM ECUS5_KNQ.dbo.DPHIEU P
INNER JOIN ECUS5_KNQ.dbo.DPHIEU_HANG H ON P.DPHIEUID = H.DPHIEUID

-- 使用 OUTER APPLY 锁定合同主数据，彻底解决 2.9 万行的行膨胀问题
OUTER APPLY (
    SELECT TOP 1 
        COALESCE(NULLIF(H.MA_NUOC, ''), NULLIF(HD.MA_NUOC, ''), NULLIF(SP.MA_NUOC, ''), 'VN') AS MA_NUOC,
        COALESCE(NULLIF(H.MA_HS, ''), NULLIF(HD.MA_HS, ''), NULLIF(SP.MA_HS, '')) AS MA_HS,
        COALESCE(NULLIF(H.MA_DVT, ''), NULLIF(HD.MA_DVT, ''), NULLIF(SP.MA_DVT, '')) AS MA_DVT,
        COALESCE(H.DON_GIA, HD.DON_GIA, 0) AS DON_GIA
    FROM (SELECT 1 as d) d_table
    LEFT JOIN ECUS5_KNQ.dbo.DHOPDONG_HANG HD ON P.DHOPDONGID = HD.DHOPDONGID AND H.MA_SP = HD.MA_SP
    LEFT JOIN ECUS5_KNQ.dbo.SSANPHAM SP ON H.MA_SP = SP.MA_SP AND SP.MA_KNQ = P.MA_KNQ
) M

-- 出库汇总 (精准匹配：单号 + 项次 + 料号)
OUTER APPLY (
    SELECT 
        SUM(ISNULL(HX.SO_LUONG, 0)) AS LUONG_XUAT,
        MAX(PX.NGAY_XUAT) AS NGAY_XUAT_CUOI
    FROM ECUS5_KNQ.dbo.DPHIEU_HANG HX
    INNER JOIN ECUS5_KNQ.dbo.DPHIEU PX ON HX.DPHIEUID = PX.DPHIEUID
    WHERE PX._XORN = 'X' 
      AND HX.MA_SP = H.MA_SP
      AND ISNULL(HX.IS_HUY, 0) = 0 
      AND (
          (HX.SOTK_N = P.SOTK AND HX.STTHANG_N = H.STTHANG AND P.SOTK <> '')
          OR (HX.SO_PHIEU_N = P.SO_PHIEU AND HX.MA_SP = H.MA_SP AND P.SO_PHIEU <> '')
      )
) X

WHERE 
    P._XORN = 'N'                             -- 必须是入库单
    AND P.MA_KNQ = 'VNNSL'                    -- 必须是 VNNSL 仓库
    AND ISNULL(P.HUY_TRANG_THAI, 0) = 0       -- 排除单头作废
    AND ISNULL(H.IS_HUY, 0) = 0               -- 排除行项作废
    
    -- 【第一性原理：针对 14,180 行对齐的核心过滤条件】
    AND P.MESSAGEID IS NOT NULL               -- 1. 必须有海关流水号（排除本地草稿）
    AND ISNULL(H.IS_KETTHUC_GETIN, 0) = 1     -- 2. 必须是已确认入场的货物（这是解决 1.5 万行差异的杀手锏）
    AND LTRIM(RTRIM(CAST(P.SOTK AS VARCHAR(50)))) LIKE '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]' -- 3. 必须是 12 位纯数字报关单

    AND (H.SO_LUONG - ISNULL(X.LUONG_XUAT, 0)) > 0.001 -- 4. 库存必须大于 0
ORDER BY P.NGAY_PHIEU DESC;