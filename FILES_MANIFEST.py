"""
Power BI 转换工具 - 文件清单和使用指南
===========================================

📦 已创建的文件总览
"""

FILES_CREATED = {
    "工具脚本": {
        "power_bi_converter.py": {
            "类型": "Python 脚本",
            "功能": "交互式 PBIX 转 PBIP 转换工具",
            "使用难度": "⭐ 简单",
            "推荐场景": "初学者，需要逐步指导",
            "启动命令": "python power_bi_converter.py",
        },
        "power_bi_auto_converter.py": {
            "类型": "Python 脚本",
            "功能": "自动化转换工具，包含详细日志",
            "使用难度": "⭐⭐ 中等",
            "推荐场景": "需要日志记录和错误追踪",
            "启动命令": "python power_bi_auto_converter.py",
        },
        "Convert-PowerBIFiles.ps1": {
            "类型": "PowerShell 脚本",
            "功能": "彩色输出，智能操作提示",
            "使用难度": "⭐⭐⭐ 强烈推荐",
            "推荐场景": "大多数用户",
            "启动命令": "Set-ExecutionPolicy Bypass; .\\Convert-PowerBIFiles.ps1",
        },
        "run_power_bi_converter.bat": {
            "类型": "Windows 批处理",
            "功能": "菜单式界面，最简单易用",
            "使用难度": "⭐ 最简单",
            "推荐场景": "不熟悉命令行的用户",
            "启动命令": "双击执行",
        },
    },
    
    "文档": {
        "README_START.txt": {
            "内容": "启动说明和快速指南",
            "用途": "第一次使用时阅读",
            "重要性": "⚠️  必读",
        },
        "QUICK_START.md": {
            "内容": "快速参考，常见问题解答",
            "用途": "遇到问题时查阅",
            "重要性": "⭐ 重要",
        },
        "POWER_BI_README.md": {
            "内容": "详细技术文档，配置说明",
            "用途": "深入了解功能细节",
            "重要性": "ℹ️ 参考",
        },
        "DEPLOYMENT_SUMMARY.md": {
            "内容": "部署总结，完整流程指南",
            "用途": "全面理解项目",
            "重要性": "ℹ️ 参考",
        },
    }
}


QUICK_START_GUIDE = """
🚀 三步快速开始
===========================================

第 1 步: 选择启动方式
──────────────────────────────────────
☐ 初学者? → 双击 run_power_bi_converter.bat
☐ 常规用户? → 运行 Convert-PowerBIFiles.ps1
☐ Python用户? → 运行 python power_bi_converter.py


第 2 步: 按照提示操作
──────────────────────────────────────
当 Power BI Desktop 打开文件时:
1. 点击 文件 → 另存为
2. 选择 Power BI 项目文件 (*.pbip)
3. 点击保存
4. 关闭 Power BI
5. 按 Enter 继续下一个文件


第 3 步: 查看结果
──────────────────────────────────────
✅ 完成后在这里查看转换结果:
   D:\\GitHub\\power_bi_develop_2026\\US_PBIP\\


🎉 就这么简单!
"""


PREREQUISITES = {
    "必需": [
        {
            "名称": "Power BI Desktop",
            "检查": "开始菜单 → 搜索 'Power BI Desktop'",
            "下载": "https://powerbi.microsoft.com/downloads/",
            "版本": "建议最新版本",
        },
        {
            "名称": "源目录存在",
            "路径": "D:\\GitHub\\ashley_develope_2026\\00-PowerBI\\DC BI",
            "文件类型": "*.pbix",
            "数量": "应包含多个 Power BI 文件",
        },
    ],
    "可选": [
        {
            "名称": "Python 3.7+",
            "用途": "仅在使用 Python 脚本时需要",
            "检查": "python --version",
            "下载": "https://www.python.org/downloads/",
        },
    ],
}


DIRECTORY_STRUCTURE = """
📁 目录结构说明
===========================================

源目录 (包含要转换的 .pbix 文件):
───────────────────────────────────────
ashley_develope_2026/
└── 00-PowerBI/
    └── DC BI/
        ├── Additional Reports.pbix
        ├── AFI Wholesale Inventory Shrink.pbix
        ├── AGV ROI Tracking - Receiving Robotics.pbix
        ├── AGV ROI Tracking Arcadia Plant 2.pbix
        ├── ALL DC Metrics - Historical.pbix
        ├── Amazon Express.pbix
        ├── ... (更多 .pbix 文件)
        └── Daily Scorecard PowerBI.pbix


转换脚本所在目录:
───────────────────────────────────────
ashley_develope_2026/
├── power_bi_converter.py
├── power_bi_auto_converter.py
├── Convert-PowerBIFiles.ps1
├── run_power_bi_converter.bat
├── README_START.txt (本文件)
├── QUICK_START.md
├── POWER_BI_README.md
└── DEPLOYMENT_SUMMARY.md


目标目录 (转换后的 .pbip 文件存储位置):
───────────────────────────────────────
power_bi_develop_2026/
└── US_PBIP/
    ├── Additional Reports/
    │   └── Additional Reports.pbip
    ├── AFI Wholesale Inventory Shrink/
    │   └── AFI Wholesale Inventory Shrink.pbip
    ├── AGV ROI Tracking - Receiving Robotics/
    │   └── AGV ROI Tracking - Receiving Robotics.pbip
    ├── AGV ROI Tracking Arcadia Plant 2/
    │   └── AGV ROI Tracking Arcadia Plant 2.pbip
    ├── ALL DC Metrics - Historical/
    │   └── ALL DC Metrics - Historical.pbip
    ├── Amazon Express/
    │   └── Amazon Express.pbip
    └── ... (更多文件夹)
"""


