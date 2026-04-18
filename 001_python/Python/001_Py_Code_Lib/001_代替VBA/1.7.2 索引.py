# dict用key取item值
dt = {'grade':5,'class':2,'id':'s195201','name':'LinXi'}

a1 = dt['name']
a2 = dt.get('name')
a3 = dt.keys()    # get所有的key
a4 = dt.values()    # get所有的values
a5 = dt.items()    # get所有的key,values
a6 = 'name' in dt
a7 = 'math' not in dt
a8 = len(dt)    # dict中 键值对 的个数
print(a3)
print(a4)
