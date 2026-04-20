# 9.2.1 numpy数组
# 创建Numpy数组
import numpy as np
a = np.array([1,2,3])
print(a)

x = np.arange(5, dtype=float)
print(x)

x1 = np.arange(10,0,-2)
print(x1)

x2 = np.linspace(10,20,5)
print(x2)

x3 = np.linspace(10,20,5, endpoint=False)    # endpoint=False 表示包含最后一个值， 默认为True
print(x3)

x4 = np.logspace(1,2,num = 10)
print(x4)


lst = range(5)
it = iter(lst)
x5 = np.fromiter(it,dtype=float)
print(x5)

x6 = np.array(lst)
print(x6)

# 2 索引和切片
b1 = np.arange(8)
print(b1)
c1 = b1[2]   # 取第3个值
c2 = b1[2:5]  # 取第3~5的值，遵循左开右闭的原则
c3 = b1[2:]   # 第3个到最后的值
c4 = b1[:5]  # 取前5个值
c5 = b1[-3]  # 取倒数第3个值
c6 = b1[-3:]  # 取倒数第3个值以后的所有值 









