import xlwings as xw

# app = xw.App(visible=True, add_book=False)
wb = xw.Book(r'd:\python_file\AshtonOH9.xlsx')
# wb.sheets('LIST').select()
# wb.api.Sheets('LIST').Visible = False    # 可以在hiden中取消
# wb.api.Sheets('LIST').Visible = 2     # VBE中才能取消


# 取消以上方式隐藏
# wb.api.Sheets('LIST').Visible = 1
