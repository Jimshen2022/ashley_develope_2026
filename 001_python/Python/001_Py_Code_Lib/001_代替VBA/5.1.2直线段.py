import xlwings as xw

bk = xw.Book()
sht = bk.sheets[0]
shp = sht.api.Shapes.AddLine(10, 10, 250, 250)  # 创建线段
ln = shp.Line  # 获取线型对象
ln.DashStyle = 3  # 设置线形对象的属性: 线型,颜色, 线宽
ln.ForeColor.RGB = xw.utils.rgb_to_int((255, 0, 0))
ln.Weight = 5


'''
constants 存放常量的地方，例如api、一些配置项 
utils 存放工具类函数 ├── pages 页面文件
'''