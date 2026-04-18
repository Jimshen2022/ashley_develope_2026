import re

a = 'ABCABCWTU238'
m = re.findall('((ABC){2})', a)
m0 = m[0][0]
m1 = re.search('((ABC){2})', a)
m2 = m1.group()

a1 = 'abcWT12389WT'
m4 = re.findall(r'WT\d+WT', a1)

m3 = re.finditer(r'(WT)\d+\1', a1)
for i in m3:
    print(i.group())

a2 = 'abWTWTPRPR123WTPR56'
m4 = re.search(r'((WT){2})((PR){2})\d+\2\4', a2)
x = m4.group(1)
x1 = m4.group(2)
x2 = m4.group(3)
x3 = m4.group(4)

# 捕获与非捕获
a3 = 'abCD123CDbc'
m5 = re.finditer(r'(?:ab)(CD)\d+\1', a3)
# for i in m5:
#     print(i.group())

m6 = re.search(r'(?:ab)(CD)\d+\1', a3)
m7 = m6.groups()


