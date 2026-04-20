import pyodbc as po
import pandas as pd
import os
import time
from datetime import datetime
import win32com.client as win32

def fetch_data(query, connection_string='DSN=MILPROD;UID=JIMSHEN;PWD=MJ2083'):
    """从数据库获取数据"""
    try:
        cnxn = po.connect(connection_string, autocommit=True)
        df = pd.read_sql(query, cnxn)
        cnxn.close()
        return df
    except Exception as e:
        print(f"数据获取过程中发生错误: {str(e)}")
        raise


def save_file(data, file_path):
    """保存并格式化Excel文件"""
    try:
        # 先保存数据
        data.to_csv(file_path, index=False)
    except Exception as e:
        print(f"保存Excel文件过程中发生错误: {str(e)}")
        raise

def main():
    start_time = time.time()

    # SQL查询
    query = """
    
-- MIL Container Utilization Details report created on Jun.26.2023 by Jimshen
-- updated item class on Aug.15.2024 by Jim,Shen
-- Aug.15.2024 updated verona and tiking belong to zipcover by bob's requirement on Aug.15.2024 

SELECT WCHBUILDING, WCIORIGIN,CONTAINER#,CUBES,ITCLS,PRODUCT,WCIDESTINATION,WCIORDER,ITEMNUMBER,QTY,WCILASTMAINTENANCETIMESTAMP,CONTAINERNUMBER,DISTINCTCONTAINER,
WCILASTMAINTENANCEUSER,ITMCQTY,UNITCUBE,UNITWEIGHT,CARTONS,CONTAINERTYPE,Date,WCHCONTAINERSIZE,Y2.ShiftDate,Y2.Shift,
(case 
	when trim(substr(WCHCONTAINERSIZE,1,2)) = '53' then CUBES/3831
	when trim(substr(WCHCONTAINERSIZE,1,2)) = '50' then CUBES/3333
	when trim(substr(WCHCONTAINERSIZE,1,3)) = '40H' then CUBES/2650
	when trim(substr(WCHCONTAINERSIZE,1,3)) = '40' then CUBES/2383
	when trim(substr(WCHCONTAINERSIZE,1,3)) = '45' then CUBES/3058
	when substr(WCHCONTAINERSIZE,1,1) = '2' then CUBES/1191
	ELSE CUBES/2650 END) AS Utilization

FROM
(SELECT s1.ContainerNumber,s1.WCIORIGIN,s1.WCIDESTINATION,s1.WCIORDER,s1.ItemNumber,s1.Qty,s1.WCILASTMAINTENANCETIMESTAMP,s1.WCILASTMAINTENANCEUSER,s1.ITMCQTY,
s1.itcls,s1.UnitCube,s1.UnitWeight,s1.Cubes,s1.Cartons,s1.Product,s2.ContainerType,to_char(s1.WCILASTMAINTENANCETIMESTAMP,'yyyy-mm-dd') as Date, 
s2.Container#
FROM 
((SELECT trim(a.WCICONTAINERNUMBER) as ContainerNumber, a.WCIORIGIN, a.WCIDESTINATION, a.WCIORDER, trim(a.WCIITEMNUMBER) as ItemNumber, a.WCIQUANTITYLOADED as Qty, 
a.WCILASTMAINTENANCETIMESTAMP, a.WCILASTMAINTENANCEUSER, b.ITMCQTY, c.itcls,c.B2Z95S as UnitCube, c.WEGHT as UnitWeight, a.WCIQUANTITYLOADED*c.B2Z95S as Cubes,
CEIL(a.WCIQUANTITYLOADED/b.ITMCQTY) as Cartons,
trim(a.WCIORIGIN)||'-'|| trim(a.WCICONTAINERNUMBER)||'-'||trim(a.WCIDESTINATION) as Container#,
(CASE 
        WHEN c.ITCLS like 'TAF%' THEN 'RP'
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
        ELSE 'Check' END) AS Product
FROM DISTLIBL.TBL_WVCONTAINER_DTL_ITM as a, AFILELIBL.ITMEXT as b, AMFLIBL.ITMRVA as c 
WHERE (a.WCIITEMNUMBER = b.itnbr) and a.WCIITEMNUMBER = c.itnbr and a.WCIORIGIN = c.STID and a.WCIORIGIN in('51')  
and  a.WCILASTMAINTENANCETIMESTAMP  between char(current date - 30 days) and char(current DATE)  
Order by a.WCICONTAINERNUMBER, a.WCIORIGIN, a.WCILASTMAINTENANCETIMESTAMP, a.WCIDESTINATION)

union all

(SELECT trim(a.WCICONTAINERNUMBER) as ContainerNumber, a.WCIORIGIN, a.WCIDESTINATION, a.WCIORDER, trim(a.WCIITEMNUMBER) as ItemNumber, a.WCIQUANTITYLOADED as Qty, 
a.WCILASTMAINTENANCETIMESTAMP, a.WCILASTMAINTENANCEUSER, b.ITMCQTY, c.itcls,c.B2Z95S as UnitCube, c.WEGHT as UnitWeight, a.WCIQUANTITYLOADED*c.B2Z95S as Cubes,
CEIL(a.WCIQUANTITYLOADED/b.ITMCQTY) as Cartons,
trim(a.WCIORIGIN)||'-'|| trim(a.WCICONTAINERNUMBER)||'-'||trim(a.WCIDESTINATION)||'-'||SUBSTR(char(a.WCIARCHIVETIMESTAMP),1,13) as Container#,
(CASE 
        WHEN c.ITCLS like 'TAF%' THEN 'RP'
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
        ELSE 'Check' END) AS Product
FROM ASHLEYARCL.WVCNTIDA as a, AFILELIBL.ITMEXT as b, AMFLIBL.ITMRVA as c
WHERE (a.WCIITEMNUMBER = b.itnbr) and a.WCIITEMNUMBER = c.itnbr and a.WCIORIGIN = c.STID and a.WCIORIGIN in('51') and a.WCILASTMAINTENANCETIMESTAMP  
between char(current date - 30 days) and char(current DATE) 
Order by a.WCICONTAINERNUMBER, a.WCIORIGIN, a.WCILASTMAINTENANCETIMESTAMP, a.WCIDESTINATION)) as s1,

-- TABLE.S2 to judge container type (combined or non-conbined)
(SELECT Container#,(case when count(Distinct PRODUCT)=1 then 'None-Mixed'  else 'Mixed' end) as ContainerType
FROM 
((SELECT trim(a.WCICONTAINERNUMBER) as ContainerNumber, a.WCIORIGIN, a.WCIDESTINATION, a.WCIORDER, trim(a.WCIITEMNUMBER) as ItemNumber, a.WCIQUANTITYLOADED as Qty, 
a.WCILASTMAINTENANCETIMESTAMP, a.WCILASTMAINTENANCEUSER, b.ITMCQTY, c.itcls,c.B2Z95S as UnitCube, c.WEGHT as UnitWeight, a.WCIQUANTITYLOADED*c.B2Z95S as Cubes,
CEIL(a.WCIQUANTITYLOADED/b.ITMCQTY) as Cartons,
trim(a.WCIORIGIN)||'-'|| trim(a.WCICONTAINERNUMBER)||'-'||trim(a.WCIDESTINATION) as Container#,
(CASE 
        WHEN c.ITCLS like 'TAF%' THEN 'RP'
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
        ELSE 'Check' END) AS Product
FROM DISTLIBL.TBL_WVCONTAINER_DTL_ITM as a, AFILELIBL.ITMEXT as b, AMFLIBL.ITMRVA as c
WHERE (a.WCIITEMNUMBER = b.itnbr) and a.WCIITEMNUMBER = c.itnbr and a.WCIORIGIN = c.STID and a.WCIORIGIN in('51')  
and  a.WCILASTMAINTENANCETIMESTAMP BETWEEN char(current date - 30 days) and char(current DATE) 
Order by a.WCICONTAINERNUMBER, a.WCIORIGIN, a.WCILASTMAINTENANCETIMESTAMP, a.WCIDESTINATION)

union all

(SELECT trim(a.WCICONTAINERNUMBER) as ContainerNumber, a.WCIORIGIN, a.WCIDESTINATION, a.WCIORDER, trim(a.WCIITEMNUMBER) as ItemNumber, a.WCIQUANTITYLOADED as Qty, 
a.WCILASTMAINTENANCETIMESTAMP, a.WCILASTMAINTENANCEUSER, b.ITMCQTY, c.itcls,c.B2Z95S as UnitCube, c.WEGHT as UnitWeight, a.WCIQUANTITYLOADED*c.B2Z95S as Cubes,
CEIL(a.WCIQUANTITYLOADED/b.ITMCQTY) as Cartons,
trim(a.WCIORIGIN)||'-'|| trim(a.WCICONTAINERNUMBER)||'-'||trim(a.WCIDESTINATION)||'-'||SUBSTR(char(a.WCIARCHIVETIMESTAMP),1,13) as Container#,
(CASE 
        WHEN c.ITCLS like 'TAF%' THEN 'RP'
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
        ELSE 'Check' END) AS Product
FROM ASHLEYARCL.WVCNTIDA as a, AFILELIBL.ITMEXT as b, AMFLIBL.ITMRVA as c
WHERE (a.WCIITEMNUMBER = b.itnbr) and a.WCIITEMNUMBER = c.itnbr and a.WCIORIGIN = c.STID and a.WCIORIGIN in('51') and a.WCILASTMAINTENANCETIMESTAMP 
between char(current date - 30 days) and char(current DATE) 
Order by a.WCICONTAINERNUMBER, a.WCIORIGIN, a.WCILASTMAINTENANCETIMESTAMP, a.WCIDESTINATION))
group by WCIORIGIN, Container#
order by Container#) as s2

WHERE s1.Container# = s2.Container#
order by s1.WCIORIGIN,s1.ContainerNumber,s1.WCILASTMAINTENANCETIMESTAMP
) AS Y1
-- TABLE Y1 to get current and archived container loaded details

right join

(Select DISTINCT(x1.Container#) as DistinctContainer,WCHCONTAINERSIZE, ShiftDate, Shift, WCHBUILDING

FROM
(SELECT 
a.WCHCONTAINERNUMBER,a.WCHORIGIN,a.WCHDESTINATION,a.WCHCONTAINERSTATUS,a.WCHTOTALCARTONS,a.WCHTOTALCUBES,a.WCHPOSTEDTIMESTAMP,a.WCHTOTALWEIGHT,
a.WCHCONTAINERSIZE, a.WCHBUILDING, 
trim(a.WCHORIGIN)||'-'|| trim(a.WCHCONTAINERNUMBER)||'-'||trim(a.WCHDESTINATION) as Container#,
 CASE
        WHEN a.WCHPOSTEDTIMESTAMP >= TIMESTAMP_FORMAT(TO_CHAR(a.WCHPOSTEDTIMESTAMP, 'YYYY-MM-DD') || ' 07:00:00', 'YYYY-MM-DD HH24:MI:SS')
             AND a.WCHPOSTEDTIMESTAMP < TIMESTAMP_FORMAT(TO_CHAR(a.WCHPOSTEDTIMESTAMP + 1 DAY, 'YYYY-MM-DD') || ' 07:00:00', 'YYYY-MM-DD HH24:MI:SS')
        THEN to_char(a.WCHPOSTEDTIMESTAMP,'yyyy-mm-dd')
        ELSE to_char(DATE(a.WCHPOSTEDTIMESTAMP) - 1 DAY,'yyyy-mm-dd') 
    END AS ShiftDate,
 CASE
        WHEN a.WCHPOSTEDTIMESTAMP >= TIMESTAMP_FORMAT(TO_CHAR(a.WCHPOSTEDTIMESTAMP, 'YYYY-MM-DD') || ' 07:00:00', 'YYYY-MM-DD HH24:MI:SS')
             AND a.WCHPOSTEDTIMESTAMP < TIMESTAMP_FORMAT(TO_CHAR(a.WCHPOSTEDTIMESTAMP,'YYYY-MM-DD') || ' 19:00:00', 'YYYY-MM-DD HH24:MI:SS')
        THEN 'DS'
        ELSE 'NS'
    END AS Shift

FROM  DISTLIBL.TBL_WVCONTAINER_HDR a
WHERE a.WCHCONTAINERSTATUS in ('P','T') AND a.WCHORIGIN IN ('51')  AND a.WCHPOSTEDTIMESTAMP BETWEEN char(current date - 15 days) and char(current DATE) 
and a.WCHCONTAINERNUMBER NOT LIKE '%AIR%' AND substr(trim(a.WCHCONTAINERNUMBER),1,4) 
NOT IN ('AAAR','AIIR','AAIR','AIRR','AIR_','AIR1','AAII','ARRR') AND a.WCHDESTINATION NOT IN ('001')

union all

SELECT  a.WCHCONTAINERNUMBER,a.WCHORIGIN,a.WCHDESTINATION,a.WCHCONTAINERSTATUS,a.WCHTOTALCARTONS,a.WCHTOTALCUBES,a.WCHPOSTEDTIMESTAMP,a.WCHTOTALWEIGHT,a.WCHCONTAINERSIZE,a.WCHBUILDING, 
trim(a.WCHORIGIN)||'-'|| trim(a.WCHCONTAINERNUMBER)||'-'||trim(a.WCHDESTINATION)||'-'||SUBSTR(char(a.WCHARCHIVETIMESTAMP),1,13) as Container#,
 CASE
        WHEN a.WCHPOSTEDTIMESTAMP >= TIMESTAMP_FORMAT(TO_CHAR(a.WCHPOSTEDTIMESTAMP, 'YYYY-MM-DD') || ' 07:00:00', 'YYYY-MM-DD HH24:MI:SS')
             AND a.WCHPOSTEDTIMESTAMP < TIMESTAMP_FORMAT(TO_CHAR(a.WCHPOSTEDTIMESTAMP + 1 DAY, 'YYYY-MM-DD') || ' 07:00:00', 'YYYY-MM-DD HH24:MI:SS')
        THEN to_char(a.WCHPOSTEDTIMESTAMP,'yyyy-mm-dd')
        ELSE to_char(DATE(a.WCHPOSTEDTIMESTAMP) - 1 DAY,'yyyy-mm-dd') 
    END AS ShiftDate,
 CASE
        WHEN a.WCHPOSTEDTIMESTAMP >= TIMESTAMP_FORMAT(TO_CHAR(a.WCHPOSTEDTIMESTAMP, 'YYYY-MM-DD') || ' 07:00:00', 'YYYY-MM-DD HH24:MI:SS')
             AND a.WCHPOSTEDTIMESTAMP < TIMESTAMP_FORMAT(TO_CHAR(a.WCHPOSTEDTIMESTAMP, 'YYYY-MM-DD') || ' 19:00:00', 'YYYY-MM-DD HH24:MI:SS')
        THEN 'DS'
        ELSE 'NS'
    END AS Shift
FROM  ASHLEYARCL.WVCNTHDA a
WHERE a.WCHCONTAINERSTATUS in ('P','T') AND a.WCHPOSTEDTIMESTAMP BETWEEN char(current date - 15 days) and char(current DATE)  and a.WCHORIGIN in ('51') 
and a.WCHCONTAINERNUMBER NOT LIKE '%AIR%'  AND substr(trim(a.WCHCONTAINERNUMBER),1,4) 
NOT IN ('AAAR','AIIR','AAIR','AIRR','AIR_','AIR1','AAII','ARRR') AND a.WCHDESTINATION NOT IN ('001')) as x1) as Y2
ON Y1.Container# = Y2.DistinctContainer
WHERE Y1.PRODUCT NOT IN ('CG', 'Bedding')

        
    """

    # 生成文件名和路径
    current_time = datetime.now().strftime('%Y%m%d_%H%M%S')
    file_name = f'mil_query_{current_time}.csv'
    file_path = os.path.join(r'C:\Users\jishen\Downloads', file_name)

    try:
        print("正在获取数据...")
        df = fetch_data(query)
        print(f"成功获取 {len(df)} 行数据")

        # 如果只想显示部分数据，可以用：
        print(df.head(10))  # 显示前10行

        print("正在保存和格式化Excel文件...")
        save_file(df, file_path)

        print(f"csv文件已成功保存到: {file_path}")

    except Exception as e:
        print(f"程序执行过程中发生错误: {str(e)}")
        raise
    finally:
        execution_time = time.time() - start_time
        print(f"\n程序总运行时间：{execution_time:.2f} 秒")


if __name__ == '__main__':
    main()
