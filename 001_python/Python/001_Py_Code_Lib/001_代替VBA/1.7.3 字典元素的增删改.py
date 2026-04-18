dt = {'grade':5,'class':2,'id':'s195201','name':'LinXi'}
dt['score'] = 90    # 增
dt['name']='MuFeng'  # 改

# update 方法
dt2 = {'grade':5,'class':2,'id':'s195201','name':'LinXi'}
dt2.update({'Score':90})   # 增
dt2.update({'class':3})   # 改
del dt2['grade']    # 删键值对

dt3 = {'grade':5,'class':2,'id':'s195201','name':'LinXi'}
a1 = dt3.pop('name')     # 删键值对

dt4 = {'grade':5,'class':2,'id':'s195201','name':'LinXi'}
dt4.clear()    # 清空所有键值对

