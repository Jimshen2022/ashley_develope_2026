# fast_excel_loader.py
import os, sys, time, hashlib, shutil
from pathlib import Path

def _hash_key(*parts) -> str:
    h = hashlib.md5()
    for p in parts:
        h.update(str(p).encode("utf-8"))
    return h.hexdigest()[:10]

def _cache_dir_for(src: Path) -> Path:
    d = src.with_suffix("").parent / (src.stem + ".__cache__")
    d.mkdir(exist_ok=True)
    return d

def _cache_path(src: Path, sheet_name, prefer: str, columns):
    key = _hash_key(src.resolve(), sheet_name, prefer, tuple(columns) if columns else "")
    return _cache_dir_for(src) / f"{src.stem}.{key}.{prefer}"

def _is_fresh(src: Path, cache: Path) -> bool:
    return cache.exists() and cache.stat().st_mtime >= src.stat().st_mtime

def _read_with_polars_parquet(pq_path: Path, columns=None):
    try:
        import polars as pl
        return pl.read_parquet(str(pq_path), columns=columns)
    except Exception:
        # 回退 pandas
        import pandas as pd
        return pd.read_parquet(str(pq_path), columns=columns)

def _read_with_duckdb_csv(csv_path: Path, columns=None):
    try:
        import duckdb
        q = f"SELECT {', '.join(columns) if columns else '*'} FROM read_csv_auto('{csv_path.as_posix()}')"
        return duckdb.query(q).to_df()
    except Exception:
        # 回退 pandas
        import pandas as pd
        return pd.read_csv(csv_path, usecols=columns)

def _xlsx_to_csv_stream(src: Path, dst_csv: Path, sheet_name=0):
    """
    优先使用 xlsx2csv（非常快）。否则用 pandas 转。
    """
    x2c = shutil.which("xlsx2csv")
    if x2c:
        import subprocess
        with open(dst_csv, "wb") as f:
            # 指定 sheet：-s 索引从1开始；sheet_name为名字时直接 -n "Name"
            if isinstance(sheet_name, int):
                sheet_arg = ["-s", str(sheet_name + 1)]
            else:
                sheet_arg = ["-n", str(sheet_name)]
            subprocess.check_call([x2c, *sheet_arg, str(src)], stdout=f)
    else:
        import pandas as pd
        df = pd.read_excel(src, sheet_name=sheet_name, engine="openpyxl")
        df.to_csv(dst_csv, index=False)

def _xlsx_to_parquet(src: Path, dst_pq: Path, sheet_name=0, columns=None):
    """
    用 pandas 读一次（可能慢一次），但只做首轮转换；dtype_backend='pyarrow'更省内存。
    """
    import pandas as pd
    try:
        df = pd.read_excel(src, sheet_name=sheet_name, engine="openpyxl", dtype_backend="pyarrow", usecols=columns)
    except TypeError:
        # 旧版 pandas 无 dtype_backend
        df = pd.read_excel(src, sheet_name=sheet_name, engine="openpyxl", usecols=columns)
    dst_pq.parent.mkdir(exist_ok=True, parents=True)
    df.to_parquet(dst_pq, index=False)

def fast_load(
    file_path: str | Path,
    prefer: str = "parquet",            # 'parquet'（推荐）或 'csv'
    sheet_name = 0,                     # 只读一个sheet，默认第一个
    columns: list[str] | None = None,   # 只要部分列可传入，进一步加速
    force_rebuild: bool = False,        # True 时强制重建缓存
    verbose: bool = True
):
    """
    返回 DataFrame（polars.DataFrame 或 pandas.DataFrame）
    Excel 第一次会慢（做转换），后续读取极快。
    """
    t0 = time.time()
    src = Path(file_path)
    if not src.exists():
        raise FileNotFoundError(src)

    prefer = prefer.lower()
    if prefer not in ("parquet", "csv"):
        raise ValueError("prefer 只支持 'parquet' 或 'csv'")

    cache_path = _cache_path(src, sheet_name, prefer, columns)

    # 新建/刷新缓存
    if force_rebuild or not _is_fresh(src, cache_path):
        if verbose:
            print(f"[fast_load] Building cache ({prefer}) for '{src.name}' ...")
        if prefer == "parquet":
            _xlsx_to_parquet(src, cache_path, sheet_name=sheet_name, columns=columns)
        else:
            _xlsx_to_csv_stream(src, cache_path, sheet_name=sheet_name)

    # 读取缓存（极快）
    if verbose:
        print(f"[fast_load] Loading from cache: {cache_path.name}")

    if prefer == "parquet":
        df = _read_with_polars_parquet(cache_path, columns=columns)
    else:
        df = _read_with_duckdb_csv(cache_path, columns=columns)

    if verbose:
        dt = (time.time() - t0) * 1000
        shape = (df.shape if hasattr(df, "shape") else (df.height, df.width))
        print(f"[fast_load] Done in {dt:.0f} ms, shape={shape}")
    return df

# --- CLI 用法 ---
if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("用法: python fast_excel_loader.py <xlsx路径> [parquet|csv]")
        sys.exit(1)
    path = sys.argv[1]
    prefer = sys.argv[2] if len(sys.argv) > 2 else "parquet"
    df = fast_load(path, prefer=prefer)
    # 仅打印预览，避免巨量输出
    try:
        import polars as pl
        if isinstance(df, pl.DataFrame):
            print(df.head(5))
        else:
            print(df.head())
    except Exception:
        print(getattr(df, "head", lambda n=5: df)(5))
