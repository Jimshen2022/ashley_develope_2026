# 1. 交运算与并运算
a = {1,2,3} & {4,5,6,1}    # 求交集  方法一
b = {'jim','linda','Mindy',1}
c = a.intersection(b)    # 求交集 方法二


#  并集
a1 = {1,2,3} | {4,5,6,1}
a2 = {'jim','linda','Mindy',1}
a3 = a1.union(a2)


# 2. 差运算
a4 = {1,2,3,6,7,8,9,10,4,5}
a5 = {'jim','linda','Mindy',1,3}
a6 = a4-a5
a7 = a4.difference(a5)
a8 = a5.difference(a4)

# 3. 对称差集运算
a9 = a4 ^ a5
a10 = a4.symmetric_difference(a5)

# 4. 子集, 真子集, 超集和真超集
a11 = {1,2,3,6,7,8,9,10,4,5}
a12 = {1,2,3,6}

print(a12 <= a11)
print(a12.issubset(a11))
print(a11.issuperset(a12))





