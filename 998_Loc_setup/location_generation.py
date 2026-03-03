import csv
import os
from pathlib import Path
from datetime import datetime

def generate_warehouse_locations(aisles_config):
    """
    生成仓库库位数据
    
    参数:
    aisles_config: list of dict, 每个dict包含通道配置
        例如: [
            {'aisle': '022', 'start_bay': 1, 'end_bay': 55, 'direction': 'forward'},
            {'aisle': '023', 'start_bay': 55, 'end_bay': 1, 'direction': 'backward'}
            {'aisle': '024', 'start_bay': 1, 'end_bay': 55, 'direction': 'forward'}
            {'aisle': '025', 'start_bay': 55, 'end_bay': 1, 'direction': 'backward'}
            {'aisle': '026', 'start_bay': 1, 'end_bay': 55, 'direction': 'forward'}
        ]
    """
    
    locations = []
    
    # 定义基础数据
    one_side = ['A', 'C', 'E', 'G', 'J', 'L', 'N', 'Q', 'S', 'U', 'W', 'Y']
    another_side = ['B', 'D', 'F', 'H', 'K', 'M', 'P', 'R', 'T', 'V', 'X', 'Z']
    second_letters = list('ABCDEFGHIJKLMNOPQRSTUVWXYZ')
    levels = [1, 2, 3, 4, 5, 6, 7, 8]
    
    # 遍历每个通道配置
    for aisle_config in aisles_config:
        aisle = aisle_config['aisle']
        start_bay = aisle_config['start_bay']
        end_bay = aisle_config['end_bay']
        direction = aisle_config['direction']
        
        # 每个通道的picking_sequence从1开始
        picking_sequence = 1
        
        print(f"正在生成通道{aisle}...")
        
        # 根据方向生成bay序列
        if direction == 'forward':
            bay_range = range(start_bay, end_bay + 1)
        else:  # backward
            bay_range = range(start_bay, end_bay - 1, -1)
        
        # 遍历每个bay
        for bay in bay_range:
            # 从C/D开始，索引从1开始
            first_letter_index = 1 + (bay - 1) // 13
            second_letter_index = (bay - 1) % 26
            
            one_side_first = one_side[first_letter_index % len(one_side)]
            another_side_first = another_side[first_letter_index % len(another_side)]
            second_letter = second_letters[second_letter_index]
            
            one_side_section = one_side_first + second_letter
            another_side_section = another_side_first + second_letter
            
            # One side 的8层 (C侧)
            for level in levels:
                picking_seq = '1' + aisle + str(picking_sequence).zfill(7)
                locations.append({
                    'Location': f'A3{aisle}{one_side_section}{level}',
                    'Building': 'A3',
                    'Aisle': aisle,
                    'Bay_Number': bay,
                    'Section': one_side_section,
                    'Level': level,
                    'Side': 'C',
                    'Picking_Sequence': picking_seq
                })
                picking_sequence += 1
            
            # Another side 的8层 (D侧)
            for level in levels:
                picking_seq = '1' + aisle + str(picking_sequence).zfill(7)
                locations.append({
                    'Location': f'A3{aisle}{another_side_section}{level}',
                    'Building': 'A3',
                    'Aisle': aisle,
                    'Bay_Number': bay,
                    'Section': another_side_section,
                    'Level': level,
                    'Side': 'D',
                    'Picking_Sequence': picking_seq
                })
                picking_sequence += 1
        
        aisle_locations = [loc for loc in locations if loc['Aisle'] == aisle]
        print(f"通道{aisle}完成，生成 {len(aisle_locations)} 个库位")
    
    return locations


def get_downloads_folder():
    """获取用户的Downloads文件夹路径"""
    # Windows
    if os.name == 'nt':
        downloads_path = Path.home() / 'Downloads'
    # macOS and Linux
    else:
        downloads_path = Path.home() / 'Downloads'
    
    # 如果Downloads文件夹不存在，使用用户主目录
    if not downloads_path.exists():
        downloads_path = Path.home()
        print(f"警告: Downloads文件夹不存在，将保存到: {downloads_path}")
    
    return downloads_path


