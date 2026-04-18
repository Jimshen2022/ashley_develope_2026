import xlwings as xw
xw.App(visible=True,add_book=False)
wb = xw.Book(r'd:\python_file\AshtonOH9.xlsx')
sht = wb.sheets['OH']
rng = sht.range('b2:d5')

print(rng[1:3,1:3].value)
print(rng[1:3,1:3].address)


# print(rng.value)
# print(rng.sheet)
# print(rng.shape)
# print(rng.row)




#
#
# # a3:c8 xlwings
# sht.range("a3:c8").select()
# sht.range("a3","c8").select()
# sht.range(sht.range('a3'),sht.range('c8')).select()
# sht.range(sht.cells(3,1),sht.cells(8,3)).select()
# sht.range((3,1),(8,3)).select()
#
#
# # offset -- xlwings
# sht.range("a3:c8").offset(1).select()   # a4:c9
# sht.range("a3:c8").offset(0,1).select()   # b3:d8
# sht.range("a3:c8").offset(1,1).select()   # b4:d9
#
# # 使用名称引用区域 xlwings，  a3:c8 = mydata
# cl = sht.range("a3:c8")
# cl.name = 'mydata'
# sht.range('mydata').select()
#
# # 引用区域内的单元格xlwings
# rng = sht.range('b2:d5')
# rng[0,0].select()     # B2，注意基数为0
#
#
#
#
