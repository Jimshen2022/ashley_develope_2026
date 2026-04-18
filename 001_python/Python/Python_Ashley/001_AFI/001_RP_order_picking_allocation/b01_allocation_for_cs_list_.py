"""
高性能库存分配系统
====================

专业级Python实现，采用数据分析最佳实践
- 向量化操作提升性能
- 链式方法优化可读性
- 完整的日志和异常处理
- 灵活的配置管理
- 专业的数据验证

Author: Senior Python Data Analyst
"""

import pandas as pd
import numpy as np
from pathlib import Path
from typing import Dict, List, Tuple, Optional, Union
from dataclasses import dataclass, field
from datetime import datetime
import logging
from functools import wraps
import warnings

# 配置日志
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler('inventory_allocation.log'),
        logging.StreamHandler()
    ]
)
logger = logging.getLogger(__name__)


@dataclass
class AllocationConfig:
    """分配配置类 - 使用数据类提升代码质量"""

    # 位置优先级映射
    location_priorities: Dict[str, int] = field(default_factory=lambda: {
        'RP03': 1,
        'RP02': 2,
        'RP01': 3,
        'RP998': 4
    })

    # 列名映射 - 提升代码可读性
    supply_columns: Dict[str, str] = field(default_factory=lambda: {
        'location': 'A',  # 位置
        'item': 'A',  # 物料编码
        'item_type': 'G',  # 物料类型
        'quantity': 'I'  # 数量
    })

    demand_columns: Dict[str, str] = field(default_factory=lambda: {
        'item': 'A',  # 物料编码
        'required_qty': 'E'  # 需求数量
    })

    # 默认值
    default_priority: int = 9
    date_format: str = '%Y-%m-%d'


def performance_monitor(func):
    """性能监控装饰器"""

    @wraps(func)
    def wrapper(*args, **kwargs):
        start_time = datetime.now()
        result = func(*args, **kwargs)
        duration = (datetime.now() - start_time).total_seconds()
        logger.info(f"{func.__name__} 执行时间: {duration:.2f}秒")
        return result

    return wrapper


def validate_dataframe(df: pd.DataFrame, required_columns: List[str], name: str) -> None:
    """数据验证函数"""
    if df.empty:
        raise ValueError(f"{name} 数据为空")

    missing_cols = [col for col in required_columns if col not in df.columns]
    if missing_cols:
        raise ValueError(f"{name} 缺少必要列: {missing_cols}")

    logger.info(f"{name} 数据验证通过: {len(df)} 行数据")


