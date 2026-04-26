import pyodbc as po
import pandas as pd
import os
import time
from datetime import datetime
import win32com.client as win32

# 配置 pandas 显示选项，优化在 PyCharm 中的显示效果
pd.options.display.html.table_schema = True
pd.options.display.max_rows = None
pd.options.display.max_columns = None
pd.options.display.expand_frame_repr = False
pd.options.display.width = 1000


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
    """处理数据"""
    try:
        df['ITNBR'] = df['ITNBR'].str.strip()
        df['MOHTQ'] = pd.to_numeric(df['MOHTQ'])
        df['QTSYR'] = pd.to_numeric(df['QTSYR'])
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
            ws.Range("D:D").NumberFormat = "#,##0.00"  # MOHTQ列
            ws.Range("F:F").NumberFormat = "#,##0.00"  # QTSYR列

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
        SELECT T1.ITNBR, T1.HOUSE, T1.ITCLS, T1.MOHTQ, T1.WHSLC, T1.QTSYR, T2.ITDSC 
        FROM AMFLIBA.ITEMBL T1
        JOIN AMFLIBA.ITMRVA T2 ON T2.ITCLS = T1.ITCLS AND T2.ITNBR = T1.ITNBR
        JOIN AMFLIBA.WHSMST T3 ON T2.STID = T3.STID AND T1.HOUSE = T3.WHID 
        WHERE T1.HOUSE='335' AND T1.MOHTQ<>0
    """

    # 生成文件名和路径
    current_time = datetime.now().strftime('%Y%m%d_%H%M%S')
    file_name = f'ahston_onhand_{current_time}.xlsx'
    file_path = os.path.join(r'C:\Users\jishen\Downloads', file_name)

    try:
        print("正在获取数据...")
        df = fetch_data(query)
        print(f"成功获取 {len(df)} 行数据")

        print("正在处理数据...")
        processed_data = process_data(df)

        # 显示数据以便在PyCharm的SciView中查看
        print("数据已处理完毕，以下数据可在PyCharm的SciView中查看:")

        # 在PyCharm中，这行代码将在SciView/DataView中显示DataFrame
        # 无需断点，当执行到这一行时会自动显示
        processed_data  # 单独一行，在PyCharm专业版中触发数据视图

        # 保存临时CSV文件，便于通过PyCharm界面下载
        temp_csv_path = os.path.join(os.path.dirname(file_path), f'temp_data_{current_time}.csv')
        processed_data.to_csv(temp_csv_path, index=False)
        print(f"已创建临时CSV文件，可通过PyCharm下载: {temp_csv_path}")

        print("正在保存和格式化Excel文件...")
        save_and_format_excel(processed_data, file_path)

        print(f"Excel文件已成功保存到: {file_path}")

        # 最后一行再次显示DataFrame，确保在程序结束前数据仍然可见
        processed_data  # 使PyCharm在程序结束前保持数据视图

    except Exception as e:
        print(f"程序执行过程中发生错误: {str(e)}")
        raise
    finally:
        execution_time = time.time() - start_time
        print(f"\n程序总运行时间：{execution_time:.2f} 秒")

        # 可以选择删除临时CSV文件
        # if os.path.exists(temp_csv_path):
        #     os.remove(temp_csv_path)


if __name__ == '__main__':
    main()

