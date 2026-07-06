# ==============================================================================
# CONFIGURATION PARAMETERS
# ==============================================================================
# Target folder path where the files are located
$folderPath = "D:\OneDriver\Ashley Furniture Industries, Inc\Asia Warehouse Operations - ashton_RP_fulfillment"
# Original template file name
$templateName = "Ashton RP Open Orders Fulfillment_v12.xlsb"
$templateFullPath = Join-Path $folderPath $templateName

# Name of the macro to be executed (Modify this to match your actual macro name, e.g., "Module1.MyMacro")
$macroName = "AshtonRPOpenOrdersFulfillment" 

# ==============================================================================
# STEP 1: GENERATE NEW FILE NAME WITH TIMESTAMP AND SAVE AS
# ==============================================================================
$timeStamp = Get-Date -Format "yyyyMMdd_HHmmss"
$newFileName = "Ashton RP Open Orders Fulfillment_v12_$timeStamp.xlsb"
$newFileFullPath = Join-Path $folderPath $newFileName

Write-Host "Copying file and generating timestamped version..."
Copy-Item -Path $templateFullPath -Destination $newFileFullPath

# ==============================================================================
# STEP 2: LAUNCH EXCEL AND EXECUTE THE SPECIFIED MACRO
# ==============================================================================
Write-Host "Launching Excel and executing macro: $macroName ..."
try {
    $excel = New-Object -ComObject Excel.Application
    $excel.Visible = $false          # Run in the background without showing the Excel window
    $excel.DisplayAlerts = $false     # Disable Excel popup alerts/warnings

    # Open the newly created timestamped file
    $workbook = $excel.Workbooks.Open($newFileFullPath)

    # Execute the macro
    $excel.Run($macroName)

    # Save and close the workbook
    $workbook.Save()
    $workbook.Close($true)
    Write-Host "Macro execution completed. File saved successfully."
}
catch {
    Write-Error "An error occurred during Excel macro execution: $_"
}
finally {
    # Ensure the Excel process is terminated to free up system resources
    if ($excel) {
        $excel.Quit()
        [System.Runtime.Interopservices.Marshal]::ReleaseComObject($excel) | Out-Null
        Remove-Variable excel
    }
    [GC]::Collect()
    [GC]::WaitForPendingFinalizers()
}

Write-Host "All automation tasks completed successfully!"