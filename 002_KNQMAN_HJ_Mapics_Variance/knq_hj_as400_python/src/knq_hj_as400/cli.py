from __future__ import annotations

import argparse


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Entry point for the KNQ / HJ / AS400 Python pipeline."
    )
    parser.add_argument(
        "--help-migration",
        action="store_true",
        help="Show the migration status for this project scaffold.",
    )
    return parser.parse_args()


def main() -> None:
    args = parse_args()
    if args.help_migration:
        print("Scaffold created. Next steps: inspect extracted workbook analysis and implement transforms.")
        return

    print("The pipeline scaffold is ready. Implement ETL steps in src/knq_hj_as400/.")
