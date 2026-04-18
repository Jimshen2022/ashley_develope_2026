import pyodbc
import pandas as pd
from datetime import datetime
# 提供完整的连接字符串
connection_string = (
    'DRIVER={iSeries Access ODBC Driver};'
    'SYSTEM=10.18.18.104;'  # 替换为你的系统名称或IP地址
    'UID=JIMSHEN;'  # 替换为你的用户名
    'PWD=MJ2078;'  # 替换为你的密码
)

# 连接数据库 10.18.18.104
cnxn = pyodbc.connect(connection_string)

# 执行查询
query = """

-- 使用CTE和LEFT JOIN优化查询 -- Oct.02.2024 by Jim,Shen
WITH BaseData AS (
    SELECT
        t4.INIVDT, t6.ITITNO, t4.INWHSE, t6.ITITCL, t6.ITSHQT, t2.UUCCIM, t7.XCUS#,
        t6.ITWHSE, t6.ITCSNO, t6.ITSPNO, T5.XNTRPN, T5.XNINVR, T5.XNORNO, t1.STACD,
        t2.CUBES AS Unit_CubicFeet,
        t2.CUBES * t6.ITSHQT as CUBES,
        t4.INPONO, t1.CUSNM, t7.XFRGHT, t7.XTCONF, t7.XDSCNT, t6.ITPRIC, t1.CCTYN as CountryCode,
        t4.INIVDT || '_' || CHAR(t5.XNTRPN) AS Container#,
    CASE
        WHEN t6.ITITCL NOT LIKE 'Z%' THEN 'RP'
        WHEN t6.ITITNO LIKE '100-%' THEN 'CG'
        WHEN REGEXP_LIKE(TRIM(t6.ITITNO), '^[1-9U]') THEN 'UPH'
        --WHEN SUBSTR(TRIM(T1.ITNBR),1,1) IN ('1','2','3','4','5','6','7','8','9','U') THEN 'UPH'
        WHEN SUBSTR(TRIM(t6.ITITNO),1,1) IN ('A') AND t2.CUBES >= 0.3 THEN 'CG'
        WHEN REGEXP_LIKE(TRIM(t6.ITITNO), '^[ALRQ]') THEN 'ACCESSORY'
        --WHEN SUBSTR(TRIM(t6.ITITNO),1,1) IN ('A','L','R','Q') THEN 'ACCESSORY'
        WHEN LENGTH(TRIM(t6.ITITNO)) = 6 AND SUBSTR(TRIM(t6.ITITNO),1,1) ='M' THEN 'ACCESSORY'
    ELSE 'CG' END AS Sub_Product,
    CASE
        WHEN t6.ITITCL NOT LIKE 'Z%' THEN 'RP'
        WHEN t6.ITITNO LIKE '100-%' THEN 'CG'
        WHEN REGEXP_LIKE(TRIM(t6.ITITNO), '^[1-9U]') THEN 'UPH'
        ELSE 'CG'
    END AS Product
    FROM
        (SELECT * FROM AFILELIB.TSITIN AS a WHERE a.ITWHSE = '335') AS t6
        LEFT JOIN  AFILELIB.TSITXN AS t7 ON t6.ITORNO = t7.XTORNO AND t6.ITITNO = t7.XTITNO AND t6.ITINVR = t7.XTINVR AND t6.ITITSQ = t7.XTITSQ
        LEFT JOIN  (SELECT * FROM AFILELIB.TSININA1 AS c WHERE c.INWHSE = '335') AS t4 ON t6.ITORNO = t4.INORNO AND t6.ITWHSE = t4.INWHSE AND t6.ITINVR = t4.ININVR
        LEFT JOIN AFILELIB.TSINXN t5 ON t6.ITORNO = t5.XNORNO AND t6.ITINVR = t5.XNINVR
        LEFT JOIN AFILELIB.ACUSMASJ t1 ON t6.ITCSNO = t1.CUSNO
        LEFT JOIN AMFLIBA.MBBZRES1 t3 ON t6.ITITNO = t3.BZAITX
        LEFT JOIN AFILELIB.ITMEXT t2 ON t6.ITITNO = t2.ITNBR
    WHERE
        t4.INWHSE = '335'
        AND t5.XNTRPN <> 0
        --AND t4.INIVDT BETWEEN INTEGER(REPLACE(CHAR(CURRENT DATE - 360 DAYS), '-', '')) AND INTEGER(REPLACE(CHAR(CURRENT DATE), '-', ''))
        AND t4.INIVDT BETWEEN 20240101 AND INTEGER(REPLACE(CHAR(CURRENT DATE), '-', ''))
        AND t6.ITSHQT > 0
),
ContainerTypes AS (
    SELECT
        Container#,
        CASE WHEN COUNT(DISTINCT Product) = 1 THEN 'None-Mixed' ELSE 'Mixed' END AS ContainerType
    FROM
        BaseData
    GROUP BY
        Container#
)
SELECT  bd.INIVDT, bd.ITITNO, bd.INWHSE, bd.ITITCL, bd.ITSHQT, bd.UUCCIM, bd.XCUS#,
    bd.ITWHSE, bd.ITCSNO, bd.ITSPNO, bd.XNTRPN, bd.XNINVR, bd.XNORNO, bd.STACD,
    bd.Unit_CubicFeet, bd.CUBES,
    bd.INPONO, bd.CUSNM, bd.XFRGHT, bd.XTCONF, bd.XDSCNT, bd.ITPRIC,bd.CountryCode,
    bd.Container#, bd.Sub_product, bd.Product,
    CASE
        WHEN ct.ContainerType = 'None-Mixed' THEN bd.Product
        ELSE ct.ContainerType
    END AS Cont_Categories,
    ct.ContainerType
FROM
    BaseData bd
    LEFT JOIN ContainerTypes ct ON bd.Container# = ct.Container#
ORDER BY
    bd.INIVDT, bd.XNTRPN


"""

# 使用 pandas 读取数据
df = pd.read_sql(query, cnxn)

# 显示查询结果
print(df)

# 获取当前日期和时间
current_time = datetime.now().strftime('%Y%m%d_%H%M%S')

# 生成带日期时间的文件名
filename = f'AshtonShipped_{current_time}.xlsx'

# 保存到当前目录的 Excel 文件
df.to_excel(filename, index=False, engine='openpyxl')
print(f"Data has been successfully saved to '{filename}'.")

# # 保存到当前目录的 Excel 文件
# df.to_excel('AshtonShipped.xlsx', index=False, engine='openpyxl')

# 关闭连接
cnxn.close()
