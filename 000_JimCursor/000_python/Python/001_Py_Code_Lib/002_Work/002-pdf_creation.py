from fpdf import FPDF  # This should work with fpdf2 installed

class PDF(FPDF):
    def __init__(self):
        super().__init__()
        self.add_font('DejaVu', '', 'DejaVuSansCondensed.ttf', uni=True)
        self.set_font('DejaVu', '', 14)

    def header(self):
        self.set_font('DejaVu', '', 12)
        self.cell(0, 10, 'Python 装饰器示例', 0, 1, 'C')

    def footer(self):
        self.set_y(-15)
        self.set_font('DejaVu', '', 8)
        self.cell(0, 10, 'Page ' + str(self.page_no()), 0, 0, 'C')

# 创建 PDF 对象
pdf = PDF()
pdf.add_page()

# 添加 Unicode 字体
pdf.add_font('DejaVu', '', 'DejaVuSansCondensed.ttf', uni=True)
pdf.set_font('DejaVu', '', 14)

text = """
Python 的装饰器（Decorator）是一种高阶函数，它可以接受一个函数作为参数，并返回一个新的函数。装饰器可以在不改变原函数代码的情况下，增加原函数的功能。

下面是一个简单的装饰器示例，我们将创建一个装饰器，它会在每次调用原函数前后打印一些文本：

def my_decorator(func):
    def wrapper():
        print("装饰器添加的功能：函数调用之前")
        func()
        print("装饰器添加的功能：函数调用之后")
    return wrapper

# 使用装饰器
@my_decorator
def say_hello():
    print("原函数：hello")

say_hello()

执行这段代码，输出将会是：

装饰器添加的功能：函数调用之前
原函数：hello
装饰器添加的功能：函数调用之后

在这个例子中，my_decorator 是一个装饰器，它内部定义了一个名为 wrapper 的嵌套函数。wrapper 函数会先执行一些操作（这里是打印文本），然后调用原始函数 func()，最后再执行一些操作（再次打印文本）。最后，装饰器返回 wrapper 函数本身。

使用 @my_decorator 语法，我们将 my_decorator 应用到了 say_hello 函数上。这样，每次调用 say_hello 时，实际上是在调用 wrapper 函数。

如果你有参数需要传递给原函数，装饰器也可以相应地进行修改以接受参数：

def my_decorator(func):
    def wrapper(*args, **kwargs):
        print("装饰器添加的功能：函数调用之前")
        result = func(*args, **kwargs)
        print("装饰器添加的功能：函数调用之后")
        return result
    return wrapper

@my_decorator
def greet(name):
    print(f"原函数：hello {name}")

greet("Alice")

输出将会是：

装饰器添加的功能：函数调用之前
原函数：hello Alice
装饰器添加的功能：函数调用之后

在这个例子中，wrapper 函数使用了 *args 和 **kwargs 来接受任意数量的位置参数和关键字参数，然后将这些参数传递给原始函数 func。

装饰器不仅限于修改函数的行为，它们还可以用于记录日志、类型检查、同步线程、缓存结果等多种用途。

希望这些例子能帮助你理解 Python 装饰器的基本概念和用法。
"""

pdf.multi_cell(0, 10, text)
pdf.output('Decorator_Example.pdf')

