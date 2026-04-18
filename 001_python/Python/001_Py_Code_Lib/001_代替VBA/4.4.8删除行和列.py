import xlwings as xw

app = xw.App(visible=True, add_book=False)
wb = app.books.open(r'd:\python_file\AshtonOH9.xlsx')
sht = wb.sheets('OH')
sht2 = wb.sheets('TRX')
#
# sht2.activate()  # 一定要激活，否则以下语句虽不报错,但是不执行
# wb.api.Sheets('TRX').Copy(After=wb.api.Sheets('OH'))

# ws = wb.sheets
# for i in range(len(ws)):
#     print(ws[i].name)
# wb.sheets('TRX (2)').name = 'TRX2'   # 改名
sht3 = wb.sheets('TRX2')
sht3.activate()
# 删除行
# a = sht3.used_range.rows.count
# for i in range(a, 1, -1):
#     if app.api.WorksheetFunction.CountA(sht.api.Rows(i)) == 0:
#         sht.api.Rows(i).Delete()

# # 删除重复行
a1 = sht3.cells(sht3.api.Rows.Count, 1).end('up').row
for i in range(a1, 1, -1):
    if app.api.WorksheetFunction.CountIf(sht3.api.Columns(5), sht3.api.Cells(i, 5)) > 1:   # 以第5列-- SN列去重
        sht3.api.Rows(i).Delete()
print('finished')


















