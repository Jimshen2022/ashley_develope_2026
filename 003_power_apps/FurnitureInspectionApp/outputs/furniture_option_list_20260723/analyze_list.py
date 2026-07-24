from pathlib import Path

import pandas as pd

INPUT = Path(r"C:\Users\jishen\Downloads\list.xlsx")

book = pd.ExcelFile(INPUT)
print("Sheets:", book.sheet_names)

for sheet_name in book.sheet_names:
    df = pd.read_excel(INPUT, sheet_name=sheet_name, dtype=str)
    print(f"\nSheet: {sheet_name}")
    print("Shape:", df.shape)
    print("Columns:", list(df.columns))
    for col in df.columns:
        series = df[col].dropna().astype(str).str.strip()
        series = series[series.ne("")]
        print(f"\nColumn: {col} | nonblank={len(series)} | unique={series.nunique()}")
        print(series.value_counts().head(12).to_string())