COMMAND_REFERENCE = {
    "Windows 菜单 (最简单)": "run_power_bi_converter.bat",
    
    "PowerShell (推荐)": [
        "# 打开 PowerShell 管理员",
        "cd D:\\GitHub\\ashley_develope_2026",
        "Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope CurrentUser",
        ".\\Convert-PowerBIFiles.ps1",
    ],
    
    "Python 脚本": [
        "# 打开 CMD 或 PowerShell",
        "cd D:\\GitHub\\ashley_develope_2026",
        "python power_bi_converter.py",
    ],
    
    "检查 Power BI Desktop": "Get-Item \"C:\\Program Files\\Microsoft Power BI Desktop\\bin\\PBIDesktop.exe\"",
    
    "查看转换日志": "type power_bi_conversion.log",
    
    "打开目标目录": "explorer D:\\GitHub\\power_bi_develop_2026\\US_PBIP",
    
    "列出转换完成的文件": [
        "Get-ChildItem D:\\GitHub\\power_bi_develop_2026\\US_PBIP",
        "-Filter '*.pbip' -Recurse | Select-Object FullName",
    ],
}


TROUBLESHOOTING = {
    "问题": "未找到 Power BI Desktop",
    "解决方案": [
        "1. 检查开始菜单中是否有 Power BI Desktop",
        "2. 如未安装，从 https://powerbi.microsoft.com/downloads/ 下载",
        "3. 安装最新版本",
        "4. 重启计算机",
    ],
    "查询安装位置": "Get-ChildItem 'C:\\Program Files*' -Recurse -Name '*PBIDesktop*'",
},


if __name__ == "__main__":
    print("""
    ╔════════════════════════════════════════════════════════════╗
    ║   Power BI PBIX 转 PBIP 批量转换工具 - 完整指南           ║
    ╚════════════════════════════════════════════════════════════╝
    """)
    
    print("✅ 文件清单:")
    print("──────────────────────────────────────────────────────────")
    print("\n🔧 工具脚本:")
    for script, details in FILES_CREATED["工具脚本"].items():
        print(f"\n  {script}")
        for key, value in details.items():
            print(f"    • {key}: {value}")
    
    print("\n\n📚 文档:")
    for doc, details in FILES_CREATED["文档"].items():
        print(f"\n  {doc}")
        for key, value in details.items():
            print(f"    • {key}: {value}")
    
    print("\n\n" + "="*60)
    print(QUICK_START_GUIDE)
    print("="*60)
    
    print("\n\n📋 前置要求:")
    print("──────────────────────────────────────────────────────────")
    print("\n必需:")
    for req in PREREQUISITES["必需"]:
        print(f"\n  • {req['名称']}")
        for key, value in req.items():
            if key != "名称":
                print(f"    - {key}: {value}")
    
    print("\n\n可选:")
    for opt in PREREQUISITES["可选"]:
        print(f"\n  • {opt['名称']}")
        for key, value in opt.items():
            if key != "名称":
                print(f"    - {key}: {value}")
    
    print("\n\n" + "="*60)
    print(DIRECTORY_STRUCTURE)
    print("="*60)
    
    print("\n\n⚡ 常用命令:")
    print("──────────────────────────────────────────────────────────")
    for desc, cmd in COMMAND_REFERENCE.items():
        print(f"\n{desc}:")
        if isinstance(cmd, list):
            for c in cmd:
                print(f"  {c}")
        else:
            print(f"  {cmd}")
    
    print("\n\n🐛 故障排除:")
    print("──────────────────────────────────────────────────────────")
    print(f"\n问题: {TROUBLESHOOTING['问题']}")
    print("解决方案:")
    for step in TROUBLESHOOTING['解决方案']:
        print(f"  {step}")
    
    print("\n\n" + "="*60)
    print("📖 更多帮助: 查看 QUICK_START.md 或 POWER_BI_README.md")
    print("🚀 立即开始: 双击 run_power_bi_converter.bat")
    print("="*60)
    print("\n")
