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
cht.HasTitle=True
cht.ChartTitle.Text = '这是图表标题'    #e3 u24
cht.SetElement(1)     # 将标题显示为居中覆盖
cht.SetElement(201)     # 显示数据标签
cht.SetElement(104)     # 显示数据标签

'''
# 根据图形和区域的位置与大小属性进行固定
rng = sht.api.Range('e3:u24')
cht.Left = rng.Left + 10  
cht.Top = rng.Top + 10
cht.Width = rng.Width - 2
cht.Height = rng.Height - 2
'''

