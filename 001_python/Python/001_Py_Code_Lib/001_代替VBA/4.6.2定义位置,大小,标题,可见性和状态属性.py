# 定义窗口位置
import xlwings as xw

app = xw.App(visible=True,add_book=True)
# 位于显示屏 左边与上边的距离
app.api.Left = 66
app.api.Top = 21

# excel 窗口大小
app.api.Width = 835
app.api.Height = 430


# excel标题
app.api.Caption = "jimshen"

# 定义窗口的显示状态--最大化
app.api.WindowState = xw.constants.WindowState.xlMaximized    # - 4140
app.api.WindowState = xw.constants.WindowState.xlMinimized    # -4137
app.api.WindowState = xw.constants.WindowState.xlNormal      # -4143









