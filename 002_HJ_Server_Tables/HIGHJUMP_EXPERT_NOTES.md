# HighJump Expert Notes

This file is a working knowledge base for `D:\GitHub\ashley_develope_2026\002_HJ_Server_Tables`.

## Scope

This folder is not only a table reference dump.
It combines three layers:

1. HighJump SQL Server stored procedures and report SQL
2. Advantage Dashboard / WebWise page wrapper scripts
3. Custom analysis code built on top of HighJump data

## Main Business Domains

### 1. Inventory and Location

Core tables:

- `t_location`
- `t_stored_item`
- `t_item_master`
- `t_serial_active`
- `t_serial_master`
- `t_item_uom`

What they represent:

- `t_location`: physical warehouse locations
- `t_stored_item`: on-hand inventory by location, lot, status, and type
- `t_item_master`: SKU master, dimensions, cube, commodity, pick/put logic
- `t_serial_active`: active serials currently visible to warehouse operations
- `t_serial_master`: serial master history / control layer
- `t_item_uom`: dimensional and volume details by UOM

Typical questions answered:

- Where is inventory now?
- Is an item active, staged, loaded, or missing?
- Does serial status in `t_serial_active` match `t_serial_master`?
- How much stock is available in storage vs staging vs yard?

### 2. Trip, Order, and Shipping

Core tables:

- `t_load_master`
- `t_order`
- `t_order_detail`
- `t_order_detail_breakdown`
- `t_pick_detail`
- `t_load_dispatch`
- `t_order_c_number`

What they represent:

- `t_load_master`: trip / load header
- `t_order`: order header tied to trip
- `t_order_detail` and `t_order_detail_breakdown`: line and item demand
- `t_pick_detail`: picked quantity details
- `t_load_dispatch`: dispatch confirmation / dispatch metadata
- `t_order_c_number`: C-number level customer or order grouping detail

Typical questions answered:

- What does a trip still need?
- What has already been picked?
- Why is a trip incomplete?
- How should trip-level reporting be grouped?

### 3. Yard, ASN, and Inbound Containers

Core tables:

- `t_trailer`
- `t_trailer_asn`
- `t_asn`
- `t_asn_detail`
- `t_ya_work_q`
- `t_ya_location`
- `t_ya_tran_log`
- `t_area_wh_id`

What they represent:

- `t_trailer`: inbound or outbound trailer / container
- `t_trailer_asn`: bridge from trailer to ASN
- `t_asn`: ASN header
- `t_asn_detail`: ASN item detail
- `t_ya_work_q`: yard movement / unloading work queue
- `t_ya_location`: yard location and yard type metadata
- `t_ya_tran_log`: yard transaction history
- `t_area_wh_id`: area-to-warehouse mapping

Typical questions answered:

- Which containers are checked in?
- What items are in yard but not yet received?
- Which trailer should be unloaded first?
- What trip demand can be fulfilled from inbound yard supply?

### 4. Labor, Team, and PPH

Core tables:

- `t_team`
- `t_team_member`
- `t_team_employee_clock_in_out`
- `t_tran_log`
- `t_lookup`
- `t_control`
- `t_employee`

What they represent:

- `t_team`: work team definition
- `t_team_member`: employee-to-team relationship
- `t_team_employee_clock_in_out`: CICO records
- `t_tran_log`: operational transaction log
- `t_lookup`: translation and transaction label mapping
- `t_control`: configuration parameters
- `t_employee`: employee master

Typical questions answered:

- How is shipping PPH calculated?
- Which team handled which quantity?
- Which transaction types count toward a labor report?
- What lunch or PPH control settings affect calculation?

### 5. Replenishment, Door, and Zone Control

Core tables:

- `t_fwd_priority_sub`
- `t_location_sub`
- `t_work_q_sub`
- `t_replenishment_rule`
- `t_zone_loca`
- `t_fwd_pick`

Typical questions answered:

- Why is replenishment failing?
- Which forward pick locations are short?
- How are doors or zones mapped to active work?

## Most Important Stored Procedures and Reports

### `usp_ww_trip_report`

File:

- `sonia\003_HJ_TABLE\SearchTripReport.sql`
- page wrapper copy: `sonia\AD1571.txt`

Main purpose:

- trip report for Advantage Dashboard / WebWise

High-value tables:

- `t_order`
- `t_order_c_number`
- `t_load_master`
- `t_afo_load_view`
- `t_load_dispatch`
- `t_carrier`

Why it matters:

- this is one of the most important outbound visibility procedures
- it captures trip type, status, dispatch, customer/service details, and load allocation logic

