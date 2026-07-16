from __future__ import annotations

import argparse
from pathlib import Path

from knq_hj_as400.live_pipeline import build_live_data_report
from knq_hj_as400.pipeline import preview_columns, summarize_report


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Run the KNQ / HJ / AS400 pipeline with live SQL pulls using VBA-compatible Setup parameters."
    )
    parser.add_argument(
        "--workbook",
        type=Path,
        required=True,
        help="Path to the workbook that contains the VBA Setup sheet and manual sheets",
    )
    parser.add_argument(
        "--preview",
        nargs="*",
        default=["Item Number", "Mapics", "WA", "KNQMAN Qty", "GAP", "Status", "Product_category"],
        help="Columns to print after the pipeline runs",
    )
    parser.add_argument("--limit", type=int, default=10, help="Preview row count")
    return parser.parse_args()


def main() -> None:
    args = parse_args()
    report = build_live_data_report(str(args.workbook))
    summary = summarize_report(report)
    print("Summary:", summary)
    print(preview_columns(report, args.preview, limit=args.limit).to_string(index=False))


if __name__ == "__main__":
    main()
