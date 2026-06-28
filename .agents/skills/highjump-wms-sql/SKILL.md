---
name: highjump-wms-sql
description: HighJump WMS SQL Server reporting and analysis skill for inventory, location, trip, shipping, order, serial number, ASN, trailer, yard, labor PPH, replenishment, door, and zone workflows. Use when Codex needs to navigate HighJump tables, stored procedures, dashboard wrappers, custom operational reporting, or warehouse business logic in the HighJump knowledge pack. Trigger on requests mentioning HighJump, HJ, trip, STO, serial, trailer, ASN, yard, PPH, replenishment, hotloading, inventory location, 货位, 波次, 出货行程, 补货, 串号, or 码头, especially under local paths like `000_JimCursor\001_AshleyProject\HJ_SQLSERVER`, `001_Wanek\050_Hotloading`, `002_HJ_setup`, and `002_KNQMAN_HJ_Mapics_Variance`.
---

# HighJump WMS SQL

Use this skill for HighJump WMS work that depends on knowing which tables, procedures, and report patterns usually answer the user's question.

## Workflow

1. Classify the request into a business domain.
   Start with one of these domains: inventory and location, trip and shipping, yard and ASN inbound, labor and PPH, or replenishment and door or zone control.
2. Choose the likely entry point before editing SQL.
   For trip readiness, start with `usp_ww_trip_report` and `usp_trip_available_sto`.
   For serial tracing, start with `usp_ww_search_by_serial_number`.
   For yard unload or trailer priority, start with `usp_Get_Asn_Equipment_Unload`.
   For labor or PPH, start with `usp_ww_shipping_pph_china`.
   For replenishment issues, start with `usp_diagnose_replenishment`.
3. Explain the current logic before changing it.
   Identify the main driving tables, joins that can multiply rows, status filters, and whether the query is operational visibility logic that intentionally uses `WITH (NOLOCK)`.
4. Preserve HighJump reporting conventions.
   Expect separate date and time columns, lookup-driven translations in `t_lookup`, configuration values in `t_control`, and duplicated local files that may represent procedure source, page export, or working copies.
5. Use the reference notes surgically.
   Load the detailed reference only for the domain or stored procedure you need instead of treating the whole note as always-required context.

## Local Path Hints

Check these locations first when the request looks HighJump related:

- `D:\GitHub\ashley_develope_2026\000_JimCursor\001_AshleyProject\HJ_SQLSERVER`
- `D:\GitHub\ashley_develope_2026\001_Wanek\050_Hotloading`
- `D:\GitHub\ashley_develope_2026\002_HJ_setup`
- `D:\GitHub\ashley_develope_2026\002_KNQMAN_HJ_Mapics_Variance`

## Working Rules

- Prefer the stored procedure or report copy that actually contains logic; some local `.sql` files are empty placeholders.
- Treat status codes, location types, and serial states as working assumptions unless the live data confirms them.
- When rewriting a query, keep the warehouse business question visible: inventory position, trip completeness, yard supply, serial traceability, labor productivity, or replenishment failure.

## Reference

Read [highjump-expert-notes.md](references/highjump-expert-notes.md) for the full table map, stored procedure inventory, business domains, and file-to-page mappings.
