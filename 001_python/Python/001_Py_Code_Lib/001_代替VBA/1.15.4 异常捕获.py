b = 2
try:
    3/b
except (ZeroDivisionError,NameError) as e:
    print(e)
else:
    print('==================')

    
b = 0
try:
    3/b
except (ZeroDivisionError,NameError) as e:
    print(e)
else:
    print('==================')
finally:
    print('执行finally')