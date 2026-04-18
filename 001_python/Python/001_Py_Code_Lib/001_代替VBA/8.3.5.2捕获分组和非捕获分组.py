import xlwings as xw
import os
import re

root = os.getcwd()
app = xw.App(visible=True, add_book=False)
wb = app.books.open(r'd:\python_file\8-3-5-2.xlsx')
sht = wb.sheets(1)
p = r'([一-龢]{1,}) (\d+\.?\d*元)'  # 正则表达式,连续重复的字符
arr = sht.range('a1').value
m = re.finditer(p,arr)    # 查找匹配数据,以可迭代对象的形式返回
num = 1
for i in m:
    num += 1
    sht.cells(num, 2).value = i.group(1)
    sht.cells(num, 3).value = i.group(2)




