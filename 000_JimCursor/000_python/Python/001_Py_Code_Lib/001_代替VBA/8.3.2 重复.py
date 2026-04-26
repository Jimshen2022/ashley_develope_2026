import re
import xlwings as xw
# # 查找字符
# a = 'W123YZW85CW0DFWU'
# m1 = re.findall(r'W\d*',a)
# m2 = re.findall(r'W\d+',a)
#
#
# # 查找有或没有小数点的数字,  ？为重复前一个字符为0次或1次
# a2 = 'W10.23RWA908C5..1'
# m3 = re.findall(r'\d+\.?\d+',a2)
#
#
# #  {n}表示前面一个字符重复n次
# a3 = 'WT123Pq89C'
# m4 = re.findall(r'\d{3}',a3)
# m5 = re.findall(r'\d{2,3}',a3)
# m6 = re.findall(r'\d{2,}',a3)

# 提取日期
app = xw.App(visible=True,add_book=False)
wb = app.books.open(r'd:\python_file\8-3-2.xlsx')
sht = wb.sheets(1)
p = r'\d{4}-\d?-\d{2}|\d{4}.\d{2}.\d{2}|\d{4}/\d{2}/\d{2}'    # 日期正则表达
arr = sht.range('a1',sht.cells(sht.cells(1,'a').end('down').row,'a')).value

for i in range(len(arr)):
    m8 = re.findall(p,arr[i])
    sht.cells(i+1,'b').value = m8











