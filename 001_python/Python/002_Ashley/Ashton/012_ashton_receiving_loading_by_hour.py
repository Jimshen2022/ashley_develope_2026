import pyodbc as po
import pandas as pd
import os
import time
from datetime import datetime
import subprocess
import csv


def fetch_data(query, connection_string='DSN=AFIPROD;UID=JIMSHEN;PWD=MJ2080'):
    """从数据库获取数据"""
    try:
        cnxn = po.connect(connection_string)
        df = pd.read_sql(query, cnxn)
        cnxn.close()
        return df
    except Exception as e:
        print(f"数据获取过程中发生错误: {str(e)}")
        raise


def process_data(df):
    """处理数据，确保特定列是纯文本格式"""
    try:
        def clean_column(col):
            return col.astype(str) \
                .str.replace(r'\..*', '', regex=True) \
                .str.strip()

        for col in ['AASER#', 'AAITM#', 'SN']:
            if col in df.columns:
                df[col] = clean_column(df[col])

        return df
    except Exception as e:
        print(f"数据处理过程中发生错误: {str(e)}")
        raise


def save_csv_with_text_columns(data, file_path, text_columns=None):
    """保存CSV文件，确保指定列作为文本处理"""
    if text_columns is None:
        text_columns = ['AASER#', 'AAITM#', 'SN']

    try:
        # 确保文件路径以.csv结尾
        if not file_path.endswith('.csv'):
            file_path = file_path.rsplit('.', 1)[0] + '.csv'

        abs_path = os.path.abspath(file_path)

        # 创建一个具有特定格式的CSV文件
        with open(abs_path, 'w', newline='') as f:
            # 写入标题行
            writer = csv.writer(f, quoting=csv.QUOTE_ALL)
            writer.writerow(data.columns)

            # 写入数据行
            for index, row in data.iterrows():
                # 将行数据转换为列表
                row_list = []
                for col in data.columns:
                    value = row[col]
                    # 对于指定为"文本"的列，添加TAB前缀，Excel会将其识别为文本
                    if col in text_columns:
                        # 再次去除首尾空格
                        value = str(value).strip()
                        # 添加制表符前缀，强制Excel将其视为文本
                        row_list.append(f"\t{value}")
                    else:
                        row_list.append(value)
                writer.writerow(row_list)

        print(f"CSV文件已保存到: {abs_path}")
        return abs_path
    except Exception as e:
        print(f"保存CSV文件过程中发生错误: {str(e)}")
        raise


def open_file(file_path):
    """打开文件"""
    try:
        # 使用默认程序(Excel)打开CSV文件
        try:
            os.startfile(file_path)  # Windows系统
            print("已在Excel中打开CSV文件")
        except AttributeError:
            # 对于非Windows系统的替代方法
            subprocess.call(['open', file_path])  # macOS
            print("已尝试打开CSV文件")
    except Exception as e:
        print(f"打开文件时发生错误: {str(e)}")
        raise


