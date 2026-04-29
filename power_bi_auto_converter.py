import os
import sys
import subprocess
import time
from pathlib import Path
import xml.etree.ElementTree as ET
import shutil

class PowerBIAutoConverter:
    """自动转换 PBIX 到 PBIP 的工具"""
    
    def __init__(self):
        # 设置路径
        self.source_dir = r"D:\GitHub\ashley_develope_2026\00-PowerBI\DC BI"
        self.target_base_dir = r"D:\GitHub\power_bi_develop_2026\US_PBIP"
        self.pbi_desktop_path = self._find_pbi_desktop()
        self.pbix_files = []
        self.log_file = "power_bi_conversion.log"
        
    def _find_pbi_desktop(self):
        """查找 Power BI Desktop 的安装路径"""
        possible_paths = [
            r"C:\Program Files\Microsoft Power BI Desktop\bin\PBIDesktop.exe",
            r"C:\Program Files (x86)\Microsoft Power BI Desktop\bin\PBIDesktop.exe",
        ]
        
        for path in possible_paths:
            if os.path.exists(path):
                return path
        
        print("❌ 未找到 Power BI Desktop，请确保已安装")
        return None
    
    def log(self, message):
        """记录日志"""
        timestamp = time.strftime("%Y-%m-%d %H:%M:%S")
        log_message = f"[{timestamp}] {message}"
        print(log_message)
        
        with open(self.log_file, 'a', encoding='utf-8') as f:
            f.write(log_message + "\n")
    
    def get_pbix_files(self):
        """获取所有 .pbix 文件"""
        if not os.path.exists(self.source_dir):
            self.log(f"❌ 源目录不存在: {self.source_dir}")
            return False
        
        try:
            pbix_files = []
            for file in os.listdir(self.source_dir):
                if file.endswith('.pbix'):
                    pbix_files.append(file)
            
            if not pbix_files:
                self.log(f"❌ 未找到 .pbix 文件在: {self.source_dir}")
                return False
            
            self.pbix_files = sorted(pbix_files)
            self.log(f"✅ 找到 {len(self.pbix_files)} 个 Power BI 文件")
            for idx, file in enumerate(self.pbix_files, 1):
                self.log(f"   {idx}. {file}")
            return True
            
        except Exception as e:
            self.log(f"❌ 读取文件列表失败: {e}")
            return False
    
    def create_folder_structure(self):
        """创建文件夹结构"""
        try:
            # 创建基础目录
            if not os.path.exists(self.target_base_dir):
                os.makedirs(self.target_base_dir)
                self.log(f"✅ 创建基础目录: {self.target_base_dir}")
            
            # 为每个 .pbix 文件创建对应的文件夹
            for pbix_file in self.pbix_files:
                folder_name = pbix_file.replace('.pbix', '')
                folder_path = os.path.join(self.target_base_dir, folder_name)
                
                if not os.path.exists(folder_path):
                    os.makedirs(folder_path)
                    self.log(f"✅ 创建文件夹: {folder_name}")
            
            return True
            
        except Exception as e:
            self.log(f"❌ 创建文件夹结构失败: {e}")
            return False
    
    def extract_pbip(self, pbix_file):
        """
        通过解压 .pbix（ZIP格式）并修改结构来转换为 .pbip
        注意：这需要 Power BI Desktop 的支持
        """
        try:
            source_path = os.path.join(self.source_dir, pbix_file)
            folder_name = pbix_file.replace('.pbix', '')
            target_folder = os.path.join(self.target_base_dir, folder_name)
            
            self.log(f"\n🔄 处理: {pbix_file}")
            
            # 步骤 1: 打开 Power BI Desktop
            self.log(f"📂 启动 Power BI Desktop...")
            
            process = subprocess.Popen([
                self.pbi_desktop_path,
                source_path
            ])
            
            # 等待应用启动
            time.sleep(15)
            
            # 步骤 2: 提示用户手动保存
            self.log(f"⚠️  请在 Power BI Desktop 中执行:")
            self.log(f"   1. 点击 '文件' -> '另存为'")
            self.log(f"   2. 文件类型选择: 'Power BI 项目文件 (*.pbip)'")
            self.log(f"   3. 文件名: {folder_name}.pbip")
            self.log(f"   4. 保存位置: {target_folder}")
            self.log(f"   5. 完成后关闭 Power BI Desktop")
            
            # 等待用户完成操作
            input("⏳ 按 Enter 检查转换结果...")
            
            # 终止进程
            process.terminate()
            try:
                process.wait(timeout=5)
            except subprocess.TimeoutExpired:
                process.kill()
            
            # 检查是否成功
            pbip_path = os.path.join(target_folder, f"{folder_name}.pbip")
            if os.path.exists(pbip_path):
                self.log(f"✅ 成功: {pbip_path}")
                return True
            else:
                self.log(f"⚠️  未找到转换文件: {pbip_path}")
                return False
                
        except Exception as e:
            self.log(f"❌ 处理失败: {e}")
            return False
    
    def convert_via_powershell(self, pbix_file):
        """
        通过 PowerShell 脚本使用 Power BI 的 COM 接口进行转换
        """
        try:
            source_path = os.path.join(self.source_dir, pbix_file)
            folder_name = pbix_file.replace('.pbix', '')
            target_folder = os.path.join(self.target_base_dir, folder_name)
            target_path = os.path.join(target_folder, f"{folder_name}.pbip")
            
            # PowerShell 脚本
            ps_script = f'''
$SourceFile = "{source_path}"
$TargetFile = "{target_path}"

try {{
    # 创建 Power BI 对象
    $pbi = New-Object -ComObject "Excel.Application"
    
    # 打开文件
    $workbook = $pbi.Workbooks.Open($SourceFile)
    
    # 另存为 PBIP
    # 注意: Power BI Desktop 没有直接的 COM 接口支持 PBIP 格式
    # 需要使用 Power BI 本身的功能
    
    Write-Host "请手动在 Power BI Desktop 中保存为 PBIP 格式"
    
}}
catch {{
    Write-Host "错误: $_"
}}
'''
            
            # 这个方法有限制，建议使用手动方法
            self.log(f"⚠️  PowerShell 方法不支持直接转换")
            return False
            
        except Exception as e:
            self.log(f"❌ PowerShell 转换失败: {e}")
            return False
    
    def run(self):
        """主程序"""
        # 清空日志
        open(self.log_file, 'w').close()
        
        self.log("\n" + "="*80)
        self.log("🚀 Power BI PBIX 批量转换 PBIP 工具")
        self.log("="*80)
        
        # 检查 Power BI Desktop
        if not self.pbi_desktop_path:
            self.log("❌ 未找到 Power BI Desktop")
            return False
        
        self.log(f"✅ Power BI Desktop: {self.pbi_desktop_path}")
        
        # 获取文件列表
        if not self.get_pbix_files():
            return False
        
        # 创建文件夹结构
        if not self.create_folder_structure():
            return False
        
        # 逐个转换
        success_count = 0
        for idx, pbix_file in enumerate(self.pbix_files, 1):
            self.log(f"\n[{idx}/{len(self.pbix_files)}]")
            if self.extract_pbip(pbix_file):
                success_count += 1
        
        # 总结
        self.log("\n" + "="*80)
        self.log(f"✅ 处理完成! 成功: {success_count}/{len(self.pbix_files)}")
        self.log(f"📋 详细日志: {self.log_file}")
        self.log("="*80 + "\n")
        
        return True


def main():
    """主入口"""
    if len(sys.argv) > 1:
        source_dir = sys.argv[1]
        target_dir = sys.argv[2] if len(sys.argv) > 2 else None
    
    converter = PowerBIAutoConverter()
    converter.run()


if __name__ == "__main__":
    main()
