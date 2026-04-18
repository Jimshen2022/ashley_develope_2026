import xlwings as xw
import os
import re

root = os.getcwd()
app = xw.App(visible=True, add_book=False)
wb = app.books.open(r'd:\python_file\8-3-5-1.xlsx')
sht = wb.sheets(1)
p = r'([a-z])\1*'  # 正则表达式,连续重复的字符
arr = sht.range('a1', sht.cells(sht.cells(1048576, 1).end('up').row, 1)).value
for i in range(len(arr)):
    m = re.finditer(p, arr[i], re.I)  # 找到全部匹配数据,不区分大小写
    num = 1
    for j in m:
        num += 1
        sht.cells(i + 1, num).value = j.group(0)  # 将匹配数据写入工作表
