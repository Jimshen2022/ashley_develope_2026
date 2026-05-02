# 🔧 Power BI 转换工具 - 故障排除指南

## ❌ 问题 1: "源目录不存在" 错误

### 症状：
```
❌ 源目录不存在: D:\GitHub\ashley_develope_2026\00-PowerBI\DC BI
```

### 原因：
- 源目录的实际路径与脚本中设置的不同
- Power BI 文件可能存储在其他位置
- 目录名称可能不同

### ✅ 解决方案：

#### 方法 1: 自动查找 Power BI 文件
```bash
# 双击运行
find_pbix_files.bat
```
这会扫描你的计算机找到所有 .pbix 文件

#### 方法 2: 手动配置路径
```bash
# 双击运行
config_paths.bat
```
然后输入正确的源目录路径

#### 方法 3: 直接编辑 BAT 文件
编辑 `run_power_bi_converter.bat`，找到这一行：
```batch
set SOURCE_DIR=D:\GitHub\ashley_develope_2026\00-PowerBI\DC BI
```
改为你的实际路径，例如：
```batch
set SOURCE_DIR=D:\My Power BI Files
set SOURCE_DIR=C:\Users\YourName\Documents\Power BI
```

#### 方法 4: 检查实际位置
```powershell
# 在 PowerShell 中运行
Get-ChildItem -Path "D:\GitHub" -Filter "*.pbix" -Recurse | Select-Object FullName
```

---

## ❌ 问题 2: 编码显示乱码

### 症状：
菜单显示的文本看起来像：
```
ΘÇëµï⌐µôìΣ╜£  (而不是中文)
```

### 原因：
- BAT 文件使用了错误的字符编码
- Windows CMD 的区域设置问题

### ✅ 解决方案：

#### 方法 1: 使用改进版本（推荐）
```bash
# 双击运行新版本（已修复编码问题）
run_power_bi_converter_v2.bat
```

#### 方法 2: 使用 PowerShell（最佳）
```powershell
cd D:\GitHub\ashley_develope_2026
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope CurrentUser
.\Convert-PowerBIFiles.ps1
```

#### 方法 3: 使用 Python
```bash
python power_bi_converter.py
```

---

## ❌ 问题 3: Python 找不到

### 症状：
```
'python' is not recognized as an internal or external command
```

### 原因：
- Python 未安装
- Python 未添加到系统 PATH

### ✅ 解决方案：

#### 检查 Python 安装：
```cmd
python --version
```

#### 如果未安装，下载：
- https://www.python.org/downloads/
- 安装时勾选"Add Python to PATH"

#### 如果已安装但找不到：
- 重启 CMD/PowerShell
- 或使用完整路径：
```cmd
C:\Users\YourName\AppData\Local\Programs\Python\Python39\python.exe power_bi_converter.py
```

---

## ❌ 问题 4: Power BI Desktop 找不到

### 症状：
```
❌ Power BI Desktop 不存在
```

### 原因：
- Power BI Desktop 未安装
- 安装路径不标准

### ✅ 解决方案：

#### 检查是否安装：
- 开始菜单搜索"Power BI Desktop"
- 如果找不到，从这里下载：
  https://powerbi.microsoft.com/downloads/

#### 如果已安装但找不到：
检查实际安装路径：
```powershell
Get-Item "C:\Program Files\Microsoft Power BI Desktop\bin\PBIDesktop.exe"
# 或
Get-Item "C:\Program Files (x86)\Microsoft Power BI Desktop\bin\PBIDesktop.exe"
```

---

## ❌ 问题 5: 没有转换权限

### 症状：
```
Access Denied / Permission Denied / 拒绝访问
```

### 原因：
- 缺少目标目录的写入权限

### ✅ 解决方案：

#### 方法 1: 以管理员身份运行
- 右键点击 BAT 文件
- 选择"以管理员身份运行"

#### 方法 2: 更改目录权限
```powershell
# 以管理员身份运行 PowerShell
$path = "D:\GitHub\power_bi_develop_2026\US_PBIP"
icacls $path /grant:r "$env:USERNAME`:(OI)(CI)F"
```

#### 方法 3: 使用不同的目标目录
使用你有完全权限的目录，例如：
```
C:\Users\YourName\Downloads\PBIP_Files
```

---

## ❌ 问题 6: 文件转换失败

### 症状：
```
✗ 文件未转换成功
```

### 原因：
- 没有在 Power BI 中保存文件
- 保存格式错误（.pbix 而不是 .pbip）
- Power BI 意外关闭

### ✅ 解决方案：

1. **手动转换一个文件测试：**
   - 打开 Power BI Desktop
   - 打开你的 .pbix 文件
   - 点击"文件" → "另存为"
   - **重要：** 选择 "Power BI 项目文件 (*.pbip)"
   - 点击保存

2. **确认文件扩展名**
   - 转换后的文件应该是 `.pbip`（不是 `.pbix`）
   - 检查文件管理器

3. **检查 Power BI 版本**
   - 确保 Power BI Desktop 是最新版本
   - 某些旧版本可能不支持 .pbip 格式

---

## ✅ 快速诊断步骤

按顺序执行以下步骤来诊断问题：

### 步骤 1: 找到 Power BI 文件
```bash
双击: find_pbix_files.bat
```

### 步骤 2: 配置正确的路径
```bash
双击: config_paths.bat
```

### 步骤 3: 检查源目录
```bash
双击: run_power_bi_converter_v2.bat
选择: 4 (Check Source Directory)
```

### 步骤 4: 验证 Power BI Desktop
```powershell
Get-Item "C:\Program Files\Microsoft Power BI Desktop\bin\PBIDesktop.exe"
```

### 步骤 5: 运行转换
```bash
双击: run_power_bi_converter_v2.bat
选择: 1 (Start Conversion)
```

---

## 🆘 仍需帮助？

### 检查日志文件：
```
power_bi_conversion.log
```
这个文件包含详细的错误信息

### 常用命令参考：

**查找文件：**
```powershell
Get-ChildItem -Path "D:\" -Filter "*.pbix" -Recurse -ErrorAction SilentlyContinue | Select-Object FullName
```

**列出 Power BI 安装位置：**
```powershell
Get-ChildItem "C:\Program Files*" -Recurse -Filter "*PowerBI*" -ErrorAction SilentlyContinue
```

**创建目录：**
```cmd
mkdir "D:\new\directory\path"
```

**检查文件权限：**
```powershell
icacls "D:\directory\path"
```

---

## 📚 文档参考

- **QUICK_START.md** - 快速开始指南
- **POWER_BI_README.md** - 详细技术文档
- **DEPLOYMENT_SUMMARY.md** - 完整部署说明
- **README_START.txt** - 启动说明

---

## 💡 最佳实践

1. ✅ 总是以管理员身份运行脚本
2. ✅ 使用新版本脚本 (`run_power_bi_converter_v2.bat`)
3. ✅ 定期检查转换日志
4. ✅ 在转换前备份重要文件
5. ✅ 转换完成后验证文件

---

**有其他问题？请提供错误消息，我来帮你解决！** 🚀
