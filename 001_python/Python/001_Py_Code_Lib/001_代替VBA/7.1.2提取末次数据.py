import xlwings as xw


app = xw.App(visible=True, add_book=False)
wb = app.books.open(r'd:\python_file\PythonTest.xlsx')
sht = wb.sheets('TRX')
nrow = sht.cells(1048576, 1).end('up').row
arr = sht.range(sht.cells(1, 1), sht.cells(nrow, 29)).value
dic = {arr[0][0]: arr[0][19]}
for i in range(nrow):
    dic[arr[i][0]] = arr[i][19]

sht2 = wb.sheets.add('dictionary')
sht2.range(sht2.cells(1, 1), sht2.cells(nrow, 2)).value = dic
