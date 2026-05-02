@echo off
REM Find Power BI Files - Scan system for .pbix files
chcp 65001 >nul

cls
echo.
echo =====================================================
echo   Find Power BI Files (.pbix)
echo =====================================================
echo.
echo Scanning for .pbix files in your system...
echo This may take a few moments...
echo.

REM Search in common locations
set FOUND=0

echo Searching in D:\GitHub...
for /r "D:\GitHub" %%F in (*.pbix) do (
    echo Found: %%F
    set FOUND=1
)

if %FOUND%==0 (
    echo.
    echo No .pbix files found in D:\GitHub
    echo.
    echo Trying other common locations...
    echo.
    
    if exist "C:\Users" (
        echo Searching in C:\Users (Documents, Downloads, Desktop)...
        for /r "C:\Users" %%F in (*.pbix) do (
            echo Found: %%F
            set FOUND=1
        )
    )
)

if %FOUND%==0 (
    echo.
    echo ✗ No .pbix files found on this computer.
    echo.
    echo Please check:
    echo 1. Do you have any Power BI files?
    echo 2. Are they in the expected location?
    echo 3. You can manually enter the path when prompted.
) else (
    echo.
    echo ✓ Search complete! See the results above.
    echo.
    echo Now you can:
    echo 1. Copy the file path
    echo 2. Use it in the configuration script
    echo 3. Run the conversion tool with the correct path
)

echo.
pause
