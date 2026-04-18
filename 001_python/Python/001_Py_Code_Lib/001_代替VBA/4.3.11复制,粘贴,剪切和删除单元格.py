import xlwings as xw

wb = xw.Book(r'd:\python_file\AshtonOH9.xlsx')
sht = wb.sheets['OH']
sht.select()
sht.range('a1:g10').select()
wb.selection.api.Copy()
sht.range('s1').select()
sht.api.Paste()

# 简化的复制与粘贴
sht.api.Range('g1:g' + str(sht.used_range.last_cell.row)).Copy(sht.api.Range('m1'))

sht2 = wb.sheets['jim']
sht.api.Range('a1').CurrentRegion.Copy(sht2.api.Range('k1'))

# 选择性粘贴 p165-p166
sht.api.Range("a1:e1").Copy()
sht.api.Range("a4:e4").PasteSpecial(Paste=xw.constants.PasteType.xlPasteValues)

# 批注
sht.api.Range("b1").AddComment('CommentTest')
sht.api.Range('a1:e1').Copy()
sht.api.Range("a5:e5").PasteSpecial(Paste=xw.constants.PasteType.xlPasteComments)

# 复制格式,  第2行的格式复制到第6行， sheet['OH']
sht.range("a2").color = (0, 255, 0)
sht.api.Range("a2").Font.Size = 20
sht.api.Range("a2").Font.Bold = True
sht.api.Range("a2").Font.Italic = True
sht.api.Range('a2:e2').Copy()
sht.api.Range("a6:e6").PasteSpecial(Paste=xw.constants.PasteType.xlPasteFormats)

# CUT 方法
sht.api.Range('a1:a10').Cut(sht.api.Range('N1'))


# 删除 Delete
sht3 = wb.sheets['Sheet3']
sht3['a2'].delete(shift='up')
sht3['b2:g10'].delete()













