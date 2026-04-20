import xlwings as xw
import pandas as pd
from datetime import datetime
import os
import psutil

# 检查并杀掉所有挂起的 Excel 进程
def kill_excel_process():
    for proc in psutil.process_iter(['name']):
        if proc.info['name'] and proc.info['name'].lower() == 'excel.exe':
            proc.kill()

# 检查目标文件是否被占用
def is_file_locked(file_path):
    if os.path.exists(file_path):
        try:
            os.rename(file_path, file_path)  # 测试是否可以重命名
            return False  # 如果没有异常，文件未被占用
        except OSError:
            return True
    return False  # 文件不存在，不会被占用

# 保存 pandas DataFrame 到 Excel
def save_dataframe_to_excel(df, base_path, base_filename):
    app = None
    wb = None
    try:
        # 动态生成文件名
        timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
        file_path = os.path.join(base_path, f"{base_filename}_{timestamp}.xlsb")

        # 确保目标目录存在
        os.makedirs(base_path, exist_ok=True)

        # 检查文件是否被占用（如果旧文件存在）
        if is_file_locked(file_path):
            raise IOError(f"File '{file_path}' is currently locked or in use.")

        # 启动 Excel 应用
        app = xw.App(visible=False)
        wb = app.books.add()

        # 将 DataFrame 写入第一个工作表
        sht = wb.sheets[0]
        sht.name = "DataFrame Export"
        sht.range("A1").value = df

        # 保存文件
        wb.save(file_path)
        print(f"File successfully saved as: {file_path}")

    except Exception as e:
        print(f"Error occurred: {e}")

    finally:
        # 确保资源释放
        if wb:
            wb.close()
        if app:
            app.quit()

# 主函数
if __name__ == "__main__":
    # 目标路径和文件名
    base_path = r'D:\GitHub\Python2038\005_Practice\001_excel_fly'
    base_filename = 'pd_xlwings'

    # 杀掉挂起的 Excel 进程
    kill_excel_process()

    # 创建示例 DataFrame
    df = pd.DataFrame([[1, 2], [3, 4]], columns=['a', 'b'])

    # 保存 DataFrame 到 Excel
    save_dataframe_to_excel(df, base_path, base_filename)
