# 新建

# import win32com.client as win32
# app = win32.gencache.EnsureDispatch('excel.application')
# app.Visible = True
# bk = app.Workbooks.Add()
# for i in range(1,11):
#     bk.Worksheets.Add(After=bk.Worksheets(bk.Worksheets.Count))

# 删除
# import win32com.client as win32
# import os
#
# app = win32.gencache.EnsureDispatch('excel.application')
# app.Visible = True
# root = os.getcwd()
# bk = app.Workbooks.Open(root + r'/test01.xlsx')
# app.DisplayAlerts = False
# for i in range(5, 1, -1):
#     bk.Sheets(i).Delete()
# app.DisplayAlerts = True

# 增加工作表
import xlwings as xw
import os
app = xw.App()
root = os.getcwd()
bk = app.books(1)
for i in range(1,11):
    bk.api.Worksheets.Add(After=bk.api.Worksheets(bk.api.Worksheets.Count))

bk.save(root+r'/test01.xlsx')
bk.close()


# 删除
import xlwings as xw
import os
root = os.getcwd()
app = xw.App(visible=True,add_book=False)
bk = app.books.open(root+r'\test01.xlsx')
app.display_alerts = False
for i in range(5,1,-1):
    bk.sheets[i].delete()
app.display_alerts = True
bk.save(root+r'\test01.xlsx')
bk.close()



