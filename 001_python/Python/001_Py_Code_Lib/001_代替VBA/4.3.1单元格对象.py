# import win32com.client as win32
# app = win32.gencache.EnsureDispatch('excel.application')
# app.Visible=True
# bk = app.Workbooks.Add()
# sht = bk.Worksheets(1)
# sht = bk.ActiveSheet
# print(sht.Name)


import xlwings as xw
wb = xw.Book()    # 新建一个工作簿对象
ws = wb.sheets(1)
ws = wb.sheets.active
print(ws.name)



