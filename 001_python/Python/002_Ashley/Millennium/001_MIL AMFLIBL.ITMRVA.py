import pyodbc as po
import pandas as pd
import os
import time
from datetime import datetime
import win32com.client as win32


def fetch_data(query, connection_string='DSN=MILPRODBI;UID=JIMSHEN;PWD=MJ2079'):
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
    """处理数据"""
    try:
        # df['ITNBR'] = df['ITNBR'].str.strip()
        # df['COQTY'] = pd.to_numeric(df['COQTY'])
        # df['QTYSH'] = pd.to_numeric(df['QTYSH'])
        # df['QTYBO'] = pd.to_numeric(df['QTYBO'])
        # 将多列同时转换为数值类型
        # df[['COQTY', 'QTYSH', 'QTYBO', 'OPEN_CO_QTY']] = df[['COQTY', 'QTYSH', 'QTYBO', 'OPEN_CO_QTY']].apply(
        #     pd.to_numeric)
        # df['BDTRP#'] = df['BDTRP#'].astype(str)
        # df['OPEN_CO_QTY'] = pd.to_numeric(df['OPEN_CO_QTY'])
        # df['QTSYR'] = pd.to_numeric(df['QTSYR'])
        return df
    except Exception as e:
        print(f"数据处理过程中发生错误: {str(e)}")
        raise


def save_and_format_excel(data, file_path):
    """保存并格式化Excel文件"""
    try:
        # 先保存数据
        data.to_excel(file_path, index=False)

        # 使用win32com格式化
        excel = win32.Dispatch('Excel.Application')
        try:
            excel.Visible = False  # 设置为不可见
            excel.DisplayAlerts = False  # 禁用警告弹窗

            wb = excel.Workbooks.Open(os.path.abspath(file_path))
            ws = wb.ActiveSheet

            # 自动调整列宽
            ws.UsedRange.Columns.AutoFit()

            # 冻结首行
            excel.ActiveWindow.SplitRow = 1
            excel.ActiveWindow.FreezePanes = True

            # 设置标题行格式
            header_range = ws.Range("A1").CurrentRegion.Rows(1)
            header_range.Font.Bold = True
            header_range.Interior.ColorIndex = 15  # 灰色背景

            # 设置所有单元格边框
            # ws.UsedRange.Borders.LineStyle = 1

            # 设置数字格式
            # ws.Range("D:D").NumberFormat = "#,##0.00"  # MOHTQ列
            # ws.Range("F:F").NumberFormat = "#,##0.00"  # QTSYR列

            # 设置列宽（如果自动调整的不够理想）
            ws.Columns("A:G").ColumnWidth = 15

            # 对齐方式
            # ws.UsedRange.HorizontalAlignment = -4108  # xlCenter

            wb.Save()
            wb.Close()
        except Exception as e:
            print(f"Excel格式化过程中发生错误: {str(e)}")
            raise
        finally:
            try:
                excel.Quit()
            except:
                pass
    except Exception as e:
        print(f"保存Excel文件过程中发生错误: {str(e)}")
        raise


def main():
    start_time = time.time()

    # SQL查询
    query = """
Select SYSTEM_TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, varchar(COLUMN_TEXT, 50) As COLUMN_DESC 
From QSYS2.SYSCOLUMNS
Where TABLE_NAME in ('ITMRVA')
"""

    # 生成文件名和路径
    # current_time = datetime.now().strftime('%Y%m%d_%H%M%S')
    # file_name = f'MIL_ITMRVA_{current_time}.xlsx'
    # file_path = os.path.join(r'C:\Users\jishen\Downloads', file_name)

    # 获取当前Python文件的文件名（不包含扩展名）
    script_name = os.path.splitext(os.path.basename(__file__))[0]

    # 生成文件名和路径
    current_time = datetime.now().strftime('%Y%m%d_%H%M%S')
    file_name = f'{script_name}_{current_time}.xlsx'
    file_path = os.path.join(r'C:\Users\jishen\Downloads', file_name)


    try:
        print("正在获取数据...")
        df = fetch_data(query)
        print(f"成功获取 {len(df)} 行数据")

        print("正在处理数据...")
        processed_data = process_data(df)

        print("正在保存和格式化Excel文件...")
        save_and_format_excel(processed_data, file_path)

        print(f"Excel文件已成功保存到: {file_path}")

        print(df)

        # 方法1：直接遍历分组
        # for name, group in df.groupby(['SYSTEM_TABLE_SCHEMA', 'TABLE_NAME']):
        #     print(f"\nGroup: {name}")  # 打印分组的键值
        #     print(group)  # 打印该组的所有数据

        result = df.groupby(['SYSTEM_TABLE_SCHEMA', 'TABLE_NAME']).agg(
            {'SYSTEM_TABLE_SCHEMA': lambda x: x.iloc[0], 'TABLE_NAME': lambda x: x.iloc[0]})
        print(result)


    except Exception as e:
        print(f"程序执行过程中发生错误: {str(e)}")
        raise
    finally:
        execution_time = time.time() - start_time
        print(f"\n程序总运行时间：{execution_time:.2f} 秒")


if __name__ == '__main__':
    main()
