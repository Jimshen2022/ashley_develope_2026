import pandas as pd
import pyodbc
from datetime import datetime
import time
import warnings

warnings.filterwarnings('ignore', category=UserWarning, message='.*pandas only supports SQLAlchemy.*')

def parse_iseries_date(val):
    if pd.isna(val):
        return pd.NaT
    
    s = str(val).strip()
    
    # 非常关键：Pandas 经常把数字读成 float，比如 1250101 会变成 "1250101.0"
    # 如果不把 ".0" 去掉，长度就是 9，会导致后续的日期解析全部失败！
    if s.endswith('.0'):
        s = s[:-2]
        
    if not s or s == 'None' or s == '0':
        return pd.NaT
        
    try:
        if len(s) == 7:
            century = int(s[0])
            year = (century * 100) + 1900 + int(s[1:3])
            month = int(s[3:5])
            day = int(s[5:7])
            return datetime(year, month, day).date()
        elif len(s) == 8:
            return datetime.strptime(s, '%Y%m%d').date()
        else:
            return pd.NaT
    except Exception:
        return pd.NaT

def run(dfs, file_path):
    print("Executing a05_pull_out_open_po...")
    start_time = time.time()

    # 直接使用你测试成功的 DSN 和账密配置
    conn_str = 'DSN=AFIPROD;UID=JIMSHEN;PWD=MJ2090'
    print(f"Using ODBC Connection: DSN=AFIPROD;UID=JIMSHEN;PWD=******")
    
    try:
        # 添加 autocommit=True，与你的测试脚本保持完全一致
        conn = pyodbc.connect(conn_str, autocommit=True)
    except Exception as e:
        print(f"Database connection failed: {e}")
        return

    sql_case_product = """
    CASE WHEN T1.ITCLS NOT LIKE 'Z%' THEN 'RP' 
         WHEN T1.ITNBR LIKE '100-%' THEN 'CG' 
         WHEN SUBSTR(TRIM(T1.ITNBR),1,1) IN ('1','2','3','4','5','6','7','8','9','U') THEN 'UPH' 
         WHEN SUBSTR(TRIM(T1.ITNBR),1,1) IN ('A') AND T1.Unit_CBM >= 0.3 THEN 'CG' 
         WHEN SUBSTR(TRIM(T1.ITNBR),1,1) IN ('A','L','R','Q') THEN 'ACCESSORY' 
         WHEN LENGTH(TRIM(t1.ITNBR)) = 6 AND SUBSTR(TRIM(T1.ITNBR),1,1) ='M' THEN 'ACCESSORY' 
         ELSE 'CG' END
    """

    sql_case_status = """
    CASE WHEN T1.PSTTS IN ('20') THEN 'On-Order: New ASN Pending by Vendor' 
         WHEN T1.PSTTS IN ('10') THEN 'Cfd Required' 
         WHEN T1.PSTTS IN ('30') THEN 'In-Transit: New ASN Accepted by Buyer' 
         WHEN T1.PSTTS IN ('40') THEN 'Rc. to Stk: PO is in Receipt To Stock Status' 
         WHEN T1.PSTTS IN ('50') THEN 'Receiver: PO is in Receiver Status' 
         ELSE 'Check' END
    """

    query = f"""
    SELECT t1.ORDNO, TRIM(t1.ITNBR) AS ITNBR, t1.HOUSE, T1.ITCLS, T1.DUEDT, T1.VNDNR, T1.PSTTS, t3.VNDRVM, t3.VNNMVM, T1.ITDSC, T1.Unit_CBM, 
           {sql_case_product} AS PRODUCT, 
           {sql_case_status} AS PO_STATUS, 
           SUM(t1.QTYOR) as Open_PO, CAST(SUM(T1.Product_CBM) AS DECIMAL(10,2)) AS Product_CBM 
    FROM (
        SELECT t1.ORDNO, t1.ITNBR, t1.HOUSE, t1.ITCLS, t1.DUEDT, t1.VNDNR, T2.PSTTS, T1.QTYOR, T1.ITDSC, 
               CAST(T3.B2Z95S*0.028317 AS DECIMAL(10,2)) AS Unit_CBM, 
               T3.B2Z95S*0.028317*T1.QTYOR AS Product_CBM 
        FROM AMFLIBA.POITEM t1, AMFLIBA.POMAST t2, AMFLIBA.ITMRVA AS T3 
        WHERE t1.ORDNO = t2.ORDNO AND t2.HOUSE = t1.HOUSE AND t1.ITNBR = T3.ITNBR AND T1.HOUSE = T3.STID 
        AND (t1.HOUSE='335') AND T2.PSTTS IN ('20','30') AND t1.DUEDT >= '1250101'
    ) AS T1 
    LEFT JOIN AMFLIBA.VENNAML0 t3 on t1.VNDNR=t3.VNDRVM 
    GROUP BY t1.ORDNO, TRIM(t1.ITNBR), t1.HOUSE, T1.ITCLS, T1.DUEDT, T1.VNDNR, T1.PSTTS, t3.VNDRVM, t3.VNNMVM, T1.ITDSC, T1.Unit_CBM, 
             {sql_case_product}, {sql_case_status}
    
    UNION ALL 
    
    SELECT t1.ORDNO, TRIM(t1.ITNBR) AS ITNBR, t1.HOUSE, T1.ITCLS, T1.DUEDT, T1.VNDNR, T1.PSTTS, t3.VNDRVM, t3.VNNMVM, T1.ITDSC, T1.Unit_CBM, 
           {sql_case_product} AS PRODUCT, 
           {sql_case_status} AS PO_STATUS, 
           SUM(t1.QTYOR) as Open_PO, CAST(SUM(T1.Product_CBM) AS DECIMAL(10,2)) AS Product_CBM 
    FROM (
        SELECT t1.ORDNO, t1.ITNBR, t1.HOUSE, t1.ITCLS, t1.DUEDT, t1.VNDNR, T2.PSTTS, T1.QTYOR, T1.ITDSC, 
               CAST(T3.B2Z95S*0.028317 AS DECIMAL(10,2)) AS Unit_CBM, 
               T3.B2Z95S*0.028317*T1.QTYOR AS Product_CBM 
        FROM AMFLIBH.POITEM t1, AMFLIBH.POMAST t2, AMFLIBA.ITMRVA AS T3 
        WHERE t1.ORDNO = t2.ORDNO AND t2.HOUSE = t1.HOUSE AND t1.ITNBR = T3.ITNBR AND T1.HOUSE = T3.STID 
        AND (t1.HOUSE='335') AND T2.PSTTS IN ('10','20','30') AND t1.DUEDT >= '1250101'
    ) AS T1 
    LEFT JOIN AMFLIBA.VENNAML0 t3 on t1.VNDNR=t3.VNDRVM 
    GROUP BY t1.ORDNO, TRIM(t1.ITNBR), t1.HOUSE, T1.ITCLS, T1.DUEDT, T1.VNDNR, T1.PSTTS, t3.VNDRVM, t3.VNNMVM, T1.ITDSC, T1.Unit_CBM, 
             {sql_case_product}, {sql_case_status}
    """

    print("Executing SQL query... This might take a moment.")
    try:
        df = pd.read_sql(query, conn)
    except Exception as e:
        print(f"Error executing SQL query: {e}")
        conn.close()
        return
    finally:
        conn.close()

    if len(df.columns) >= 6:
        string_cols = df.columns[0:6]
        for col in string_cols:
            df[col] = df[col].astype(str)
            
    if 'DUEDT' in df.columns:
        df['DUEDT'] = df['DUEDT'].apply(parse_iseries_date)

    dfs['OpenPO'] = df

    elapsed_time = time.time() - start_time
    print(f"a05_pull_out_open_po completed in {elapsed_time:.2f} seconds.")
