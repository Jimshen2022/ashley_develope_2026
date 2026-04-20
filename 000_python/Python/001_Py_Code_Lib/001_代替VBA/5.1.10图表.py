import xlwings as xw
bk = xw.Book(r'D:\python_file\AshtonOH.xlsx')
sht = bk.sheets['INV.TURNS']
sht.api.Range('A1').CurrentRegion.Select()

# 图表类型可参考 P235 表5-9
sht.api.Shapes.AddChart2(-1,xw.constants.ChartType.xlColumnClustered,
                         30,150,1600,900,True)    # -1为默认样式

sht.api.Shapes.AddChart2(-1,xw.constants.ChartType.xlPie,
                         30,150,1600,900,True)    # -1为默认样式




