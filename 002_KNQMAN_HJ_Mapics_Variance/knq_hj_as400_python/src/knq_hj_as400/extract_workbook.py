from __future__ import annotations

import argparse
import json
import re
import zipfile
from collections import defaultdict
from pathlib import Path
from typing import Any

import pandas as pd
from oletools.olevba import VBA_Parser
from pyxlsb import open_workbook


CODE_NAME_PATTERN = re.compile(b"S\x00h\x00e\x00e\x00t\x00(?:[0-9]\x00)+")
SHEET_REF_PATTERN = re.compile(r"\bSheet\d+\b|Sheets\(\"([^\"]+)\"\)")
CALL_PATTERN = re.compile(r"\bCall\s+([A-Za-z0-9_]+)|\b([A-Za-z0-9_]+)\s*\(", re.IGNORECASE)


def _decode_vba(source: Any) -> str:
    if isinstance(source, bytes):
        return source.decode("utf-8", errors="replace")
    return str(source)


def _extract_vba(workbook_path: Path, output_dir: Path) -> dict[str, str]:
    parser = VBA_Parser(str(workbook_path))
    if not parser.detect_vba_macros():
        raise RuntimeError(f"No VBA macros found in {workbook_path}")

    macros: dict[str, str] = {}
    vba_dir = output_dir / "vba"
    vba_dir.mkdir(parents=True, exist_ok=True)

    try:
        for _file_name, _stream_path, vba_name, vba_code in parser.extract_all_macros():
            name = Path(vba_name).name
            text = _decode_vba(vba_code)
            macros[name] = text
            (vba_dir / name).write_text(text, encoding="utf-8")
    finally:
        parser.close()

    return macros


def _sheet_code_name_map(workbook_path: Path) -> list[dict[str, Any]]:
    with zipfile.ZipFile(workbook_path) as archive, open_workbook(workbook_path) as workbook:
        target_to_name = {target.replace("\\", "/"): name for name, target in workbook._sheets}
        rows: list[dict[str, Any]] = []
        for target, sheet_name in target_to_name.items():
            raw = archive.read(f"xl/{target}")
            match = CODE_NAME_PATTERN.search(raw[:256])
            code_name = None
            if match:
                code_name = match.group(0).decode("utf-16le")
            rows.append(
                {
                    "sheet_name": sheet_name,
                    "sheet_part": target,
                    "code_name": code_name,
                }
            )
    return rows


def _sheet_preview(workbook_path: Path, max_rows: int = 5) -> list[dict[str, Any]]:
    workbook = pd.ExcelFile(workbook_path, engine="pyxlsb")
    previews: list[dict[str, Any]] = []
    for sheet_name in workbook.sheet_names:
        try:
            frame = pd.read_excel(
                workbook_path,
                sheet_name=sheet_name,
                engine="pyxlsb",
                nrows=max_rows,
            )
        except Exception as exc:  # pragma: no cover - analysis helper
            previews.append(
                {
                    "sheet_name": sheet_name,
                    "error": str(exc),
                }
            )
            continue

        previews.append(
            {
                "sheet_name": sheet_name,
                "columns": [str(column) for column in frame.columns.tolist()],
                "rows": frame.fillna("").astype(str).to_dict(orient="records"),
            }
        )
    return previews


def _macro_dependencies(macros: dict[str, str], sheet_map: list[dict[str, Any]]) -> dict[str, Any]:
    known_macros = {Path(name).stem for name in macros}
    sheet_names = {item["sheet_name"] for item in sheet_map}
    code_names = {item["code_name"] for item in sheet_map if item["code_name"]}

    result: dict[str, Any] = {}
    for macro_name, text in macros.items():
        calls: set[str] = set()
        sheet_refs: set[str] = set()

        for match in CALL_PATTERN.finditer(text):
            candidate = match.group(1) or match.group(2)
            if not candidate:
                continue
            cleaned = candidate.strip()
            if cleaned in known_macros:
                calls.add(cleaned)

        for match in SHEET_REF_PATTERN.finditer(text):
            raw = match.group(0)
            if raw.startswith('Sheets("'):
                sheet_refs.add(match.group(1))
            elif raw in code_names:
                sheet_refs.add(raw)

        for sheet_name in sheet_names:
            if f'"{sheet_name}"' in text:
                sheet_refs.add(sheet_name)

        result[macro_name] = {
            "calls": sorted(calls),
            "sheet_refs": sorted(sheet_refs),
        }

    return result


def _write_json(path: Path, payload: Any) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(payload, ensure_ascii=False, indent=2), encoding="utf-8")


def build_analysis(workbook_path: Path, output_dir: Path) -> None:
    output_dir.mkdir(parents=True, exist_ok=True)

    macros = _extract_vba(workbook_path, output_dir)
    sheet_map = _sheet_code_name_map(workbook_path)
    previews = _sheet_preview(workbook_path)
    dependencies = _macro_dependencies(macros, sheet_map)

    _write_json(output_dir / "sheet_map.json", sheet_map)
    _write_json(output_dir / "sheet_previews.json", previews)
    _write_json(output_dir / "macro_dependencies.json", dependencies)

    sheet_ref_index: dict[str, list[str]] = defaultdict(list)
    for macro_name, meta in dependencies.items():
        for sheet_ref in meta["sheet_refs"]:
            sheet_ref_index[sheet_ref].append(macro_name)
    _write_json(output_dir / "sheet_ref_index.json", dict(sorted(sheet_ref_index.items())))


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Extract VBA and workbook metadata from the KNQ workbook.")
    parser.add_argument("workbook", type=Path, help="Path to the source xlsb workbook")
    parser.add_argument(
        "--output-dir",
        type=Path,
        default=Path("analysis"),
        help="Directory that will receive extracted macros and metadata",
    )
    return parser.parse_args()


def main() -> None:
    args = parse_args()
    build_analysis(args.workbook, args.output_dir)


if __name__ == "__main__":
    main()
