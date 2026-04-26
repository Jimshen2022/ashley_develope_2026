#!/usr/bin/env python3
"""Generate a simple HTML summary from query_results.csv."""

from __future__ import annotations

import argparse
import csv
import datetime as dt
import html
import pathlib
from typing import Dict, List


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Create an HTML summary report of top items by volume."
    )
    parser.add_argument(
        "--input",
        default="query_results.csv",
        help="Path to the input CSV file (default: query_results.csv).",
    )
    parser.add_argument(
        "--output",
        default="summary_report.html",
        help="Path to the output HTML file (default: summary_report.html).",
    )
    parser.add_argument(
        "--top",
        type=int,
        default=10,
        help="Number of rows to include in the report (default: 10).",
    )
    return parser.parse_args()


def normalize_column(column_name: str) -> str:
    return "".join(ch for ch in column_name.lower() if ch.isalnum())


def parse_volume(value: str) -> float:
    cleaned = value.strip().replace(",", "")
    if not cleaned:
        return 0.0
    return float(cleaned)


def select_item_column(fieldnames: List[str], volume_column: str) -> str:
    preferred = ("item", "itemid", "sku", "name", "description")
    normalized_map = {normalize_column(name): name for name in fieldnames}
    for key in preferred:
        if key in normalized_map and normalized_map[key] != volume_column:
            return normalized_map[key]

    for name in fieldnames:
        if name != volume_column:
            return name
    return volume_column


def load_top_rows(input_path: pathlib.Path, top_n: int) -> Dict[str, object]:
    if not input_path.exists():
        raise FileNotFoundError(f"Input file not found: {input_path}")

    with input_path.open("r", encoding="utf-8-sig", newline="") as handle:
        reader = csv.DictReader(handle)
        if not reader.fieldnames:
            raise ValueError("Input CSV is missing a header row.")

        volume_column = None
        for name in reader.fieldnames:
            if normalize_column(name) == "volume":
                volume_column = name
                break
        if volume_column is None:
            raise ValueError("Input CSV must contain a 'volume' column.")

        rows = []
        for idx, row in enumerate(reader, start=2):
            raw_value = row.get(volume_column, "")
            try:
                numeric_volume = parse_volume(raw_value)
            except ValueError as exc:
                raise ValueError(
                    f"Invalid volume value on CSV line {idx}: {raw_value!r}"
                ) from exc

            row_copy = dict(row)
            row_copy["_numeric_volume"] = numeric_volume
            rows.append(row_copy)

    rows.sort(key=lambda r: r["_numeric_volume"], reverse=True)
    return {
        "top_rows": rows[:top_n],
        "fieldnames": reader.fieldnames,
        "volume_column": volume_column,
        "item_column": select_item_column(reader.fieldnames, volume_column),
        "total_rows": len(rows),
    }


def build_html_report(summary: Dict[str, object], top_n: int) -> str:
    top_rows = summary["top_rows"]
    fieldnames = summary["fieldnames"]
    volume_column = summary["volume_column"]
    item_column = summary["item_column"]
    total_rows = summary["total_rows"]
    timestamp = dt.datetime.now().strftime("%Y-%m-%d %H:%M:%S")

    row_html = []
    for rank, row in enumerate(top_rows, start=1):
        cells = [
            f"<td>{rank}</td>",
            f"<td>{html.escape(str(row.get(item_column, '')))}</td>",
            f"<td>{row.get('_numeric_volume', 0):,.2f}</td>",
        ]
        for col in fieldnames:
            if col in (item_column, volume_column):
                continue
            cells.append(f"<td>{html.escape(str(row.get(col, '')))}</td>")
        row_html.append("<tr>" + "".join(cells) + "</tr>")

    extra_columns = [col for col in fieldnames if col not in (item_column, volume_column)]
    header_cells = (
        "<th>Rank</th><th>Item</th><th>Volume</th>"
        + "".join(f"<th>{html.escape(col)}</th>" for col in extra_columns)
    )

    return f"""<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <title>Query Results Summary</title>
  <style>
    body {{ font-family: Arial, sans-serif; margin: 2rem; color: #222; }}
    h1 {{ margin-bottom: 0.5rem; }}
    .meta {{ color: #555; margin-bottom: 1rem; }}
    table {{ border-collapse: collapse; width: 100%; }}
    th, td {{ border: 1px solid #ddd; padding: 0.5rem; text-align: left; }}
    th {{ background: #f3f5f8; }}
    td:nth-child(1), td:nth-child(3) {{ text-align: right; }}
  </style>
</head>
<body>
  <h1>Top {top_n} Items by Volume</h1>
  <p class="meta">Generated: {timestamp} | Source rows: {total_rows}</p>
  <table>
    <thead><tr>{header_cells}</tr></thead>
    <tbody>
      {''.join(row_html)}
    </tbody>
  </table>
</body>
</html>
"""


def main() -> None:
    args = parse_args()
    if args.top <= 0:
        raise ValueError("--top must be greater than zero.")

    input_path = pathlib.Path(args.input)
    output_path = pathlib.Path(args.output)

    summary = load_top_rows(input_path, args.top)
    report = build_html_report(summary, args.top)
    output_path.write_text(report, encoding="utf-8")
    print(f"Report generated: {output_path.resolve()}")


if __name__ == "__main__":
    main()
