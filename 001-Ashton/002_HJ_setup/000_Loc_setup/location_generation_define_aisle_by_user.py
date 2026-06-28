import csv
import os
from pathlib import Path
from datetime import datetime


def generate_warehouse_locations(aisles_config):
    """
    生成仓库库位数据

    每个bay会生成 4个section字母 × 4层(level) × 2个side(C/D) = 32个location

    规则：
    - 第一个字母（决定side的大分区）：每6个bay换一次，
      C侧依次用 C,E,G,J,L,N,Q,S,U,W,Y；D侧依次用 D,F,H,K,M,P,R,T,V,X,Z
    - 第二个字母：从24个字母中取（跳过I和O），每个bay用其中连续4个，
      用完24个后随第一个字母推进重新从头开始
      （bay1:A,B,C,D  bay2:E,F,G,H  bay3:J,K,L,M  bay4:N,P,Q,R  bay5:S,T,U,V  bay6:W,X,Y,Z  bay7:A,B,C,D...）

    参数:
    aisles_config: list of dict, 每个dict包含通道配置
        例如: [
            {'aisle': '022', 'start_bay': 1, 'end_bay': 53, 'direction': 'forward'},
            {'aisle': '023', 'start_bay': 53, 'end_bay': 1, 'direction': 'backward'}
        ]
    """

    locations = []

    # 定义基础数据
    one_side_letters = ['C', 'E', 'G', 'J', 'L', 'N', 'Q', 'S', 'U', 'W', 'Y']  # side C 用的第一个字母，每6个bay换一个
    another_side_letters = ['D', 'F', 'H', 'K', 'M', 'P', 'R', 'T', 'V', 'X', 'Z']  # side D 用的第一个字母，每6个bay换一个
    second_letters = list('ABCDEFGHJKLMNPQRSTUVWXYZ')  # 24个字母，跳过 I 和 O
    levels = [1, 2, 3, 4]
    sections_per_bay = 4  # 每个bay在每个side上有4个section（4个第二字母）

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
            # 每6个bay换一次第一个字母
            group_index = (bay - 1) // 6
            # 在当前6-bay组内的位置(0~5)，决定取哪4个第二字母
            position_in_group = (bay - 1) % 6

            one_side_first = one_side_letters[group_index % len(one_side_letters)]
            another_side_first = another_side_letters[group_index % len(another_side_letters)]

            second_start = position_in_group * sections_per_bay
            bay_second_letters = second_letters[second_start:second_start + sections_per_bay]

            # One side 的4个section x 4层 (C侧)
            for second_letter in bay_second_letters:
                section = one_side_first + second_letter
                for level in levels:
                    picking_seq = '1' + aisle + str(picking_sequence).zfill(7)
                    locations.append({
                        'Location': f'A3{aisle}{section}{level}',
                        'Building': 'A3',
                        'Aisle': aisle,
                        'Bay_Number': bay,
                        'Section': section,
                        'Level': level,
                        'Side': 'C',
                        'Picking_Sequence': picking_seq
                    })
                    picking_sequence += 1

            # Another side 的4个section x 4层 (D侧)
            for second_letter in bay_second_letters:
                section = another_side_first + second_letter
                for level in levels:
                    picking_seq = '1' + aisle + str(picking_sequence).zfill(7)
                    locations.append({
                        'Location': f'A3{aisle}{section}{level}',
                        'Building': 'A3',
                        'Aisle': aisle,
                        'Bay_Number': bay,
                        'Section': section,
                        'Level': level,
                        'Side': 'D',
                        'Picking_Sequence': picking_seq
                    })
                    picking_sequence += 1

        aisle_locations = [loc for loc in locations if loc['Aisle'] == aisle]
        print(f"通道{aisle}完成，生成 {len(aisle_locations)} 个库位")

    return locations


def build_aisles_config(start_aisle, end_aisle, bay_count=53, first_direction='forward'):
    """
    根据起始/结束通道号，自动生成 aisles_config 列表。
    方向规则：从 first_direction 开始，逐个通道正反交替
    （例如 36=forward, 37=backward, 38=forward, ...）

    参数:
    start_aisle: int, 起始通道号 (例如 36)
    end_aisle: int, 结束通道号 (例如 50)
    bay_count: int, 每个通道的bay总数 (默认53，即bay从1到53)
    first_direction: 'forward' 或 'backward'，start_aisle对应的方向

    返回:
    aisles_config: list of dict，可直接传给 generate_warehouse_locations
    """
    aisles_config = []

    # 支持 start_aisle <= end_aisle (升序) 或 start_aisle > end_aisle (降序)
    step = 1 if end_aisle >= start_aisle else -1
    aisle_numbers = range(start_aisle, end_aisle + step, step)

    for i, aisle_num in enumerate(aisle_numbers):
        # 交替方向：第0个用first_direction，第1个用相反方向，以此类推
        if i % 2 == 0:
            direction = first_direction
        else:
            direction = 'backward' if first_direction == 'forward' else 'forward'

        if direction == 'forward':
            start_bay, end_bay = 1, bay_count
        else:
            start_bay, end_bay = bay_count, 1

        # 通道号统一格式化为3位数字字符串，例如 36 -> '036'
        aisle_str = str(aisle_num).zfill(3)

        aisles_config.append({
            'aisle': aisle_str,
            'start_bay': start_bay,
            'end_bay': end_bay,
            'direction': direction
        })

    return aisles_config


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
    # 只需指定起始通道号、结束通道号，方向会自动交替
    # 例如：从36到50，36=forward, 37=backward, 38=forward, ... 以此类推
    START_AISLE = 36  # 起始通道号
    END_AISLE = 50  # 结束通道号
    BAY_COUNT = 53  # 每个通道的bay数量 (1~53)
    FIRST_DIRECTION = 'forward'  # START_AISLE 对应的方向: 'forward' 或 'backward'

    aisles_config = build_aisles_config(
        start_aisle=START_AISLE,
        end_aisle=END_AISLE,
        bay_count=BAY_COUNT,
        first_direction=FIRST_DIRECTION
    )

    # 输出文件名前缀（会自动添加时间戳）
    output_base_filename = f'warehouse_locations_A3_{START_AISLE:03d}_{END_AISLE:03d}'
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

    first_aisle = aisles_config[0]['aisle']
    print(f"\n通道交界处示例（通道{first_aisle}最后5条）:")
    print("-" * 60)
    first_aisle_locs = [loc for loc in locations if loc['Aisle'] == first_aisle]
    if first_aisle_locs:
        for i, loc in enumerate(first_aisle_locs[-5:], len(first_aisle_locs) - 4):
            print(
                f"{i}. {loc['Location']} | Bay:{loc['Bay_Number']} | Side:{loc['Side']} | Seq:{loc['Picking_Sequence']}")

    if len(aisles_config) > 1:
        print(f"\n通道交界处示例（通道{aisles_config[1]['aisle']}前5条）:")
        print("-" * 60)
        aisle_2_locs = [loc for loc in locations if loc['Aisle'] == aisles_config[1]['aisle']]
        if aisle_2_locs:
            for i, loc in enumerate(aisle_2_locs[:5], 1):
                print(
                    f"{i}. {loc['Location']} | Bay:{loc['Bay_Number']} | Side:{loc['Side']} | Seq:{loc['Picking_Sequence']}")

    print("\n" + "=" * 60)
    print("完成！")
    print(f"文件位置: {saved_path}")
    print("=" * 60)


if __name__ == "__main__":
    main()