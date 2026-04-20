# 方法一
# print("占位符1 占位符2" % ('字符串1','字符串2'))
print("hello %s" % "python")    # %s 格式化字符串
print("%s %s %d" % ('hello','python',2021))    # %d 格式化整数
print("%19.5f" % 3.1415927111)    # %f 格式化符点数,可指定小数点后的精度，  19指整个数字的宽度，包含小数点前后的位数
print("%10.5f" % 3.1415927111)    # %f 格式化符点数,可指定小数点后的精度
print("%+10.5f" % 3.1415927111)    # %f 格式化符点数,可指定小数点后的精度
print("%010.5f" % 3.14159271115555)    # %f 格式化符点数,可指定小数点后的精度

# 方法二 format
print("不指定顺序:{}".format('hello','python'))
print("指定顺序:{1} {0}".format('hello','python'))

print("{0}{1}{0}{1}".format('hello','python'))
print("保留2位小数:{:.2f}".format(3.1415))
print("显示为百分比格式：{:.3%}".format(0.12))
print("使用参数名称匹配:{name},{age}".format(age=30,name='张三'))

