# Workbook Lineage

## Control flow

The workbook entry point is `Z999_Excute.a999_Ashton_KNQMAN_vs_HJ_Report_()`.

It runs in four layers:

1. Pull or refresh staging sheets from HighJump SQL, AS400, and KNQ SQL Server.
2. Build comparison sheets such as `PO`, `Trips`, `KNQ delared but HJ not`, and `Trailer in Yard but KNQ not`.
3. Rebuild `DATA` from item-level aggregates.
4. Reapply annotations, variance categories, location counts, orphaned counts, and product grouping.

## Source to staging

These sheets are raw or near-raw sources:

- `HJ_SN`: HighJump serial-level on-hand rows.
- `HJ_SN_Orphaned`: orphaned serial rows from HighJump.
- `HJ_NG`: NG-location serial rows from HighJump.
- `ASYARD`: trailer or yard inventory by item and PO.
- `HJ_2W_SA`: recent HighJump shipped activity.
- `AS400_SA`: recent AS400 SA transactions.
- `Mapics_OnHand`: MAPICS item on-hand.
- `KNQ_OnHand`: KNQ bonded inventory by item.
- `KNQ_4W_Import`: recent KNQ import declarations.
- `KNQ_4W_Export`: recent KNQ export declarations.
- `HJ_4W_Received`: recent HighJump receipts by item and PO.
- `HJ_4W_Shipped`: recent HighJump shipments by item and trip.
- `Adjusted`: AS400 adjustment transactions.
- `exception`: manual exception quantities.
- `KNQ Variances List`: historical closed variance quantities.
- `Previous_Data`: last workbook snapshot with manual notes.
- `Item`: item-to-class lookup from AS400.

## Derived staging

These sheets exist to explain gaps before the final report is rebuilt:

- `PO`: items received in HighJump in the last 14 days where the PO is not in `KNQ_4W_Import`.
- `Trips`: items shipped in HighJump in the last 14 days where the trip is not in `KNQ_4W_Export`.
- `KNQ delared but HJ not`: KNQ import declarations from the last 14 days whose PO is not yet present in `HJ_4W_Received`.
- `Trailer in Yard but KNQ not`: yard rows whose `customer_po_number` does not exist in `KNQ_4W_Import`.

## DATA rebuild

`a0091_MAPICS_HJ_KNQ_VARIANCE_()` rebuilds `DATA` from three item universes:

- `KNQ_OnHand.Item`
- `HJ_SN.item_number` excluding location `SH001AA2`
- `Mapics_OnHand.ITNBR`

Then it populates item-level measures:

- `Mapics`: sum of `Mapics_OnHand.MOHTQ`
- `WA`: count of `HJ_SN` serial rows excluding `SH001AA2`
- `KNQMAN Qty`: sum of `KNQ_OnHand.KNQ_ONHAND`
- `YA Qty`: sum of `ASYARD.Qty_shipped`
- `YA Received`: sum of `ASYARD.Qty_received`
- `YA Qty Remained`: sum of `ASYARD.Qty_remaining`
- `YA DOOR Qty`: sum of `ASYARD.Qty_shipped` where `location_name` starts with `D`
- `Shipped Not Invoiced`: unresolved HighJump shipped quantity from `HJ_2W_SA` plus RP-order quantity matched through `AS400_SA`
- `Mapics HJ Diff`: `WA + YA DOOR Qty + Shipped Not Invoiced - Mapics`
- `KNQ HJ Variance`: `WA + YA Qty + Shipped Not Invoiced - KNQMAN Qty`

## Final enrichments

The later macros add final business columns:

- `PO`, `Trip`, `KNQ delared but HJ not`, `Trailer in Yard KNQ not`: exception measures.
- `GAP`: `KNQMAN Qty + PO - Trip - KNQ delared but HJ not - WA`
- `KNQ-AS400`: `KNQMAN Qty - Mapics`
- `EX001AA1`, `SH001AA1`, `SH001AA2`, `EX001AA2`: location counts from `HJ_SN`
- `RollBack`: sum of `rollback.TRQTY`
- `VarianceQty`: `-GAP`
- `Category`: sign-based label from `VarianceQty`
- `Variance`: sum of historical `KNQ Variances List.ABS(Qty)` for the item
- `Gap`: `Variance - ABS(Variances)`
- `Orphaned.1`: orphaned serial count excluding `NG001OP*`
- `Product_category`: derived from AS400 item class

Manual note columns are carried forward from `Previous_Data` and then overwritten for obvious no-variance cases.
