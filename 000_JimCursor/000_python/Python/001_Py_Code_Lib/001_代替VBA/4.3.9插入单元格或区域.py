import xlwings as xw

app = xw.App(visible=True,add_book=False)
wb = app.books.open(r'd:\python_file\AshtonOH9.xlsx')
sht = wb.sheets['OH']
sht.activate()

sht.range('a1').color = (0,255,0)
sht.range('a2').insert(shift='down',copy_origin='format_from_left_or_above')
sht.range('b4:c5').insert()





