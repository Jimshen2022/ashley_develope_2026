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
# cht = sht.api.Shapes.AddChart().Chart    # 添加图表
cht = sht.api.Shapes.AddChart2(-1,xw.constants.ChartType.xlColumnClustered,200,20,600,500,True).Chart    # 添加图表
cht.FullSeriesCollection(1).XValues = sht.api.Range("a2:a28")        # 这个是选择x轴的资料范围，不包括列名
axs=cht.Axes(1)     # 横坐标
axs.Border.ColorIndex=3   # 红色
axs.Border.Weight=3    # 线宽
axs.HasMinorGridlines=True  # 显示次级网格线
axs2=cht.Axes(2)    # 纵坐标
axs2.Border.Color=xw.utils.rgb_to_int((0,0,255))   # 蓝色
axs2.Border.Weight=3    # 线宽
axs2.HasMinorGridlines=True    # 显示次级网格线
