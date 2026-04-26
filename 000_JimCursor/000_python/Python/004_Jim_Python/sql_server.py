import pymssql
connect = pymssql.connect('JIM_SHEN','Jim_Shen','1234',)
if connect:
    print('connected successful')

cursor = connect.cursor()
cursor.execute('create table student(id varchar(20))')

print('operation successfully')
connect.commit()
cursor.close()
connect.close()

