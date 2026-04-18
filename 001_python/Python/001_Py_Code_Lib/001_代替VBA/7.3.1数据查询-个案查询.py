import xlwings as xw
import os
root = os.getcwd()
app = xw.App(visible=True,add_book=False)
wb = app.books.open(r'd:\python_file\B.xlsx')
sht = wb.sheets('Sheet2')

# arr = sht.range('a1',sht.cells(sht.cells(1048576,'e').end('up').row,'ac')).value
arr = sht.range('a1').current_region.value

d = {}
for i in range(len(arr)):   # 遍历每行数据
    d[arr[i][4]] = [arr[i][0],arr[i][1]]     # 将SN作key, 款号与commodity code as 值

sht2 = wb.sheets('Sheet1')
sht2.api.Columns('b:b').NumberFormat = '@'
brr = sht2.range('a1').current_region.value

for j in range(len(brr)):
    sht2.cells(j+1,'b').value = d[sht2.cells(j+1,'a').value]
print('done')











