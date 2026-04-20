# 1.5.1 创建列表
a1 = [1,2,3,4,5]
a2 = ['excel','python','world']

# 用List函数创建列表
# 1. 把字符串转为列表
a3 = list('hello')

# 2. 把区间转为列表
a4 = range(8)
a5 = list(a4)
a6 = range(0,10,2)
a7 = list(a6)

# 3.把元组，字典，集合转为列表
a8 = (1,'abc',True)
a9 = list(a8)

a10 = {'张三':89,'李四':92}
a11 = list(a10)

a12 = {1,'abc',123,'hi'}
a13 = list(a12)

# 4. 用split方法建列表
a14 = 'where are you from ?'
a15 = a14.split()

print(a1)
print(a2)
print(a3)
print(a5)
print(a7)
print(a9)
print(a11)
print(a13)
print(a15)