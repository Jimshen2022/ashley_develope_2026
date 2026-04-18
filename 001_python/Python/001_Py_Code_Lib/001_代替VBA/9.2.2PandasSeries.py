# 列表,元组,字典,numpy数组 转换为Series

import pandas as pd
import numpy as np

ser = pd.Series([10, 20, 30, 40])
print(ser)

ser2 = pd.Series((10, 20, 30, 40))
print(ser2)

ser3 = pd.Series({'a': 10, 'b': 20, 'c': 30, 'd': 40, 'e': 50})
print(ser3)

ser4 = pd.Series(np.arange(10, 50, 10))
print(ser4)

# 创建Series时指定index
ser5 = pd.Series(np.arange(10, 50, 10), index=['a', 'b', 'c', 'd'], name='JimShen')
print(ser5)
print('*********************************************************************************************')
shapevalue = ser5.shape
sizevalue = ser5.size
x = ser5.index
y = x.values
print(y)
ser5_value = ser5.values
ser5_head = ser5.head(2)
ser5_tail = ser5.tail(2)

# 数据索引和切片
ser6 = pd.Series(np.arange(10, 50, 10), index=['a', 'b', 'c', 'd'])
r1 = ser6['b']
t1 = type(r1)
r2 = ser6[['a', 'd']]
t2 = type(r2)

r3 = ser6.loc[['a', 'b']]
r4 = ser6.iloc[[0, 3]]
r5 = ser6['a':'c']
r6 = ser6.iloc[1:]

# 4.布尔索引
r7 = ser6[ser6.values <= 20]
r8 = ser6[ser6.index != 'a']
