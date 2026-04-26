import pandas as pd

# 增加行
df = pd.read_excel(r'd:\python_file\OH.xlsx',usecols=['ITNBR','HOUSE','ITCLS','MOHTQ','ITDSC'],nrows=10)
df.loc[10] = ['TVjimshen','335','ZDUM',10000,'ForTesting']   # 增加行

# 也可以用append方法
s = pd.DataFrame([['tv2jimshen','335','zdzz',500,'fortest2']],columns=['ITNBR','HOUSE','ITCLS','MOHTQ','ITDSC'])
df = df.append(s,ignore_index=True)

# 增加列
df['NewColumn'] = df['MOHTQ']*9

print(df)
