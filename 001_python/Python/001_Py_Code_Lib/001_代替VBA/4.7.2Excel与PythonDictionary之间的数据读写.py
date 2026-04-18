import xlwings as xw

app = xw.App(visible=True, add_book=False)
wb = app.books.open(r'd:\python_file\bk4.xlsx')
sht = wb.sheets[0]

sht = xw.sheets.active
print(sht.range('a1:b2').options(dict).value)  # excel值装入dict
print(sht.range('a4:b5').options(dict,transpose=True).value)  # excel值装入dict


