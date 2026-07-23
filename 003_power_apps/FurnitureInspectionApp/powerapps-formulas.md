# Power Apps Mobile Formulas

Use a phone Canvas app, similar to `Ashton Receiving Issue Collection.msapp`.

## Patched Downloaded Package Notes

The generated app currently uses one screen, `MainScreen1`, and the main edit form is `Form1`.

Already patched in `Furniture Inspection Collection.modified.msapp`:

```powerfx
NewRecordAddIcon1.OnSelect =
Set(varInspectionId, "FI-" & Text(Now(), "[$-en-US]yyyymmddhhmmss") & "-" & Left(Text(GUID()), 8));
Set(varItemNumber, Blank());
Set(varSerialNumber, Blank());
NewForm(Form1);
UpdateContext({ newMode: true, editMode: false, itemSelected: true })
```

```powerfx
DataCardValue4.OnChange = Set(varItemNumber, Self.Text)
DataCardValue5.OnChange = Set(varSerialNumber, Self.Text)
```

After inserting Barcode reader controls in Power Apps Studio, set:

```powerfx
brItemNumber.OnScan = Set(varItemNumber, First(brItemNumber.Barcodes).Value); Reset(DataCardValue4)
brSerialNumber.OnScan = Set(varSerialNumber, First(brSerialNumber.Barcodes).Value); Reset(DataCardValue5)
```

The package currently validates 10-20 attachments on `SubmitFormButton1.OnSelect`. To save photos into `FurnitureInspectionPhotos`, first add that list as a data source, then replace `Form1.OnSuccess` with the two-list patch pattern below.
Data sources:

```text
FurnitureInspections
FurnitureInspectionPhotos
```

Recommended screens:

```text
scrHome
scrInspectionForm
```

## App.OnStart

```powerfx
Set(varSelectedInspection, Blank());
Set(varItemNumber, Blank());
Set(varSerialNumber, Blank());
Set(varUploadingPhotos, false);
Clear(colInspectionPhotos);
```

## scrHome.OnVisible

```powerfx
Concurrent(
    Refresh(FurnitureInspections),
    Refresh(FurnitureInspectionPhotos)
)
```

## New Button OnSelect

```powerfx
Clear(colInspectionPhotos);
Set(varSelectedInspection, Blank());
Set(varItemNumber, Blank());
Set(varSerialNumber, Blank());
NewForm(frmInspection);
Navigate(scrInspectionForm, ScreenTransition.Fade)
```

## Gallery Items

```powerfx
SortByColumns(
    Filter(
        FurnitureInspections,
        InspectionDate >= DateAdd(Today(), -14, TimeUnit.Days)
    ),
    "ID",
    SortOrder.Descending
)
```

Optional search by `InspectionID`, `ItemNumber`, or `SerialNumber`:

```powerfx
SortByColumns(
    Filter(
        FurnitureInspections,
        InspectionDate >= DateAdd(Today(), -14, TimeUnit.Days) &&
        (
            IsBlank(txtSearch.Text) ||
            StartsWith(InspectionID, txtSearch.Text) ||
            StartsWith(ItemNumber, txtSearch.Text) ||
            StartsWith(SerialNumber, txtSearch.Text)
        )
    ),
    "ID",
    SortOrder.Descending
)
```

## Gallery OnSelect

```powerfx
Set(varSelectedInspection, ThisItem);
Set(varItemNumber, ThisItem.ItemNumber);
Set(varSerialNumber, ThisItem.SerialNumber);
Clear(colInspectionPhotos);
EditForm(frmInspection);
Navigate(scrInspectionForm, ScreenTransition.Fade)
```

## frmInspection.Item

```powerfx
If(
    frmInspection.Mode = FormMode.New,
    Defaults(FurnitureInspections),
    varSelectedInspection
)
```

## ItemNumber Manual + Barcode Scan

Use a Text input named:

```text
txtItemNumber
```

Use a Barcode reader named:

```text
brItemNumber
```

`brItemNumber.Text`:

```powerfx
"Scan Item"
```

`brItemNumber.OnScan`:

```powerfx
Set(varItemNumber, First(brItemNumber.Barcodes).Value);
Reset(txtItemNumber)
```

`brItemNumber.OnCancel`:

```powerfx
Notify("Item scan cancelled.", NotificationType.Information)
```

`brItemNumber.BarcodeType`:

```powerfx
'Microsoft.BarcodeReader.BarcodeType'.Code128 &
'Microsoft.BarcodeReader.BarcodeType'.Code39 &
'Microsoft.BarcodeReader.BarcodeType'.UPC &
'Microsoft.BarcodeReader.BarcodeType'.EAN
```

If the warehouse uses mixed barcode formats, use Auto first.

`txtItemNumber.Default`:

```powerfx
Coalesce(varItemNumber, Parent.Default)
```

`txtItemNumber.OnChange`:

```powerfx
Set(varItemNumber, Self.Text)
```

`ItemNumber_DataCard.Update`:

```powerfx
txtItemNumber.Text
```

## SerialNumber Manual + Barcode Scan

Use a Text input named:

```text
txtSerialNumber
```

