---
name: db2-warehouse-sql
description: DB2, AS400, Mapics, and warehouse SQL analysis skill for inventory, cycle count, damaged inventory, inbound or outbound variance, ASN, PO, serial number tracking, PPH, item master, location logic, inventory age, and warehouse reports. Use when Codex needs to explain, review, optimize, or rewrite warehouse-related SQL and must preserve business meaning while staying compatible with DB2-style syntax. Trigger on requests mentioning DB2, AS400, Mapics, inventory, item master, location, ASN, PO, serial, PPH, 库存, 库龄, 周转, 物料主档, or 仓库报表, especially under local paths like `000_db2_schema\DB2`, `017_ItemMaster`, `001-MIL`, and `002_KNQMAN_HJ_Mapics_Variance`.
---

# DB2 Warehouse SQL

Use this skill to work on warehouse-facing SQL where the business result matters as much as the query syntax.

## Workflow

1. Identify the business purpose before changing SQL.
   Common intents include inventory accuracy, cycle count, damaged or defect handling, inbound or outbound variance, ASN or PO tracing, serial tracking, PPH, item master, and location setup logic.
2. Explain the current query before rewriting it.
   Call out the main driving table, joins that may duplicate rows, and filters that can change the business result.
3. Rewrite carefully.
   Prefer CTEs for readability, avoid `SELECT *`, keep original field names when practical, and add short comments only where business logic is easy to misunderstand.
4. Protect platform compatibility.
   Assume DB2-style SQL unless the user explicitly says the target is SQL Server. Be careful with date fields stored as numeric or character values.
5. Validate the business outcome.
   When optimizing, preserve result logic unless the change is explicitly intended. Mark assumptions when a table or code value is not fully confirmed.

## Local Path Hints

Check these locations first when the request looks DB2 or Mapics related:

- `D:\GitHub\ashley_develope_2026\000_db2_schema\DB2`
- `D:\GitHub\ashley_develope_2026\017_ItemMaster`
- `D:\GitHub\ashley_develope_2026\001-MIL`
- `D:\GitHub\ashley_develope_2026\002_KNQMAN_HJ_Mapics_Variance`

## Output Pattern

When returning a finished SQL answer:

1. Give the corrected SQL first.
2. Explain the key changes in Chinese.
3. List risks, assumptions, or places that still need live-data verification.

## Reference

Read [source-notes.md](references/source-notes.md) when you want the original source wording for this skill.
