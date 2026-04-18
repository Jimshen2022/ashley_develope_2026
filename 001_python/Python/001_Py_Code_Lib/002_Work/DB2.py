import pyodbc

# 连接数据库
cnxn = pyodbc.connect('DSN=AFIPROD; PWD=MJ2078')

# 创建 cursor 并设置其 behavior 来访问列名
cursor = cnxn.cursor()

# 执行查询
cursor.execute("""
    SELECT T1.ITNBR, T1.HOUSE, T1.ITCLS, T1.MOHTQ, T1.WHSLC, T1.QTSYR, T2.ITDSC 
    FROM AMFLIBA.ITEMBL T1, AMFLIBA.ITMRVA T2, AMFLIBA.WHSMST T3 
    WHERE T2.ITCLS = T1.ITCLS AND T2.ITNBR = T1.ITNBR AND T2.STID = T3.STID 
      AND T1.HOUSE = T3.WHID AND T1.HOUSE='335' AND T1.MOHTQ<>0
    """)

# 获取所有行
rows = cursor.fetchall()

# 访问列值：使用行索引和列名
print('name by index:', rows[1][0])  # 通过索引访问，ITNBR 在第1列
print('name by column:', rows[1].ITNBR)  # 通过列名访问


columns = [column[0] for column in cursor.description]  # 获取列名

# 迭代行并将其转换为字典
for row in rows:
    row_dict = dict(zip(columns, row))
    print('ITNBR:', row_dict['ITNBR'])  # 通过列名访问
