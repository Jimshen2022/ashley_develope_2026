# win32方法
# import win32com.client as win32
# from win32com.client import Dispatch, constants
# import os
#
# app = win32.gencache.EnsureDispatch('excel.application')
# app.Visible = True
# root = os.getcwd()
# bk = app.Workbooks.Open(r'd:\python_file\AshtonOH.xlsx')
#
# # 增加一个新工作表
# sht = bk.Worksheets.Add(After=bk.Worksheets(bk.Worksheets.Count - 1))
# sht.Name = "Summary"
#
# # 清楚summary中的内容
# sht.Cells.Clear()
#
# # copy report head
# sht.Range('a1').Value = 'TableName'
# bk.Worksheets(1).Range('a1:G1').Copy(sht.Range('B1'))
#
# # 遍历除"Summary"工作表以外的每个工作表, 复制数据
# for shtt in bk.Worksheets:
#     if shtt.Name not in ['Summary', 'TRX']:
#         rngt = shtt.Range('A2', shtt.Cells(shtt.Range('a' + str(shtt.Rows.Count)).End(constants.xlUp).Row, 7))
#         row = sht.Range('a1').CurrentRegion.Rows.Count + 1
#
#         # 复制数据到Summary表的第2列
#         rngt.Copy(sht.Cells(row, 2))
#         rt = sht.Range('a' + str(sht.Rows.Count)).End(constants.xlUp).Row + 1
#         row2 = shtt.Range('A1').CurrentRegion.Rows.Count - 1
#         rt2 = rt + row2
#         for i in range(rt, rt2):
#             sht.Cells(i, 1).Value = shtt.Name
# print('finish')

# xlwings方法
import xlwings as xw
from xlwings.constants import Direction
import os
root = os.getcwd()

app = xw.App(visible=True,add_book=False)
bk = app.books.open(r'd:\python_file\AshtonOH.xlsx')
ws = bk.sheets

tlist = []
# 判断是否有同名工作表，若有则删除
for j in range(len(ws),0,-1):
    list1 = ws(j).name
    tlist.append(list1)
if 'Total' in tlist:
    ws('Total').select()
    ws('Total').api.Cells.Clear()
    sht = bk.api.Worksheets('Total')
else:
    sht = bk.api.Worksheets.Add(After=bk.api.Worksheets(bk.api.Worksheets.Count))
    sht.Name = 'Total'
# sht.Cells.Clear()

# 复制表头

sht.Range('a1').Value = 'TableName'
bk.api.Worksheets(1).Range('a1:g1').Copy(sht.Range('b1'))

# 遍历除total工作表以外的每个工作表
for shtt in bk.api.Worksheets:
    if shtt.Name not in ['Total','TRX']:
        rngt = shtt.Range('A2',shtt.Cells(shtt.Range('a'+str(shtt.Rows.Count)).End(Direction.xlUp).Row,7))
        row=sht.Range('a1').CurrentRegion.Rows.Count+1
        rngt.Copy(sht.Cells(row,2))    # 复制数据

        # 在第一列添加汇总工作表名称
        rt = sht.Range('A'+str(sht.Rows.Count)).End(Direction.xlUp).Row +1
        row2 = shtt.Range('a1').CurrentRegion.Rows.Count-1
        rt2 = rt+row2
        for i in range(rt,rt2):
            sht.Cells(i,1).Value = shtt.Name
bk.save(r'd:\python_file\AshtonOH.xlsx')
print('finished')


















