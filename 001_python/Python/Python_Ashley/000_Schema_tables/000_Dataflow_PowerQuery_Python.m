let
    // 连接到 Power Platform Dataflows
    Source = PowerPlatform.Dataflows(null),

    // 获取所有工作区
    Workspaces = Source{[Id="Workspaces"]}[Data],

    // 选定特定的工作区
    #"5839814b-ec95-48ea-a07a-ec0241ac9946" = Workspaces{[workspaceId="5839814b-ec95-48ea-a07a-ec0241ac9946"]}[Data],

    // 选定特定 Dataflow
    #"b28ca4a8-74c9-45bf-b91c-57b7b0797a6e" = #"5839814b-ec95-48ea-a07a-ec0241ac9946"{[dataflowId="b28ca4a8-74c9-45bf-b91c-57b7b0797a6e"]}[Data],

    // 读取实体数据 ashton_trip_fill
    ashton_trip_fill_ = #"b28ca4a8-74c9-45bf-b91c-57b7b0797a6e"{[entity="ashton_trip_fill", version=""]}[Data],

    // 执行 Python 脚本
    PythonStep = Python.Execute(
        "
import pandas as pd

# 重命名列
dataset = dataset.rename(columns={'FLTRIPNO': 'Trip_number'})

# 转换时间列为 datetime 类型
dataset['FLRDTE_PLUS_12H'] = pd.to_datetime(dataset['FLRDTE_PLUS_12H'])
dataset['FLPDTE_PLUS_12H'] = pd.to_datetime(dataset['FLPDTE_PLUS_12H'])

# 计算时间间隔（小时），保留两位小数（字符串形式）
dataset['Time_Difference_Hours'] = (
    (dataset['FLPDTE_PLUS_12H'] - dataset['FLRDTE_PLUS_12H']).dt.total_seconds() / 3600
).apply(lambda x: format(x, '.2f') if pd.notna(x) else None)

# 定义时间分类函数
def classify_time_difference(hours_str):
    try:
        hours = float(hours_str)
    except (TypeError, ValueError):
        return 'Unknown'

    if hours < 1:
        return 'a. 0-1 Hour'
    elif hours < 2:
        return 'b. 1-2 Hour'
    elif hours < 3:
        return 'c. 2-3 Hour'
    elif hours < 4:
        return 'd. 3-4 Hour'
    elif hours < 5:
        return 'e. 4-5 Hour'
    elif hours < 6:
        return 'f. 5-6 Hour'
    elif hours < 7:
        return 'g. 6-7 Hour'
    elif hours < 8:
        return 'h. 7-8 Hour'
    elif hours < 12:
        return 'i. 8-12 Hour'
    elif hours < 24:
        return 'j. 12-24 Hour'
    elif hours < 36:
        return 'k. 1-1.5 Days'
    elif hours < 48:
        return 'l. 1.5-2 Days'
    else:
        return 'm. Over 2 days'

# 应用分类函数
dataset['Time_Differ_Range'] = dataset['Time_Difference_Hours'].apply(classify_time_difference)

# 提取请求日期（只保留日期）
dataset['fill_request_date'] = dataset['FLRDTE_PLUS_12H'].dt.date

# 输出结果
output = dataset
        ",
        [dataset = ashton_trip_fill_]
    ),

    // 获取 Python 输出结果
    output = PythonStep{[Name="output"]}[Value]
in
    output
