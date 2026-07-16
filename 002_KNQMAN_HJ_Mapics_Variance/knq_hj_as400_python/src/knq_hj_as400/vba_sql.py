from __future__ import annotations

from pathlib import Path
import re


SQL_VAR_NAMES = ("sql_query", "cmdtxt")
SQL_VAR_SET = {name.lower() for name in SQL_VAR_NAMES}
ASSIGNMENT_RE = re.compile(r"^(?P<var>sql_query|cmdtxt)\s*=\s*(?P<expr>.*)$", re.IGNORECASE)


def _unescape_vba_string(token: str) -> str:
    return token[1:-1].replace('""', '"')


def _split_vba_concat(expression: str) -> list[str]:
    tokens: list[str] = []
    current: list[str] = []
    in_string = False
    i = 0
    while i < len(expression):
        char = expression[i]
        if char == '"':
            current.append(char)
            if in_string and i + 1 < len(expression) and expression[i + 1] == '"':
                current.append('"')
                i += 1
            else:
                in_string = not in_string
        elif char == "&" and not in_string:
            token = "".join(current).strip()
            if token:
                tokens.append(token)
            current = []
        else:
            current.append(char)
        i += 1
    tail = "".join(current).strip()
    if tail:
        tokens.append(tail)
    return tokens


def _render_expression(expression: str, substitutions: dict[str, str]) -> str:
    pieces: list[str] = []
    for token in _split_vba_concat(expression):
        lowered = token.lower()
        if token.startswith('"') and token.endswith('"'):
            pieces.append(_unescape_vba_string(token))
        elif lowered in {"vbcrlf", "vblf"}:
            pieces.append("\n")
        elif lowered in SQL_VAR_SET:
            continue
        elif lowered in substitutions:
            pieces.append(substitutions[lowered])
        elif token in substitutions:
            pieces.append(substitutions[token])
        else:
            pieces.append(substitutions.get(lowered, ""))
    return "".join(pieces)


def _join_vba_statement_lines(lines: list[str]) -> str:
    parts: list[str] = []
    for line in lines:
        stripped = line.strip()
        if not stripped:
            continue
        if stripped.endswith("_"):
            stripped = stripped[:-1].rstrip()
        parts.append(stripped)
    return " ".join(parts)


def _collect_assignment_statement(lines: list[str], start_index: int) -> tuple[str, int]:
    collected = [lines[start_index]]
    index = start_index
    continuation = lines[start_index].strip().endswith("_")

    while continuation and index + 1 < len(lines):
        index += 1
        candidate = lines[index]
        if not candidate.strip():
            continue
        collected.append(candidate)
        continuation = candidate.strip().endswith("_")

    return _join_vba_statement_lines(collected), index


def extract_vba_sql(vba_text: str, substitutions: dict[str, str] | None = None) -> str:
    substitutions = {key.lower(): value for key, value in (substitutions or {}).items()}
    rendered_parts: list[str] = []
    lines = vba_text.splitlines()

    index = 0
    while index < len(lines):
        line = lines[index].strip()
        match = ASSIGNMENT_RE.match(line)
        if not match or match.group("var").lower() not in SQL_VAR_SET:
            index += 1
            continue

        statement, index = _collect_assignment_statement(lines, index)
        expression = statement.split("=", 1)[1].strip()
        rendered = _render_expression(expression, substitutions)
        if rendered:
            rendered_parts.append(rendered)
        index += 1

    sql_text = "".join(rendered_parts).strip()
    if not sql_text:
        raise ValueError("No VBA SQL assignment found in the provided module text.")
    return sql_text


def extract_vba_sql_file(module_path: str | Path, substitutions: dict[str, str] | None = None) -> str:
    path = Path(module_path)
    return extract_vba_sql(path.read_text(encoding="utf-8"), substitutions=substitutions)
