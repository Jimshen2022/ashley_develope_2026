import xlwings as xw

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
cht = sht.api.Shapes.AddChart2(-1, xw.constants.ChartType.xlColumnClustered, 200, 20, 600, 500, True).Chart  # 添加图表

cht.FullSeriesCollection(1).XValues = sht.api.Range("a2:a28")  # 这个是选择x轴分类资料范围，不包括列名
cht.SeriesCollection(1).AxisGroup = 1  # 第一个序列使用主轴
cht.SeriesCollection(2).AxisGroup = 2  # 第二个序列使用辅轴
cht.SeriesCollection(2).ChartType = xw.constants.ChartType.xlLine  # 折线图
cht.SeriesCollection(2).MarkerStyle = xw.constants.MarkerStyle.xlMarkerStyleTriangle  # 折线图上每个节点的形状为三角形
cht.SeriesCollection(2).MarkerForegroundColor = xw.utils.rgb_to_int((0, 0, 255))  # 折线图节点三角形的外框颜色为蓝色
cht.SeriesCollection(2).MarkerSize = 6  # 折线图节点三角形的大小
cht.SeriesCollection(2).HasDataLabels = True  # 加上数据标签
cht.SeriesCollection(1).HasDataLabels = True  # 加上数据标签

# 获取和设置主纵轴，取值范围为0~60, 设置坐标轴标题
axs1 = cht.Axes(2, 1)  # 第一个值为1表示分类轴，为2表示数值轴; 第二个值为1时表示为主轴，为2时表示辅轴
axs1.MinimumScale = 0
axs1.MaximumScale = 40
axs1.HasTitle = True
axs1.AxisTitle.Text = '纵坐标轴1'

# 获取和设置辅纵轴,取值范围为10~160, 设置坐标轴标题
axs2 = cht.Axes(2, 2)
axs2.MinimumScale = 0
axs2.MaximumScale = 40
axs2.HasTitle = True
axs2.AxisTitle.Text = '纵坐标轴2'





