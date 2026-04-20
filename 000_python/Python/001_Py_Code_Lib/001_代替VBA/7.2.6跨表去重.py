import xlwings as xw
import os
root = os.getcwd()
app = xw.App(visible=True,add_book=False)
wb = app.books.open(r'd:\python_file\A-2.xlsx')
sht = wb.sheets(1)
ind = sht.range('e2',sht.cells(sht.cells(1048576,'e').end('up').row,'e')).value
inds1 = set(ind)    # 用集合set将序列号去重

sht2 = wb.sheets(2)
ind2 = sht2.range('e2',sht2.cells(sht2.cells(1048576,'e').end('up').row,'e')).value
inds2 = set(ind2)
inds = inds1 - inds2   # 求工号差集
indl = list(inds)   # 将差集转换为列表

rng = sht.range('a1').current_region
dd = []
for i in range(rng.rows.count):
    debug = sht[i,4].value
    if sht[i,4].value in indl:
        indl.remove(sht[i,4].value)
        dd.append(rng.rows(i+1).value)  # 将将行数据添加到dd列表中, +1 是因为rows是从1开始的，不是从0
sht3 = wb.sheets.add(name='join',after='0303')
sht3.range('a1').value = dd
print('done')


