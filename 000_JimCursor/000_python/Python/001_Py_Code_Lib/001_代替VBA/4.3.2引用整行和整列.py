# 1.引用整行 xlwings
sht.range('1:1').select()
sht['1:1'].select()

# 引用多行 xlwings
sht.range("1:5").select()
sht["1:5"].select()
sht[0:5,:].select()

# 引用整列 xlwings
sht.range('a:a').select()


# 引用多列xlwings
sht.range("b:c").select()
sht[:,1:3].select()