class InventoryAllocator:
    """
    专业级库存分配器
    ==================

    采用现代Python数据分析最佳实践:
    - 向量化操作
    - 链式方法
    - 类型提示
    - 异常处理
    - 日志记录
    """

    def __init__(self, config: Optional[AllocationConfig] = None):
        self.config = config or AllocationConfig()
        self.supply_data: Optional[pd.DataFrame] = None
        self.demand_data: Optional[pd.DataFrame] = None
        self.allocation_results: Optional[pd.DataFrame] = None

        logger.info("库存分配器初始化完成")

    @performance_monitor
    def load_data(self,
                  file_path: Union[str, Path],
                  supply_sheet: str = 'Sheet19',
                  demand_sheet: str = 'Sheet28') -> 'InventoryAllocator':
        """
        加载Excel数据 - 链式方法设计

        Args:
            file_path: Excel文件路径
            supply_sheet: 供应数据工作表
            demand_sheet: 需求数据工作表

        Returns:
            self: 支持方法链式调用
        """
        file_path = Path(file_path)

        if not file_path.exists():
            raise FileNotFoundError(f"文件不存在: {file_path}")

        try:
            # 使用上下文管理器确保资源正确释放
            with pd.ExcelFile(file_path) as excel_file:
                self.supply_data = pd.read_excel(excel_file, sheet_name=supply_sheet)
                self.demand_data = pd.read_excel(excel_file, sheet_name=demand_sheet)

            logger.info(f"数据加载成功 - 供应: {len(self.supply_data)} 行, 需求: {len(self.demand_data)} 行")

        except Exception as e:
            logger.error(f"数据加载失败: {e}")
            raise

        return self

    def _calculate_location_priority(self, locations: pd.Series) -> pd.Series:
        """
        向量化计算位置优先级

        Args:
            locations: 位置编码Series

        Returns:
            优先级Series
        """
        # 使用向量化操作替代循环，大幅提升性能
        priority_series = pd.Series(self.config.default_priority, index=locations.index)

        for prefix, priority in self.config.location_priorities.items():
            mask = locations.astype(str).str.startswith(prefix, na=False)
            priority_series.loc[mask] = priority

        return priority_series

    @performance_monitor
    def preprocess_supply_data(self) -> 'InventoryAllocator':
        """
        预处理供应数据 - 使用pandas最佳实践
        """
        if self.supply_data is None:
            raise ValueError("请先加载供应数据")

        logger.info("开始预处理供应数据")

        # 数据清洗和验证
        self.supply_data = (self.supply_data
                            .dropna(subset=['A'])  # 移除关键字段为空的行
                            .reset_index(drop=True))

        # 向量化计算优先级
        self.supply_data['priority'] = self._calculate_location_priority(
            self.supply_data['A']
        )

        # 高效排序 - 使用多级排序
        self.supply_data = (self.supply_data
                            .sort_values(['G', 'priority'], ascending=[True, True])
                            .reset_index(drop=True))

        logger.info(f"供应数据预处理完成，共 {len(self.supply_data)} 行")
        return self

    def _build_supply_inventory(self) -> Dict[str, Dict[str, Union[str, float]]]:
        """
        构建供应库存字典 - 优化的聚合方法

        Returns:
            供应库存字典
        """
        if self.supply_data is None:
            raise ValueError("供应数据未加载")

        # 使用pandas groupby进行高效聚合
        supply_grouped = (self.supply_data
                          .groupby(['A', 'G'])['I']
                          .sum()
                          .reset_index())

        # 构建字典，使用更高效的方式
        inventory_dict = {}
        for _, row in supply_grouped.iterrows():
            key = f"{row['A']}|{row['G']}"
            inventory_dict[key] = {
                'item': row['A'],
                'type': row['G'],
                'available_qty': float(row['I'])
            }

        logger.info(f"构建供应库存完成，共 {len(inventory_dict)} 个SKU")
        return inventory_dict

    @performance_monitor
    def execute_allocation(self) -> 'InventoryAllocator':
        """
        执行库存分配 - 核心业务逻辑
        """
        if self.demand_data is None:
            raise ValueError("需求数据未加载")

        logger.info("开始执行库存分配")

        # 构建供应库存
        supply_inventory = self._build_supply_inventory()

        # 准备结果DataFrame
        results = self.demand_data.copy()

        # 初始化分配相关列
        allocation_columns = {
            'allocated_qty': 0.0,
            'allocated_details': '',
            'shortage_qty': 0.0,
            'allocation_rate': 0.0,
            'ready_date': datetime.now().strftime(self.config.date_format)
        }

        for col, default_val in allocation_columns.items():
            results[col] = default_val

        # 执行分配逻辑
        for idx, demand_row in results.iterrows():
            if idx == 0:  # 跳过标题行
                continue

            item_code = demand_row['A']
            required_qty = float(demand_row['E']) if not pd.isna(demand_row['E']) else 0

            if required_qty <= 0:
                continue

            remaining_demand = required_qty
            allocation_details = []
            total_allocated = 0.0

            # 寻找匹配的供应
            keys_to_remove = []

            for supply_key, supply_info in supply_inventory.items():
                if supply_info['item'] != item_code or remaining_demand <= 0:
                    continue

                available_qty = supply_info['available_qty']

                if available_qty <= 0:
                    keys_to_remove.append(supply_key)
                    continue

                # 计算分配数量
                allocated_qty = min(remaining_demand, available_qty)

                # 更新分配记录
                total_allocated += allocated_qty
                allocation_details.append(f"{item_code}*{allocated_qty:.0f}pcs")

                # 更新库存
                supply_inventory[supply_key]['available_qty'] -= allocated_qty
                remaining_demand -= allocated_qty

                if supply_inventory[supply_key]['available_qty'] <= 0:
                    keys_to_remove.append(supply_key)

                if remaining_demand <= 0:
                    break

            # 清理用完的库存
            for key in keys_to_remove:
                if key in supply_inventory and supply_inventory[key]['available_qty'] <= 0:
                    del supply_inventory[key]

            # 更新结果
            results.at[idx, 'allocated_qty'] = total_allocated
            results.at[idx, 'allocated_details'] = '|'.join(allocation_details)
            results.at[idx, 'shortage_qty'] = remaining_demand
            results.at[idx, 'allocation_rate'] = (total_allocated / required_qty * 100) if required_qty > 0 else 0

        self.allocation_results = results
        logger.info("库存分配执行完成")
        return self

    def get_allocation_summary(self) -> Dict[str, Union[float, int]]:
        """
        生成分配摘要统计

        Returns:
            分配摘要字典
        """
        if self.allocation_results is None:
            raise ValueError("请先执行分配")

        # 过滤掉标题行
        data = self.allocation_results.iloc[1:]

        summary = {
            'total_demand': data['E'].fillna(0).sum(),
            'total_allocated': data['allocated_qty'].sum(),
            'total_shortage': data['shortage_qty'].sum(),
            'allocation_rate': 0.0,
            'total_orders': len(data),
            'fully_allocated_orders': len(data[data['shortage_qty'] == 0]),
            'partial_allocated_orders': len(data[(data['allocated_qty'] > 0) & (data['shortage_qty'] > 0)]),
            'unallocated_orders': len(data[data['allocated_qty'] == 0])
        }

        if summary['total_demand'] > 0:
            summary['allocation_rate'] = (summary['total_allocated'] / summary['total_demand']) * 100

        return summary

    @performance_monitor
    def save_results(self,
                     output_path: Union[str, Path],
                     sheet_name: str = 'AllocationResults') -> 'InventoryAllocator':
        """
        保存分配结果到Excel

        Args:
            output_path: 输出文件路径
            sheet_name: 工作表名称
        """
        if self.allocation_results is None:
            raise ValueError("没有分配结果可保存")

        output_path = Path(output_path)

        try:
            # 使用ExcelWriter进行专业的Excel输出
            with pd.ExcelWriter(output_path, engine='openpyxl') as writer:
                # 保存主要结果
                self.allocation_results.to_excel(
                    writer,
                    sheet_name=sheet_name,
                    index=False
                )

                # 保存分配摘要
                summary_df = pd.DataFrame([self.get_allocation_summary()]).T
                summary_df.columns = ['Value']
                summary_df.to_excel(
                    writer,
                    sheet_name='Summary',
                    header=['指标值']
                )

                # 格式化工作表
                workbook = writer.book
                worksheet = writer.sheets[sheet_name]

                # 设置列宽
                for column in worksheet.columns:
                    max_length = max(len(str(cell.value or '')) for cell in column)
                    worksheet.column_dimensions[column[0].column_letter].width = min(max_length + 2, 50)

            logger.info(f"结果已保存到: {output_path}")

        except Exception as e:
            logger.error(f"保存结果失败: {e}")
            raise

        return self

    def generate_report(self) -> str:
        """
        生成专业的分配报告

        Returns:
            格式化的报告字符串
        """
        if self.allocation_results is None:
            raise ValueError("请先执行分配")

        summary = self.get_allocation_summary()

        report = f"""
╔══════════════════════════════════════╗
║           库存分配报告                 ║
╠══════════════════════════════════════╣
║ 生成时间: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}
║ 
║ 📊 分配统计:
║   • 总需求量: {summary['total_demand']:,.0f}
║   • 已分配量: {summary['total_allocated']:,.0f} 
║   • 短缺数量: {summary['total_shortage']:,.0f}
║   • 分配率: {summary['allocation_rate']:.2f}%
║
║ 📋 订单统计:
║   • 总订单数: {summary['total_orders']:,}
║   • 完全满足: {summary['fully_allocated_orders']:,} ({summary['fully_allocated_orders'] / summary['total_orders'] * 100:.1f}%)
║   • 部分满足: {summary['partial_allocated_orders']:,} ({summary['partial_allocated_orders'] / summary['total_orders'] * 100:.1f}%)
║   • 无法满足: {summary['unallocated_orders']:,} ({summary['unallocated_orders'] / summary['total_orders'] * 100:.1f}%)
╚══════════════════════════════════════╝
        """

        return report


