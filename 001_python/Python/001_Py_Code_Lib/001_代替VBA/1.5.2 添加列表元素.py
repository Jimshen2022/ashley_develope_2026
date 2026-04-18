# 1. 使用append方法
a = list(range(1,10,1))
a.append('jim')             # 一次只能加一个

# 2. 使用extend方法
a.extend(['jim',123,True])  # 一次加多个, 更适用于列表拼接
a.extend('abc')  # 追加字符串
a.extend((3,4,5))  # 追加元组
a.extend(range(1,10,2))  # 追加区间

# 3. 使用insert方法
a1 = [1,2,3,4,5,6]
a1.insert(3,'test')    # 3为插入列表的位置

# 4. 使用运算符
c = [1,2,3]
d = [4,5,6]
a2 = c+d

print(a)
print(a1)
print(a2)
