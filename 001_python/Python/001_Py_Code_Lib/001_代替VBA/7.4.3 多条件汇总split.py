import xlwings as xw
import os
import numpy as np
root = os.getcwd()
app = xw.App(visible=True,add_book=False)
wb = app.books.open(r'd:\python_file\7-4-3.xlsx')
sht = wb.sheets(1)
arr = sht.range('a1').current_region.value
d = {}

#  初使化字典
for i in range(1,len(arr)):
    d[str(arr[i][4])+'&'+str(arr[i][5])] = 0

for i in range(1,len(arr)):
    d[str(arr[i][4])+'&'+str(arr[i][5])] = d[str(arr[i][4])+'&'+str(arr[i][5])] + arr[i][6]    # 将字典key对应值累加

i = 0
for k in d.keys():    # 对每个条件组合成的键进行拆分,得到多个条件
    k2 = k.split('&')    # 将dict的key值split
    i+=1
    wb.sheets(2).cells(i+1,1).value = k2     # i+1 表示从第二行开始
    wb.sheets(2).cells(i+1, 3).value = d[k]    # 将dict累加的值查询过来填写在单元格中
wb.sheets(2).range('a1:c1').value = ['Name','Product','SaledQty']
print('done')


