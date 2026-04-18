import xlwings as xw

app = xw.App(visible=True,add_book=False)
wb = app.books.open(r'd:\python_file\AshtonOH9.xlsx')
sht = wb.sheets('OH')
sht.select()   # 一定要先选择工作簿，否则以下会报错

# Copy行再paste
# sht.api.Rows('2:3').Select()
# sht.api.Rows('2:3').Copy()
#
# sht.api.Range('A7').Select()
# sht.api.Paste()

# Cut行再paste
# # sht.api.Rows('2:3').Select()
# sht.api.Rows('2:10').Cut()
# sht.api.Range('A13').Select()
# sht.api.Paste()

# copy行再paste
# sht.api.Rows('13:21').Copy()
# sht.api.Range("a2").Select()
# sht.api.Paste()

# copy列
# sht.api.Columns('a:a').Copy()
# sht.api.Range('H1').Select()
# sht.api.Paste()

sht.api.Columns("b:c").Copy()
sht.api.Range('k1').Select()
sht.api.Paste()