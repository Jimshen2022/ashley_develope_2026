@echo off
REM Power BI Batch Conversion Tool - Quick Launch Script
REM This script provides a simple menu interface
chcp 65001 >nul

setlocal enabledelayedexpansion

REM Configuration - Update these paths as needed
set SOURCE_DIR=D:\GitHub\ashley_develope_2026\00-PowerBI\DC BI
set TARGET_DIR=D:\GitHub\power_bi_develop_2026\US_PBIP

:menu
cls
echo.
echo ===============================================
echo     Power BI PBIX to PBIP Batch Conversion Tool
echo ===============================================
echo.
echo Select Operation:
echo.
echo 1. Interactive Conversion (Recommended for beginners)
echo 2. Automated Conversion
echo 3. Check Source Directory Files
echo 4. Open Target Directory
echo 5. View Conversion Log
echo 6. Exit
echo.
set /p choice="Please select (1-6): "

if "%choice%"=="1" (
    echo.
    echo Starting interactive conversion tool...
    python power_bi_converter.py
    pause
    goto menu
)

if "%choice%"=="2" (
    echo.
    echo Starting automated conversion tool...
    python power_bi_auto_converter.py
    pause
    goto menu
)

if "%choice%"=="3" (
    echo.
    echo Showing source directory files...
    if exist "%SOURCE_DIR%" (
        dir "%SOURCE_DIR%" /s *.pbix
    ) else (
        echo Error: Source directory does not exist: %SOURCE_DIR%
        echo Please check the path or create the directory with .pbix files.
    )
    pause
    goto menu
)

if "%choice%"=="4" (
    echo.
    echo Opening target directory...
    if not exist "%TARGET_DIR%" mkdir "%TARGET_DIR%"
    start explorer "%TARGET_DIR%"
    goto menu
)

if "%choice%"=="5" (
    echo.
    echo Showing conversion log...
    if exist power_bi_conversion.log (
        type power_bi_conversion.log
    ) else (
        echo Log file not found. Please run the conversion tool first.
    )
    pause
    goto menu
)

if "%choice%"=="6" (
    echo Exiting program.
    exit /b
)

echo.
echo Invalid choice. Please try again.
timeout /t 2 /nobreak
goto menu
