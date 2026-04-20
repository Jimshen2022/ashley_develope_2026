import xlwings as xw
import os
root = os.getcwd()
app = xw.App(visible=True,add_book=False)
wb = app.books.open(r'd:\python_file\7-5-1.xlsx')
sht = wb.sheets(1)
arr = sht.range('a2',sht.cells(sht.cells(1048576,'a').end('up').row, 'a')).value
arr = sorted(arr)

d = {}
brr = sht.range('a2',sht.cells(sht.cells(1048576,'a').end('up').row, 'h'))
for i in range(len(arr)):
    d[brr[i,0].value] = brr.rows(i+1).value

sht2 = wb.sheets(2)
m = 0
for i in range(len(arr)):
    m += 1
    sht2.cells(m,1).value = d[arr[i]]
print('done')



