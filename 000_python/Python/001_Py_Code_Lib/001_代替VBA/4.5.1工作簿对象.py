# 创建和找开工作簿

import xlwings as xw
import win32com.client as win32

# app = win32.gencache.EnsureDispatch("excel.application")
# app.Visible = True
# bk = app.Workbooks.Add(r'd:\python_file\AshtonOH3.xlsx')

app2 = xw.App(visible=True,add_book=False)

xw.Book(r'd:\python_file\AshtonOH.xlsx')
bk1 = app2.books.open(r'd:\python_file\AshtonOH5.xlsx')

bk4 = app2.api.Workbooks.Open(r'd:\python_file\AshtonOH2.xlsx')

bk2 = app2.api.Workbooks.Add(xw.constants.WBATemplate.xlWBATChart)
bk3 = app2.api.Workbooks.Add(r'd:\python_file\AshtonOH3.xlsx')

