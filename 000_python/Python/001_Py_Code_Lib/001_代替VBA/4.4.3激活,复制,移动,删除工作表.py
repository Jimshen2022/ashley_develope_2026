import xlwings as xw

app = xw.App(visible=True,add_book=False)
wb = app.books.open(r'd:\python_file\AshtonOH9.xlsx')
bk = app.books.open(r'd:\python_file\AshtonOH.xlsx')

# 激活工作表
# sht = wb.sheets['OH']
#
# wb.sheets[1].activate()
# sht_name = wb.sheets[1].name
#
# wb.sheets[2].select()
# sht_name2 = wb.sheets[2].name
#
# wb.api.Worksheets(3).Activate()
# sht_name3 = wb.api.Worksheets(3).Name
#
# wb.api.Worksheets(4).Select()
# sht_name4 = wb.api.Worksheets(4).Name

# 复制工作表
# wb.api.Sheets('OH').Copy()    # 在wb工作表外的一个独立工作簿
# wb.api.Sheets("Sheet3").Copy(After=wb.api.Sheets('OH'))    # 在wb的OH后面复制增加

# 复制到其他工作簿
# wb.api.Sheets("Sheet3").Copy(After=bk.api.Sheets('Sheet2'))

# move到其他工作簿
# wb.api.Sheets('Sheet3').Move(Before=bk.api.Sheets('Sheet1'))

# 同时move多个工作表
# wb.api.Sheets(['OH','Summary']).Move(Before=bk.api.Sheets('Sheet1'))

# 删除工作表
# bk.api.Sheets(['OH','Summary']).Delete()
