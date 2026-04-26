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

# 创建更多类型的图表
sht.api.Range('b1:c28').Select()
cht = sht.api.Shapes.AddChart().Chart

cht.FullSeriesCollection(1).XValues = sht.api.Range("a2:a28")        # 这个是选择x轴的资料范围，不包括列名
ser2 = cht.SeriesCollection('CG')  # 第2个序列
ser2.ChartType = xw.constants.ChartType.xlLine  # 折线图
ser2.Smooth = True  # 平滑处理
ser2.MarkerStyle = xw.constants.MarkerStyle.xlMarkerStyleTriangle  # 标记
ser2.MarkerForegroundColor = xw.utils.rgb_to_int((0, 0, 255))  # 颜色
ser2.HasDataLabels = True  # 数据标签

# 更改某个数据点的格式
ser2.Points(3).MarkerForegroundColor=xw.utils.rgb_to_int((0,0,255))
ser2.Points(3).MarkerBackgroundColor=xw.utils.rgb_to_int((0,0,255))
ser2.Points(3).MarkerStyle=xw.constants.MarkerStyle.xlMarkerStyleDiamond
ser2.Points(3).MarkerSize = 13

# 更改直方图某个柱子颜色
# RGB
ser = cht.SeriesCollection('UPH')
# ser.Format.Fill.ForeColor.RGB = xw.utils.rgb_to_int((0,255,0))

# 主题颜色着色
# ser.Format.Fill.ForeColor.ObjectThemeColor = 10

# 使用配色方案着色
ser.Format.Fill.ForeColor.SchemeColor=3


num = ser2.Points().Count
print(num)