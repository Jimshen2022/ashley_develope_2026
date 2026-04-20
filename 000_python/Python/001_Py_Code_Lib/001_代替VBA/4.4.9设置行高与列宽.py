import xlwings as xw

app = xw.App(visible=True,add_book=False)
# wb1 = app.books.open(r'd:\python_file\AshtonOH9.xlsx')
wb2 = app.books.open(r'd:\python_file\AshtonOH.xlsx')

sht = wb2.sheets('jim')
sht.activate()

sht.api.Rows(3).RowHeight = 30
sht.api.Range('c5').EntireRow.RowHeight = 40
sht.api.Range('c6').RowHeight = 45
sht.api.Cells.RowHeight = 30

sht.api.Columns(2).ColumnWidth = 20
sht.api.Range('c4').ColumnWidth = 15
sht.api.Range('c5').EntireColumn.ColumnWidth = 16
sht.api.Cells.ColumnWidth = 20

# 行与列自动autofit
sht.autofit(axis=None)    # 'rows' or 'r' 时，自动调整行;   'columns'或 'c'时， 自动调整列



wb2.save()
wb2.close()
app.quit()

print("done")