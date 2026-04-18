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

# 制作直方图

sht.api.Range('a1').CurrentRegion.Select()  # 图表绑定数据
# cht.SetSourceData(Source=rng, PlotBy=1)   # PlotBy=1 表示按列取值，2表示按行取值？？？？？？？？？？？？？？？
cht = wb.api.Charts.Add()  # 添加图表
cht.ChartType = xw.constants.ChartType.xlColumnClustered  # 图表类型
cht.HasTitle = True  # 有标题
cht.ChartTitle.Text = 'MIL Inventory Turns Ratio'  # 标题文本
