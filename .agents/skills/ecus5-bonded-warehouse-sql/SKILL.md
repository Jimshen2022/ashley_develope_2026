---
name: ecus5-bonded-warehouse-sql
description: ECUS5 bonded warehouse SQL reverse-engineering skill for Vietnam customs bonded warehouse workflows including contract liquidation, import or export ledgers, FIFO on-hand inventory, ownership transfer, destruction, rut hang, and customs traceability. Use when Codex needs to analyze or adapt ECUS5 SQL involving DPHIEU, DPHIEU_HANG, DHOPDONG, DVANBAN, DTIEUHUY, DRUTHANG, bonded warehouse inventory, or aging logic. Trigger on requests mentioning ECUS5, KNQ, bonded warehouse, customs, FIFO, on hand, liquidation, transfer, destruction, import ledger, export ledger, 保税仓, 海关, 结存, 库龄, 过户, 销毁, 入库, 出库, or 结关, especially under local paths like `002_KNQMAN_HJ_Mapics_Variance\dnspy`, `002_KNQMAN_HJ_Mapics_Variance\KNQMAN`, and `002_KNQMAN_HJ_Mapics_Variance\SN check`.
---

# ECUS5 Bonded Warehouse SQL

Use this skill for ECUS5 and Vietnamese bonded-warehouse SQL where customs rules, document validity, and FIFO matching are more important than surface-level query cleanup.

## Workflow

1. Determine the business scenario first.
   Common scenarios are contract liquidation, import ledger, export ledger, real-time on-hand inventory, inventory aging, ownership transfer, destruction, and container-to-loose conversion (`rut hang`).
2. Apply the core document rules before trusting any result.
   Distinguish `_XORN = 'N'` and `_XORN = 'X'`.
   Distinguish `TYPE = 1` container cargo and `TYPE = 2` loose cargo.
   Respect document status and latest-version logic such as `TRANG_THAI`, `PB_PHIEU`, `DPHIEUID_NEXT`, and `DPHIEUID_PREV`.
3. Map the query to the core tables.
   `DHOPDONG` is the contract layer.
   `DPHIEU` and `DPHIEU_HANG` are the document header and line foundation.
   `DVANBAN` handles ownership transfer.
   `DTIEUHUY` handles supervised destruction.
   `DRUTHANG` handles unloading or unstuffing from container to loose cargo.
4. Preserve the real inventory logic.
   Do not simplify FIFO matching into plain `SUM(in) - SUM(out)` when the scenario depends on batch-level consumption.
   Keep multi-generation ownership tracing when stock age or original entry date matters.
5. Treat the bundled SQL as source material, not blind copy-paste.
   Reuse the full reference scripts when they match the request, but explain which filters, temp tables, and loops are essential before adapting them.

## Local Path Hints

Check these locations first when the request looks ECUS5 or bonded-warehouse related:

- `D:\GitHub\ashley_develope_2026\002_KNQMAN_HJ_Mapics_Variance\dnspy`
- `D:\GitHub\ashley_develope_2026\002_KNQMAN_HJ_Mapics_Variance\KNQMAN`
- `D:\GitHub\ashley_develope_2026\002_KNQMAN_HJ_Mapics_Variance\SN check`

## Working Rules

- If the task is about on-hand inventory or aging, assume FIFO reconciliation is the critical part until proven otherwise.
- If the task is about transfer or ownership, check whether warehouse stock moved physically or only changed contract ownership.
- If the task is about customs-compliant balances, verify that effective-status filters are present before trusting totals.
- Keep Chinese explanations concise and explicit when returning final SQL, especially around status flags and business assumptions.

## Reference

Read [ecus5-knowledge-base.md](references/ecus5-knowledge-base.md) for the detailed data dictionary, status semantics, and full production-style SQL patterns.
