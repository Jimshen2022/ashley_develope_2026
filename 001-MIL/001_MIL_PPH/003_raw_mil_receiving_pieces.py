# this file is tested and works well by Jim,Shen on Mar.08.2025
import pandas as pd
import os
from sqlalchemy import create_engine
import urllib
import os
import time
from datetime import datetime

# 记录开始时间
start_time = time.time()

# 数据库连接信息
server = 'ashley-edw.database.windows.net'
database = 'ASHLEY_EDW'

# 创建连接URL
params = urllib.parse.quote_plus(
    "DRIVER={ODBC Driver 18 for SQL Server};"
    f"SERVER={server};"
    f"DATABASE={database};"
    "Authentication=ActiveDirectoryIntegrated;"
    "Encrypt=yes;"
    "TrustServerCertificate=no;"
)

# 创建引擎
engine = create_engine(f"mssql+pyodbc:///?odbc_connect={params}")

# SQL 查询语句
query = """

WITH emp AS (
    SELECT
        t.Plant,
        cast(t.EmployeeNumber as int) as EmployeeNumber,
        t.EmpReportName,
        t.GroupNumber,
        t.Schedule,
        t.HomeDepartment,
        t.TerminationDate
    FROM Manufacturing_ProductionPlanning_MIL.EMMSTR as t
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
        WHEN c.ITCLS LIKE 'TAF%' THEN 'RP'
        WHEN c.ITCLS IN ('MTA','CTA','FFR','MVN') THEN 'RP'
        WHEN c.ITCLS IN ('PACS','ZACM','WVVG') THEN 'UnKits'
        WHEN c.ITCLS LIKE 'Z%K'  THEN 'UnKits'
        WHEN c.ITCLS IN ('ZDTP','ZKBP')  THEN 'Pillow'
        WHEN c.ITCLS IN ('ZASU','ZMLH','ZMLR','ZUSR','ZUSU','ZVUC','ZXUC','ZUSU','ZUMU','ZAMU','ZASM','ZASR','ZDMA','ZMUC','ZSUS','ZUMS','ZUSM','ZVMA','ZVUS','ZXLH','ZXLM','ZXLR','ZXMS','ZXMU') THEN 'UPH'
        WHEN c.ITCLS IN ('ZDAA','ZDAE','ZDWC','ZDAY','ZVAA','ZDAB','ZDAW','ZDYB','ZDBC','ZABC','ZECD','ZEBR') THEN 'CG'
        WHEN c.ITCLS IN ('ZBMA','ZKIS','ZAIS','ZKBA','ZNFR','ZKBP','ZNFR') THEN 'Bedding'
        WHEN c.ITCLS IN ('WPLS') THEN 'Plastics'
        WHEN c.ITCLS IN ('WVBC','WVCS') THEN 'Foundation'
		WHEN c.ITCLS IN ('PANL') THEN 'Panel'
		WHEN c.ITCLS IN ('ZKIZ','BBFR','WVHC') THEN 'ZipperCover'
        -- WHEN c.ITCLS IN ('BBFR','WVHC') THEN 'Verona'
		WHEN c.ITCLS NOT LIKE 'Z%' THEN 'RawMaterial'
    ELSE 'Check' END AS Product
FROM MasterData_ItemMaster_MIL.ITMRVA AS c
INNER JOIN MasterData_ItemMaster_MIL.ITBEXT AS d on c.ITNBR = d.ITNBR and c.STID = d.HOUSE
INNER JOIN MasterData_ItemMaster_MIL.ITMEXT as e on e.ITNBR = c.ITNBR
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

    -- 合成位置信息判断
    CASE
        WHEN
            CAST(ToArea AS VARCHAR) +
            RIGHT('000' + CAST(ToAisle AS VARCHAR), 3) +
            CAST(ToSection AS VARCHAR) +
            CAST(ToTier AS VARCHAR) IN ('HJ001AA1','HJ001AA2')
        THEN 'Receiving'
        WHEN
            CAST(ToArea AS VARCHAR) +
            RIGHT('000' + CAST(ToAisle AS VARCHAR), 3) +
            CAST(ToSection AS VARCHAR) +
            CAST(ToTier AS VARCHAR) IN ('HJ001AA3','HJ001AA4')
        THEN 'Receiving'
        ELSE NULL
    END AS pph_type,

    CASE
        WHEN
            CAST(ToArea AS VARCHAR) +
            RIGHT('000' + CAST(ToAisle AS VARCHAR), 3) +
            CAST(ToSection AS VARCHAR) +
            CAST(ToTier AS VARCHAR) IN ('HJ001AA1','HJ001AA2')
        THEN 'B1'
        WHEN
            CAST(ToArea AS VARCHAR) +
            RIGHT('000' + CAST(ToAisle AS VARCHAR), 3) +
            CAST(ToSection AS VARCHAR) +
            CAST(ToTier AS VARCHAR) IN ('HJ001AA3')
        THEN 'B3'
        WHEN
            CAST(ToArea AS VARCHAR) +
            RIGHT('000' + CAST(ToAisle AS VARCHAR), 3) +
            CAST(ToSection AS VARCHAR) +
            CAST(ToTier AS VARCHAR) IN ('HJ001AA3','HJ001AA4')
        THEN 'B4'
        ELSE NULL
    END AS building,

    -- 时间与班次
    RIGHT('000000' + CAST(t.AddTime AS VARCHAR(6)), 6) AS AddTime6,
    CASE
        WHEN CAST(LEFT(RIGHT('000000' + CAST(t.AddTime AS VARCHAR(6)), 6), 2) AS INT) BETWEEN 7 AND 18
        THEN 'D'
        ELSE 'N'
    END AS Shift,

    -- 新增shift_date列
    CASE
        WHEN CAST(LEFT(RIGHT('000000' + CAST(t.AddTime AS VARCHAR(6)), 6), 2) AS INT) BETWEEN 0 AND 6
        THEN CAST(CONVERT(CHAR(8), DATEADD(DAY, -1, CAST(CAST(t.AddDate AS VARCHAR(8)) AS DATE)), 112) AS INT)
        ELSE t.AddDate
    END AS shift_date,

    -- 显示 emp 的所有列
    e.*,
    i.Product
FROM
    Manufacturing_ProductionPlanning_MIL.ACTAUDT AS t
LEFT JOIN emp AS e
    ON e.EmployeeNumber = CAST(t.EmpBadge AS INT)  -- 修正 JOIN 类型匹配
LEFT JOIN itm as i
    ON i.ITNBR = t.Item
WHERE
    t.AddDate BETWEEN CAST(CONVERT(CHAR(8), DATEADD(DAY, -7, GETDATE()), 112) AS INT)
        AND CAST(CONVERT(CHAR(8), GETDATE(), 112) AS INT)
    AND t.ActivityCodeOne = 'MV'
    AND t.FromWhs = '51'
    AND t.ActivityCodeTwo = 'SN'
    AND t.FromArea = 'RM'
    AND t.ToArea = 'HJ'
    AND t.Serial <> 0;
    
    
"""

# 执行查询
try:
    df = pd.read_sql(query, engine)
    print("查询成功！数据已加载到 DataFrame。")
except Exception as e:
    print("数据库连接或查询失败！", e)
    exit()


# 生成文件名和路径
current_time = datetime.now().strftime('%Y%m%d_%H%M%S')
output_dir = os.path.expanduser("~/Downloads")
# output_path = os.path.join(output_dir, f"query_results_{current_time}.xlsx")
csv_path = os.path.join(output_dir, f"raw_mil_receiving_pieces_{current_time}.csv")
# html_path = os.path.join(output_dir, f"data_view_{current_time}.html")

# 导出到 CSV 文件
try:
    df.to_csv(csv_path, index=False)
    print(f"数据已成功导出到 CSV 文件：{csv_path}")
except Exception as e:
    print("导出 CSV 文件失败！", e)


# 计算并打印总运行时间
end_time = time.time()
execution_time = end_time - start_time
print(f"\n程序总运行时间：{execution_time:.2f} 秒")


