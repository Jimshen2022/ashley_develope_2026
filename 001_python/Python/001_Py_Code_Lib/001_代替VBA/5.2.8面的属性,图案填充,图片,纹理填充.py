import xlwings as xw

bk = xw.Book()
sht = bk.sheets(1)

shp = sht.api.Shapes.AddShape(1, 100, 50, 200, 100)
ff = shp.Fill
# ff.UserPicture(r'd:\Users\jishen\Pictures\ID\NICE PIC1.jpg')   # 图片填充
# ff.UserTextured(r'd:\Users\jishen\Pictures\ID\NICE PIC1.jpg')     # 纹理填充
ff.PresetTextured(9)    # 预设纹理, 绿色大理石   P252


# ff.ForeColor.RGB = xw.utils.rgb_to_int((255, 0, 0))  # 面的填充色
# ff.Patterned(3)    # 图案填充
# ff.BackColor.RGB = xw.utils.rgb_to_int((0,255,0))


