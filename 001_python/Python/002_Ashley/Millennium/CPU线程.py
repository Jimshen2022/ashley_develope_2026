import psutil
import os

print(f"物理核心数: {psutil.cpu_count(logical=False)}")
print(f"逻辑核心数: {psutil.cpu_count(logical=True)}")
print(f"当前CPU使用率: {psutil.cpu_percent(interval=1)}%")
print(f"可用内存: {psutil.virtual_memory().available / (1024**3):.1f} GB")