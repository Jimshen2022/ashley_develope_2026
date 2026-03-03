# -*- coding: utf-8 -*-
# This file is tested and works well by Jim, Shen on Mar.08.2025
import os
import time
from datetime import datetime
import urllib
import numpy as np
import pandas as pd
from sqlalchemy import create_engine

# ==============================
# 0) 计时与基础配置
# ==============================
start_time = time.time()

server = 'ashley-edw.database.windows.net'
database = 'ASHLEY_EDW'

# 连接字符串（Azure AD 集成认证 + ODBC Driver 18）
params = urllib.parse.quote_plus(
    "DRIVER={ODBC Driver 18 for SQL Server};"
    f"SERVER={server};"
    f"DATABASE={database};"
    "Authentication=ActiveDirectoryIntegrated;"
    "Encrypt=yes;"
    "TrustServerCertificate=no;"
)
engine = create_engine(f"mssql+pyodbc:///?odbc_connect={params}")

# ==============================
# 1) SQL 查询（Hour 字段；cartons 保留小数）
# ==============================
query = """
WITH emp AS (
    SELECT
        t.Plant,
        CAST(t.EmployeeNumber AS INT) AS EmployeeNumber,
        t.EmpReportName,
        t.GroupNumber,
        t.Schedule,
        t.HomeDepartment,
        t.TerminationDate
    FROM Manufacturing_ProductionPlanning_MIL.EMMSTR AS t
),
itm AS (
    SELECT
        c.ITNBR,
        c.ITCLS,
        c.B2Z95S,
        c.WEGHT,
        d.ITMCLSID,
        d.PICKPUT,
        e.ITMCQTY,
        CASE 
            WHEN TRIM(c.ITNBR) LIKE 'M%UN' THEN 'ZipperCover'
            WHEN c.ITCLS IN ('ZKIZ', 'BBFR', 'WVHC') THEN 'ZipperCover'
            WHEN c.ITCLS LIKE 'TAF%' THEN 'RP'
            WHEN c.ITCLS IN ('MTA', 'CTA') THEN 'RP'
            WHEN c.ITCLS LIKE 'Z%K' THEN 'UnKits'            
            WHEN c.ITCLS IN ('FFR', 'MVN', 'PACS', 'ZACM', 'WVVG', 'ZDTP', 'ZKBP', 'ZSUS', 'ZUMS', 'ZUSM', 'ZVMA', 'ZVUS', 'ZXLH', 'ZXLM', 'ZXLR', 'ZXMS', 'ZXMU') THEN 'UnKits'
            WHEN c.ITCLS IN ('ZDAA', 'ZDAE', 'ZDWC', 'ZDAY', 'ZVAA', 'ZDAB', 'ZDAW', 'ZDYB', 'ZDBC', 'ZABC', 'ZECD', 'ZEBR') THEN 'CG'
            WHEN c.ITCLS IN ('ZBMA', 'ZKIS', 'ZAIS', 'ZKBA', 'ZNFR', 'ZKBP') THEN 'Bedding'
            WHEN c.ITCLS IN ('WPLS') THEN 'Plastics'
            WHEN c.ITCLS IN ('WVBC', 'WVCS') THEN 'Foundation'
            WHEN c.ITCLS  IN ('PANL') THEN 'Panel'
            WHEN c.ITCLS NOT LIKE 'Z%' THEN 'RawMaterial'
            ELSE 'Check'
        END AS Product    
    FROM MasterData_ItemMaster_MIL.ITMRVA AS c
    INNER JOIN MasterData_ItemMaster_MIL.ITBEXT AS d
        ON c.ITNBR = d.ITNBR AND c.STID = d.HOUSE
    INNER JOIN MasterData_ItemMaster_MIL.ITMEXT AS e
        ON e.ITNBR = c.ITNBR
    WHERE c.STID = '51' 
)
SELECT
    t.ActivityCodeOne,
    t.ActivityCodeTwo,
    t.FromRegion,
    t.FromWhs,
    t.FromArea,
    t.FromAisle,
    t.FromSection,
    t.FromTier,
    t.ToRegion,
    t.ToWhs,
    t.ToArea,
    t.ToAisle,
    t.ToSection,
    t.ToTier,
    t.[Order],
    t.Item,
    t.Serial,
    t.LicensePlate,
    t.TransQty,
    t.Emp,
    CAST(t.EmpBadge AS INT) AS EmpBadge,
    t.SuprBadge,
    t.Scanner,
    t.Equipment,
    t.AddDate,
    t.AddTime,
    t.AddUser,
    t.AddProgram,
    t.Transfer,
    t.Trip,
    CAST(t.Serial AS VARCHAR(50)) AS SN,

    -- pph_type（示例：都归 Receiving）
    CASE
        WHEN CAST(ToArea AS VARCHAR) + RIGHT('000' + CAST(ToAisle AS VARCHAR), 3) + CAST(ToSection AS VARCHAR) + CAST(ToTier AS VARCHAR) IN ('HJ001AA1','HJ001AA2') THEN 'Receiving'
        WHEN CAST(ToArea AS VARCHAR) + RIGHT('000' + CAST(ToAisle AS VARCHAR), 3) + CAST(ToSection AS VARCHAR) + CAST(ToTier AS VARCHAR) IN ('HJ001AA3','HJ001AA4') THEN 'Receiving'
        ELSE NULL
    END AS pph_type,

    -- building（互斥分支修正）
    CASE
        WHEN CAST(ToArea AS VARCHAR) + RIGHT('000' + CAST(ToAisle AS VARCHAR), 3) + CAST(ToSection AS VARCHAR) + CAST(ToTier AS VARCHAR) IN ('HJ001AA1','HJ001AA2') THEN 'B1'
        WHEN CAST(ToArea AS VARCHAR) + RIGHT('000' + CAST(ToAisle AS VARCHAR), 3) + CAST(ToSection AS VARCHAR) + CAST(ToTier AS VARCHAR) IN ('HJ001AA3')             THEN 'B3'
        WHEN CAST(ToArea AS VARCHAR) + RIGHT('000' + CAST(ToAisle AS VARCHAR), 3) + CAST(ToSection AS VARCHAR) + CAST(ToTier AS VARCHAR) IN ('HJ001AA4')             THEN 'B4'
        ELSE NULL
    END AS building,

    -- 时间与班次
    RIGHT('000000' + CAST(t.AddTime AS VARCHAR(6)), 6) AS AddTime6,
    CAST(LEFT(RIGHT('000000' + CAST(t.AddTime AS VARCHAR(6)), 6), 2) AS INT) AS Hour,
    CASE WHEN CAST(LEFT(RIGHT('000000' + CAST(t.AddTime AS VARCHAR(6)), 6), 2) AS INT) BETWEEN 7 AND 18 THEN 'D' ELSE 'N' END AS Shift,

    -- 新增 shift_date（0-6 点归到前一日）
    CASE
        WHEN CAST(LEFT(RIGHT('000000' + CAST(t.AddTime AS VARCHAR(6)), 6), 2) AS INT) BETWEEN 0 AND 6
            THEN CAST(CONVERT(CHAR(8), DATEADD(DAY, -1, CAST(CAST(t.AddDate AS VARCHAR(8)) AS DATE)), 112) AS INT)
        ELSE t.AddDate
    END AS shift_date,

    -- 员工与物料分类
    e.*,
    i.Product,
    -- cartons：保留小数，不在行级抬高到 1；0 防护
    CAST(t.TransQty AS DECIMAL(18,6)) / NULLIF(CAST(i.ITMCQTY AS DECIMAL(18,6)), 0) AS cartons
FROM Manufacturing_ProductionPlanning_MIL.ACTAUDT AS t
LEFT JOIN emp AS e
    ON e.EmployeeNumber = CAST(t.EmpBadge AS INT)
LEFT JOIN itm AS i
    ON i.ITNBR = t.Item
WHERE
    t.AddDate BETWEEN CAST(CONVERT(CHAR(8), DATEADD(DAY, -22, GETDATE()), 112) AS INT)
        AND CAST(CONVERT(CHAR(8), GETDATE(), 112) AS INT)
    AND t.ActivityCodeOne = 'MV'
    AND t.FromWhs = '51'
    AND t.ActivityCodeTwo = 'SN'
    AND t.FromArea = 'RM'
    AND t.ToArea = 'HJ'
    AND t.Serial <> 0
    AND i.product = 'UnKits';
"""

