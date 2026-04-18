import re
a = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890'
m = re.findall('[AEIOU]',a)
m1 = re.findall('[^AEIOU]',a)
m2 = re.findall('[G-T]',a)
m3 = re.findall('[1-5g-t]',a,re.I)

# 中文字符
a1 = 'ABCDEFGHIJKLMNOPQRSTUVWX江苏省YZ1234567890昆山市'
m4 = re.findall('[一-龥]',a1)

# 替代
m5 = re.sub('[一-龥]','JimShen',a1)


