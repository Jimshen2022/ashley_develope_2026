import pyodbc as po
import pandas as pd
import os
import time
from datetime import datetime
import win32com.client as win32


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
        df['AASER#'] = df['AASER#'].astype(str).str.strip()
        df['AAITM#'] = df['AAITM#'].astype(str).str.strip()
        # df['MOHTQ'] = pd.to_numeric(df['MOHTQ'])
        # df['QTSYR'] = pd.to_numeric(df['QTSYR'])
        return df
    except Exception as e:
        print(f"数据处理过程中发生错误: {str(e)}")
        raise


def start_excel_app():
    """启动Excel应用程序，并返回一个Excel应用实例"""
    try:
        # 尝试启动Excel应用程序
        excel = win32.gencache.EnsureDispatch('Excel.Application')
        excel.Visible = True  # 确保Excel窗口可见

        print("Excel应用程序已成功启动")
        return excel
    except Exception as e:
        print(f"启动Excel应用程序时出错: {str(e)}")
        raise


def save_and_format_excel(data, file_path, excel_app=None, open_excel=True):
    """保存并格式化Excel文件，并可选择是否打开Excel"""
    try:
        # 先保存数据到Excel
        data.to_excel(file_path, index=False)
        abs_path = os.path.abspath(file_path)

        # 如果没有传入Excel应用实例，则获取或创建一个
        if excel_app is None:
            try:
                # 尝试获取已运行的Excel实例
                excel_app = win32.GetActiveObject('Excel.Application')
            except:
                # 如果没有运行的Excel实例，创建一个新的
                excel_app = win32.gencache.EnsureDispatch('Excel.Application')

        # 设置Excel可见
        excel_app.Visible = True
        excel_app.DisplayAlerts = False

        try:
            # 打开工作簿
            wb = excel_app.Workbooks.Open(abs_path)
            ws = wb.ActiveSheet

            # 自动调整列宽
            ws.UsedRange.Columns.AutoFit()

            # 冻结首行
            excel_app.ActiveWindow.SplitRow = 1
            excel_app.ActiveWindow.FreezePanes = True

            # 设置标题行格式
            header_range = ws.Range("A1").CurrentRegion.Rows(1)
            header_range.Font.Bold = True
            header_range.Interior.ColorIndex = 15  # 灰色背景

            # 保存工作簿
            wb.Save()

            # 如果不需要保持打开，则关闭工作簿
            if not open_excel:
                wb.Close(SaveChanges=True)

            return wb  # 返回工作簿对象，以便调用者可以进一步操作

        except Exception as e:
            print(f"Excel格式化过程中发生错误: {str(e)}")
            raise

    except Exception as e:
        print(f"保存Excel文件过程中发生错误: {str(e)}")
        raise


def main():
    start_time = time.time()

    # SQL查询
    query = """
    SELECT T1.*, VARCHAR(T1.AASER#) AS SN 
    FROM (
        SELECT * FROM DISTLIB.ACTAUDT
        WHERE AAADAT BETWEEN 20250425 AND 20250426 
          AND AAFWHS = '335'
          AND AACOD1 = 'BT'
        ORDER BY AAITM#, AAADAT, AAATIM 
        FETCH FIRST 1000 ROWS ONLY
    ) T1
    """

    # 生成文件名和路径
    current_time = datetime.now().strftime('%Y%m%d_%H%M%S')
    file_name = f'ashton_receiving_loading_planned_vs_actual_{current_time}.xlsx'
    file_path = os.path.join(r'C:\Users\jishen\Downloads', file_name)

    try:
        # 首先启动Excel应用程序
        print("正在启动Excel应用程序...")
        excel_app = start_excel_app()

        print("正在获取数据...")
        df = fetch_data(query)
        print(f"成功获取 {len(df)} 行数据")

        print("正在处理数据...")
        processed_data = process_data(df)

        print("数据已处理完毕，以下数据可在PyCharm的SciView中查看:")
        processed_data

        temp_csv_path = os.path.join(os.path.dirname(file_path), f'temp_data_{current_time}.csv')
        processed_data.to_csv(temp_csv_path, index=False)
        print(f"已创建临时CSV文件，可通过PyCharm下载: {temp_csv_path}")

        print("正在保存和格式化Excel文件...")
        # 将Excel应用实例传递给save_and_format_excel函数
        wb = save_and_format_excel(processed_data, file_path, excel_app=excel_app, open_excel=True)

        print(f"Excel文件已成功保存到: {file_path}")
        processed_data

    except Exception as e:
        print(f"程序执行过程中发生错误: {str(e)}")
        raise
    finally:
        execution_time = time.time() - start_time
        print(f"\n程序总运行时间：{execution_time:.2f} 秒")
        # if os.path.exists(temp_csv_path):
        #     os.remove(temp_csv_path)


if __name__ == '__main__':
    main()
