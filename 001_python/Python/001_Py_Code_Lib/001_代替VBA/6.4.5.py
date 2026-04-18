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

# 创建的图表
sht.api.Range('b1:c28').Select()
# cht = sht.api.Shapes.AddChart().Chart    # 添加图表
cht = sht.api.Shapes.AddChart2(-1, xw.constants.ChartType.xlColumnClustered, 200, 20, 600, 500, True).Chart  # 添加图表

# 横坐标轴设置
cht.FullSeriesCollection(1).XValues = sht.api.Range("a2:a28")  # 这个是选择x轴的资料范围，不包括列名
axs = cht.Axes(1)
axs.Border.ColorIndex = 3  # 红色
axs.Border.Weight = 3  # 线宽
axs.HasMinorGridlines = True  # 显示次级网格线

# 横坐标轴标题设置
axs.HasTitle = True  # 是否有标题
axs.AxisTitle.Caption = "横坐标轴标题"  # 标题文本内容
axs.AxisTitle.Font.Italic = True  # 字体
axs.AxisTitle.Font.Color = xw.utils.rgb_to_int((255, 0, 0))  # 标题显示为红色
axs.MajorTickMark = 4    # 主刻度线设置为跨轴形式  P283
axs.MinorTickMark = 2    # 次刻度线设置为轴内显示
axs.TickMarkSpacing = 1    # 返回或设置每隔多少个数据显示一个主刻度线


t0 = axs.TickLabels     # x轴分类标签
t0.TickLabelPosition = -4127    # -4127图表的顶部或右侧    -4134坐标轴左侧，  4 坐标轴旁边， -4142无刻度线   P284
axs.TickLabels.TickLabelsSpacing = 3    # 每隔多少个分类显示一个刻度标签
# axs.TickLabelSpacingIsAuto = True    # 自动设置刻度标签的间距



# 纵坐标
axs2 = cht.Axes(2)  # 纵坐标
axs2.Border.Color = xw.utils.rgb_to_int((0, 0, 255))  # 蓝色
axs2.Border.Weight = 3  # 线宽
axs2.HasMinorGridlines = True  # 显示次级网格线

# 纵坐标轴标题设置
axs2.HasTitle = True  # 有标题
axs2.AxisTitle.Caption = '纵坐标轴标题'  # 标题文本内容
axs2.AxisTitle.Font.Bold = True  # 字体加粗
axs2.MinimumScale = 5        # y轴最小值
axs2.MaximumScale = 50     # y轴最大值
axs2.MajorUnit = 4     # 主要刻度单位， 设置后数值轴上从最小值开始每隔4个数据显示一个主刻度线
axs2.MinorUnit = 2     # 次要刻度单位 , 设置后数值轴上从最小值开始每隔2个数据显示一个次刻度线
# axs2.MajorUnitIsAuto = True     # 自动计算主刻度单位
# axs2.MinorUnitIsAuto = True     # 自动计算次刻度单位

t1 = axs2.TickLabels     # 纵坐标轴上的刻度标签  P284
t1.NumberFormat = '0.00'   # 数字显示格式
t1.Font.Italic = True   # 字体倾斜
t1.Font.Name = 'Times New Roman'    # 字体名称
t1.Orientation = 45    # 45度方向




