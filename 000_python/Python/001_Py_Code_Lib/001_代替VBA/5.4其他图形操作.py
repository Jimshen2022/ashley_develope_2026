# 5.4.1 遍历工作表中的图形
import xlwings as xw

bk = xw.Book()
sht = bk.sheets(1)

# 新建矩形
shp = sht.api.Shapes.AddShape(1, 100, 50, 200, 100)   # 矩形
ff = shp.Fill
ff.Solid    # 单色填充
ff.TwoColorGradient(3,1)    # 双色渐变填充
ff.ForeColor.RGB = xw.utils.rgb_to_int((255, 0, 0))  # 面的填充色   # 起始颜色
ff.BackColor.RGB = xw.utils.rgb_to_int((0,255, 0))  # 面的填充色   # 终止颜色

# 新建椭圆
shp2 = sht.api.Shapes.AddShape(9, 200, 30, 120, 80)
lf2 = shp2.Line  # 椭圆形区域中的线形对象,即区域的边线
lf2.ForeColor.RGB = xw.utils.rgb_to_int((255, 0, 0))  # 红色
lf2.DashStyle = 3   # 线条的线型， 点虚线
lf2.Weight = 1  # 线宽

# 新建线
shp3 = sht.api.Shapes.AddLine(20, 20, 100, 100)
lf = shp3.Line
lf.ForeColor.RGB = xw.utils.rgb_to_int((255, 0, 0))
lf.DashStyle = 5  # 线型,点虚线
lf.Weight = 1  # 线宽

sht.range('F1').value = ['名称','类型','左上角横坐标','左上角纵坐标','宽度','高度']   # 表头
i = 0
for shpx in sht.api.Shapes:
    i +=1
    sht.api.Cells(i+1,'f').Value = shpx.Name
    sht.api.Cells(i+1,'g').Value = shpx.Type
    sht.api.Cells(i+1,'h').Value = shpx.Left
    sht.api.Cells(i+1,'i').Value = shpx.Top
    sht.api.Cells(i+1,'j').Value = shpx.Width
    sht.api.Cells(i+1,'k').Value = shpx.Height


# 统计集合中自选图形的个数
j = 0
for shps in sht.api.Shapes:
    if(shps.Type==1):    # 如果为自选图形
        print(shps.Name)
        j+=1    # 累计个数
print('有'+str(j)+'个自选图形')

# 清空sht中所有图形
for x in sht.api.Shapes:
    x.Delete()
x.api.Shapes.Count
