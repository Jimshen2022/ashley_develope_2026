# f = open(r'd:\python_file\bfest.cad','wb')
# f.write(bytes(('10 '+'10 '+'100+ '+'200'),"utf-8"))
# f.close()


f = open(r'd:\python_file\bfest.cad','rb')
ln = f.read().decode('utf-8')
f.close()
dt = ln.split(" ")
xl = int(dt[0])
print(xl)




