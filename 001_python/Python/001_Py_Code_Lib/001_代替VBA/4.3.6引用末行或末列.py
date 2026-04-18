import xlwings  as xw

app = xw.App(visible=True,add_book=False)
wb = app.books.open(r'd:\python_file\AshtonOH9.xlsx')
ws = wb.sheets
sht = ws['OH']
sht.select()

nrow = sht.range("A1048576").end('up').row
nrow1 = sht.range('a1').end('down').row
nrow2 = sht.cells(1,1).end('down').row
# now3 = sht.range('a'+str(sht.api.Rows.count)).end('up').row


col1 = sht.range('a1').end('right').column
col2 = sht.range('1').end('left').column




