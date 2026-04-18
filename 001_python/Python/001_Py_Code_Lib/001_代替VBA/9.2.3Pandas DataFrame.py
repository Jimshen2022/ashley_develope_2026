import pandas as pd
import numpy as np

# 列表创建
data = [[1, 2, 3], [4, 5, 6], [7, 8, 9]]  # 创建二维列表
df = pd.DataFrame(data)
df1 = pd.DataFrame(data, index=['a', 'b', 'c'], columns=['A', 'B', 'C'])

# 元组创建
data3 = ((1, 2, 3), (4, 5, 6), (7, 8, 9))
df3 = pd.DataFrame(data3)

# 字典创建
dic4 = {'a': [1, 2, 3], 'b': [4, 5, 6], 'c': [7, 8, 9]}
df4 = pd.DataFrame(dic4)
df5 = pd.DataFrame.from_dict(dic4, orient='index')

# 用numpy
data5 = np.array(([1, 2, 3], [4, 5, 6], [7, 8, 9]))
df6 = pd.DataFrame(data5)
print(df6)

# DataFrame对象属性和方法
# info, describe, dtypes, shape

data7 = [[1, 2, 3], [4, 5, 6], [7, 8, 9]]
df7 = pd.DataFrame(data7, index=['a', 'b', 'c'], columns=['A', 'B', 'C'])
print(df7.info())  # 方法
print(df7.dtypes)  # 属性
print(df7.shape)  # 方法
print(df7.dtypes)  # 属性
print(len(df7))  # 函数获取df的行数和列数
print(df7.index)  # 属性, 获取行索引标签
print(df7.columns)  # 属性, 获取列索引标签
print(df7.values)  # 属性, 获取df值
print(df7.head(1))  # 方法, 获取前n行
print(df7.tail(2))  # 方法, 获取后n行
print(df7.describe())  # 方法, 获取每列数所的描述统计量

# 索引与切片
data8 = [[1, 2, 3], [4, 5, 6], [7, 8, 9]]
df8 = pd.DataFrame(data7, index=['a', 'b', 'c'], columns=['A', 'B', 'C'])
c1 = df8['A']  # Series,  取A列的值
c2 = df8[['A']]  # DataFrame
c3 = df8.loc['a']  # 取索引标签为'a'的行

c4 = df8[['A', 'C']]  # 取a，c两列
c5 = df8.loc[['a', 'c']]  # 取a，c两行

c6 = df8.loc[:, 'B']  # loc获取列
ar = df8['B'].values  # type 为 numpy.ndarray类型
c7 = df8.loc[:, 'A':'B']
c8 = df8.loc['a':'b', 'A':'B']
c9 = df8.loc['b':, :'B']

c10 = df8[df8['B'] >= 3]
c11 = df8[(df8['A'] >= 2) & (df8['C'] == 9)]
c12 = df8[df8['B'].between(4,9)]

# 获取df中A列数据取0-5范围内整数的行数据
c13 = df8[df8['A'].isin(range(6))]

# 获取df中B列数据介于4-9之间的行数据, 然后获取A列与C列的数据
c14 = df8[df8['B'].between(4,9)][['A','C']]

c15 = df8.loc[['b']]>=5
