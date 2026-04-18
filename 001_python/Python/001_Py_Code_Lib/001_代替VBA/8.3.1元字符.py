import re
import xlwings as xw
import os
a = 'BC_101PW%'
m0 = re.findall('[0-9]', a)  # 找到所有数字，以列表显示
m1 = re.findall(r'\d', a)
m2 = re.findall('\\d', a)
m3 = re.findall('.+', a)
m4 = re.findall('.*', a)
m5 = re.findall('.*', a)
m6 = re.sub('\d', 'jim', a)  # 将所有数字以jim替代

b = 'C5dC56 C5'
m7 = re.sub(r'\bC\d', 'jim', b)  # \b 表示string的开头或结尾

c = '12345my09'
m8 = re.findall(r'^\d+', c)

d = '1234my09W'
m9 = re.findall(r'\d+\D', d)
m10 = re.findall(r'\d+\D$', d)

# import xlwings as xw
# import os
# root = os.getcwd()
# app = xw.App(visible=True,add_book=False)
# wb = app.books.open(r'd:\python_file\8-3-1.xlsx')
# sht = wb.sheets(1)
# arr = sht.range('a1').current_region.value
# n = 0
# for i in range(len(arr)):
#     mt = re.findall(r'^[a-z]+\d+$',arr[i],re.I)
#     for j in range(len(mt)):
#         n+=1
#         sht.cells(n,3).value = mt[j]




root = os.getcwd()
app = xw.App(visible=True, add_book=False)
wb = app.books.open(r'd:\python_file\8-3-1-2.xlsx')
sht = wb.sheets(1)
# arr = sht.range('a1').current_region.value
arr = sht.range('b2', sht.cells(sht.cells(1, 'b').end('down').row, 'b')).value
n = 0
for i in range(len(arr)):
    mt = re.sub(r'[\u4e00-\u9fa5]+\*','',arr[i])  # 将中文和星号替换为空
    v = eval(str(mt))  # 剩下算式,计算结果
    sht.cells(i + 2, 3).value = v
