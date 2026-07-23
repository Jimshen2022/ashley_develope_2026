param(
    [string]$SiteUrl = "https://masterashley.sharepoint.com/sites/AsiaWarehouseOperations/power_app"
)

$ErrorActionPreference = "Stop"

function Invoke-M365 {
    param([Parameter(Mandatory)][string]$Command)

    Write-Host "m365 $Command"
    Invoke-Expression "m365 $Command"
}

function Add-Field {
    param(
        [Parameter(Mandatory)][string]$ListTitle,
        [Parameter(Mandatory)][string]$Xml
    )

    $escapedXml = $Xml.Replace("'", "''")
    Invoke-M365 "spo field add --webUrl '$SiteUrl' --listTitle '$ListTitle' --xml '$escapedXml' --options AddFieldInternalNameHint,AddFieldToDefaultView --output none"
}

Write-Host "Checking Microsoft 365 CLI login status..."
$status = m365 status --output text
if ($status -match "Logged out") {
    throw "Microsoft 365 CLI is logged out. Run m365 login with a tenant-approved appId before running this script."
}

Write-Host "Creating SharePoint lists..."
Invoke-M365 "spo list add --webUrl '$SiteUrl' --title 'FurnitureInspections' --baseTemplate GenericList --description 'Furniture product inspection records, one row per serial number inspection.' --enableVersioning true --enableAttachments false --output none"
Invoke-M365 "spo list add --webUrl '$SiteUrl' --title 'FurnitureInspectionPhotos' --baseTemplate GenericList --description 'Inspection photos linked to FurnitureInspections.' --enableVersioning true --enableAttachments false --output none"

Write-Host "Adding FurnitureInspections fields..."
Add-Field "FurnitureInspections" '<Field Type="Text" DisplayName="InspectionID" Name="InspectionID" StaticName="InspectionID" Required="FALSE" Indexed="TRUE" EnforceUniqueValues="TRUE" />'
Add-Field "FurnitureInspections" '<Field Type="DateTime" DisplayName="InspectionDate" Name="InspectionDate" StaticName="InspectionDate" Required="TRUE" Format="DateTime" FriendlyDisplayFormat="Disabled" Indexed="TRUE" />'
Add-Field "FurnitureInspections" '<Field Type="Text" DisplayName="ItemNumber" Name="ItemNumber" StaticName="ItemNumber" Required="TRUE" Indexed="TRUE" />'
Add-Field "FurnitureInspections" '<Field Type="Text" DisplayName="SerialNumber" Name="SerialNumber" StaticName="SerialNumber" Required="TRUE" Indexed="TRUE" />'
Add-Field "FurnitureInspections" '<Field Type="Choice" DisplayName="IssueFrom" Name="IssueFrom" StaticName="IssueFrom" Required="TRUE" Format="Dropdown"><CHOICES><CHOICE>Ashton</CHOICE><CHOICE>Vendor</CHOICE></CHOICES></Field>'
Add-Field "FurnitureInspections" '<Field Type="Note" DisplayName="DamagedDescription" Name="DamagedDescription" StaticName="DamagedDescription" Required="TRUE" NumLines="6" RichText="FALSE" />'
Add-Field "FurnitureInspections" '<Field Type="Note" DisplayName="Reason" Name="Reason" StaticName="Reason" Required="FALSE" NumLines="4" RichText="FALSE" />'
Add-Field "FurnitureInspections" '<Field Type="Text" DisplayName="DamagedBy" Name="DamagedBy" StaticName="DamagedBy" Required="FALSE" />'
Add-Field "FurnitureInspections" '<Field Type="Choice" DisplayName="WhseDealWithStatus" Name="WhseDealWithStatus" StaticName="WhseDealWithStatus" Required="TRUE" Format="Dropdown"><CHOICES><CHOICE>Pending</CHOICE><CHOICE>In Review</CHOICE><CHOICE>Repaired</CHOICE><CHOICE>Scrapped</CHOICE><CHOICE>Returned to Vendor</CHOICE><CHOICE>Closed</CHOICE></CHOICES><Default>Pending</Default></Field>'
Add-Field "FurnitureInspections" '<Field Type="Text" DisplayName="Inspector" Name="Inspector" StaticName="Inspector" Required="TRUE" />'
Add-Field "FurnitureInspections" '<Field Type="Note" DisplayName="Notes" Name="Notes" StaticName="Notes" Required="FALSE" NumLines="4" RichText="FALSE" />'
Add-Field "FurnitureInspections" '<Field Type="Number" DisplayName="PhotoCount" Name="PhotoCount" StaticName="PhotoCount" Required="FALSE" Decimals="0" />'
Add-Field "FurnitureInspections" '<Field Type="DateTime" DisplayName="ReportDate" Name="ReportDate" StaticName="ReportDate" Required="FALSE" Format="DateOnly" FriendlyDisplayFormat="Disabled" Indexed="TRUE" />'

Write-Host "Adding FurnitureInspectionPhotos fields..."
Add-Field "FurnitureInspectionPhotos" '<Field Type="Number" DisplayName="InspectionListID" Name="InspectionListID" StaticName="InspectionListID" Required="TRUE" Indexed="TRUE" Decimals="0" />'
Add-Field "FurnitureInspectionPhotos" '<Field Type="Text" DisplayName="InspectionID" Name="InspectionID" StaticName="InspectionID" Required="FALSE" Indexed="TRUE" />'
Add-Field "FurnitureInspectionPhotos" '<Field Type="Number" DisplayName="PhotoIndex" Name="PhotoIndex" StaticName="PhotoIndex" Required="FALSE" Decimals="0" />'
Add-Field "FurnitureInspectionPhotos" '<Field Type="Text" DisplayName="PhotoName" Name="PhotoName" StaticName="PhotoName" Required="FALSE" />'
Add-Field "FurnitureInspectionPhotos" '<Field Type="Thumbnail" DisplayName="Photo" Name="Photo" StaticName="Photo" Required="FALSE" />'
Add-Field "FurnitureInspectionPhotos" '<Field Type="URL" DisplayName="PhotoLink" Name="PhotoLink" StaticName="PhotoLink" Required="FALSE" Format="Hyperlink" />'

Write-Host "Done. If the Thumbnail/Image field fails in this tenant, create the Photo column manually as an Image column in SharePoint, then refresh the Power Apps data source."

