# import win32com.client as win32
#
# app = win32.gencache.EnsureDispatch('excel.application')
# app.Visible = True
# bk = app.Workbooks.Add()
# sht = bk.Worksheets.Add()
# sht.Range('a1').Value = 10

# 4.2.3用xlwings创建excel对象
import xlwings as xw

app2 = xw.App()
bk2 = xw.sheets
# sht2 = bk2.sheets.add()
sht2 = bk2[0]
sht2.range('a2').value = 20


