# 1. math数学函数
import math

print(dir(math))

# 2. cmath 模块的复数运算函数
import cmath

print(dir(cmath))

# 3. random 生成随机函数

import random as rd

rd01 = rd.random()
print(rd01)
print(rd.randrange(10, 50, 2))

# 使用循环生成随机数
lst = []
for i in range(10):
    lst.append(rd.randrange(10, 60, 2))
print(lst)

# 使用uniform函数可以生成指定范围内满足均匀分布的随机数
lst1 = []
for i in range(10):
    a = rd.uniform(1, 2)
    lst1.append(float('%0.3f' % a))
print(lst1)

# choice  随机选取一个数
# shuffle 函数可以将可迭代对象中的数据进行置乱,即随机排序
lst2 = [1,2,5,6,7,8,9,10]
print(rd.choice(lst2))
rd.shuffle(lst2)
print(lst2)

# sample 函数可以从指定序列中随之机选取指定大小的样本
samp = rd.sample(lst2,6)
print(samp)



