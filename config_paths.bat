@echo off
REM Power BI Conversion Tool - Path Configuration Script
REM This script helps you configure the source and target directories
chcp 65001 >nul

cls
echo.
echo =====================================================
echo   Power BI Conversion Tool - Path Configuration
echo =====================================================
echo.
echo This script will help you set up the correct paths for:
echo - Source directory (containing .pbix files)
echo - Target directory (for output .pbip files)
echo.

:get_source
echo.
echo Current source directory setting:
echo   D:\GitHub\ashley_develope_2026\00-PowerBI\DC BI
echo.
set /p new_source="Enter new source directory (or press Enter to skip): "

if not "%new_source%"=="" (
    if exist "%new_source%" (
        echo ✓ Source directory found!
        set SOURCE_DIR=%new_source%
    ) else (
        echo ✗ Directory not found: %new_source%
        goto get_source
    )
)

:get_target
echo.
echo Current target directory setting:
echo   D:\GitHub\power_bi_develop_2026\US_PBIP
echo.
set /p new_target="Enter new target directory (or press Enter to skip): "

if not "%new_target%"=="" (
    if exist "%new_target%" (
        echo ✓ Target directory found!
    ) else (
        echo Creating target directory: %new_target%
        mkdir "%new_target%"
        echo ✓ Created!
    )
    set TARGET_DIR=%new_target%
)

:confirmation
echo.
echo =====================================================
echo Configuration Summary:
echo =====================================================
echo.
echo Source: %SOURCE_DIR%
echo Target: %TARGET_DIR%
echo.
set /p confirm="Is this correct? (Y/N): "

if /i "%confirm%"=="Y" (
    echo.
    echo ✓ Configuration saved!
    echo.
    echo To use these paths, update the following in run_power_bi_converter.bat:
    echo   set SOURCE_DIR=%SOURCE_DIR%
    echo   set TARGET_DIR=%TARGET_DIR%
    echo.
    pause
    exit /b 0
) else if /i "%confirm%"=="N" (
    goto get_source
) else (
    echo Invalid choice. Try again.
    timeout /t 2 /nobreak
    goto confirmation
)