def main():
    start_time = time.time()

    # SQL查询
    query = """
WITH i AS (
    SELECT
        t4.ITNBR,
        t4.STID,
        t2.MOHTQ,
        t2.PLREQ AS Demand,
        t2.DOFLS AS date_of_last_sales,
        t2.LDQOH AS Last_date_affecting_onhand,
        t2.WHSLC,
        t2.ITCLS,
        t4.B2Z95S AS UnitCube,
        t4.ITDSC,
        t1.TIHIUNLD,
        t1.PICKPUT,
        t1.ITMCLSID,
        t1.UNITSWIDE,
        t1.UNITLAYERS,
        t1.UNITSDEEP,
        t1.SCOOPQTY,
        t1.SKIDSIZE,
        t3.QTYCR,
        t3.NBSEAT,
        t3.CRTWIN,
        t3.CRTLIN,
        t3.CRTHIN,
        t3.PRDWIN,
        t3.PRDHIN,
        t3.PRDLIN,
        t3.ITMWEGHT,
        CAST(t3.ITMWEGHT * 0.453592 AS DECIMAL(10,2)) AS "Unit_Weight(KG)",
        t2.MPUPQ AS OPEN_PO,
        CASE
            WHEN t2.MOHTQ / NULLIF(t1.SCOOPQTY, 0) <= 1 THEN 1
            ELSE ROUND(t2.MOHTQ / NULLIF(t1.SCOOPQTY, 0))
        END AS PALLETS,
        CAST(t1.SCOOPQTY * t3.ITMWEGHT * 0.453592 AS DECIMAL(10,2)) AS "SCOOP_Weight(KG)"
    FROM (SELECT * FROM AMFLIBA.ITMRVA t WHERE t.STID = '335') AS t4
    LEFT JOIN (SELECT * FROM AMFLIBA.ITEMBL a0 WHERE a0.HOUSE = '335') AS t2
        ON t4.ITNBR = t2.ITNBR AND t4.STID = t2.HOUSE
    LEFT JOIN AFILELIB.ITBEXT t1
        ON t1.ITNBR = t4.ITNBR AND t1.HOUSE = t4.STID
    LEFT JOIN AFILELIB.ITMEXT t3
        ON t3.ITNBR = t4.ITNBR
    WHERE t4.STID = '335'
),
all_data AS (
    SELECT
        t.AATWHS,
        t.AACOD1,
        t.AAITM#,
        CASE
            WHEN i.PICKPUT = 'UPH' THEN 'UPH'
            ELSE 'CG'
        END AS product,
        CASE
            WHEN t.AACOD1 IN ('RP','RC') THEN 'receiving'
        ELSE 'loading' end as tran_type,
        CHAR(t.AASER#) AS SN,
        CASE
            WHEN t.AACOD1 IN ('RC','RP') AND t.AACOD3 IN ('UL') THEN -t.AATQTY
            WHEN t.AACOD1 IN ('BT') AND t.AACOD3 IN ('UL') THEN -t.AATQTY
        ELSE t.AATQTY END AS AATQTY,
        CHAR(t.AAADAT) AS AAADAT,
        RIGHT('000000'||t.AAATIM,6) AS AAATIM,
        TO_DATE(CHAR(t.AAADAT), 'yyyymmdd') AS aaadat_date,
        TO_DATE(CHAR(t.AAADAT) || ' ' || RIGHT('000000' || t.AAATIM, 6), 'yyyymmdd hh24miss') AS date_time,
        TO_DATE(CHAR(t.AAADAT) || ' ' || RIGHT('000000' || t.AAATIM, 6), 'yyyymmdd hh24miss') + 12 HOURS AS vietnam_date_time,
        DATE(
            TO_DATE(CHAR(t.AAADAT) || ' ' || RIGHT('000000' || t.AAATIM, 6), 'yyyymmdd hh24miss') + 12 HOURS
        ) AS vietnam_date
    FROM DISTLIB.ACTAUDT AS t
    LEFT JOIN i ON t.AAITM# = i.ITNBR
    WHERE t.AAADAT BETWEEN INTEGER(TO_CHAR(CURRENT_DATE - 7 DAYS, 'YYYYMMDD'))
                      AND INTEGER(TO_CHAR(CURRENT_DATE + 1 DAYS, 'YYYYMMDD'))
          AND (t.AATWHS = '335' or t.AAFWHS = '335')
          AND (
              (t.AACOD1 = 'RC' AND t.AACOD2 = 'SN') OR
              (t.AACOD1 = 'RP' AND t.AACOD2 = 'IT')
              OR (t.AACOD1 = 'BT' AND t.AACOD2 = 'SN')
          )
)
SELECT
    t1.vietnam_date,
    t1.product,
    t1.tran_type,
    SUBSTR(CHAR(t1.vietnam_date_time), 12, 2) AS hour_part,
    SUM(t1.AATQTY) as Qty
FROM all_data AS t1
LEFT JOIN i ON i.ITNBR = t1.AAITM#
WHERE t1.vietnam_date >= DATE('2025-04-27')
GROUP BY
    t1.vietnam_date,
    t1.product,
    t1.tran_type,
    SUBSTR(CHAR(t1.vietnam_date_time), 12, 2)
ORDER BY t1.vietnam_date, SUBSTR(CHAR(t1.vietnam_date_time), 12, 2)
    """

    # 生成文件名和路径
    current_time = datetime.now().strftime('%Y%m%d_%H%M%S')
    file_name = f'ashton_receiving_loading_planned_vs_actual_{current_time}.csv'
    file_path = os.path.join(r'C:\Users\jishen\Downloads', file_name)

    try:
        print("正在获取数据...")
        df = fetch_data(query)
        print(f"成功获取 {len(df)} 行数据")

        print("正在处理数据...")
        processed_data = process_data(df)

        print("数据已处理完毕，以下数据可在PyCharm的SciView中查看:")
        print(processed_data)

        print("正在保存CSV文件...")
        text_columns = ['AASER#', 'AAITM#', 'SN']
        csv_path = save_csv_with_text_columns(processed_data, file_path, text_columns)

        print("正在打开CSV文件...")
        open_file(csv_path)

        print(f"CSV文件已成功保存到: {csv_path}")

    except Exception as e:
        print(f"程序执行过程中发生错误: {str(e)}")
        raise
    finally:
        execution_time = time.time() - start_time
        print(f"\n程序总运行时间：{execution_time:.2f} 秒")


if __name__ == '__main__':
    main()