def save_to_csv(locations, base_filename='warehouse_locations'):
    """保存数据到CSV文件（保存到Downloads文件夹，文件名带时间戳）"""
    
    # 获取Downloads文件夹路径
    downloads_folder = get_downloads_folder()
    
    # 生成带时间戳的文件名
    timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
    filename = f"{base_filename}_{timestamp}.csv"
    full_path = downloads_folder / filename
    
    headers = ['Location', 'Building', 'Aisle', 'Bay_Number', 'Section', 'Level', 'Side', 'Picking_Sequence']
    
    with open(full_path, 'w', newline='', encoding='utf-8-sig') as csvfile:
        writer = csv.DictWriter(csvfile, fieldnames=headers)
        writer.writeheader()
        writer.writerows(locations)
    
    print(f"\n✓ CSV文件已保存到: {full_path}")
    print(f"✓ 总记录数: {len(locations)}")
    
    return full_path


def main():
    """主函数"""
    print("=" * 60)
    print("仓库库位生成器 - 可配置通道版本")
    print("=" * 60)
    print()
    
    # ==================== 配置区域 ====================
    # 在这里自定义你的通道配置
    aisles_config = [
        {
            'aisle': '022',           # 通道号
            'start_bay': 1,           # 起始bay
            'end_bay': 55,            # 结束bay
            'direction': 'forward'    # 方向: 'forward'(正序) 或 'backward'(倒序)
        },
        {
            'aisle': '023',
            'start_bay': 55,
            'end_bay': 1,
            'direction': 'backward'
        },
        {
            'aisle': '024',  # 通道号
            'start_bay': 1,  # 起始bay
            'end_bay': 55,  # 结束bay
            'direction': 'forward'  # 方向: 'forward'(正序) 或 'backward'(倒序)
        },
        {
            'aisle': '025',
            'start_bay': 55,
            'end_bay': 1,
            'direction': 'backward'
        },
        {
            'aisle': '026',  # 通道号
            'start_bay': 1,  # 起始bay
            'end_bay': 55,  # 结束bay
            'direction': 'forward'  # 方向: 'forward'(正序) 或 'backward'(倒序)
        },
        {
            'aisle': '027',
            'start_bay': 55,
            'end_bay': 1,
            'direction': 'backward'
        },
    ]
    
    # 输出文件名前缀（会自动添加时间戳）
    output_base_filename = 'warehouse_locations_A3_022_023'
    # ================================================
    
    print("通道配置:")
    print("-" * 60)
    for i, config in enumerate(aisles_config, 1):
        print(f"{i}. 通道{config['aisle']}: Bay {config['start_bay']}→{config['end_bay']} ({config['direction']})")
    print()
    
    # 生成库位数据
    locations = generate_warehouse_locations(aisles_config)
    
    # 保存到Downloads文件夹的CSV
    saved_path = save_to_csv(locations, output_base_filename)
    
    # 显示统计信息
    print("\n统计信息:")
    print("-" * 60)
    for config in aisles_config:
        aisle_count = sum(1 for loc in locations if loc['Aisle'] == config['aisle'])
        aisle_locs = [loc for loc in locations if loc['Aisle'] == config['aisle']]
        if aisle_locs:
            first_seq = aisle_locs[0]['Picking_Sequence']
            last_seq = aisle_locs[-1]['Picking_Sequence']
            print(f"通道{config['aisle']}库位数: {aisle_count}, Picking_Sequence: {first_seq} → {last_seq}")
    print(f"总库位数: {len(locations)}")
    
    # 显示示例数据
    print("\n前10条记录示例:")
    print("-" * 60)
    for i, loc in enumerate(locations[:10], 1):
        print(f"{i}. {loc['Location']} | Bay:{loc['Bay_Number']} | Side:{loc['Side']} | Seq:{loc['Picking_Sequence']}")
    
    print("\n通道交界处示例（通道022最后5条）:")
    print("-" * 60)
    aisle_022_locs = [loc for loc in locations if loc['Aisle'] == '022']
    if aisle_022_locs:
        for i, loc in enumerate(aisle_022_locs[-5:], len(aisle_022_locs)-4):
            print(f"{i}. {loc['Location']} | Bay:{loc['Bay_Number']} | Side:{loc['Side']} | Seq:{loc['Picking_Sequence']}")
    
    if len(aisles_config) > 1:
        print(f"\n通道交界处示例（通道{aisles_config[1]['aisle']}前5条）:")
        print("-" * 60)
        aisle_2_locs = [loc for loc in locations if loc['Aisle'] == aisles_config[1]['aisle']]
        if aisle_2_locs:
            for i, loc in enumerate(aisle_2_locs[:5], 1):
                print(f"{i}. {loc['Location']} | Bay:{loc['Bay_Number']} | Side:{loc['Side']} | Seq:{loc['Picking_Sequence']}")
    
    print("\n" + "=" * 60)
    print("完成！")
    print(f"文件位置: {saved_path}")
    print("=" * 60)


if __name__ == "__main__":
    main()