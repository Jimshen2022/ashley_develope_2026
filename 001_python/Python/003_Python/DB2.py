'''
Python使用pyodbc访问数据库操作方法详解
 更新时间：2018年07月05日 11:14:45   作者：CICI_ll  
这篇文章主要介绍了Python使用pyodbc访问数据库操作方法,结合实例形式详细分析了Python基于pyodbc针对数据库的连接、查询、插入、修改、删除等操作技巧与注意事项,需要的朋友可以参考下

本文实例讲述了Python使用pyodbc访问数据库操作方法。

数据库连接

数据库连接网上大致有两种方法，一种是使用pyodbc,另一种是使用win32com.client,测试了很多遍，最终只有pyodbc成功，而且比较好用，所以这里只介绍这种方法

工具库安装

在此基础上安装pyodbc工具库，在cmd窗口执行如下语句安装

pip install pyodbc

如果安装了anaconda也可以使用conda install pyodbc

分享给大家供大家参考，具体如下：

检验是否可以正常连接数据库检查是否有一个Microsoft Access ODBC驱动程序可用于你的Python环境（在Windows上）的方法：

    >>> import pyodbc
    >>>[x for x in pyodbc.drivers() if x.startswith('Microsoft Access Driver')]

如果你看到一个空列表，那么您正在运行64位Python，并且需要安装64位版本的“ACE”驱动程序。如果您只看到['Microsoft Access Driver (*.mdb)']并且需要使用.accdb文件，那么您需要安装32位版本的“ACE”驱动程序

安装64位的ODBC 驱动器：

64位ODBC驱动器的下载地址 https://www.microsoft.com/en-us/download/details.aspx?id=13255
直接安装会报错，所以我们需要修改一下文件AccessDatabaseEngine_X64.exe，先对其进行解压，然后打开AccessDatabaseEngine_X64文件夹，有一个AceRedist.msi文件。用Orca软件将AceRedist.msi打开，找到找到LaunchCondition里面的BLOCKINSTALLATION，删除那一行数据并进行保存。然后再运行AceRedist.msi，就可以把64位的ODBC 驱动器安装成功。

如果感觉上面的操作比较麻烦，可以直接下载脚本之家小编已经处理过的版本。

下载地址：https://www.jb51.net/softs/695978.html

注意：

1、不用配置数据源
2、Orcad的下载地址 https://www.jb51.net/softs/16217.html

下面是经过脚本之家小编测试过的代码

access是2000的，理论上2010也可以。
1
2
3
4
5
6
7
8
9
10
11
	
import pyodbc 
 
DBfile = r"F:\python\caiji.mdb" # 数据库文件需要带路径
print(DBfile)
conn = pyodbc.connect(r"DRIVER={Microsoft Access Driver (*.mdb, *.accdb)};DBQ="+ DBfile +";Uid=;Pwd=;") 
cursor = conn.cursor() 
SQL = "SELECT * from sites;"
for row in cursor.execute(SQL): 
 print(row) 
cursor.close() 
conn.close()

完整测试代码
1
2
3
4
5
6
7
8
9
10
11
12
13
14
15
16
17
18
19
20
21
22
23
24
25
26
27
28
29
30
31
32
33
34
35
36
37
38
39
40
41
42
43
44
45
46
47
48
49
50
51
52
	
# -*-coding:utf-8-*-
import pyodbc
 
# 连接数据库（不需要配置数据源）,connect()函数创建并返回一个 Connection 对象
cnxn = pyodbc.connect(r'DRIVER={Microsoft Access Driver (*.mdb, *.accdb)};DBQ=.\data\goods.mdb')
# cursor()使用该连接创建（并返回）一个游标或类游标的对象
crsr = cnxn.cursor()
 
# 打印数据库goods.mdb中的所有表的表名
print('`````````````` goods ``````````````')
for table_info in crsr.tables(tableType='TABLE'):
  print(table_info.table_name)
 
 
l = crsr.execute("SELECT * from goods WHERE goodsId='0001'")# [('0001', '扇叶', 20, 'A公司', 'B公司', 2000, 2009)]
 
rows = crsr.execute("SELECT currentStock from goods") # 返回的是一个元组
for item in rows:
  print(item)
 
l = crsr.execute("UPDATE users SET username='lind' WHERE password='123456'")
print(crsr.rowcount) # 想知道数据修改和删除时，到底影响了多少条记录，这个时候你可以使用cursor.rowcount的返回值。
 
# 修改数据库中int类型的值
value = 10
SQL = "UPDATE goods " \
   "SET lowestStock=" + str(value) + " " \
   "WHERE goodsId='0005'"
 
# 删除表users
crsr.execute("DROP TABLE users")
# 创建新表 users
crsr.execute('CREATE TABLE users (login VARCHAR(8),userid INT, projid INT)')
# 给表中插入新数据
crsr.execute("INSERT INTO users VALUES('Linda',211,151)")
 
''''''
# 更新数据
crsr.execute("UPDATE users SET projid=1 WHERE userid=211")
 
# 删除行数据
crsr.execute("DELETE FROM goods WHERE goodNum='0001'")
 
# 打印查询的结果
for row in crsr.execute("SELECT * from users"):
  print(row)
 
 
# 提交数据（只有提交之后，所有的操作才会对实际的物理表格产生影响）
crsr.commit()
crsr.close()
cnxn.close()

1、连接数据库

1）直接连接数据库和创建一个游标（cursor)
1
2
	
cnxn =pyodbc.connect('DRIVER={SQL Server};SERVER=localhost;DATABASE=testdb;UID=me;PWD=pass')
cursor =cnxn.cursor()

2）使用DSN连接。通常DSN连接并不需要密码，还是需要提供一个PSW的关键字。
1
2
	
cnxn =pyodbc.connect('DSN=test;PWD=password')
cursor =cnxn.cursor()

关于连接函数还有更多的选项，可以在pyodbc文档中的 connect funtion 和 ConnectionStrings查看更多的细节
2、数据查询（SQL语句为 select ...from..where）

1）所有的SQL语句都用cursor.execute函数运行。如果语句返回行，比如一个查询语句返回的行，你可以通过游标的fetch函数来获取数据，这些函数有（fetchone,fetchall,fetchmany）.如果返回空行，fetchone函数将返回None,而fetchall和fetchmany将返回一个空列。
1
2
3
4
	
cursor.execute("select user_id, user_name from users")
row =cursor.fetchone()
if row:
 printrow

2）Row这个类，类似于一个元组，但是他们也可以通过字段名进行访问。
1
2
3
4
	
cursor.execute("select user_id, user_name from users")
row =cursor.fetchone()
print'name:', row[1]  # access by column index
print'name:', row.user_name # or access by name

3）如果所有的行都被检索完，那么fetchone将返回None.
1
2
3
4
5
	
while 1:
 row= cursor.fetchone()
 ifnot row:
 break
 print'id:', row.user_id

4)使用fetchall函数时，将返回所有剩下的行，如果是空行，那么将返回一个空列。（如果有很多行，这样做的话将会占用很多内存。未读取的行将会被压缩存放在数据库引擎中，然后由数据库服务器分批发送。一次只读取你需要的行，将会大大节省内存空间）
1
2
3
4
	
cursor.execute("select user_id, user_name from users")
rows =cursor.fetchall()
for row in rows:
 printrow.user_id, row.user_name

5）如果你打算一次读完所有数据，那么你可以使用cursor本身。

Python客栈送红包、纸质书
1
2
3
	
cursor.execute("select user_id, user_name from users"):
for row in cursor:
 printrow.user_id, row.user_name

6）由于cursor.execute返回一个cursor，所以你可以把上面的语句简化成：
1
2
	
for row in cursor.execute("select user_id, user_name from users"):
 printrow.user_id, row.user_name

7）有很多SQL语句用单行来写并不是很方便，所以你也可以使用三引号的字符串来写：
1
2
3
4
5
6
	
cursor.execute("""
  select user_id, user_name
   from users
  where last_logon < '2001-01-01'
   and bill_overdue = 'y'
  """)
3、参数

1）ODBC支持在SQL语句中使用一个问号来作为参数。你可以在SQL语句后面加上值，用来传递给SQL语句中的问号。
1
2
3
4
5
6
	
cursor.execute("""
  select user_id, user_name
   from users
  where last_logon < ?
   and bill_overdue = ?
  """,'2001-01-01','y')

这样做比直接把值写在SQL语句中更加安全，这是因为每个参数传递给数据库都是单独进行的。如果你使用不同的参数而运行同样的SQL语句，这样做也更加效率。

3）python DB API明确说明多参数时可以使用一个序列来传递。pyodbc同样支持：
1
2
3
4
5
6
	
cursor.execute("""
  select user_id, user_name
   from users
  where last_logon < ?
   and bill_overdue = ?
  """, ['2001-01-01','y'])
1
2
3
	
cursor.execute("select count(*) as user_count from users where age > ?",21)
row =cursor.fetchone()
print'%d users' %row.user_count
4、数据插入

1）数据插入，把SQL插入语句传递给cursor的execute函数，可以伴随任何需要的参数。
1
2
	
cursor.execute("insert into products(id, name) values ('pyodbc', 'awesome library')")
cnxn.commit()
1
2
	
cursor.execute("insert into products(id, name) values (?, ?)",'pyodbc', 'awesome library')
cnxn.commit()

注意调用cnxn.commit()函数：你必须调用commit函数，否者你对数据库的所有操作将会失效！当断开连接时，所有悬挂的修改将会被重置。这很容易导致出错，所以你必须记得调用commit函数。
5、数据修改和删除

1）数据修改和删除也是跟上面的操作一样，把SQL语句传递给execute函数。但是我们常常想知道数据修改和删除时，到底影响了多少条记录，这个时候你可以使用cursor.rowcount的返回值。
1
2
3
	
cursor.execute("delete from products where id <> ?",'pyodbc')
printcursor.rowcount, 'products deleted'
cnxn.commit()

2）由于execute函数总是返回cursor，所以有时候你也可以看到像这样的语句：（注意rowcount放在最后面）
1
2
	
deleted =cursor.execute("delete from products where id <> 'pyodbc'").rowcount
cnxn.commit()

同样要注意调用cnxn.commit()函数
6、小窍门

1）由于使用单引号的SQL语句是有效的，那么双引号也同样是有效的：
1
	
deleted =cursor.execute("delete from products where id <> 'pyodbc'").rowcount

2）假如你使用的是三引号，那么你也可以这样使用：
1
2
3
4
5
	
deleted =cursor.execute("""
    delete
    from products
    where id <> 'pyodbc'
    """).rowcount

3）有些数据库（比如SQL Server）在计数时并没有产生列名，这种情况下，你想访问数据就必须使用下标。当然你也可以使用"as"关键字来取个列名（下面SQL语句的"as name-count"）
1
2
	
row =cursor.execute("select count(*) as user_count from users").fetchone()
print'%s users' %row.user_count

4）假如你只是需要一个值，那么你可以在同一个行局中使用fetch函数来获取行和第一个列的所有数据。
1
2
	
count =cursor.execute("select count(*) from users").fetchone()[0]
print'%s users' %count

如果列为空，将会导致该语句不能运行。fetchone()函数返回None，而你将会获取一个错误:NoneType不支持下标。如果有一个默认值，你能常常使用ISNULL,或者在SQL数据库直接合并NULLs来覆盖掉默认值。
1
	
maxid =cursor.execute("select coalesce(max(id), 0) from users").fetchone()[0]

在这个例子里面，如果max(id)返回NULL，coalesce(max(id),0)将导致查询的值为0。

更多关于Python相关内容感兴趣的读者可查看本站专题：《Python+MySQL数据库程序设计入门教程》、《Python常见数据库操作技巧汇总》、《Python数学运算技巧总结》、《Python数据结构与算法教程》、《Python函数使用技巧总结》、《Python字符串操作技巧汇总》、《Python入门与进阶经典教程》及《Python文件与目录操作技巧汇总》

希望本文所述对大家Python程序设计有所帮助。


'''









