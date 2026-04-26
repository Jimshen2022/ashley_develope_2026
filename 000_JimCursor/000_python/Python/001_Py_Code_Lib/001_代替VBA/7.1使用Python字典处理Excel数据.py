# -*- coding UTF-8 -*-
import xlwings as xw
import os
# 7.1.1 数据提取  找第一笔资料

app = xw.App(visible=True,add_book=False)
bk = app.books.open(r'd:\python_file\PythonTest.xlsx')
sht = bk.sheets('TRX')
rows = sht.cells(1,'a').end('down').row    # 数据行数
arr = sht.range(sht.cells(1,1),sht.cells(rows,29)).value
dic = {arr[0][0]:arr[0][20]}    # 创建字典
for i in range(rows):    # 遍历各行数据
    if (arr[i][0] not in dic):
        dic[arr[i][0]] = arr[i][19]

sht2 = bk.sheets.add('dictest')
sht2.api.Range('a1:a10000').NumberFormat = "@"
sht2.range(sht2.cells(1,'a'), sht2.cells(len(dic),'b')).value = dic