### `usp_Get_Asn_Equipment_Unload`

File:

- `sonia\003_HJ_TABLE\usp_Get_Asn_Equipment_Unload.sql`
- page wrapper copy: `sonia\usp_Get_Asn_Equipment_Unload (1).txt`
- page variant: `sonia\003_HJ_TABLE\usp_Get_Asn_Equipment_Unload_ya1456.sql`

Main purpose:

- inbound trailer / yard / ASN unload visibility

High-value tables:

- `t_ya_work_q`
- `t_asn`
- `t_trailer`
- `t_trailer_asn`
- `t_item_master`
- `t_load_master`
- `t_ya_tran_log`

Why it matters:

- this is one of the heaviest and most business-critical inbound procedures
- the logic spans yard state, ASN demand, trailer prioritization, and trip linkage

### `usp_trip_available_sto`

File:

- `sonia\003_HJ_TABLE\STOavailableReport.sql`
- duplicate copy: `009_AvaiableSTO\099-STOavailableReport.sql`
- direct-query rewrite: `009_AvaiableSTO\000_Ashton_Trip_available_STO_hjsev.sql`
- related working query: `sonia\usp_trip_available_sto_query.sql`

Main purpose:

- compare trip demand against available stock, staged stock, yard, ASN, overflow, and in-transit supply

High-value tables:

- `t_stored_item`
- `t_location`
- `t_load_master`
- `t_order`
- `t_order_detail_breakdown`
- `t_pick_detail`
- `t_asn`
- `t_asn_detail`

Why it matters:

- this is the clearest native bridge between outbound demand and upstream available supply
- it strongly influenced the custom Python allocation work in this folder

### `usp_ww_search_by_serial_number`

File:

- `sonia\003_HJ_TABLE\search_for_active_serial_number.sql`
- page wrapper copy: `sonia\AD1580 (1).txt`

Main purpose:

- serial number search by serial, item, PO, location, order, and LP

High-value tables:

- `t_serial_active`
- `t_serial_master`
- `t_item_master`
- `t_carb_master`
- `t_stored_item`

Why it matters:

- this is the key serial-tracking procedure for tracing active warehouse serials
- it also reveals common serial status values and mismatch cases

### `usp_ww_shipping_pph_china`

File:

- `sonia\003_HJ_TABLE\AD1568-ShippingPPH.sql`
- duplicate copy: `sonia\003_HJ_TABLE\Ashton_pph.sql`
- page wrapper copy: `sonia\AD1568 Shipping PPH.txt`

Main purpose:

- shipping PPH calculation using team CICO windows and transaction logs

High-value tables:

- `t_team`
- `t_team_member`
- `t_team_employee_clock_in_out`
- `t_tran_log`
- `t_lookup`
- `t_control`

Why it matters:

- it is the clearest example of HighJump labor-report logic in this folder

### Other Important Procedures

- `usp_ww_pick_run_report`: pick run and exception visibility
- `usp_ww_item_loc_date_transaction`: item/location/date transaction trace
- `usp_ww_forward_pick_locations_report`: forward pick shortage / utilization
- `usp_diagnose_replenishment`: replenishment troubleshooting
- `usp_search_trailer_byitem`: trailer search by item
- `usp_ww_shipping_door_management`: shipping door status view
- `usp_ww_door_management_decoupled_zone`: zone / door coordination
- `usp_load_summary`: load summary page logic, though the local `.sql` file is empty and the text copy is the real source

## Page and File Mapping

Common page-to-file mappings confirmed in this folder:

- `AD1571` -> `usp_ww_trip_report`
- `AD1568` -> `usp_ww_shipping_pph_china`
- `AD1580` -> `usp_ww_search_by_serial_number`
- `AD1960` -> `usp_ww_pick_run_report`
- `WA1044` -> `Search_Location`
- `WA1180` -> `usp_AF_check_reader_status`
- `YA1456` -> `usp_Get_Asn_Equipment_Unload`
- `page 1220` -> stored item search style query
- `page 1423` -> `usp_trip_available_sto`

## Important Custom Analysis Work

### Yard vs Trip Demand Allocation

Files:

- `trip_demand.sql`
- `yard_supply.sql`
- `yard_vs_trip_demand_fulfillment.py`
- `yard_vs_trip_demand_fulfillment_v00.py`
- `yard_vs_trip_demand_fulfillment_v01.py`
- `yard_vs_trip_demand_fulfillment_v02.py`
- sample output: `Allocation_Result_20260408_224128.xlsx`

Business idea:

