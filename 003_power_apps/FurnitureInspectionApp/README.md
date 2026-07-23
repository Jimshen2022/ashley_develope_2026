# Furniture Inspection Power App

Target site:

```text
https://masterashley.sharepoint.com/sites/AsiaWarehouseOperations/power_app
```

This package is based on `Ashton Receiving Issue Collection.msapp`.

## Current App Package

The downloaded app has been patched directly at the `.msapp` package level.

```text
Furniture Inspection Collection.modified.msapp
```

Original backup:

```text
Furniture Inspection Collection.original.msapp
```

Patched in the current package:

1. New inspections auto-generate `InspectionID` as `FI-yyyymmddhhmmss-guid8`.
2. New records default `InspectionDate` and `ReportDate` to today.
3. New records default `Inspector` to `User().FullName`.
4. `ItemNumber` and `SerialNumber` still allow manual entry, and their text inputs are wired to variables so barcode-reader controls can set the same values later.
5. Save validates required business fields and requires 10-20 photo attachments.
6. `PhotoCount` is calculated from the attachments control.
7. The browse gallery searches by `InspectionID`, `ItemNumber`, and `SerialNumber`.

Important remaining items:

1. The current downloaded package only contains the `FurnitureInspections` data source. Add `FurnitureInspectionPhotos` as a second data source before using the two-list photo patch formula.
2. Barcode reader controls are not safely injected into the package because their control template is not present in this `.msapp`. Add two Barcode reader controls in Studio, then use the formulas in `powerapps-formulas.md`.
3. The scheduled Excel email still needs a Power Automate cloud flow. Microsoft 365 CLI login is blocked by tenant app consent, so this cannot be created headlessly yet.
The old app pattern is:

1. Save one master SharePoint list item.
2. Use `frmIssue.LastSubmit.ID`.
3. Loop local photo collection and patch each image into a second SharePoint list.

The new app should keep the same pattern:

1. `FurnitureInspections` stores one record per serial-number inspection.
2. `FurnitureInspectionPhotos` stores 10-20 photos linked to the inspection.
3. `ItemNumber` and `SerialNumber` support both Power Apps Mobile barcode scan and manual text entry.
4. Power Automate writes a unique `InspectionID`.
5. Power Automate sends daily Excel attachments at 6:50 AM and 7:50 PM.

## Current Blocker

Microsoft 365 CLI is installed locally, but it is currently logged out.

The tenant resolves as:

```text
masterashley.onmicrosoft.com
Tenant ID observed from login error: 5a9d9cfd-c32e-4ac1-a9ed-fe83df4f9e4d
```

The public CLI app id failed because it is not installed/consented in this tenant:

```text
31359c7f-bd7e-475c-86db-fdb8c937548e
```

To run `create-sharepoint-lists.ps1`, use either:

1. A tenant-approved Entra app id for CLI Microsoft 365 delegated login.
2. Admin consent/install for the CLI app above.
3. An already-authenticated Microsoft 365 CLI session.

This is an authentication/tenant-consent boundary; it should not be bypassed.

## Files

- `sharepoint-schema.json`: list and field design.
- `create-sharepoint-lists.ps1`: Microsoft 365 CLI script to create lists and columns.
- `powerapps-formulas.md`: formulas for the mobile Canvas app.
- `power-automate-flows.md`: flow build steps and expressions.
- `test-plan.md`: end-to-end test checklist.



