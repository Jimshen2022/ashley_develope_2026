-- =====================================================================
-- TERMINATIONS 数值逆向工程分析
-- ADV HC Review, 2026-03-28 周, Terminations = 4
-- =====================================================================

-- 已知数据:
-- Week: 2026-03-28 (MAR)
-- Dept_HC: 248
-- Terminations: 4  <-- 目标值
-- Hires: 6
-- WC/LOA: 5
-- Final_HC: 245
-- HC_Need: -5

-- 验证公式:
-- Final_HC = Dept_HC - (Terminations + WC/LOA) + Hires
-- 245 = 248 - (4 + 5) + 6
-- 245 = 248 - 9 + 6
-- 245 = 245  ✓ 正确

-- =====================================================================
-- YTD背景数据 (从 ADV HC Review 行 18-24提取)
-- =====================================================================
-- 累计期间: 2026-02-14 至 2026-05-30 (约18周)
-- 
-- 部门级别YTD统计:
-- ADV WHS Ecomm Ship:           Hired=7,   Termed=2   (净+5)
-- ADV WHS Receiving:            Hired=24,  Termed=19  (净+5)
-- ADV WHS Shipping:             Hired=51,  Termed=67  (净-16)
-- ADV WHS Transfers:            Hired=4,   Termed=2   (净+2)
-- ADV WHS Uph Line Clearing:    Hired=1,   Termed=3   (净-2)
-- ADV WHS UPH Receiving:        Hired=4,   Termed=3   (净+1)
-- =====================================================================
-- TOTAL YTD:                    Hired=91,  Termed=96
-- =====================================================================

-- 计算YTD平均离职率:
-- 总离职数 / 周数 = 96 / 18 ≈ 5.33 人/周
-- 目标周 (2026-03-28) 的Terminations=4 < 平均值 (5.33)
--  → 表明这周的预测低于平均值

-- =====================================================================
-- 分析各部门周期性模式
-- =====================================================================

-- ADV WHS Shipping 数据最多 (YTD Termed=67):
-- 67 terminations / 18 weeks ≈ 3.72 人/周 (平均)

-- 这表明Terminations预测可能是:
-- 1. 基于部门级别的历史离职率
-- 2. 按部门的YTD离职数累积计算
-- 3. 再按比例分配回总HC

-- =====================================================================
-- 现在需要确认的关键问题:
-- =====================================================================

-- Q1: 这4个人来自哪些部门?
--    - Shipping占比最高 (67%), 可能预测 4 * 0.696 ≈ 2.8 ≈ 3 人来自Shipping
--    - 其他部门占比 (30%), 可能预测 1 人来自其他部门

-- Q2: 是否有SQL表记录了这些YTD数据?
--    - t_employee (termination_date字段?)
--    - t_employee_history
--    - HR_Forecast表

-- Q3: 每周的Terminations预测是如何更新的?
--    - 固定公式? 
--    - 每周重新计算YTD平均?
--    - 趋势分析?

-- =====================================================================
-- 推荐的SQL查询来源表
-- =====================================================================

-- 选项1: 从t_employee的历史记录计算
SELECT 
    e.wh_id,
    e.department_code,
    DATEPART(WEEK, e.termination_date) as term_week,
    COUNT(*) as terminations_count
FROM Distribution_Warehouse_Wholesale.t_employee e
WHERE e.wh_id = 'ADV'
  AND e.termination_date IS NOT NULL
  AND YEAR(e.termination_date) = 2026
GROUP BY e.wh_id, e.department_code, DATEPART(WEEK, e.termination_date)
ORDER BY term_week

-- 选项2: 从HR预测表 (如果存在)
SELECT 
    week_ending,
    warehouse_code,
    department,
    forecasted_terminations
FROM [HR_Forecast] OR [t_forecast_terminations]  
WHERE warehouse_code = 'ADV'
  AND week_ending = '2026-03-28'

-- 选项3: 从Power BI/Excel数据流
-- 需要查找Power Query脚本或dataflow定义

