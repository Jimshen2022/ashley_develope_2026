import xlwings as xw
import os
root = os.getcwd()
app = xw.App(visible=True,add_book=False)
wb = app.books.open(r'd:\python_file\PythonTest.xlsx')
sht = wb.sheets('TRX')
rng = sht.range('a1').current_region
d = {}    # 创建空字典
for i in range(rng.rows.count):     # 遍历rng每一行
    if sht[i,4].value not in d.keys():    # 如果d的键不包含该SN
        d[sht[i,4].value] = rng.rows(i+1).value    # 将SN作key, rng行数据作Items添加到字典
lst = list(d.values())    # 将字典的值转换为list, values函数将字典所有值以列表形式返回.   items返回键+值， keys返回key

wb.sheets.add('dic')
sht2 = wb.sheets('dic')
sht2.range('a1').value = lst