Use a Barcode reader named:

```text
brSerialNumber
```

`brSerialNumber.Text`:

```powerfx
"Scan Serial"
```

`brSerialNumber.OnScan`:

```powerfx
Set(varSerialNumber, First(brSerialNumber.Barcodes).Value);
Reset(txtSerialNumber)
```

`brSerialNumber.OnCancel`:

```powerfx
Notify("Serial scan cancelled.", NotificationType.Information)
```

`brSerialNumber.BarcodeType`:

```powerfx
'Microsoft.BarcodeReader.BarcodeType'.Code128 &
'Microsoft.BarcodeReader.BarcodeType'.Code39 &
'Microsoft.BarcodeReader.BarcodeType'.UPC &
'Microsoft.BarcodeReader.BarcodeType'.EAN
```

`txtSerialNumber.Default`:

```powerfx
Coalesce(varSerialNumber, Parent.Default)
```

`txtSerialNumber.OnChange`:

```powerfx
Set(varSerialNumber, Self.Text)
```

`SerialNumber_DataCard.Update`:

```powerfx
txtSerialNumber.Text
```

## Default Fields

`InspectionDate_DataCard.Default`:

```powerfx
If(frmInspection.Mode = FormMode.New, Now(), ThisItem.InspectionDate)
```

`InspectionDate_DataCard.Update`:

```powerfx
Now()
```

`Inspector_DataCard.Default`:

```powerfx
If(frmInspection.Mode = FormMode.New, User().FullName, ThisItem.Inspector)
```

`Inspector_DataCard.Update`:

```powerfx
Coalesce(txtInspector.Text, User().FullName)
```

`WhseDealWithStatus_DataCard.DefaultSelectedItems`:

```powerfx
If(
    frmInspection.Mode = FormMode.New,
    {Value: "Pending"},
    Parent.Default
)
```

## Add Photo Control

Use an Add picture control named:

```text
btnAddPhoto
```

`btnAddPhoto.OnChange`:

```powerfx
If(
    CountRows(colInspectionPhotos) >= 20,
    Notify("Maximum 20 photos.", NotificationType.Warning),
    Collect(
        colInspectionPhotos,
        {
            Name: Text(GUID()) & ".jpg",
            Value: btnAddPhoto.Media,
            PhotoIndex: CountRows(colInspectionPhotos) + 1
        }
    )
)
```

Use a gallery named `galPhotos`.

`galPhotos.Items`:

```powerfx
colInspectionPhotos
```

Trash icon inside `galPhotos.OnSelect`:

```powerfx
Remove(colInspectionPhotos, ThisItem)
```

## Save Button

`btnSave.DisplayMode`:

```powerfx
If(
    frmInspection.Valid &&
    CountRows(colInspectionPhotos) >= 1 &&
    CountRows(colInspectionPhotos) <= 20,
    DisplayMode.Edit,
    DisplayMode.Disabled
)
```

If photos are required to be 10-20, use this instead:

```powerfx
If(
    frmInspection.Valid &&
    CountRows(colInspectionPhotos) >= 10 &&
    CountRows(colInspectionPhotos) <= 20,
    DisplayMode.Edit,
    DisplayMode.Disabled
)
```

`btnSave.OnSelect`:

```powerfx
If(
    frmInspection.Valid,
    Set(varUploadingPhotos, true);
    SubmitForm(frmInspection),
    Notify("Please fix validation errors before saving.", NotificationType.Error)
)
```

## frmInspection.OnSuccess

```powerfx
Set(varSelectedInspection, frmInspection.LastSubmit);
Set(varInspectionListID, frmInspection.LastSubmit.ID);

If(
    CountRows(colInspectionPhotos) > 0,
    ForAll(
        colInspectionPhotos As p,
        Patch(
            FurnitureInspectionPhotos,
            Defaults(FurnitureInspectionPhotos),
            {
                Title: "Inspection-" & Text(varInspectionListID) & "-" & p.Name,
                InspectionListID: varInspectionListID,
                InspectionID: frmInspection.LastSubmit.InspectionID,
                PhotoIndex: p.PhotoIndex,
                PhotoName: p.Name,
                Photo:
                    Patch(
                        Defaults(FurnitureInspectionPhotos).Photo,
                        { Value: p.Value }
                    )
            }
        )
    )
);

Patch(
    FurnitureInspections,
    frmInspection.LastSubmit,
    {
        PhotoCount: CountRows(colInspectionPhotos),
        ReportDate: Today()
    }
);

Clear(colInspectionPhotos);
Reset(btnAddPhoto);
Set(varUploadingPhotos, false);
Notify("Saved", NotificationType.Success);
Navigate(scrHome, ScreenTransition.Fade)
```

## frmInspection.OnFailure

```powerfx
Set(varUploadingPhotos, false);
If(
    !IsBlank(frmInspection.Error),
    Notify(frmInspection.Error, NotificationType.Error),
    Notify("Save failed.", NotificationType.Error)
)
```

## Cancel Button

```powerfx
Set(varUploadingPhotos, false);
Clear(colInspectionPhotos);
ResetForm(frmInspection);
Back()
```



