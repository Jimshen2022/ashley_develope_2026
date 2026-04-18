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
cht = sht.charts.add(50, 200)  # 添加图表

# 方法1
cht.set_source_data(sht.range('a1').expand())  # 图表绑定数据
cht.chart_type = 'column_clustered'  # 图表类型
cht.api[1].HasTitle = True  # 图表有标题
cht.api[1].ChartTitle.Text = 'MIL Inventory Turns Ratio'  # 标题文本
