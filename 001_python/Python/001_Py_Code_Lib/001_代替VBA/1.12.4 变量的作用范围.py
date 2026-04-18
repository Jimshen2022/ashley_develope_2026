# v = 10
# print(v)
#
# def f1():
#     v = 20
#
# print(f1())
# print(v)

v = 10
print(v)

def f2():
    global v
    v = 20
def f3():
    print(v)

f2()
print(v)
f3()

