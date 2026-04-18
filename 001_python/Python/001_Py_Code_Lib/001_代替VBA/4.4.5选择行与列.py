import xlwings as xw

app = xw.App(visible=True,add_book=False)
wb = app.books.open(r'd:\python_file\AshtonOH9.xlsx')
wb.sheets('OH').select()
sht = wb.sheets('OH')

# sht.cells(1,2).select()
# sht.api.Rows(3).Select()
# sht.api.Range('5:5').Select()
# sht.api.Range('E1').EntireColumn.Select()

# 选择1-5行
# sht['1:5'].select()
# sht[0:5,:].select()
# sht.api.Rows('1:5').Select()
# sht.api.Range('1:5').Select()
# sht.api.Range("a1:a9").EntireRow.Select()

# sht.range('1:5,7:10').select()
# sht.api.Range('2:5,8:10').Select()

# 选择列
# sht.range('a:b').select()
# sht.api.Columns(5).Select()
# sht.api.Columns('a').Select()
# sht.api.Range('a:h').Select()
# sht.api.Range('K1').EntireColumn.Select()

sht.range('b:c').select()
sht[:,1:3].select()
sht.api.Columns('B:C').Select()
sht.api.Range('B:H').Select()
sht.api.Range("b1:c2").EntireColumn.Select()