# ==============================
# 2) 执行查询
# ==============================
try:
    df = pd.read_sql(query, engine)
    print("查询成功！数据已加载到 DataFrame。")
except Exception as e:
    print("数据库连接或查询失败！", e)
    raise SystemExit(1)

# ==============================
# 3) 导出原始数据 CSV
# ==============================
current_time = datetime.now().strftime('%Y%m%d_%H%M%S')
output_dir = os.path.expanduser("~/Downloads")
os.makedirs(output_dir, exist_ok=True)

csv_raw = os.path.join(output_dir, f"raw_mil_receiving_pieces_{current_time}.csv")
try:
    df.to_csv(csv_raw, index=False)
    print(f"数据已成功导出到 CSV 文件：{csv_raw}")
except Exception as e:
    print("导出 CSV 文件失败！", e)

# ==============================
# 4) 生成 “UnKits：按 日期×小时” 两张透视表
#     表①：unique Item 数；表②：cartons 合计（先合计再 ceil）
# ==============================
df_u = df[df['Product'] == 'UnKits'].copy()

# 兜底 Hour
if 'Hour' not in df_u.columns:
    df_u['AddTime6'] = df_u['AddTime6'].astype(str).str.zfill(6)
    df_u['Hour'] = df_u['AddTime6'].str[:2].astype(int)

