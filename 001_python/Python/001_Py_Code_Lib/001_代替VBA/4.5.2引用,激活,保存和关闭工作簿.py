import xlwings as xw

app = xw.App(visible=True,add_book=False)
wb = app.books.open(r'd:\python_file\AshtonOH.xlsx')
bk = xw.books[0]       # 在xlwings方式下,book对象是books集合的成员，可以直接使用book对象在books集合中的索引号进行引用
bk2 = xw.books(1)      # 方括号引用基数为0， 圆括号基数为1

print(bk.name)
print(bk2.name)

app2 = xw.App()
bk3 = app2.books['Book1']
print(bk3.name)

# 多个工作簿时，用pid索引来引用
pid = xw.apps.keys()
print(pid)

app3 = xw.apps[pid[0]]
bk4 = app3.books[0]
print(bk4.name)
print('-------------------------------------------------------------------------------------------------------')

# 取得工作簿名字
print(xw.books.active.name)


# 使用activate方法激活工作簿
xw.books(1).activate()


bk4.save(r'd:\python_file\bk4.xlsx')
bk4.close()
wb.close()

# bk5 = app.api.Workbooks(1)
# bk5.Save(r'd:\python_file\bk5.xlsx')


# 另存
bk.SaveAs(r'd:\python_file\bk33.xlsx')
bk.SaveCopyAs(r'd:\python_file\bk333.xlsx')













