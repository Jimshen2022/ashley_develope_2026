import re
a = '''各地普通中小学班额信息公示网站链接,监督电话及邮箱
 市     县市区    网站链接    监督电话    监督邮箱
 省教育厅    http://sbe.sei.edu.cn:8094/    0591-81916517   jjc@shaong.cn
 某某市      http://jndu.jinn.gov.cn/art/2019/3/5art_18904_2865186.html?
 tdsourcetag=s_pcqq_aiomsg    0591-66608024    jnsjyjjjc@jn.shndong.cn
 某某市    某某区    http://www.liia.gov.cn/art/2019/3/9art_1317_2853507.html
 0591-86553601    jnlxjyjbgs@jn.shadong.cn
 某某市    某某区    http://60.316.102.41/wznrYongRi/ArticleID/45001
 0591-67987522    jnsz820296@163.com'''

# 1. 查找
# 1.1.  re.match函数查找
a1 = 'abc123def456'
m1 =re.match('abc',a1)
print(m1)

b = 'aBC123DEF456'
m1 =re.match('abc',b,re.I)
print(m1)


# 1.2. re.search函数查找
a2 = 'aBC123dEf456'
m2 = re.search('def',a2,re.I)
print(m2)

# 1.3. re.findall --返回列表
a3 = 'aBC123dEf456ABC789abC'
m3 = re.findall('abc',a3,re.I)
print(m3)

# 1.4. re.finditer   # 迭代器
a4 = 'aBC123dEf456abc789abC'
m4 = re.finditer('abc',a4,re.I)

for i in m4:
    print(i)


# 2. 替换
# 2.1 re.sub
a5 = 'aBC123dEf456abc789abC'
m5 = re.sub('abc','xyz',a5,0,re.I)    # 0 表示进行替换的最大次数, 默认值为0, 表示全部替换
print(m5)

print('-------------------------------------------------------------------------------------------------------')
# 2.2 re.subn 函数
a6 = 'aBC123dEf456abc789abC'
m6 = re.subn('abc','xyz',a6,0,re.I)
print(m6)

# 3. 分割 re.split
a7 = 'aBC&123dEf&456abc&789abC'
m7 = re.split('&',a7,1)




