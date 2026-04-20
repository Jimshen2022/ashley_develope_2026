import xlwings as xw
import os

# 来源工作簿
app2 = xw.App(visible=False, add_book=False)
bk = app2.books.open(r'd:\python_file\AshtonOH.xlsx')
sht2 = bk.sheets('CHART')
rng = sht2.range('a1').expand('table').value  # 一定要带value, 否则不行

# 目标工作簿
app = xw.App()
wb = app.books.active  # 活动工作表
sht = wb.sheets(1)
sht.range('a1').value = rng
'''---------------------------------------------------------------------------------------------'''
# 创建图表
sht.api.Range('b1:c28').Select()
cht = sht.api.Shapes.AddChart().Chart  # 添加图表  p266
# cht = sht.api.Shapes.AddChart2(-1, xw.constants.ChartType.xlColumnClustered, 200, 20, 600, 500, True).Chart  # 添加图表

cht.FullSeriesCollection(1).XValues = sht.api.Range("a2:a28")  # 这个是选择x轴分类资料范围，不包括列名

# AxisBetweenCategories属性设置数值轴和分类轴的相交位置  P288
cht.Axes(1).AxisBetweenCategories = True
# cht.Axes(1).AxisBetweenCategories = False #

# 数值轴在最大值处与分类轴相交 P289
cht.Axes(1).Crosses = 2   # 数值轴在最大值处相交---即Y轴在右边
cht.Axes(1).Crosses = 4   # 数值轴在最小值处相交---即Y轴在左边

# CrossAt属性返回或设置数值轴上数值轴与分类轴的交点，仅用于数值轴
cht.Axes(2).CrossesAt = 5    # 类似于Y轴最小值
cht.Axes(1).TickLabelSpacing = 4  # 分类轴上标签之间的分类数





