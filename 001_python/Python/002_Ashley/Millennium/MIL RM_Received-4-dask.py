# -*- coding: UTF-8 -*-
# 使用 Dask 实现多线程数据库查询
import pandas as pd
import pyodbc
import dask
from dask import delayed
from dask.distributed import Client
from datetime import datetime, timedelta
import time

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


@delayed
def fetch_data_for_period(date_start_str, date_end_str):
    conn = pyodbc.connect(f'DSN={DSN};PWD={PWD}', autocommit=True)
    sql = SQL_TEMPLATE.format(date_start=date_start_str, date_end=date_end_str)
    try:
        df = pd.read_sql(sql, conn)
        print(f"Successfully fetched {len(df)} records from {date_start_str} to {date_end_str}")
    except Exception as e:
        print(f"Error fetching data from {date_start_str} to {date_end_str}: {e}")
        df = pd.DataFrame()  # 返回空DataFrame避免影响主流程
    finally:
        conn.close()
    return df


def main():
    # 记录开始时间
    start_time = time.time()
    start_datetime = datetime.now().strftime('%Y-%m-%d %H:%M:%S')

    # 创建 Dask 客户端，使用线程池调度器，设置12个线程（匹配逻辑核心数）
    # 你的CPU: 10物理核心，12逻辑核心
    client = Client(processes=False, threads_per_worker=1, n_workers=12)
    print(f"Dask dashboard: {client.dashboard_link}")

    try:
        # 定义拆分的时间区间（字符串格式需和SQL里CHAR格式对应）
        # 你的原SQL时间格式大概是类似 '1yymmdd hh24:mi:ss'，需要生成对应格式
        # 抓取过去60天的数据，每天一个线程

        base_date = datetime.now().date()
        periods = []
        for i in range(59, -1, -1):  # 从59天前到今天（共60天）
            day_start = base_date - timedelta(days=i)
            day_start_str = '1' + day_start.strftime('%y%m%d') + ' 00:00:00'
            day_end_str = '1' + day_start.strftime('%y%m%d') + ' 23:59:59'
            periods.append((day_start_str, day_end_str))

        # 创建延迟计算任务
        delayed_tasks = [fetch_data_for_period(start, end) for start, end in periods]

        # 并行执行任务并获取结果
        print(f"开始并行查询数据...（过去60天，共{len(periods)}个时间段）")
        results = dask.compute(*delayed_tasks)

        # 过滤掉空的DataFrame
        dfs = [df for df in results if not df.empty]

        if dfs:
            full_df = pd.concat(dfs, ignore_index=True)
        else:
            full_df = pd.DataFrame()

        # 计算运行时间
        end_time = time.time()
        end_datetime = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
        elapsed_time = end_time - start_time

        # 准备运行时间信息行
        runtime_info = {
            'HOUSE': f'程序开始时间: {start_datetime}',
            'TCODE': f'程序结束时间: {end_datetime}',
            'ORDNO': f'总运行时间: {elapsed_time:.2f}秒',
            'ITNBR': f'总记录数: {len(full_df)}',
            'ITCLS': 'Dask多线程查询',
            'UPDDT': '',
            'UPDTM': '',
            'TRQTY': '',
            'ENTUM': '',
            'VNDNR': '',
            'REFNO': '',
            'LLOCN': '',
            'BATCH': '',
            'TRMID': '',
            'TrxTime': ''
        }

        # 如果有数据，在第一行插入运行时间信息
        if not full_df.empty:
            runtime_df = pd.DataFrame([runtime_info])
            full_df = pd.concat([runtime_df, full_df], ignore_index=True)
        else:
            # 如果没有数据，也要创建包含运行时间信息的DataFrame
            full_df = pd.DataFrame([runtime_info])

        # 保存文件
        full_df.to_csv(r'd:\Python_file\MIL_RM_Received_dask.csv', index=False, encoding='utf-8-sig')
        print(f"导出完成，共 {len(full_df) - 1} 条数据记录（不含时间信息行）。")
        print(f"程序总运行时间: {elapsed_time:.2f}秒")

    finally:
        # 关闭客户端
        client.close()


if __name__ == '__main__':
    main()