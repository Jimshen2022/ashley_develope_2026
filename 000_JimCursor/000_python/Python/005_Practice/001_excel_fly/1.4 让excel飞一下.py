import xlwings as xw
app = xw.App(visible=True, add_book=False)
for i in range(1,21):
    workbook = app.books.add()
    workbook.save(f'练习{i}.xlsx')
    workbook.save(f'c:\jishen\Downloads\练习{i}.xlsx')
    workbook.close()
app.quit()



