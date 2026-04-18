import xlwings as xw

app = xw.App(visible=True, add_book=False)
app.screen_updating = False

wb = app.books.open(r'd:\python_file\AshtonOH9.xlsx')
ws = wb.sheets
sht = ws['OH']
sht2 = ws['test20220724']
# sht2 = wb.sheets.add('test20220724', after='OH')

sht.select()
sht.range('c2').resize(3).select()
sht2.select()

# sht2.range('b3').expand('table').select()
sht2.range('b3').expand().select()


app.screen_updating = True
