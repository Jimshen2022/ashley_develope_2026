# -*- coding: utf-8 -*-
"""
polars 版本：
- 读取 xlsb 用 pandas+pyxlsb，随后转 polars 加速处理
- 其余逻辑与 pandas 版一致
依赖：pip install polars pandas pyxlsb python-dateutil
"""

import time
import re
from pathlib import Path
from datetime import date
from dateutil.parser import parse as dt_parse
import pandas as pd
import polars as pl

# ===== 配置 =====
XLSB_PATH = r"D:\Documents\00-Query\00-AshtonQuery\AFI SA TRX - 2038.xlsb"
SHEET_TRX = "Trx by date (3)"
SHEET_CAT = "category"
DEFAULT_YEAR = 2025
OUT_CSV = Path.home() / "Downloads" / "AFI_SA_TRX_summary.csv"

def _parse_from_header_year(x):
    s = str(x).strip()
    m7 = re.fullmatch(r"1(\d{6})", s)
    m6 = re.fullmatch(r"(\d{6})", s)
    val = None
    if m7:
        val = m7.group(1)
    elif m6:
        val = m6.group(1)
    if val:
        yy = int(val[0:2]); mm = int(val[2:4]); dd = int(val[4:6])
        try:
            return (date(2000 + yy, mm, dd)).year
        except Exception:
            return None
    return None

def _week_to_saturday_py(week_val, year_val):
    # 用于 map_elements 的 Python 函数
    try:
        w = int(str(week_val).strip())
        y = int(str(year_val).strip())
        if 1 <= w <= 53:
            return date.fromisocalendar(y, w, 6)
    except Exception:
        pass

    s = str(week_val).strip()
    m = re.match(r"^\s*(\d{4})\s*[-\sW]?(\d{1,2})\s*$", s, flags=re.I)
    if m:
        y2 = int(m.group(1)); w2 = int(m.group(2))
        if 1 <= w2 <= 53:
            try:
                return date.fromisocalendar(y2, w2, 6)
            except Exception:
                return None

    try:
        d = dt_parse(s, dayfirst=False, yearfirst=True).date()
        iso_y, iso_w, _ = d.isocalendar()
        return date.fromisocalendar(iso_y, iso_w, 6)
    except Exception:
        return None

def main():
    t0 = time.perf_counter()

    # 1) 读取 .xlsb
    with pd.ExcelFile(XLSB_PATH, engine="pyxlsb") as xls:
        trx_pd = pd.read_excel(xls, sheet_name=SHEET_TRX, header=1)
        cat_pd = pd.read_excel(xls, sheet_name=SHEET_CAT)
        raw_head = pd.read_excel(xls, sheet_name=SHEET_TRX, header=None, nrows=2)

    # 2) 解析年份
    base_year = DEFAULT_YEAR
    try:
        if raw_head.shape[1] >= 2 and str(raw_head.iat[0,0]).strip().upper() == "FROM":
            maybe_year = _parse_from_header_year(raw_head.iat[0,1])
            if maybe_year:
                base_year = maybe_year
    except Exception:
        pass

    # 3) 转 polars，并明确列
    trx_pd["ITNBR"] = trx_pd["ITNBR"].astype(str).str.strip()
    cat_pd["ITNBR"] = cat_pd["ITNBR"].astype(str).str.strip()

    trx = pl.from_pandas(trx_pd)      # 列：TCODE, HOUSE, QTY, ITNBR, ITCLS, WEEK
    cat = pl.from_pandas(cat_pd)      # 列：ITNBR, ITCLS, Category, 1st

    # 4) 左连接 Category
    cat_small = cat.select([
        pl.col("ITNBR"),
        pl.col("Category").alias("category")
    ])
    trx_enriched = trx.join(cat_small, on="ITNBR", how="left")

    # 5) 计算 week_saturday（用 base_year + WEEK）
    trx_enriched = trx_enriched.with_columns(
        pl.struct(["WEEK"]).map_elements(lambda s: _week_to_saturday_py(s["WEEK"], base_year)).alias("week_saturday")
    )

    # 6) 汇总
    summary = (
        trx_enriched
        .group_by(["HOUSE", "category", "week_saturday"])
        .agg(pl.col("QTY").sum().alias("qty_sum"))
        .sort(["HOUSE", "category", "week_saturday"])
    )

    # 7) 输出
    OUT_CSV.parent.mkdir(parents=True, exist_ok=True)
    summary.write_csv(OUT_CSV)

    t1 = time.perf_counter()
    print(f"✅ polars 版完成，输出：{OUT_CSV}")
    print(f"⏱️ 总耗时：{t1 - t0:.2f} 秒")

if __name__ == "__main__":
    main()
