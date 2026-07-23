# Test Plan

## SharePoint Lists

1. Confirm `FurnitureInspections` exists.
2. Confirm `FurnitureInspectionPhotos` exists.
3. Confirm `InspectionID` is indexed and unique.
4. Confirm `ItemNumber`, `SerialNumber`, and `ReportDate` are indexed.
5. Confirm `Photo` is an Image/Thumbnail column.

## Power Apps Mobile

1. Open the app in Power Apps Mobile, not a browser.
2. Tap New.
3. Scan `ItemNumber` barcode.
4. Confirm `txtItemNumber.Text` is populated.
5. Manually overwrite `ItemNumber`; confirm the typed value is saved.
6. Scan `SerialNumber` barcode.
7. Confirm `txtSerialNumber.Text` is populated.
8. Manually overwrite `SerialNumber`; confirm the typed value is saved.
9. Fill all required fields.
10. Upload 10-20 photos.
11. Save.

## Data Validation

1. Confirm one row appears in `FurnitureInspections`.
2. Confirm `InspectionID` is generated as `INS-yyyyMMdd-0000`.
3. Confirm `PhotoCount` matches uploaded photo count.
4. Confirm all photo rows appear in `FurnitureInspectionPhotos`.
5. Confirm each photo row has `InspectionListID`.

## Report Flow

1. Manually trigger the 6:50 AM report flow.
2. Confirm only today's inspection records appear.
3. Confirm Excel opens and has all required columns.
4. Confirm email reaches Ashton CS Team.
5. Confirm email reaches Inventory Team.
6. Manually trigger the 7:50 PM report flow and repeat.

