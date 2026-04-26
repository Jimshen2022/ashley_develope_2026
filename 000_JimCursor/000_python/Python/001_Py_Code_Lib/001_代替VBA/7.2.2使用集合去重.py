import xlwings as xw
import os
root = os.getcwd()
app = xw.App(visible=True,add_book=False)
wb = app.books.open(r'd:\python_file\PythonTest.xlsx')
sht = wb.sheets('TRX')
ind = sht.range('e1',sht.cells(sht.cells(1048576,"e").end('up').row,'e')).value
inds = set(ind)     # SN列表转集合
indl=list(inds)     # 集合转列表
# rng = sht.range('a1').current_region
rng = sht.range('a1',sht.cells(sht.cells(1048576,'e').end('up').row,'ac'))

dd = []    # 创建空列表,去除去重后的数据
for i in range(rng.rows.count):    # 遍历rng的每行数据
    if sht[i,4].value in indl:    # 如果该行SN在indl中
        indl.remove(sht[i,4].value)
        dd.append(rng.rows(i+1).value)   # 将行数据添加到dd中

wb.sheets.add('unique')
sht2 = wb.sheets('unique')
sht2.range('a1').value = dd     # 将dd数据写入工作表中

