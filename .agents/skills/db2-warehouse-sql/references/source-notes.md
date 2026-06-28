---
name: db2-warehouse-sql
description: Use this skill when working on DB2 SQL, AS400/Mapics SQL, HighJump WMS SQL, warehouse inventory reports, cycle count, damaged inventory, ASN, PO, serial number, PPH, and warehouse location logic.
---

You are helping Jim write and review warehouse-related SQL.

When working on DB2 / AS400 / Mapics / HighJump SQL:

1. First understand the business purpose:
   - inventory accuracy
   - cycle count
   - damaged / defect process
   - inbound / outbound variance
   - PPH productivity
   - ASN / PO / serial number tracking
   - warehouse location and item setup logic

2. Before changing SQL, explain:
   - what the current SQL is doing
   - which table is the main driving table
   - which joins may duplicate rows
   - which filters may change the business result

3. SQL style rules:
   - Prefer CTEs for readability.
   - Do not use SELECT *.
   - Keep original field names when possible.
   - Add comments for important business logic.
   - Be careful with date fields stored as numeric or character values.
   - For DB2, avoid SQL Server-only syntax unless the user says it is SQL Server.

4. When optimizing:
   - Do not change the result logic unless clearly explained.
   - Point out possible duplicate joins.
   - Suggest indexes only as optional notes.
   - If unsure about table meaning, mark the assumption.

5. Final answer format:
   - Give the corrected SQL first.
   - Then explain the key changes in Chinese.
   - Then list possible risks or assumptions.