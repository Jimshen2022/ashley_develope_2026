# import win32com.client as win32
# import os
#
# app = win32.gencache.EnsureDispatch('excel.application')
# app.Visible = True
# bk = app.Workbooks.Open(r'd:\python_file\AshtonOH.xlsx')
# app.ScreenUpdating = False
# for sht in bk.Worksheets:
#     sht.Copy()
#     app.ActiveWorkbook.SaveAs('d:\\python_file\\'+sht.Name+'.xlsx',51)
#     app.ActiveWorkbook.Close()
# app.ScreenUpdating = True
# print("done")

# xlwings
import xlwings as xw
import os

root = os.getcwd()
app = xw.App(visible=True, add_book=False)
bk = app.books.open(r'd:\python_file\AshtonOH.xlsx')
# app.screen_updating = False
for sht in bk.api.Worksheets:
    sht.Copy()
    bk2 = xw.books(2)
    # xw.books(2).activate()
    # name1 = xw.books.active.name
    # print(name1)
    bk2.save('d:\\python_file\\'+sht.Name+'.xlsx')
    bk2.close()
# app.screen_updating = True
print('done')
