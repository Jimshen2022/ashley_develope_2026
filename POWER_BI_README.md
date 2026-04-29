# Power BI PBIX 到 PBIP 批量转换工具

## 📋 功能说明

这个工具可以帮助你自动化以下流程：
1. 从源目录获取所有 `.pbix` 文件
2. 在目标目录创建对应的文件夹结构
3. 逐个打开 Power BI 文件并转换为 `.pbip` 格式

## 🚀 使用方法

### 方法 1: 交互式转换（推荐）

```bash
python power_bi_converter.py
```

**操作步骤：**
1. 脚本会自动获取所有 `.pbix` 文件
2. 自动创建对应的文件夹结构
3. Power BI Desktop 会依次打开每个文件
4. 按照提示在 Power BI 中执行：
   - 点击 **文件** → **另存为**
   - 选择保存类型：**Power BI 项目文件 (*.pbip)**
   - 文件名和保存位置已经指定
   - 点击保存并关闭
5. 回到终端按 Enter 继续下一个文件

### 方法 2: 自动化转换

```bash
python power_bi_auto_converter.py
```

## 📁 目录结构

转换完成后的目录结构：

```
power_bi_develop_2026/
└── US_PBIP/
    ├── Additional Reports/
    │   └── Additional Reports.pbip
    ├── AFI Wholesale Inventory Shrink/
    │   └── AFI Wholesale Inventory Shrink.pbip
    ├── AGV ROI Tracking - Receiving Robotics/
    │   └── AGV ROI Tracking - Receiving Robotics.pbip
    └── ... (其他文件)
```

## 🔧 前提条件

1. **Power BI Desktop** 已安装
   - 下载链接: https://powerbi.microsoft.com/downloads/
   - 默认安装路径: `C:\Program Files\Microsoft Power BI Desktop\bin\PBIDesktop.exe`

2. **Python 3.7+** 已安装
   - 检查：`python --version`

3. **源目录存在**
   - 默认路径: `D:\GitHub\ashley_develope_2026\00-PowerBI\DC BI`

## ⚙️ 配置项

在脚本中修改这些变量来改变行为：

```python
# 源目录（包含所有 .pbix 文件）
self.source_dir = r"D:\GitHub\ashley_develope_2026\00-PowerBI\DC BI"

# 目标目录（转换后的 .pbip 文件存储位置）
self.target_base_dir = r"D:\GitHub\power_bi_develop_2026\US_PBIP"
```

## 📊 功能对比

| 功能 | power_bi_converter.py | power_bi_auto_converter.py |
|------|----------------------|----------------------------|
| 自动创建文件夹 | ✅ | ✅ |
| 打开 Power BI | ✅ | ✅ |
| 人工操作提示 | ✅ | ✅ |
| 日志记录 | ❌ | ✅ |
| 错误处理 | ✅ | ✅ |
| 批量处理 | ✅ | ✅ |

## 🐛 故障排除

### 问题 1: 未找到 Power BI Desktop

**解决方案：**
1. 确保 Power BI Desktop 已安装
2. 修改脚本中的 `pbi_desktop_path` 为正确的安装路径
3. 查看安装位置：开始菜单 → Power BI Desktop → 右键 → 打开文件位置

### 问题 2: 权限错误

**解决方案：**
1. 以管理员身份运行 PowerShell/CMD
2. 确保目标目录有写入权限

### 问题 3: 文件未转换

**解决方案：**
1. 确保在 Power BI 中手动保存为 `.pbip` 格式
2. 确保选择的保存位置正确
3. 检查日志文件：`power_bi_conversion.log`

## 📝 日志文件

转换过程的详细日志保存在：`power_bi_conversion.log`

查看日志：
```bash
cat power_bi_conversion.log
```

## 🎯 工作流程图

```
开始
  ↓
获取所有 .pbix 文件
  ↓
创建文件夹结构
  ↓
循环处理每个文件：
  ├─ 启动 Power BI Desktop
  ├─ 打开 .pbix 文件
  ├─ 用户在 Power BI 中另存为 .pbip
  ├─ 关闭 Power BI
  ├─ 检查转换结果
  ├─ 记录日志
  └─ 继续下一个文件
  ↓
显示汇总结果
  ↓
结束
```

## 🔐 安全提示

1. 脚本不会删除原始 `.pbix` 文件
2. 建议在运行前备份重要文件
3. 转换后的 `.pbip` 文件存储在新的目录中

## 📞 技术支持

如遇问题，请检查：
1. Power BI Desktop 版本（建议最新版本）
2. Python 版本（建议 3.8+）
3. 系统权限和磁盘空间
4. 查看日志文件获取详细错误信息

## 📌 版本历史

- **v1.0** (2024-05-21)
  - 初始版本
  - 支持批量转换
  - 自动文件夹创建
  - 详细日志记录
