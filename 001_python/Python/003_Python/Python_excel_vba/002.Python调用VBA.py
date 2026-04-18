import win32com.client

try:
    excel = win32com.client.Dispatch("Excel.Application")
    workbook = excel.Workbooks.Open(r"D:\Users\Documents\GitHub\Jim2038\016_Python\Python_excel_vba\Py_excel.xlsb")
    excel.Application.Run("HelloWorld")
    workbook.Close(SaveChanges=False)
    excel.Application.Quit()
except Exception as e:
    print(f"Error: {e}")
finally:
    del excel

