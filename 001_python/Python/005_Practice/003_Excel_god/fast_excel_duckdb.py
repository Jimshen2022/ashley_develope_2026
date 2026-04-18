# fast_excel_duckdb.py
import time, subprocess, shutil, hashlib
from pathlib import Path

def _hash_key(*parts) -> str:
    h = hashlib.md5()
    for p in parts:
        h.update(str(p).encode("utf-8"))
    return h.hexdigest()[:10]

def _cache_dir_for(src: Path) -> Path:
    d = src.with_suffix("").parent / (src.stem + ".__cache__")
    d.mkdir(exist_ok=True, parents=True)
    return d

def _csv_cache_path(src: Path, sheet_name) -> Path:
    key = _hash_key(src.resolve(), sheet_name)
    return _cache_dir_for(src) / f"{src.stem}.{key}.csv"

def _is_fresh(src: Path, cache: Path) -> bool:
    return cache.exists() and cache.stat().st_mtime >= src.stat().st_mtime

def _ensure_xlsx2csv():
    x2c = shutil.which("xlsx2csv")
    if not x2c:
        raise RuntimeError(
            "未找到 xlsx2csv，可先安装：pip install xlsx2csv\n"
            "安装后确保命令行可执行 `xlsx2csv`。"
        )
    return x2c

def _xlsx_to_csv(src: Path, dst_csv: Path, sheet_name=0, verbose=True):
    x2c = _ensure_xlsx2csv()
    if verbose:
        print(f"[fast] xlsx2csv → {dst_csv.name}")
    # -s 的 sheet 索引从 1 开始；若 sheet_name 是字符串，用 -n
    if isinstance(sheet_name, int):
        sheet_arg = ["-s", str(sheet_name + 1)]
    else:
        sheet_arg = ["-n", str(sheet_name)]
    with open(dst_csv, "wb") as f:
        subprocess.check_call([x2c, *sheet_arg, str(src)], stdout=f)

def _quote_ident(col: str) -> str:
    # 简单且安全的 DuckDB 标识符引用
    return '"' + col.replace('"', '""') + '"'

def fast_load_duckdb(
    file_path: str | Path,
    sheet_name = 0,                 # 读哪个 sheet（索引或名称）
    columns: list[str] | None = None,  # 只取部分列（更快）
    force_rebuild: bool = False,
    verbose: bool = True
):
    """
    读取 .xlsx：首轮用 xlsx2csv 转 CSV 缓存；随后用 DuckDB 读 CSV（极快）。
    返回 pandas.DataFrame（DuckDB 会转成 pandas）。
    """
    import duckdb

    t0 = time.time()
    src = Path(file_path)
    if not src.exists():
        raise FileNotFoundError(src)

    csv_cache = _csv_cache_path(src, sheet_name)

    if force_rebuild or not _is_fresh(src, csv_cache):
        _xlsx_to_csv(src, csv_cache, sheet_name=sheet_name, verbose=verbose)

    if verbose:
        print(f"[fast] DuckDB loading: {csv_cache.name}")

    if columns:
        select_cols = ", ".join(_quote_ident(c) for c in columns)
    else:
        select_cols = "*"

    # read_csv_auto 会自动推断分隔符、编码、列类型，速度很快
    q = f"SELECT {select_cols} FROM read_csv_auto('{csv_cache.as_posix()}')"
    try:
        df = duckdb.query(q).pl()  # 优先返回 polars.DataFrame
    except Exception:
        df = duckdb.query(q).to_df()  # 如果没装 polars，则回退 pandas

    # df = duckdb.query(q).to_df()
    # df = duckdb.query(q).pl()
    if verbose:
        dt = (time.time() - t0) * 1000
        print(f"[fast] Done in {dt:.0f} ms, shape={df.shape}")

    return df
