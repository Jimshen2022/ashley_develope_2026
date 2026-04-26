import xlwings as xw

app = xw.App(visible=True, add_book=False)
# app.screen_updating=False
wb = app.books.open(r'd:\python_file\PythonTest.xlsx')
sht = wb.sheets('TRX')
nrow = sht.api.Range('a1').CurrentRegion.Rows.Count
# nrow = sht.cells(1048576,1).end('up').row
rng = sht.range('e1', sht.cells(nrow, 5))
lst = [rng.rows(1).value]  # 创建列表
for i in range(rng.rows.count):
    r = rng.rows(i).value
    if r not in lst:  # 如果行数据在列表中不存在,则将其添加到列表中
        lst.append(r)

wb.sheets.add('list1')
sht2 = wb.sheets('list1')

sht2.range('a1',sht2.cells(len(lst),1)).options(transpose=True).value = lst
# 上一句是将一维list在excel中变成二维！！！！

# wb.save(r'd:\python_file\PythonTest.xlsx')
# wb.close()
# app.screen_updating=True
print("done")
