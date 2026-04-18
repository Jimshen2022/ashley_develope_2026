import win32com.client

# 创建 Excel 应用程序对象
excel = win32com.client.Dispatch("Excel.Application")

# 打开包含 VBA 宏的 Excel 文件
workbook = excel.Workbooks.Open(r"D:\Users\Documents\GitHub\Jim2038\016_Python\Python_excel_vba\Py_excel.xlsb")

# 运行 VBA 宏
excel.Application.Run("HelloWorld")

# 关闭工作簿（不保存）
workbook.Close(SaveChanges=False)

# 退出 Excel
excel.Application.Quit()

# 清理 COM 对象
del excel
