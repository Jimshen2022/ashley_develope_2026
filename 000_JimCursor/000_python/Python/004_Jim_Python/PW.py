import itertools

# 定义字符集
characters = [
    '0', '1', '2', '3', '4', '5', '6', '7', '8', '9',
    'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z',
    'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z',
    '~', '!', '@', '#', '$', '%', '^', '&', '*'
]

# 定义文件路径
file_path = r"D:\Users\Documents\GitHub\Python2038\004_Jim_Python\psswdNum20241003.txt"

# 打开文件以写入模式
with open(file_path, 'w') as file_object:
    # 生成所有可能的11位密码组合
    for combination in itertools.product(characters, repeat=11):
        password = ''.join(combination)
        file_object.write(password + '\n')
        # 如果生成文件太大，可以考虑注释掉下面的打印语句
        # print(password)
