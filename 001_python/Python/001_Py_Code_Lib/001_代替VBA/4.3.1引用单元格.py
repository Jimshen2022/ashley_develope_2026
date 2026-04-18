# 引用单个单元格 xlwings
sht.range('a1').select()
sht.range(1,1).select()
sht['a1'].select()
sht.cells(1,1).select()
sht.cells(1,'a').select()

# 引用多个单元格 xlwings
sht.range('b2,c5,c7').select()
sht['b2,c5,d7'].select()


# 引用活动单元格
import xlwings as xw
pid = xw.apps.keys()
app = xw.apps[pid[0]]
sht['c3'].value = 3.0
sht['c3'].select()
a = app.api.ActiveCell.Value

# 使用名称引用单元格 xlwings
c1= sht.cells(3,3)
c1.name = 'test'
sht.range('test').select()

# 使用变量引用单元格 xlwings
i = 3
sht.range('c'+str(i)).value
sht.cells(i,i).value



