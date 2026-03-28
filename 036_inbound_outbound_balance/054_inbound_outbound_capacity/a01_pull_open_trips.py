import pandas as pd
import pyodbc
from datetime import datetime
import time
import warnings

warnings.filterwarnings('ignore', category=UserWarning, message='.*pandas only supports SQLAlchemy.*')

def get_ibm_driver():
    drivers = pyodbc.drivers()
    for d in drivers:
        if 'iSeries Access ODBC Driver' in d:
            return f"{{{d}}}"
    for d in drivers:
        if 'i Access ODBC' in d or 'Client Access ODBC' in d:
            return f"{{{d}}}"
    return '{IBM i Access ODBC Driver}'

def run(dfs, file_path):
    print("Executing a01_Pull_Open_Trips...")
    start_time = time.time()

    # 直接使用测试成功的 DSN 和账密配置
    conn_str = 'DSN=AFIPROD;UID=JIMSHEN;PWD=MJ2090'
    print(f"Using ODBC Connection: DSN=AFIPROD;UID=JIMSHEN;PWD=******")
    
    try:
        conn = pyodbc.connect(conn_str, autocommit=True)
    except Exception as e:
        print(f"Database connection failed: {e}")
        return

    query = """
    WITH itm AS (
      SELECT TRIM(a.itnbr) AS itnbr, a.itcls, b.pickput, b.ITMCLSID, 
      CASE WHEN a.itcls NOT LIKE 'Z%' THEN 'RP' 
           WHEN b.pickput = 'UPH' THEN 'UPH' 
           WHEN b.ITMCLSID = 'RUGS' THEN 'RUGS' 
           WHEN b.ITMCLSID LIKE 'FLO%' THEN 'BULK' 
           ELSE 'CG' END AS product 
      FROM AMFLIBA.ITMRVA AS a 
      LEFT JOIN AFILELIB.ITBEXT AS b 
      ON b.itnbr = a.itnbr AND a.stid = b.house 
      WHERE a.stid = '335' AND a.itcls LIKE 'Z%' AND a.itcls NOT LIKE 'Z%K'
    ),
    dp AS (
      SELECT * FROM AFILELIB.ATOFILE AS T1 WHERE t1.HOUS = '335'
    )
    SELECT a1.HOUSE, a1.ORDNO, a1.SHINS AS "Ship Inst", a1.ITMSQ, a1.ITNBR, a1.ITDSC, a1.ITCLS, 
    a1.CCUSNO, a1.CSHPNO, a1.CUSNM, a1.CUSPO, CHAR(a1.TKNDAT) AS TKNDAT, 
    CHAR(a1.FRZDAT) AS FRZDAT, CHAR(a1.RQSDAT) AS RQSDAT, CHAR(a1.RQIDT) AS RQIDT, 
    CHAR(a1.MFIDT) AS MFIDT, a1.ORDUSR, a1.COQTY, a1.QTYSH, a1.QTYBO, a1.OPEN_CO_QTY, 
    a1.ALC, a1.Product, x1.BDTRP#, x1.BDISEQ, x1.BDITQT, x1.BDITCT, x1.BDITWT, 
    x1.BDREF#, x1.BHCDAT, x1.BHCTIM, x1.BHRDAT, x1.BHLDAT, x1.BHLTIM, a1.Load_Lead_Time, 
    a1.Terms, a1.OrderType1, a1.OrderType2, a1.OrderType3, a1.OrderType4, 
    CASE WHEN d.PLNDDT > 0 THEN VARCHAR_FORMAT(TIMESTAMP_FORMAT(CHAR(d.PLNDDT), 'YYYYMMDD'), 'YYYY-MM-DD') 
         ELSE VARCHAR_FORMAT(TIMESTAMP_FORMAT(CHAR(a1.MFIDT), 'YYYYMMDD'), 'YYYY-MM-DD') END AS Dispatch_Date
    FROM (
      SELECT t1.HOUSE, t1.ORDNO, t1.ITMSQ, t1.ITNBR, t1.ITDSC, t1.ITCLS, t1.CCUSNO, t3.CUSNM, T1.CSHPNO, 
      T1.RQIDT, T1.MFIDT, T1.UNMSR, t4.CUSPO, t4.SHINS, t4.TERMD AS Terms, t4.SHLTC AS Load_Lead_Time, 
      i.product, t2.TKNDAT, t2.FRZDAT, t2.RQSDAT, t2.ORDUSR, t1.COQTY, t1.QTYSH, t1.QTYBO, 
      T1.COQTY-T1.QTYSH AS OPEN_CO_QTY, (CASE WHEN t1.IAFLG=0 THEN 'N' WHEN t1.IAFLG=2 THEN 'Y' ELSE 'Check' END) AS ALC, 
      t2.OTTYP1 AS OrderType1, t2.OTTYP2 AS OrderType2, t2.OTTYP3 AS OrderType3, t2.OTTYP4 AS OrderType4 
      FROM AFILELIB.CODATAN t1 
      INNER JOIN AFILELIB.EXTORD t2 ON t2.XORDNO = t1.ORDNO 
      INNER JOIN AFILELIB.ACUSMASJ t3 ON t3.CUSNO = t1.CCUSNO 
      INNER JOIN AFILELIB.COMAST t4 ON t1.ORDNO = t4.ORDNO 
      LEFT JOIN itm i ON t1.ITNBR = i.ITNBR 
      WHERE t1.house IN ('335') AND t1.COQTY - t1.QTYSH <> 0
    ) AS a1 
    LEFT JOIN (
      SELECT t1.BDTRP#, t1.BDORD#, t1.BDISEQ, t1.BDITM#, t1.BDITMD, t1.BDCUS#, t1.BDITQT, 
      t1.BDITCT, t1.BDITWT, t1.BDREF#, t1.BDCDAT, t1.BDCTIM, t2.BHTRPS, t2.BHCDAT, t2.BHCTIM, t2.BHRDAT, 
      t2.BHLDAT, t2.BHLTIM 
      FROM DISTLIB.BTTRIPD t1, DISTLIB.BTTRIPH t2 
      WHERE t2.BHWHS# IN ('335') AND t2.BHLDAT BETWEEN 0 AND 20261231 AND t2.BHTRPS IN ('A','R','X') 
      AND t1.BDTRP# = t2.BHTRP#
    ) x1 
    ON a1.ORDNO||a1.ITMSQ||a1.ITNBR||a1.CCUSNO = x1.BDORD#||x1.BDISEQ||x1.BDITM#||x1.BDCUS# 
    LEFT JOIN dp d ON x1.BDTRP# = d.TO# 
    ORDER BY a1.MFIDT, x1.BDTRP#, a1.ITNBR, x1.BDISEQ
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

    # Step 4: Data Processing
    date_cols_1 = ['TKNDAT', 'FRZDAT', 'RQSDAT', 'RQIDT', 'MFIDT']
    for col in date_cols_1:
        if col in df.columns:
            df[col] = df[col].astype(str).str.strip()
            df[col] = pd.to_datetime(df[col], format='%Y%m%d', errors='coerce').dt.date

    # Use Python to accurately calculate WeekSaturday instead of relying on AS400 SQL DAYOFWEEK
    if 'MFIDT' in df.columns:
        dt_series = pd.to_datetime(df['MFIDT'], errors='coerce')
        days_to_add = (5 - dt_series.dt.weekday) % 7
        df['WeekSaturday'] = (dt_series + pd.to_timedelta(days_to_add, unit='D')).dt.date

    date_cols_2 = ['Dispatch_Date']
    for col in date_cols_2:
        if col in df.columns:
            df[col] = df[col].astype(str).str.strip()
            df[col] = pd.to_datetime(df[col], format='%Y-%m-%d', errors='coerce').dt.date

    string_cols = df.columns[0:11]
    for col in string_cols:
        df[col] = df[col].astype(str)

    dfs['CustomerOrder'] = df

    elapsed_time = time.time() - start_time
    print(f"a01_Pull_Open_Trips completed in {elapsed_time:.2f} seconds.")