# 工厂函数 - 简化使用
def create_allocator(config_overrides: Optional[Dict] = None) -> InventoryAllocator:
    """
    创建库存分配器的工厂函数

    Args:
        config_overrides: 配置覆盖参数

    Returns:
        配置好的InventoryAllocator实例
    """
    config = AllocationConfig()

    if config_overrides:
        for key, value in config_overrides.items():
            if hasattr(config, key):
                setattr(config, key, value)

    return InventoryAllocator(config)


# 便捷函数 - 一键执行完整流程
@performance_monitor
def run_allocation_pipeline(
        excel_file: Union[str, Path],
        output_file: Optional[Union[str, Path]] = None,
        supply_sheet: str = 'Sheet19',
        demand_sheet: str = 'Sheet28',
        show_report: bool = True
) -> Dict[str, Union[float, int]]:
    """
    一键执行完整的库存分配流程

    Args:
        excel_file: 输入Excel文件
        output_file: 输出文件路径（可选）
        supply_sheet: 供应数据工作表
        demand_sheet: 需求数据工作表
        show_report: 是否显示报告

    Returns:
        分配摘要字典
    """
    try:
        # 创建分配器并执行完整流程
        allocator = (create_allocator()
                     .load_data(excel_file, supply_sheet, demand_sheet)
                     .preprocess_supply_data()
                     .execute_allocation())

        # 显示报告
        if show_report:
            print(allocator.generate_report())

        # 保存结果
        if output_file:
            allocator.save_results(output_file)
        else:
            # 默认保存到输入文件同目录
            default_output = Path(
                excel_file).parent / f"allocation_results_{datetime.now().strftime('%Y%m%d_%H%M%S')}.xlsx"
            allocator.save_results(default_output)

        return allocator.get_allocation_summary()

    except Exception as e:
        logger.error(f"分配流程失败: {e}")
        raise


if __name__ == "__main__":
    """
    使用示例 - 展示专业用法
    """

    # 示例1: 基础用法
    try:
        summary = run_allocation_pipeline(
            excel_file="inventory_data.xlsx",
            output_file="allocation_results.xlsx"
        )

        print(f"分配完成！分配率: {summary['allocation_rate']:.2f}%")

    except FileNotFoundError:
        print("请将您的Excel文件重命名为 'inventory_data.xlsx' 或修改文件路径")

    # 示例2: 高级用法 - 自定义配置
    try:
        custom_config = {
            'location_priorities': {
                'RP03': 1,
                'RP02': 2,
                'RP01': 3,
                'RP998': 4,
                'RP999': 5  # 新增优先级
            }
        }

        allocator = (create_allocator(custom_config)
                     .load_data("inventory_data.xlsx")
                     .preprocess_supply_data()
                     .execute_allocation()
                     .save_results("custom_allocation_results.xlsx"))

        print(allocator.generate_report())

    except Exception as e:
        print(f"执行失败: {e}")