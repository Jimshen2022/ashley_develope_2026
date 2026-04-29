import os
import sys
import subprocess
import time
from pathlib import Path
import json
import shutil

class PowerBIConverter:
    def __init__(self):
        # 设置路径
        self.source_dir = r"D:\GitHub\ashley_develope_2026\00-PowerBI\DC BI"
        self.target_base_dir = r"D:\GitHub\power_bi_develop_2026\US_PBIP"
        self.pbix_files = []
        
    def get_pbix_files(self):
        """获取所有 .pbix 文件"""
        if not os.path.exists(self.source_dir):
            print(f"❌ 源目录不存在: {self.source_dir}")
            return False
        
        try:
            for file in os.listdir(self.source_dir):
                if file.endswith('.pbix'):
                    self.pbix_files.append(file)
            
            if not self.pbix_files:
                print(f"❌ 未找到 .pbix 文件在: {self.source_dir}")
                return False
            
            print(f"✅ 找到 {len(self.pbix_files)} 个 Power BI 文件:")
            for idx, file in enumerate(self.pbix_files, 1):
                print(f"   {idx}. {file}")
            return True
            
        except Exception as e:
            print(f"❌ 读取文件列表失败: {e}")
            return False
    
    def create_folder_structure(self):
        """创建文件夹结构"""
        try:
            # 创建基础目录
            if not os.path.exists(self.target_base_dir):
                os.makedirs(self.target_base_dir)
                print(f"✅ 创建基础目录: {self.target_base_dir}")
            
            # 为每个 .pbix 文件创建对应的文件夹
            for pbix_file in self.pbix_files:
                # 移除 .pbix 扩展名作为文件夹名称
                folder_name = pbix_file.replace('.pbix', '')
                folder_path = os.path.join(self.target_base_dir, folder_name)
                
                if not os.path.exists(folder_path):
                    os.makedirs(folder_path)
                    print(f"✅ 创建文件夹: {folder_path}")
                else:
                    print(f"ℹ️  文件夹已存在: {folder_path}")
            
            return True
            
        except Exception as e:
            print(f"❌ 创建文件夹结构失败: {e}")
            return False
    
    def convert_to_pbip(self, pbix_filename):
        """使用 Power BI Desktop 将 .pbix 转换为 .pbip"""
        try:
            source_file = os.path.join(self.source_dir, pbix_filename)
            target_folder = os.path.join(
                self.target_base_dir, 
                pbix_filename.replace('.pbix', '')
            )
            target_file = os.path.join(target_folder, pbix_filename.replace('.pbix', '.pbip'))
            
            print(f"\n{'='*70}")
            print(f"🔄 处理: {pbix_filename}")
            print(f"   源文件: {source_file}")
            print(f"   目标: {target_file}")
            print(f"{'='*70}")
            
            # 检查源文件是否存在
            if not os.path.exists(source_file):
                print(f"❌ 源文件不存在: {source_file}")
                return False
            
            # 方法 1: 使用 Power BI Desktop 打开文件
            pbix_path = Path(source_file).as_posix()
            
            # 启动 Power BI Desktop
            print(f"📂 正在打开 Power BI Desktop...")
            subprocess.Popen([
                r"C:\Program Files\Microsoft Power BI Desktop\bin\PBIDesktop.exe",
                pbix_path
            ])
            
            # 等待 Power BI 打开
            time.sleep(10)
            
            print(f"⚙️  请执行以下步骤:")
            print(f"   1. Power BI Desktop 将在几秒钟后打开")
            print(f"   2. 点击 '文件' -> '另存为'")
            print(f"   3. 在 '保存类型' 中选择 'Power BI 项目文件 (*.pbip)'")
            print(f"   4. 将文件名设为: {os.path.basename(target_file)}")
            print(f"   5. 选择位置: {target_folder}")
            print(f"   6. 点击保存后，关闭 Power BI Desktop")
            print(f"\n⏳ 按 Enter 继续下一个文件...")
            input()
            
            # 检查转换是否成功
            if os.path.exists(target_file):
                print(f"✅ 成功转换: {pbix_filename}")
                return True
            else:
                print(f"⚠️  未检测到转换后的文件，请手动检查")
                return False
                
        except Exception as e:
            print(f"❌ 转换失败: {e}")
            return False
    
    def run(self):
        """主程序流程"""
        print("\n" + "="*70)
        print("🚀 Power BI 文件批量转换工具")
        print("="*70)
        
        # Step 1: 获取文件列表
        if not self.get_pbix_files():
            return False
        
        # Step 2: 创建文件夹结构
        if not self.create_folder_structure():
            return False
        
        # Step 3: 逐个转换文件
        success_count = 0
        for idx, pbix_file in enumerate(self.pbix_files, 1):
            print(f"\n[{idx}/{len(self.pbix_files)}]", end=" ")
            if self.convert_to_pbip(pbix_file):
                success_count += 1
        
        # 完成
        print("\n" + "="*70)
        print(f"✅ 处理完成! 成功转换: {success_count}/{len(self.pbix_files)} 个文件")
        print("="*70 + "\n")
        
        return True


def main():
    """主入口函数"""
    converter = PowerBIConverter()
    converter.run()


if __name__ == "__main__":
    main()
