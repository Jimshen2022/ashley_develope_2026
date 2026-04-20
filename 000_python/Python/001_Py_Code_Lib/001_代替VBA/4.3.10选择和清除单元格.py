import xlwings as xw

app = xw.App(visible=True, add_book=False)
wb = app.books.open(r'd:\python_file\AshtonOH9.xlsx')
sht = wb.sheets['OH']
sht.select()  # 选择sheet
sht.range('a1:a10').select()  # 选择单元格
sht.range('a1:a10,c3,e1:e5').select()  # 选择单元格
sht.range('a2:a10').insert(shift='down', copy_origin='format_from_left_or_above')  # 插入单元格

sht.range('a79:g' + str(sht.used_range.last_cell.row)).clear()      # 清除某个区域资料
sht.range('a78:g' + str(sht.used_range.last_cell.row)).clear_contents()      # 清除某个区域正文内容




