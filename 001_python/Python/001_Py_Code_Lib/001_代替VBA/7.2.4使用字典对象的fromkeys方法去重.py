import xlwings as xw
import os
root = os.getcwd()
app = xw.App(visible=True,add_book=False)
wb = app.books.open(r'd:\python_file\PythonTest.xlsx')
sht = wb.sheets('TRX')

nrow = sht.range('a1048576').end('up').row
ind = sht.range('e1',sht.cells(nrow,'e')).value   # SN
d = {}
inds = d.fromkeys(ind)     # 用SN做key生成字典
indl = list(inds.keys())   # 将字典inds转换成列表indl
rng = sht.range('a1').current_region
dd = []
for i in range(rng.rows.count):
    if sht[i,4].value in indl:     # 如果行SN在列表indl中
        indl.remove(sht[i,4].value)    # 从indl列表中删除
        dd.append(rng.rows(i+1).value)   # 将行数据添加到dd列表中
wb.sheets.add('unique2')
sht2 = wb.sheets('unique2').range('a1').value = dd

