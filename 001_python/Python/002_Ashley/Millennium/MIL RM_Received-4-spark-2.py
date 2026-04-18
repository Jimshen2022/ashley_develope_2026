# main.py
# -*- coding: utf-8 -*-
from pyspark.sql import SparkSession
from pyspark.sql.types import *
from concurrent.futures import ThreadPoolExecutor, as_completed
from datetime import datetime, timedelta
import pandas as pd
import time
import pyodbc

from config import DSN, PWD
from utils import generate_date_periods, get_schema, log
from pathlib import Path

# 读取 SQL 模板
with open("query_template.sql", encoding="utf-8") as f:
    SQL_TEMPLATE = f.read()


def create_spark_session():
    return SparkSession.builder \
        .appName("DatabaseParallelQuery") \
        .config("spark.executor.memory", "4g") \
        .config("spark.driver.memory", "2g") \
        .config("spark.sql.shuffle.partitions", "12") \
        .getOrCreate()


def fetch_data_for_period(date_start_str, date_end_str):
    try:
        conn = pyodbc.connect(f'DSN={DSN};PWD={PWD}', autocommit=True)
        sql = SQL_TEMPLATE.format(date_start=date_start_str, date_end=date_end_str)
        df = pd.read_sql(sql, conn)
        log(f"✔ 成功获取 {date_start_str} 到 {date_end_str} 的 {len(df)} 条记录")
        return df
    except Exception as e:
        log(f"❌ 查询 {date_start_str} 到 {date_end_str} 出错: {e}")
        return pd.DataFrame()


def main():
    start_time = time.time()
    start_datetime = datetime.now().strftime('%Y-%m-%d %H:%M:%S')

    spark = create_spark_session()
    log(f"Spark UI: {spark.sparkContext.uiWebUrl}")

    try:
        periods = generate_date_periods(60)
        pandas_dfs = []

        log("🚀 开始并发查询数据（过去60天）...")

        with ThreadPoolExecutor(max_workers=8) as executor:
            future_to_period = {
                executor.submit(fetch_data_for_period, start, end): (start, end)
                for start, end in periods
            }

            for future in as_completed(future_to_period):
                try:
                    df = future.result()
                    if not df.empty:
                        pandas_dfs.append(df)
                except Exception as exc:
                    log(f"⚠ 异常: {exc}")

        if pandas_dfs:
            combined_pd_df = pd.concat(pandas_dfs, ignore_index=True)
            full_df = spark.createDataFrame(combined_pd_df, schema=get_schema())
        else:
            full_df = spark.createDataFrame([], schema=get_schema())

        end_time = time.time()
        end_datetime = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
        elapsed_time = end_time - start_time

        runtime_info = {
            'HOUSE': f'程序开始时间: {start_datetime}',
            'TCODE': f'程序结束时间: {end_datetime}',
            'ORDNO': f'总运行时间: {elapsed_time:.2f}秒',
            'ITNBR': f'总记录数: {full_df.count()}',
            'ITCLS': 'Spark并发查询',
            'UPDDT': '', 'UPDTM': '', 'TRQTY': '',
            'ENTUM': '', 'VNDNR': '', 'REFNO': '',
            'LLOCN': '', 'BATCH': '', 'TRMID': '',
            'TrxTime': ''
        }

        runtime_df = spark.createDataFrame([runtime_info], schema=get_schema())
        full_df = runtime_df.union(full_df)

        output_path = Path("d:/Python_file/MIL_RM_Received_spark.csv")
        full_df.toPandas().to_csv(output_path, index=False, encoding='utf-8-sig')

        log(f"✅ 导出完成: {output_path}（记录数：{full_df.count() - 1}）")
        log(f"⌛ 总运行时间: {elapsed_time:.2f} 秒")

    finally:
        spark.stop()


if __name__ == '__main__':
    main()
