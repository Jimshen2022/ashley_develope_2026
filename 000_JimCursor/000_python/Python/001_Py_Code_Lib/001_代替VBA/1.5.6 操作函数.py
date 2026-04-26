a = [1,2,3,2,2,4,5,6,5,5,5,2]
b = len(a)        # 获取列表的长度
c = a.count(2)     # count方法仇人相见定元素在列表中出现的次数
d = 1 in a
f = 9 not in a

student = ['Jim',90]
print('姓名:{0[0]}, 数学成绩：{0[1]}'.format(student))

print(b)
print(c)
print(d)
print(f)