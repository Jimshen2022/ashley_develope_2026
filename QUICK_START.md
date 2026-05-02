# 🚀 Power BI 转换工具 - 快速参考

## 📦 已创建的文件

```
ashley_develope_2026/
├── power_bi_converter.py          ← Python 交互式工具
├── power_bi_auto_converter.py     ← Python 自动化工具
├── Convert-PowerBIFiles.ps1       ← PowerShell 脚本
├── run_power_bi_converter.bat     ← Windows 批处理菜单
├── POWER_BI_README.md             ← 详细文档
└── QUICK_START.md                 ← 本文件
```

---

## 🎯 三种使用方法

### 方法 1: 最简单 - 使用 Windows 菜单

**适合:** 初学者，不熟悉命令行

```bash
# 双击运行此文件：
run_power_bi_converter.bat
```

效果：
- ✅ 图形菜单界面
- ✅ 简单易用
- ✅ 无需了解命令行

**步骤：**
1. 双击 `run_power_bi_converter.bat`
2. 选择 "1" 运行交互式转换
3. 按照提示在 Power BI 中保存文件
4. 继续下一个文件

---

### 方法 2: 推荐 - PowerShell 脚本

**适合:** 有一定计算机基础的用户

```powershell
# 打开 PowerShell (Win + X, 选择 PowerShell 管理员)
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope CurrentUser
.\Convert-PowerBIFiles.ps1
```

特点：
- ✅ 彩色输出，易于理解
- ✅ 更好的错误处理
- ✅ 操作指南清晰

---

### 方法 3: 灵活 - Python 脚本

**适合:** 需要自定义的高级用户

```bash
# 打开 CMD 或 PowerShell
cd D:\GitHub\ashley_develope_2026

# 运行交互式版本
python power_bi_converter.py

# 或运行自动化版本
python power_bi_auto_converter.py
```

---

## 📋 工作流程

```
开始
 ↓
[选择方法 1/2/3]
 ↓
创建目录结构
 ↓
循环处理每个 .pbix 文件:
 ├─ Power BI 自动打开文件
 ├─ 用户在 Power BI 中执行:
 │  ├─ 文件 → 另存为
 │  ├─ 文件类型: Power BI 项目文件 (*.pbip)
 │  └─ 选择指定位置保存
 ├─ 用户关闭 Power BI
 └─ 脚本检查转换结果
 ↓
显示汇总统计
 ↓
完成！
```

---

## 🔧 必要条件检查清单

- [ ] **Power BI Desktop 已安装**
  ```powershell
  # 检查：
  Get-Item "C:\Program Files\Microsoft Power BI Desktop\bin\PBIDesktop.exe"
  ```

- [ ] **Python 3.7+ 已安装** (仅用 Python 方法需要)
  ```bash
  python --version
  ```

- [ ] **源目录存在且有 .pbix 文件**
  ```powershell
  # 检查：
  Get-ChildItem "D:\GitHub\ashley_develope_2026\00-PowerBI\DC BI" -Filter "*.pbix"
  ```

- [ ] **目标目录有写入权限**
  ```powershell
  # 创建测试文件：
  New-Item -Path "D:\GitHub\power_bi_develop_2026\US_PBIP\test.txt"
  ```

---

## ⚡ 快速命令

### Windows 命令行快速启动

```batch
REM 打开菜单
start run_power_bi_converter.bat

REM 直接运行 Python 工具
python power_bi_converter.py

REM 打开目标目录
explorer D:\GitHub\power_bi_develop_2026\US_PBIP

REM 查看转换日志
type power_bi_conversion.log
```

### PowerShell 快速命令

```powershell
# 运行 PowerShell 脚本
.\Convert-PowerBIFiles.ps1

# 指定源和目标目录
.\Convert-PowerBIFiles.ps1 -SourceDir "D:\path\to\source" -TargetDir "D:\path\to\target"

# 显示详细信息
.\Convert-PowerBIFiles.ps1 -Verbose
```

---

## 🎓 Power BI 中的操作步骤

当文件在 Power BI Desktop 中打开时：

1. **点击菜单栏中的 "文件"**
   ![1. 点击文件](step1.png)

2. **选择 "另存为"**
   ![2. 另存为](step2.png)

3. **选择保存类型**
   ```
   文件类型: Power BI 项目文件 (*.pbip)
            ↑ 确保选择这个，不是 Power BI 桌面 (*.pbix)
   ```

4. **确认文件名和位置**
   ```
   文件名: [自动填充，无需修改]
   保存位置: D:\GitHub\power_bi_develop_2026\US_PBIP\[文件名]/
   ```

5. **点击保存**
   - 等待文件保存完成（可能需要几秒到几分钟）
   - 关闭 Power BI Desktop

6. **回到脚本，按 Enter 继续**

---

## 🐛 常见问题

### Q1: 工具找不到 Power BI Desktop？
**A:** 
```powershell
# 检查安装路径：
Get-ChildItem "C:\Program Files*" -Recurse -Name "PBIDesktop.exe"

# 然后在脚本中修改路径
```

### Q2: 如何中途停止？
**A:** 
- 按 `Ctrl + C` 终止脚本
- 关闭 Power BI Desktop 窗口

### Q3: 转换失败，如何重试单个文件？
**A:** 
- 手动打开 .pbix 文件
- 另存为 .pbip 格式到对应文件夹
- 重新运行脚本

### Q4: 如何查看转换进度？
**A:** 
- Python 版本：查看 `power_bi_conversion.log`
- PowerShell 版本：直接在终端看彩色输出
- Batch 版本：查看菜单中的"查看转换日志"选项

---

## 📊 预期结果

完成后，你应该看到：

```
D:\GitHub\power_bi_develop_2026\US_PBIP\
├── Additional Reports/
│   ├── Additional Reports.pbip
│   ├── Report1.rdl
│   └── ...
├── AFI Wholesale Inventory Shrink/
│   ├── AFI Wholesale Inventory Shrink.pbip
│   └── ...
└── ... (更多文件夹)
```

每个 `.pbip` 文件是一个 Power BI 项目文件，包含了原始 `.pbix` 的所有内容，但采用项目格式。

---

## 💡 提示

- 🟢 **绿色输出** = 成功的操作
- 🔴 **红色输出** = 错误或失败
- 🟡 **黄色输出** = 警告或需要注意的信息
- 🔵 **蓝色输出** = 一般信息

---

## 🔐 安全提示

- ✅ 脚本不会删除原始 `.pbix` 文件
- ✅ 转换在新目录中进行，不会覆盖现有文件
- ✅ 建议在转换前备份重要文件
- ✅ 脚本需要的权限：读取源文件、写入目标目录

---

## 📞 获取帮助

1. 查看详细文档：`POWER_BI_README.md`
2. 查看转换日志：`power_bi_conversion.log`
3. 检查 Power BI Desktop 是否最新版本
4. 确保网络连接正常（某些操作需要联网）

---

## ✨ 最佳实践

1. **备份原始文件**
   ```powershell
   Copy-Item -Path "D:\GitHub\ashley_develope_2026\00-PowerBI\DC BI" `
             -Destination "D:\Backup\DC BI" -Recurse
   ```

2. **在工作时间进行转换**
   - Power BI 可能需要占用较多系统资源
   - 转换期间避免在 Power BI 中进行其他操作

3. **逐个检查转换结果**
   - 每个文件转换后检查是否完整
   - 某些大型文件可能需要更长时间

4. **定期检查日志**
   - 及时发现和解决问题
   - 保留日志以供审查

---

**祝转换顺利！** 🎉
