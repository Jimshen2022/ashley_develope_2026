import pandas as pd
df = pd.read_excel(r'd:\python_file\OH.xlsx',engine='openpyxl')

df.loc[0,'ITNBR'] = 'R334999'   # modify values
df.loc[[1,2],['HOUSE','ITCLS']] = [[336,'TAT'],[337,'ZJIM']]   # modify area values
df['MOHTQ'] = df['MOHTQ'].apply(lambda x:x*1.2)

df.loc[df.ITCLS=='TA','ITNBR'] = df['ITNBR'].astype(str) + "_00001"
print(df)





