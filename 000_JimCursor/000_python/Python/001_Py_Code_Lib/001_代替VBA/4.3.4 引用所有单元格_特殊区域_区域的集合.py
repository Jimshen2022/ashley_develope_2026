import win32com.client as win32
import xlwings as xw

# xw.App(visible=True, add_book=False)
# wb = xw.Book(r'd:\python_file\AshtonOH9.xlsx')
# ws = wb.sheets
# sht = ws['OH']
#
# # 1. 引用所有单元格 xlwings
# rng = sht.cells.select()
# rng1 = sht.cells
#
# # 2 引用特殊区域
# # a.一次引用多个区域 xlwings
# rng2 = sht['a2,B3:C8,E2:F5'].select()
# rng3 = sht.range("a2,b3:c8,e2:f5").select()
#
# # b.引用指定单元格的当前区域
# rng4 = sht.range('a2').current_region.select()
#
# # c. 引用指定工作表的已用区域
# rng5 = sht.used_range.select()
# rng6 = sht['a2']

# 3. 引用区域的集合
app = win32.gencache.EnsureDispatch('excel.application')
app.Visible = True
bk = app.Workbooks.Add()
sht2 = bk.Worksheets.Add()
sht2.Range('a1').Value = 'Jimshen*5'

app.Union(sht2.Range('b4:d8'), sht2.Range('c2:f5')).Select()
app.Intersect(sht2.Range('b4:d8'), sht2.Range('c2:f25')).Select()
