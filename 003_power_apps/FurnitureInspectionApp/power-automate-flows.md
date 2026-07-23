# Power Automate Flows

## Flow 1: Generate InspectionID

Name:

```text
FI - Generate InspectionID
```

Trigger:

```text
SharePoint - When an item is created
Site: https://masterashley.sharepoint.com/sites/AsiaWarehouseOperations/power_app
List: FurnitureInspections
```

Compose action:

```text
Compose_InspectionID
```

Expression:

```text
concat(
  'INS-',
  formatDateTime(triggerOutputs()?['body/Created'], 'yyyyMMdd'),
  '-',
  substring(
    concat('0000', string(triggerOutputs()?['body/ID'])),
    sub(length(concat('0000', string(triggerOutputs()?['body/ID']))), 4),
    4
  )
)
```

Update the item using `Send an HTTP request to SharePoint`.

Method:

```text
POST
```

URI:

```text
_api/web/lists/GetByTitle('FurnitureInspections')/items(@{triggerOutputs()?['body/ID']})/ValidateUpdateListItem
```

Headers:

```json
{
  "Accept": "application/json;odata=nometadata",
  "Content-Type": "application/json;odata=nometadata"
}
```

Body:

```json
{
  "formValues": [
    {
      "FieldName": "Title",
      "FieldValue": "@{outputs('Compose_InspectionID')}"
    },
    {
      "FieldName": "InspectionID",
      "FieldValue": "@{outputs('Compose_InspectionID')}"
    },
    {
      "FieldName": "ReportDate",
      "FieldValue": "@{formatDateTime(triggerOutputs()?['body/Created'], 'yyyy-MM-dd')}"
    }
  ],
  "bNewDocumentUpdate": false
}
```

## Flow 2: Daily Report at 6:50 AM

Name:

```text
FI - Daily Inspection Excel Report - 0650
```

Trigger:

```text
Recurrence
Frequency: Day
Interval: 1
Time zone: SE Asia Standard Time
At these hours: 6
At these minutes: 50
```

If the team wants US time, change the time zone before enabling.

## Flow 3: Daily Report at 7:50 PM

Name:

```text
FI - Daily Inspection Excel Report - 1950
```

Trigger:

```text
Recurrence
Frequency: Day
Interval: 1
Time zone: SE Asia Standard Time
At these hours: 19
At these minutes: 50
```

## Shared Report Steps

Initialize variables:

```text
varStartOfDay = startOfDay(convertTimeZone(utcNow(), 'UTC', 'SE Asia Standard Time'))
varEndOfDay = addDays(variables('varStartOfDay'), 1)
```

Get items from `FurnitureInspections`.

Filter Query:

```text
InspectionDate ge '@{formatDateTime(variables('varStartOfDay'), 'yyyy-MM-ddTHH:mm:ssZ')}' and InspectionDate lt '@{formatDateTime(variables('varEndOfDay'), 'yyyy-MM-ddTHH:mm:ssZ')}'
```

Excel columns:

```text
InspectionID
InspectionDate
ItemNumber
SerialNumber
IssueFrom
DamagedDescription
Reason
DamagedBy
WhseDealWithStatus
Inspector
Notes
PhotoCount
InspectionListID
```

Recommended photo handling:

1. Do not embed 10-20 high-resolution photos per inspection into Excel.
2. Put SharePoint links to the photo rows or a filtered list view.
3. Keep the email attachment small and reliable.

Email:

```text
To: Ashton CS Team; Inventory Team
Subject: Daily Furniture Inspection Report - @{formatDateTime(utcNow(), 'yyyy-MM-dd HH:mm')}
Attachment: FurnitureInspectionReport_yyyyMMdd_HHmm.xlsx
```

If distribution lists have email addresses, use those addresses directly instead of display names.