- use HighJump outbound trip demand and inbound yard ASN supply
- allocate item-level yard supply against open trip demand
- score trip readiness and container usefulness

Demand logic source:

- `t_load_master`
- `t_order`
- `t_order_detail_breakdown`
- `t_pick_detail`

Supply logic source:

- `t_trailer`
- `t_trailer_asn`
- `t_asn`
- `t_asn_detail`

Output concept:

- `Demand` sheet: how much of each trip demand can be satisfied by yard supply
- `Supply` sheet: how much of each container contributes to current trip demand

This is not a standard HighJump object.
It is a custom operational decision model built from HighJump base tables.

## Common Query Patterns in This Folder

### 1. Combine date and time columns

HighJump commonly stores date and time separately.

Typical pattern:

```sql
DATEADD(SECOND, DATEDIFF(SECOND, 0, dispatch_time), dispatch_date)
```

Or:

```sql
start_tran_date + start_tran_time
```

### 2. Heavy use of `NOLOCK`

Most report SQL here uses `WITH (NOLOCK)`.

Implication:

- optimized for operational visibility
- accepts possible dirty reads
- typical for warehouse live-reporting queries

### 3. `t_lookup` translates transaction meaning

Typical use:

- map `tran_type` to readable description
- map location or order type lookup codes
- map page-specific display values

Common sources seen here:

- `BillableContainer`
- `TransferContainer`
- `MoveContainer`
- `PPHLunchTime`

### 4. `t_control` holds report behavior switches

Typical uses:

- lunch time / PPH goal
- building used for forward pick logic
- automation thresholds
- dashboard behavior flags

### 5. Multi-copy files are normal

This folder contains true duplicates:

- `AD1568-ShippingPPH.sql` == `Ashton_pph.sql`
- `usp_ww_pick_run_report.sql` == `AD1960 (1).txt`
- `search_for_active_serial_number.sql` == `AD1580 (1).txt`
- `usp_Get_Asn_Equipment_Unload.sql` == `usp_Get_Asn_Equipment_Unload (1).txt`
- `STOavailableReport.sql` == `099-STOavailableReport.sql`

Interpretation:

- some files are procedure sources
- some are page exports or user copies
- some are developer working copies

## Known Status and Business Clues

These values are visible in the local SQL and should be treated as working assumptions until verified in live data.

Serial statuses often seen:

- `H` = hold
- `R` = in warehouse
- `L` = loaded
- `S` = shipped
- `O` = orphaned

Load statuses often filtered out:

- `S`
- `X`
- `C`

Warehouse / location clues:

- `wh_id = '335'` appears often in local custom analysis
- `UPH` is an important `pick_put_id`
- location types such as `A`, `M`, `I`, `X`, `P`, `S`, `D`, `DOOR`, `DRAYAGE` matter in report logic

## Files With Special Meaning

### `WMS tables.xlsx`

Purpose:

- schema dictionary export

Observed facts:

- about 13,057 field rows
- about 1,030 tables
- includes `dbo`, `cdc`, and backup-style tables

Use this when:

- checking a column name
- identifying table ownership
- exploring rarely used tables

### `HIGHJUMP_EXPERT_NOTES.md`

Purpose:

- reusable knowledge base for future work in this folder

### Empty placeholders

These local files are currently empty and should not be trusted as source logic:

- `sonia\003_HJ_TABLE\Ashton_replenishment.sql`
- `sonia\003_HJ_TABLE\usp_load_summary .sql`

Use their related text or page copies instead if you need the real logic.

## Best Starting Points By Task

If the task is:

- trip readiness -> start with `usp_ww_trip_report` and `usp_trip_available_sto`
- serial tracing -> start with `usp_ww_search_by_serial_number`
- yard unload priority -> start with `usp_Get_Asn_Equipment_Unload`
- labor / PPH -> start with `usp_ww_shipping_pph_china`
- replenishment issue -> start with `usp_diagnose_replenishment`
- location investigation -> start with `Search_Location.sql`
- trailer-by-item search -> start with `usp_search_trailer_byitem`
- custom supply-vs-demand study -> start with `trip_demand.sql`, `yard_supply.sql`, and `yard_vs_trip_demand_fulfillment_v02.py`

## Working Conclusion

This folder is already enough to build practical expertise in HighJump reporting for:

- outbound trip visibility
- inbound ASN / trailer visibility
- serial tracking
- inventory availability
- labor PPH reporting
- replenishment diagnosis
- custom yard-to-trip allocation analysis

For future work, treat this folder as a report-and-operations reference pack, not just a schema folder.
