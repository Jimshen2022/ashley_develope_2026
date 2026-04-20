import pyodbc as po
import pandas as pd
import os
import time
from datetime import datetime
import win32com.client as win32
import tkinter as tk
from tkinter import messagebox


def fetch_data(query, connection_string='DSN=AFIPROD;UID=JIMSHEN;PWD=MJ2080'):
    try:
        cnxn = po.connect(connection_string)
        df = pd.read_sql(query, cnxn)
        cnxn.close()
        return df
    except Exception as e:
        raise Exception(f"数据获取错误: {str(e)}")


def process_data(df):
    try:
        df['AASER#'] = df['AASER#'].astype(str).str.strip()
        df['AAITM#'] = df['AAITM#'].astype(str).str.strip()
        return df
    except Exception as e:
        raise Exception(f"数据处理错误: {str(e)}")


def save_and_format_excel(data, file_path, open_excel=True):
    try:
        data.to_excel(file_path, index=False)
        excel = win32.Dispatch('Excel.Application')
        try:
            excel.Visible = open_excel
            excel.DisplayAlerts = False
            wb = excel.Workbooks.Open(os.path.abspath(file_path))
            ws = wb.ActiveSheet
            ws.UsedRange.Columns.AutoFit()
            excel.ActiveWindow.SplitRow = 1
            excel.ActiveWindow.FreezePanes = True
            header_range = ws.Range("A1").CurrentRegion.Rows(1)
            header_range.Font.Bold = True
            header_range.Interior.ColorIndex = 15
            wb.Save()
            if not open_excel:
                wb.Close()
        except Exception as e:
            raise Exception(f"Excel格式化错误: {str(e)}")
        finally:
            if not open_excel:
                try:
                    excel.Quit()
                except:
                    pass
    except Exception as e:
        raise Exception(f"Excel保存错误: {str(e)}")


def run_program(open_excel=True):
    start_time = time.time()
    query = """
    SELECT T1.*, VARCHAR(T1.AASER#) AS SN 
    FROM (
        SELECT t.AACOD1,
            t.AAITM#,
            to_date(t.AAADAT,
            t.AAATIM,
            
 
        FROM DISTLIB.ACTAUDT AS t
        WHERE t.AAADAT BETWEEN 20250425 AND 20250501 
          AND t.AATWHS = '335'
          AND t.AACOD1 = 'RC' 
          AND t.AACOD2 = 'SN'
        ORDER BY t.AAITM#, t.AAADAT, t.AAATIM 
        FETCH FIRST 1000 ROWS ONLY
    ) T1
    """
    current_time = datetime.now().strftime('%Y%m%d_%H%M%S')
    file_name = f'ashton_receiving_loading_planned_vs_actual_{current_time}.xlsx'
    file_path = os.path.join(r'C:\Users\jishen\Downloads', file_name)

    try:
        df = fetch_data(query)
        processed = process_data(df)
        save_and_format_excel(processed, file_path, open_excel=open_excel)
        duration = time.time() - start_time
        messagebox.showinfo("成功", f"Excel 已保存到:\n{file_path}\n\n耗时 {duration:.2f} 秒")
    except Exception as e:
        messagebox.showerror("出错了", str(e))


# ------------------------
# 创建图形界面
# ------------------------
def launch_gui():
    window = tk.Tk()
    window.title("数据导出工具")
    window.geometry("400x200")

    label = tk.Label(window, text="是否导出后自动打开 Excel？", font=("Arial", 12))
    label.pack(pady=20)

    open_excel_var = tk.BooleanVar()
    open_excel_var.set(True)
    checkbox = tk.Checkbutton(window, text="打开 Excel", variable=open_excel_var, font=("Arial", 11))
    checkbox.pack()

    def on_run():
        run_program(open_excel=open_excel_var.get())

    run_button = tk.Button(window, text="运行程序", command=on_run, height=2, width=15, bg="#4CAF50", fg="white")
    run_button.pack(pady=20)

    window.mainloop()


if __name__ == '__main__':
    launch_gui()
