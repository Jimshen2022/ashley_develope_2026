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
