import xlwings as xw
import os
import re
root = os.getcwd()
app = xw.App(visible=True,add_book=False)
wb = app.books.open(r'd:\python_file\8-3-2-1.xlsx')
sht = wb.sheets(1)
p = r'\D\d+\.\D'    # 正则表达式--数字前面不是数字, 后面跟小数点, 小数点后面跟非数字
arr = sht.range('A1',sht.cells(sht.cells(1,'a').end('down').row,'a')).value
for i in range(len(arr)):    # 遍历每行数据
    m = re.findall(p,arr[i])   # 所有匹配项,反回给m列表
    sp = re.split(p,arr[i])    # 匹配项为分隔符进行分割, 结果返回给sp列表
    s = sp[0]
    for j in range(len(m)):
        s += m[j][0] + '\n' + m[j][1] + m[j][2] + sp[j+1]   # 拚接sp和m
    sht.cells(i+1,2).value = s





