import xlwings as xw
import pandas as pd
import numpy as np
sheet = xw.Book().sheets[0]
data = np.arange(1000_000 * 20).reshape(1000_000, 20)
df = pd.DataFrame(data=data)
sheet['A1'].options(chunksize=10_000).value = df

# And the same for reading:
# As DataFrame
df = sheet['A1'].expand().options(pd.DataFrame, chunksize=10_000).value
# As list of list
df = sheet['A1'].expand().options(chunksize=10_000).value


'''
# 字典转换器
# 字典转换器把Excel中的两列转换成一个字典。

>>> sht = xw.sheets.active
>>> sht.range('A1:B2').options(dict).value
{'a': 1.0, 'b': 2.0}
>>> sht.range('A4:B5').options(dict, transpose=True).value
{'a': 1.0, 'b': 2.0}
'''




