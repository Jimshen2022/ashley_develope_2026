
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

# 替换
m = re.sub('某某区','某某县',a)
print(m)
print('-----------------------------------------------------------------------------------------------------')
# 查找电话号码
cl = re.findall('[0-9]{4}-[0-9]{8}',a)
print(cl)

# 查找电子邮件
em = re.findall('[0-9a-zA-Z_]*@[0-9a-zA-Z._]*\.[com,net,org,cn]{1,3}',a)
print(em)

print('********************************************************************************************************')
# finditer
em2 = re.finditer('([0-9a-zA-Z_]*)@([0-9a-zA-Z_.]*\.[com,net,org.cn]{1,3})',a)
print(em2)

for i in em2:
    un = i.group(1)
    dn = i.group(2)
    print(un+'\t'+dn)





