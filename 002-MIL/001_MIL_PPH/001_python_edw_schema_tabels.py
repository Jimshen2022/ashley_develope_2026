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

WITH ctn AS (
SELECT 
a.WCHCONTAINERNUMBER,a.WCHORIGIN,a.WCHDESTINATION,a.WCHCONTAINERSTATUS,a.WCHTOTALCARTONS,a.WCHTOTALCUBES,a.WCHPOSTEDTIMESTAMP,a.WCHTOTALWEIGHT,
a.WCHCONTAINERSIZE, a.WCHBUILDING, 
LTRIM(RTRIM(a.WCHORIGIN))+'-'+ LTRIM(RTRIM(a.WCHCONTAINERNUMBER))+'-'+LTRIM(RTRIM(a.WCHDESTINATION)) as Container#
FROM Manufacturing_ProductionPlanning_MIL.WVCNTHD a
WHERE 
 a.WCHORIGIN IN ('51')  
 AND a.WCHBUILDING LIKE 'B%'
UNION ALL
SELECT a.WCHCONTAINERNUMBER,a.WCHORIGIN,a.WCHDESTINATION,a.WCHCONTAINERSTATUS,a.WCHTOTALCARTONS,a.WCHTOTALCUBES,a.WCHPOSTEDTIMESTAMP,a.WCHTOTALWEIGHT,a.WCHCONTAINERSIZE,a.WCHBUILDING, 
LTRIM(RTRIM(a.WCHORIGIN))+'-'+ LTRIM(RTRIM(a.WCHCONTAINERNUMBER))+'-'+LTRIM(RTRIM(a.WCHDESTINATION))+'-'+SUBSTRING(CONVERT(VARCHAR(20), a.WCHARCHIVETIMESTAMP, 120),1,13) as Container#
FROM Manufacturing_ProductionPlanning_MIL.WVCNTHDA a
WHERE 
a.WCHPOSTEDTIMESTAMP BETWEEN CONVERT(VARCHAR(10), DATEADD(DAY, -60, GETDATE()), 120) AND CONVERT(VARCHAR(10), GETDATE(), 120)
AND a.WCHORIGIN IN ('51') 
AND a.WCHBUILDING LIKE 'B%'
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
),
load_data as 
((SELECT LTRIM(RTRIM(a.WCICONTAINERNUMBER)) as ContainerNumber, a.WCIORIGIN, a.WCIDESTINATION, a.WCIORDER, LTRIM(RTRIM(a.WCIITEMNUMBER)) as ItemNumber, a.WCIQUANTITYLOADED as Qty, 
a.WCILASTMAINTENANCETIMESTAMP, a.WCILASTMAINTENANCEUSER,
LTRIM(RTRIM(a.WCIORIGIN))+'-'+ LTRIM(RTRIM(a.WCICONTAINERNUMBER))+'-'+LTRIM(RTRIM(a.WCIDESTINATION)) as Container#
FROM Manufacturing_ProductionPlanning_MIL.WVCNTID as a 
WHERE a.WCIORIGIN IN('51')  
AND a.WCILASTMAINTENANCETIMESTAMP BETWEEN CONVERT(VARCHAR(10), DATEADD(DAY, -30, GETDATE()), 120) AND CONVERT(VARCHAR(10), GETDATE(), 120)
) 
UNION ALL
(SELECT LTRIM(RTRIM(a.WCICONTAINERNUMBER)) as ContainerNumber, a.WCIORIGIN, a.WCIDESTINATION, a.WCIORDER, LTRIM(RTRIM(a.WCIITEMNUMBER)) as ItemNumber, a.WCIQUANTITYLOADED as Qty, 
a.WCILASTMAINTENANCETIMESTAMP, a.WCILASTMAINTENANCEUSER,
LTRIM(RTRIM(a.WCIORIGIN))+'-'+ LTRIM(RTRIM(a.WCICONTAINERNUMBER))+'-'+LTRIM(RTRIM(a.WCIDESTINATION))+'-'+SUBSTRING(CONVERT(VARCHAR(20), a.WCIARCHIVETIMESTAMP, 120),1,13) as Container#
FROM Manufacturing_ProductionPlanning_MIL.WVCNTIDA as a 
WHERE a.WCIORIGIN IN('51') 
AND a.WCILASTMAINTENANCETIMESTAMP BETWEEN CONVERT(VARCHAR(10), DATEADD(DAY, -30, GETDATE()), 120) AND CONVERT(VARCHAR(10), GETDATE(), 120)
))
SELECT 
    t.ContainerNumber,
    t.WCIORIGIN,
    t.WCIDESTINATION,
    t.WCIORDER,
    t.ItemNumber,
    t.Qty,
    t.WCILASTMAINTENANCETIMESTAMP,
    t.WCILASTMAINTENANCEUSER,
    b.ITMCQTY, 
    b.itcls,
    b.B2Z95S as UnitCube, 
    b.WEGHT as UnitWeight,
    t.Qty*b.B2Z95S as Cubes,
    CEILING(CAST(t.Qty AS FLOAT)/CAST(b.ITMCQTY AS FLOAT)) as Cartons,
    n.Container#,
    n.WCHBUILDING,
    n.WCHCONTAINERSTATUS,
    n.WCHDESTINATION,
    n.WCHTOTALCARTONS,
    n.WCHTOTALCUBES,
    n.WCHPOSTEDTIMESTAMP,
    n.WCHTOTALWEIGHT,
    n.WCHCONTAINERSIZE, 
    n.WCHBUILDING,
    CASE 
        WHEN DATEPART(HOUR, t.WCILASTMAINTENANCETIMESTAMP) BETWEEN 7 AND 18 THEN 'D'
        ELSE 'N'
    END AS Shift
FROM load_data as t
LEFT JOIN itm as b ON t.ItemNumber =  LTRIM(RTRIM(b.ITNBR))
LEFT JOIN ctn as n ON n.Container# = t.Container#
WHERE n.WCHBUILDING LIKE 'B%'

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
csv_path = os.path.join(output_dir, f"query_results_{current_time}.csv")
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