all_hours = list(range(24))

# 表①：每小时唯一 Item 数
pivot_unique_items = (
    df_u.groupby(['shift_date', 'Hour'])['Item']
        .nunique()
        .unstack(fill_value=0)
        .reindex(columns=all_hours, fill_value=0)
        .sort_index()
)

# 表②：每小时 cartons 合计（先合计，再统一无条件进位）
pivot_cartons = (
    df_u.groupby(['shift_date', 'Hour'])['cartons']
        .sum()              # 合计为小数
        .pipe(np.ceil)      # 整体无条件进位
        .astype('int64')    # 明确整型
        .unstack(fill_value=0)
        .reindex(columns=all_hours, fill_value=0)
        .sort_index()
)

# 导出透视表
csv_unique = os.path.join(output_dir, f"unkits_unique_items_bydate_byhour_{current_time}.csv")
csv_qty    = os.path.join(output_dir, f"unkits_cartons_bydate_byhour_{current_time}.csv")

pivot_unique_items.to_csv(csv_unique, index=True)
pivot_cartons.to_csv(csv_qty, index=True)

print(f"UnKits - unique Item count (by date x hour) -> {csv_unique}")
print(f"UnKits - Cartons sum (by date x hour)     -> {csv_qty}")

# ==============================
# 5) 可选：一致性自检（两种口径比较）
# ==============================
try:
    a = df_u.groupby(['shift_date','Hour'])['cartons'].sum().pipe(np.ceil).astype('int64')
    b = (
        df_u['TransQty'].astype(float) / df_u['ITMCQTY'].astype(float)
    ).groupby([df_u['shift_date'], df_u['Hour']]).sum().pipe(np.ceil).astype('int64')
    print("自检：按 SQL 行级 cartons 汇总 与 现场再算(TransQty/ITMCQTY) 汇总 是否一致：", a.equals(b))
except Exception as _:
    # 某些极端行(ITMCQTY=0/缺失)可能跳过对比
    pass

# ==============================
# 6) 结束与用时
# ==============================
end_time = time.time()
print(f"\n程序总运行时间：{end_time - start_time:.2f} 秒")
