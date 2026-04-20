import win32com.client as win32

# 启动 Excel 应用程序
excel_app = win32.Dispatch('Excel.Application')
excel_app.Visible = True  # 让 Excel 可见（设置为 False 可以隐藏）

# 打开一个 Excel 文件（更换路径为你的 Excel 文件路径）
workbook = excel_app.Workbooks.Open(r'D:\Users\Documents\GitHub\Python2038\003_Python_VBA\Py_excel.xlsb')

# 选择工作表（根据你的 Excel 文件中的工作表名称）
ws = workbook.Sheets('Sheet1')

# 通过 Python 模拟 VBA 操作
# 示例：清除工作表的所有内容
ws.Cells.Clear()

# 示例：在单元格 A1 中输入值
ws.Range("A1").Value = "Hello from Python!"

# 示例：设置单元格 A1 到 A1 的背景色为黄色
ws.Range("A1:A1").Interior.Color = 65535  # 65535 是黄色


# 自动调整列 A 的宽度以适应内容
ws.Columns("A:A").AutoFit()


# 将值写入从 A1 到 J10 的单元格
for i in range(1,10):  # 行数从 1 到 10
    for j in range(1, 11):  # 列数从 1 到 10
        # ws.Cells(i, j).Value = f"Hello {i},{j} from Python!"
        ws.Cells(i, j).Value = "Hello from Python!"

ws.Range("A1:K5").Value = ""

# 7 通常对应于绿色
ws.Range("A6:J9").Interior.ColorIndex = 7  # 7 通常对应于绿色


# 设置 A1 单元格的字体颜色为红色
ws.Range("A6:J9").Font.ColorIndex = 12  # 255 是红色的 RGB 值
ws.Range("A1").Value = 'JimShenTest'  # 255 是红色的 RGB 值
ws.Range("A1").Font.ColorIndex = 12   # 255 是红色的 RGB 值
# # 保存 Excel 文件并关闭
# workbook.Save()
# workbook.Close()
# excel_app.Quit()
