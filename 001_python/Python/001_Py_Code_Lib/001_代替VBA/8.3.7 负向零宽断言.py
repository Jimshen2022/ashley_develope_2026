import re
a = "5123Wgh123hp123456"
m = re.finditer('\w123(?![A-Z])',a)
for i in m:
    print(i.group())


# 匹配不包含who的单词
a2 = 'dwho efgh whow'
m1 = re.finditer(r'\b((?!who)\w)+\b',a)
for i in m1:
    print(i.group())

# 匹配前面不是小写字母的5位数字。
a3 = 'abcD1234567'
m3 = re.search(r'(?<![a-z])\d{5}',a)
m3.group()


print('====================================================================================================')
# 匹配不以ing结尾的单词
a4 = 'eating get climb'
m4 = re.finditer(r'\b\w+(?!ing\b)',a4)
for i in m4:
    print(i.group())

a5 = 'eating get climbing, ingg'
m5 = re.findall(r'\w+ing',a5)
