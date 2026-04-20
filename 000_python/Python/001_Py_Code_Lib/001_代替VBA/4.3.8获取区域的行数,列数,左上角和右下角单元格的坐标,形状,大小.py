import xlwings as xw
# import win32com.client as win32
#
# app = win32.gencache.EnsureDispatch('excel.application')
# app.Visible=True
# bk = app.Workbooks.Add(r'd:\python_file\AshtonOH9.xlsx')
#
# sht = bk.Worksheets['OH']
# sht.Activate()
# a = sht.UsedRange.Rows.Count
# a1 = sht.UsedRange.Columns.Count

app2 = xw.App(visible=True,add_book=False)
wb = app2.books.open(r'd:\python_file\AshtonOH.xlsx')
ws = wb.sheets['Jim']
ws.select()
b = ws.used_range.rows.count
b1 = ws.used_range.columns.count
b3 = ws.used_range.row
b4 = ws.used_range.columns
b5 = ws.used_range.last_cell.row
b6 = ws.used_range.last_cell.column
b7 = ws.used_range.shape    # 获取区域的形状
b8 = ws.used_range.size    # 获取区域的大小





