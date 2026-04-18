# -*- coding: UTF-8 -*-
# 代码示例（拆分近3天，每天一个线程拉数据）
import pandas as pd
import pyodbc
from concurrent.futures import ThreadPoolExecutor, as_completed
from datetime import datetime, timedelta

DSN = 'MILPROD'
PWD = 'MJ2080'

# 原SQL中的时间条件替换为变量 {date_start} 和 {date_end}，方便多线程调用
SQL_TEMPLATE = """
SELECT t1.HOUSE,t1.TCODE,t1.ORDNO,TRIM(t1.ITNBR) ITNBR,t2.ITCLS, t1.UPDDT,t1.UPDTM,t1.TRQTY,t1.ENTUM,t1.VNDNR,t1.REFNO,t1.LLOCN,t1.BATCH,t1.TRMID,
CHAR(t1.UPDDT||' '||right('000000'||ltrim(t1.UPDTM),6)) AS "TrxTime"
FROM AMFLIBL.IMHIST  t1, AMFLIBL.ITMRVA t2, AMFLIBL.WHSMST t3
WHERE t1.ITNBR=t2.ITNBR  
AND t2.STID = t3.STID 
AND t1.HOUSE = t3.WHID 
AND t1.TRQTY > 0 
AND t1.TCODE IN ('RP','RM','PQ') 
AND CHAR(t1.UPDDT||' '||right('000000'||ltrim(t1.UPDTM),6)) 
    BETWEEN '{date_start}' AND '{date_end}'
AND t2.ITCLS NOT LIKE 'Z%'
"""

def fetch_data_for_period(date_start_str, date_end_str):
    conn = pyodbc.connect(f'DSN={DSN};PWD={PWD}', autocommit=True)
    sql = SQL_TEMPLATE.format(date_start=date_start_str, date_end=date_end_str)
    try:
        df = pd.read_sql(sql, conn)
    except Exception as e:
        print(f"Error fetching data from {date_start_str} to {date_end_str}: {e}")
        df = pd.DataFrame()  # 返回空DataFrame避免影响主流程
    finally:
        conn.close()
    return df

def main():
    # 定义拆分的时间区间（字符串格式需和SQL里CHAR格式对应）
    # 你的原SQL时间格式大概是类似 '1yymmdd hh24:mi:ss'，需要生成对应格式
    # 例如今天是 2025-05-22，拆分3天：20,21,22号的时间段

    base_date = datetime.now().date()
    periods = []
    for i in range(2, -1, -1):  # 2天前，到今天
        day_start = base_date - timedelta(days=i)
        day_start_str = '1' + day_start.strftime('%y%m%d') + ' 00:00:00'
        day_end_str = '1' + day_start.strftime('%y%m%d') + ' 23:59:59'
        periods.append( (day_start_str, day_end_str) )

    dfs = []
    with ThreadPoolExecutor(max_workers=3) as executor:
        futures = [executor.submit(fetch_data_for_period, start, end) for start, end in periods]
        for future in as_completed(futures):
            df_part = future.result()
            if not df_part.empty:
                dfs.append(df_part)

    if dfs:
        full_df = pd.concat(dfs, ignore_index=True)
    else:
        full_df = pd.DataFrame()

    # 保存文件
    full_df.to_csv(r'd:\Python_file\MIL_RM_Received_multithread.csv', index=False, encoding='utf-8-sig')
    print(f"导出完成，共 {len(full_df)} 条记录。")

if __name__ == '__main__':
    main()
