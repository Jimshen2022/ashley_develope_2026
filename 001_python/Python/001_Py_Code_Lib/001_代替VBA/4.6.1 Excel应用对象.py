import xlwings as xw
app = xw.App()
app2 = xw.App()

a = app.books.count
a1 = app.api.Workbooks.Count

# 激活app2
app2.activate()

# 查看当前活动工作簿中的活动工作表的A1单元格的值
a2 = app.range('a1').value

app.range('c3').value = 10
app2.range('a3').value = 10
app.range('c3').select()

xw.apps
xw.apps.add()

a3 = xw.apps.count

# 获取每个bk的pid值
pid = xw.apps.keys()
print(pid)

# 应用标题
name = xw.apps[pid[0]].api.Caption

