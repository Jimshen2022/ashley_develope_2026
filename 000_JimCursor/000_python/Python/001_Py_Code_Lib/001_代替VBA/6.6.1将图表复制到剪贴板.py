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
# cht = sht.api.Shapes.AddChart().Chart  # 添加图表  p266
rng = sht.api.Range('e1:u24')
cht = sht.api.Shapes.AddChart2(-1, xw.constants.ChartType.xlColumnClustered, rng.Left, rng.Top, rng.Width - 2,
                               rng.Height - 2, True).Chart  # 添加图表

cht.FullSeriesCollection(1).XValues = sht.api.Range("a2:a28")  # 这个是选择x轴分类资料范围，不包括列名
cht.HasTitle = True
cht.ChartTitle.Text = '这是图表标题'  # e3 u24
cht.SetElement(1)  # 将标题显示为居中覆盖
cht.SetElement(201)  # 显示数据标签
cht.SetElement(104)  # 显示数据标签

# 图表区域设置
cha = cht.ChartArea  # 图表区域
cha.Format.Fill.ForeColor.RGB = xw.utils.rgb_to_int((155, 255, 0))
cha.Shadow = True  # 显示阴影
pla = cht.PlotArea  # 绘图区
pla.Format.Fill.UserPicture(r'd:\Users\jishen\Pictures\ID\NICE PIC1.jpg')
cht.SeriesCollection(1).Format.Fill.ForeColor.RGB = xw.utils.rgb_to_int((255, 255, 0))
cht.Axes(2).HasMajorGridlines = False

cha.Shadow=False
pla.Format.Shadow.Visible  = True
pla.Format.Shadow.OffsetX = 3   # 阴影的水平偏移
pla.Format.Shadow.OffsetY = 3   # 阴影的垂直偏移


# 设置图例
cht.Legend.Font.Italic = True
cht.Legend.Format.Fill.ForeColor.RGB = xw.utils.rgb_to_int((255,255,0))
cht.Legend.Format.Line.ForeColor.RGB = xw.utils.rgb_to_int((0,0,255))
cht.Legend.Position = -4152  #  -4131左, -4107下， -4160上， -4152右

# 将图表复制到剪贴板
cht.CopyPicture()
sht2 = wb.api.Worksheets.Add()
sht2.Range('c3').Select()
sht2.Paste()
cht.Export(r'd:\python_file\chttest.jpg')