# -*-coding:utf-8-*-
import pyodbc
 
# 连接数据库（不需要配置数据源）,connect()函数创建并返回一个 Connection 对象
cnxn = pyodbc.connect(r'DRIVER={Microsoft Access Driver (*.mdb, *.accdb)};DBQ=.\data\goods.mdb')
# cursor()使用该连接创建（并返回）一个游标或类游标的对象
crsr = cnxn.cursor()
 
# 打印数据库goods.mdb中的所有表的表名
print('`````````````` goods ``````````````')
for table_info in crsr.tables(tableType='TABLE'):
  print(table_info.table_name)
 
 
l = crsr.execute("SELECT * from goods WHERE goodsId='0001'")# [('0001', '扇叶', 20, 'A公司', 'B公司', 2000, 2009)]
 
rows = crsr.execute("SELECT currentStock from goods") # 返回的是一个元组
for item in rows:
  print(item)
 
l = crsr.execute("UPDATE users SET username='lind' WHERE password='123456'")
print(crsr.rowcount) # 想知道数据修改和删除时，到底影响了多少条记录，这个时候你可以使用cursor.rowcount的返回值。
 
# 修改数据库中int类型的值
value = 10
SQL = "UPDATE goods " \
   "SET lowestStock=" + str(value) + " " \
   "WHERE goodsId='0005'"
 
# 删除表users
crsr.execute("DROP TABLE users")
# 创建新表 users
crsr.execute('CREATE TABLE users (login VARCHAR(8),userid INT, projid INT)')
# 给表中插入新数据
crsr.execute("INSERT INTO users VALUES('Linda',211,151)")
 
''''''
# 更新数据
crsr.execute("UPDATE users SET projid=1 WHERE userid=211")
 
# 删除行数据
crsr.execute("DELETE FROM goods WHERE goodNum='0001'")
 
# 打印查询的结果
for row in crsr.execute("SELECT * from users"):
  print(row)
 
 
# 提交数据（只有提交之后，所有的操作才会对实际的物理表格产生影响）
crsr.commit()
crsr.close()
cnxn.close()