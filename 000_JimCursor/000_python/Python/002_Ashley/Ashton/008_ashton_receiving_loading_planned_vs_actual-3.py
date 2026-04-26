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
    SELECT T1.*, VARCHAR(T1.AASER#) AS SN 
    FROM (
        SELECT * FROM DISTLIB.ACTAUDT
        WHERE AAADAT BETWEEN 20250101 AND 20250426 
          AND AAFWHS = '335'
          AND AACOD1 = 'BT'
        ORDER BY AAITM#, AAADAT, AAATIM 
        FETCH FIRST 1000 ROWS ONLY
    ) T1
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
