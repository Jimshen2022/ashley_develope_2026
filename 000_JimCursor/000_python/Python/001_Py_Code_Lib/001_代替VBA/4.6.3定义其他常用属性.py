# 1 重画
import xlwings as xw

app = xw.App(visible=True, add_book=False)
app.screen_updating = False
wb = app.books.open(r'D:\python_file\AshtonOH8.xlsx')
print(wb.name)

# 遍历工作表名
ws = wb.sheets
for i in range(len(ws)):
    print(ws[i].name)

# 第一个工作表名
sht = wb.sheets[0]
print(sht.name)

# 用API的函数公式
sht.range('k1').value = app.api.WorksheetFunction.CountIf(app.api.Range('d2:d1000'),'>8')

app.screen_updating = True
print('Successful!!!')
# 警示窗口

# app.display_alerts = False
# app.display_alerts = True
