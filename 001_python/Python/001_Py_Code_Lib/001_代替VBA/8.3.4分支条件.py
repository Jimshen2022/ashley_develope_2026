import re
a = 'ABC1234W8T32131'
m1 = re.findall(r'ABC|W\d+',a)     # | 表示条件 或
m2 = re.findall(r'ABC|W....',a)     # | 表示条件 或

a2 = '10公斤 20kg 30千克'
m3 = re.findall(r'\d+(公斤|千克|kg)',a2)
m33 = re.findall(r'\d+公斤|\d+千克|\d+kg',a2)
m4 = re.finditer(r'\d+(公斤|千克|kg)',a2)
for i in m4:
    print(i.group(0))




