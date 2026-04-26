import pandas as pd

# loading destination into dict
data = pd.read_excel(r'C:\Users\jjshe\Downloads\Wanek_Allocation_List.xlsx', sheet_name='Destination',dtype={'Destination':str,'Whs':str})
dict1 = dict(zip(data['Destination'],data['Whs']))
print(dict1)

df = pd.read_excel(r'C:\Users\jjshe\Downloads\Wanek_Allocation_List.xlsx',sheet_name=0,skiprows=1,
                   dtype={'Item':str,'Priority':str,'WHs':str,'Total':str,'Destination':str})

df['Due'] = pd.to_datetime(df['Due'],errors='coerce')
df['Due'] = df['Due'].dt.strftime('%m/%d/%Y')
df.set_index=['Item','Destination']
print(df)

# import excel file Allocated_List.xlsx into df2 then loaded into dictionary:
df2 = pd.read_excel(r'C:\Users\jjshe\Downloads\Allocated_List.xlsx',sheet_name=0,usecols='B,D,H:Z',
                    dtype={'Production Item':str})
df2['*MFG Date'] = pd.to_datetime(df2['*MFG Date'],errors='coerce')
df2['*MFG Date'] = df2['*MFG Date'].dt.strftime('%m/%d/%Y')
df2 = df2[df2['*MFG Date']==df['Due'][0]]
df2.reset_index(inplace=True)
df2.drop(columns='index',inplace=True)
print(df2)
# 逆透视
df2=pd.melt(df2,id_vars=['*MFG Date','Production Item'],var_name='Destination',value_name='AllocatedQty')
df2 = df2[df2['AllocatedQty'] != 0]
df2.reset_index(inplace=True)
df2.drop(columns='index',inplace=True)
df2['Whs'] = df2['Destination'].apply(lambda  x: dict1[x])    # through dict1 to query destination whse for comparision with df1

df2.rename(columns={'*MFG Date':'Due','Production Item':'Item','Whs':'WHs'},inplace=True)
df2.set_index=['Item','WHs']
print(df2)

# df['Total'] =df['Total'].apply(pd.to_numeric,errors='coerce')
df['Total'] =df['Total'].astype(int)

df3 = pd.merge(df,df2,on = ['Item','WHs'],how='outer')
df3['AllocatedQty-PlannedQty(Total)'] = df3['AllocatedQty']-df3['Total']
df3 = df3[df3['AllocatedQty-PlannedQty(Total)'] != 0]
df3.to_excel('123.xlsx',index=False)






