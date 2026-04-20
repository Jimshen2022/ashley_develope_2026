# -*- coding: UTF-8 -*-
# 使用 Spark 和 pyodbc 实现分布式数据库查询
from pyspark.sql import SparkSession
from pyspark.sql import functions as F
from datetime import datetime, timedelta
import time
import pyodbc
import pandas as pd
from pyspark.sql.types import *

# 数据库连接配置
DSN = 'MILPROD'
PWD = 'MJ2080'

# 原SQL中的时间条件替换为变量 {date_start} 和 {date_end}，方便分区查询
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


# 定义数据结构
def get_schema():
    return StructType([
        StructField("HOUSE", StringType(), True),
        StructField("TCODE", StringType(), True),
        StructField("ORDNO", StringType(), True),
        StructField("ITNBR", StringType(), True),
        StructField("ITCLS", StringType(), True),
        StructField("UPDDT", StringType(), True),
        StructField("UPDTM", StringType(), True),
        StructField("TRQTY", StringType(), True),
        StructField("ENTUM", StringType(), True),
        StructField("VNDNR", StringType(), True),
        StructField("REFNO", StringType(), True),
        StructField("LLOCN", StringType(), True),
        StructField("BATCH", StringType(), True),
        StructField("TRMID", StringType(), True),
        StructField("TrxTime", StringType(), True)
    ])


def create_spark_session():
    """创建 SparkSession 并配置相关参数"""
    return SparkSession.builder \
        .appName("DatabaseParallelQuery") \
        .config("spark.executor.memory", "4g") \
        .config("spark.driver.memory", "2g") \
        .config("spark.sql.shuffle.partitions", "12") \
        .getOrCreate()


def generate_date_periods(days=60):
    """生成日期区间列表，每个区间代表一天"""
    base_date = datetime.now().date()
    periods = []
    for i in range(days - 1, -1, -1):
        day_start = base_date - timedelta(days=i)
        day_start_str = '1' + day_start.strftime('%y%m%d') + ' 00:00:00'
        day_end_str = '1' + day_start.strftime('%y%m%d') + ' 23:59:59'
        periods.append((day_start_str, day_end_str))
    return periods


def fetch_data_for_period(date_start_str, date_end_str):
    """使用 pyodbc 从数据库获取指定时间段的数据"""
    try:
        # 建立数据库连接
        conn = pyodbc.connect(f'DSN={DSN};PWD={PWD}', autocommit=True)
        sql = SQL_TEMPLATE.format(date_start=date_start_str, date_end=date_end_str)

        # 执行查询并获取数据
        df = pd.read_sql(sql, conn)
        print(f"成功获取 {date_start_str} 到 {date_end_str} 的 {len(df)} 条记录")
        return df
    except Exception as e:
        print(f"获取 {date_start_str} 到 {date_end_str} 的数据时出错: {e}")
        return pd.DataFrame()  # 返回空 DataFrame


def main():
    # 记录开始时间
    start_time = time.time()
    start_datetime = datetime.now().strftime('%Y-%m-%d %H:%M:%S')

    # 创建 SparkSession
    spark = create_spark_session()
    print(f"Spark UI: {spark.sparkContext.uiWebUrl}")

    try:
        # 生成日期区间
        periods = generate_date_periods(60)

        # 并行获取各时间段的数据
        print(f"开始并行查询数据...（过去60天，共{len(periods)}个时间段）")

        # 使用 pyodbc 顺序查询各时间段数据
        pandas_dfs = []
        for start, end in periods:
            df = fetch_data_for_period(start, end)
            if not df.empty:
                pandas_dfs.append(df)

        # 合并所有 Pandas DataFrame
        if pandas_dfs:
            combined_pd_df = pd.concat(pandas_dfs, ignore_index=True)

            # 将 Pandas DataFrame 转换为 Spark DataFrame
            full_df = spark.createDataFrame(combined_pd_df, schema=get_schema())
        else:
            # 创建空 Spark DataFrame
            full_df = spark.createDataFrame([], schema=get_schema())

        # 计算运行时间
        end_time = time.time()
        end_datetime = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
        elapsed_time = end_time - start_time

        # 准备运行时间信息行
        runtime_info = {
            'HOUSE': f'程序开始时间: {start_datetime}',
            'TCODE': f'程序结束时间: {end_datetime}',
            'ORDNO': f'总运行时间: {elapsed_time:.2f}秒',
            'ITNBR': f'总记录数: {full_df.count()}',
            'ITCLS': 'Spark分布式查询',
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

        # 将运行时间信息添加到 DataFrame
        runtime_df = spark.createDataFrame([runtime_info], schema=get_schema())
        full_df = runtime_df.union(full_df)

        # 保存文件
        output_path = r'd:\Python_file\MIL_RM_Received_spark.csv'
        full_df.toPandas().to_csv(output_path, index=False, encoding='utf-8-sig')

        print(f"导出完成，共 {full_df.count() - 1} 条数据记录（不含时间信息行）。")
        print(f"程序总运行时间: {elapsed_time:.2f}秒")

    finally:
        # 关闭 SparkSession
        spark.stop()


if __name__ == '__main__':
    main()