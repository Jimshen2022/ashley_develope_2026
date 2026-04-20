# -*- coding: utf-8 -*-
"""
pandas 版本：
1) 读取 xlsb
2) ITNBR 转文本并 left join Category
3) 依据 WEEK 计算该周周六日期（年份优先从表头“FROM 1250601”解析，失败则用 DEFAULT_YEAR=2025）
4) 汇总 HOUSE, category, week_saturday 的 QTY 合计
5) 输出 CSV 到 Downloads
6) 打印总耗时
依赖：pip install pandas pyxlsb python-dateutil
"""

import time
import re
from pathlib import Path
from datetime import date
from dateutil.parser import parse as dt_parse
import pandas as pd

# ===== 配置 =====
XLSB_PATH = r"D:\Documents\00-Query\00-AshtonQuery\AFI SA TRX - 2038.xlsb"
SHEET_TRX = "Trx by date (3)"
SHEET_CAT = "category"
DEFAULT_YEAR = 2025  # 若无法从表头解析年份，则使用此年份
OUT_CSV = Path.home() / "Downloads" / "AFI_SA_TRX_summary.csv"

def _parse_from_header_year(x):
    """
    从 Trx 表的第一行（例如 FROM 1250601）解析年份：
      - 若是 7 位并以 '1' 开头（如 1250601），取后 6 位当 yymmdd -> 20yy-mm-dd -> year
      - 若是 6 位（yymmdd），直接解析为 20yy-mm-dd -> year
    解析失败返回 None
    """
    s = str(x).strip()
    m7 = re.fullmatch(r"1(\d{6})", s)
    m6 = re.fullmatch(r"(\d{6})", s)
    val = None
    if m7:
        val = m7.group(1)
    elif m6:
        val = m6.group(1)
    if val:
        yy = int(val[0:2])
        mm = int(val[2:4])
        dd = int(val[4:6])
        try:
            # 假设 20yy
            return (date(2000 + yy, mm, dd)).year
        except Exception:
            return None
    return None

def _week_to_saturday(week_val, year_val):
    """
    将 (year, week) 解析为该周的周六日期（ISO 周：周一=1，周六=6）
    支持 week 是数字或字符串（允许 '2025-41'、'2025W41' 等，但本脚本通常走 year+week）
    """
    # 尝试 year + week 数字
    try:
        w = int(str(week_val).strip())
        y = int(str(year_val).strip())
        if 1 <= w <= 53:
            return date.fromisocalendar(y, w, 6)
    except Exception:
        pass

    # 兼容字符串形态
    s = str(week_val).strip()
    m = re.match(r"^\s*(\d{4})\s*[-\sW]?(\d{1,2})\s*$", s, flags=re.I)
    if m:
        y2 = int(m.group(1))
        w2 = int(m.group(2))
        if 1 <= w2 <= 53:
            try:
                return date.fromisocalendar(y2, w2, 6)
            except Exception:
                return pd.NaT

    # 若是具体日期字符串，则先解析日期，再换算到周六
    try:
        d = dt_parse(s, dayfirst=False, yearfirst=True).date()
        iso_y, iso_w, _ = d.isocalendar()
        return date.fromisocalendar(iso_y, iso_w, 6)
    except Exception:
        return pd.NaT

def main():
    t0 = time.perf_counter()

    # 1) 读取 xlsb
    with pd.ExcelFile(XLSB_PATH, engine="pyxlsb") as xls:
        # 注意：Trx 表前两行为说明/头部，实际表头在第 2 行（0-based header=1）
        trx = pd.read_excel(xls, sheet_name=SHEET_TRX, header=1)
        cat = pd.read_excel(xls, sheet_name=SHEET_CAT)

        # 读取原始第一行用于解析年份（header=None 读取）
        raw_head = pd.read_excel(xls, sheet_name=SHEET_TRX, header=None, nrows=2)

    # 2) 解析年份（优先 FROM 行）
    year_from_header = None
    try:
        # 结构类似：第一行 [FROM, 1250601, TO, ...]
        if raw_head.shape[1] >= 2 and str(raw_head.iat[0,0]).strip().upper() == "FROM":
            year_from_header = _parse_from_header_year(raw_head.iat[0,1])
    except Exception:
        pass
    base_year = year_from_header or DEFAULT_YEAR

    # 3) 统一列名（保持与文件一致以免混淆，后续显式选择）
    # Trx 必有列：TCODE, HOUSE, QTY, ITNBR, ITCLS, WEEK
    # Cat 必有列：ITNBR, ITCLS, Category, 1st
    # 转字符串再 strip
    trx["ITNBR"] = trx["ITNBR"].astype(str).str.strip()
    cat["ITNBR"] = cat["ITNBR"].astype(str).str.strip()

    # 4) 左连接 Category
    trx_enriched = trx.merge(cat[["ITNBR", "Category"]].rename(columns={"Category": "category"}),
                             on="ITNBR", how="left")

    # 5) 计算 week_saturday（用 base_year + WEEK）
    trx_enriched["week_saturday"] = [
        _week_to_saturday(w, base_year) for w in trx_enriched["WEEK"]
    ]

    # 6) 汇总：HOUSE, category, week_saturday 求 QTY 合计
    summary = (
        trx_enriched
        .groupby(["HOUSE", "category", "week_saturday"], dropna=False)["QTY"]
        .sum()
        .reset_index()
        .rename(columns={"QTY": "qty_sum"})
        .sort_values(["HOUSE", "category", "week_saturday"], kind="mergesort")
    )

    # 7) 输出
    OUT_CSV.parent.mkdir(parents=True, exist_ok=True)
    summary.to_csv(OUT_CSV, index=False, encoding="utf-8-sig")

    t1 = time.perf_counter()
    print(f"✅ pandas 版完成，输出：{OUT_CSV}")
    print(f"⏱️ 总耗时：{t1 - t0:.2f} 秒")

if __name__ == "__main__":
    main()
