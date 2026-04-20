import xlwings as xw
import os
import numpy as np
root = os.getcwd()

app = xw.App(visible=True,add_book=False)
wb = app.books.open(r'd:\python_file\7-3-2.xlsx')
sht = wb.sheets(1)
arr = sht.range('a1').current_region.value
d = {}
d2 = {}

# 将字典的key装入，并初使化值为0， 这一步非常重要，否则如下字典累加时会 因为str+number而出错！！！！！！！！
for i in range(1,len(arr)):
    d[str(arr[i][4])+str(arr[i][5])] = 0
    d2[str(arr[i][4]) + str(arr[i][5])] = 0

# 遍历来源表，并将key的值累加
for i in range(1,len(arr)):
    x = arr[i][6]
    d[str(arr[i][4])+str(arr[i][5])] = d[str(arr[i][4])+str(arr[i][5])] + arr[i][6]      # 多条件组合成键
    d2[str(arr[i][4])+str(arr[i][5])] = d2[str(arr[i][4])+str(arr[i][5])] + arr[i][7]  # 多条件组合成键

# 遍历查询目的地表，并遍历待查询的key值, 从字典读取填入单元格
sht2 = wb.sheets(2)
brr = sht2.range('a1').current_region.value
for j in range(1,len(brr)):
    sht2.cells(j+1, 'c').value = d[str(sht2.cells(j+1,'a').value)+str(sht2.cells(j+1,'b').value)]
    sht2.cells(j+1, 'd').value = d2[str(sht2.cells(j+1,'a').value)+str(sht2.cells(j+1,'b').value)]
print('done')

