# 1. excel是行数据
# import win32com.client as win32
# app = win32.gencache.EnsureDispatch("excel.application")
# app.Visible = True
# bk = app.Workbooks.Open(r'D:\python_file\bk4.xlsx')
# sht = bk.Worksheets(1)
#
# lst = sht.Range("a1:e1").Value
# print(lst)
# list1 = list(lst[0])
#
#
# import xlwings as xw
# wb = xw.Book(r'd:\python_file\bk4.xlsx')
# sht = wb.sheets[0]
# lst = sht.range('a1:e1').value
# list1 = list(lst)
# print(list1)

# import xlwings as xw
# bk = xw.Book(r'd:\python_file\bk4.xlsx')
# sht = bk.api.Sheets(1)
# lst = sht.Range('a1:e1').Value
# print(lst)
# list1 = list(lst[0])

# excel是列数据
# import win32com.client as win32
# app = win32.gencache.EnsureDispatch("excel.application")
# app.Visible = True
# bk = app.Workbooks.Open(r'D:\python_file\bk4.xlsx')
# sht = bk.Worksheets(1)
# lst = sht.Range("a1:a5").Value    # 得到二维元组
# print(lst)
#
# # 将二维元组转为二维列表
# lst2 = []
# for i in range(len(lst)):
#     lst2.append(list(lst[i]))
#
# print(lst2)


# 将python列表数据写入excel工作表中

# xlwings
import xlwings  as xw
app = xw.App(visible=True,add_book=False)
bk = app.books.open(R'D:\python_file\bk4.xlsx')
sht = bk.sheets[0]

# 一维列表
lst = [1,2,3,4,5,6]
sht.range('a1').value = lst
sht.range('a10:a15').value = app.api.WorksheetFunction.Transpose(lst)    # 转置, 如果不转置，则值会放到A10:F10

# 二维列表
lst2 = [[1,3,6],[2,3,5],[3,4,7],[4,6,7],[5,8,9],[6,6,4],[7,3,3]]
sht.range('h1').value = lst2

# EXPAND

sht.range('A5:B6').value = [[1,2],[3,4]]
sht.range('a20').options(expand='table').value = [[1,2],[3,4]]











# import xlwings as xw
# bk = xw.Book(r'd:\python_file\bk4.xlsx')
# sht = bk.sheets[0]
# # lst = sht.range('a1:a5').value
# # print(lst)










