import xlwings as xw
import os
import re
root = os.getcwd()
app = xw.App(visible=True,add_book=False)
wb = app.books.open(r'd:\python_file\8-3-6.xlsx')
sht = wb.sheets(1)
p = r'\d+\.?\d*(?=(公斤|千克|kg))'    # 匹配单位前面的数字
arr = sht.range('b2',sht.cells(sht.cells(1048576,'b').end('up').row,'b')).value
for i in range(len(arr)):
    sm = 0
    m = re.finditer(p,arr[i])
    for j in m:
        sm += int(j.group(0))
    sht.cells(i+2,3).value = sm










