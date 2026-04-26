import xlwings as xw
import os
root = os.getcwd()
app = xw.App(visible=True,add_book=False)
wb = app.books.open(r'd:\python_file\dic9.xlsx')
sht2 = wb.api.Sheets('汇总')
for sht in wb.api.Sheets:    # 遍历工作表
    if sht.Name not in ['汇总','去重']:
       hrow = sht2.UsedRange.Rows.Count    # 粘贴位置
       sht.UsedRange.Copy(sht2.Cells(hrow,1))    # 将数据复制到汇总工作表中

# 单表去重,结果显示在去重工作表
sht2 = wb.sheets('汇总')
rng = sht2.range('A1').current_region
d = {}
for i in range(rng.rows.count):
    if sht2[i,4].value not in d.keys():
        d[sht2[i,4].value] = rng.rows(i+1).value
lst = list(d.values())
sht3 = wb.sheets('去重')
sht3.range('a1').value = lst


