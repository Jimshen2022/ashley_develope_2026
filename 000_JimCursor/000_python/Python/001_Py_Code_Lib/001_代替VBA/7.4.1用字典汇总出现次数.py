import xlwings as xw
import os

root = os.getcwd()
app = xw.App(visible=True, add_book=False)
wb = app.books.open(r'd:\python_file\7-4-1.xlsx')
sht = wb.sheets(1)
arr = sht.range('a1').current_region.value
d = {}

# 遍历arr将key值装入，并初使化为0
for i in range(1, len(arr)):
    d[arr[i][5]] = 0
for i in range(1, len(arr)):
    d[arr[i][5]] = d[arr[i][5]] + 1

sht2 = wb.sheets(2)
sht2.range('a2', sht2.cells(len(d), 'b')).value = d
