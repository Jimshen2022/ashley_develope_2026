import xlwings as xw

# 来源工作簿
app2 = xw.App(visible=False, add_book=False)
bk = app2.books.open(r'd:\python_file\AshtonOH.xlsx')
sht2 = bk.sheets('TURNS')
rng = sht2.range('a1').expand('table').value  # 一定要带value, 否则不行

# 目标工作簿
app = xw.App()
wb = app.books.active  # 活动工作表
sht = wb.sheets(1)
sht.range('a1').value = rng

# 制作图表
sht.api.Range('a1').CurrentRegion.Select()
sht.api.Shapes.AddChart2(-1,xw.constants.ChartType.xlColumnClustered,30,150,300,200,True)




