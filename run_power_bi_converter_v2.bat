@echo off
REM Power BI PBIX to PBIP Batch Conversion Tool - Main Menu
REM Enhanced version with path configuration
chcp 65001 >nul
setlocal enabledelayedexpansion

REM Load configuration if it exists
if exist "config.ini" (
    for /f "tokens=1,2 delims==" %%A in (config.ini) do (
        set "%%A=%%B"
    )
) else (
    REM Default paths
    set "SOURCE_DIR=D:\GitHub\power_bi_develop_2026\DC BI"
    set "TARGET_DIR=D:\GitHub\power_bi_develop_2026\US_PBIP"
)

:menu
cls
echo.
echo ======================================================
echo    Power BI PBIX to PBIP Batch Conversion Tool
echo ======================================================
echo.
echo Current Settings:
echo   Source: %SOURCE_DIR%
echo   Target: %TARGET_DIR%
echo.
echo ======================================================
echo.
echo Main Menu:
echo.
echo 1. Start Conversion
echo 2. Find Power BI Files
echo 3. Configure Paths
echo 4. Check Source Directory
echo 5. Open Target Directory
echo 6. View Conversion Log
echo 7. Help
echo 8. Exit
echo.
set /p choice="Please select (1-8): "

if "%choice%"=="1" goto start_conversion
if "%choice%"=="2" goto find_files
if "%choice%"=="3" goto configure
if "%choice%"=="4" goto check_source
if "%choice%"=="5" goto open_target
if "%choice%"=="6" goto view_log
if "%choice%"=="7" goto help
if "%choice%"=="8" goto exit_program

echo Invalid choice. Please try again.
timeout /t 2 /nobreak
goto menu

:start_conversion
echo.
echo ======================================================
echo Select Conversion Type:
echo ======================================================
echo.
echo 1. Interactive (Step-by-step, recommended for beginners)
echo 2. Automated (Automatic processing)
echo 3. Back to Main Menu
echo.
set /p conv_choice="Please select (1-3): "

if "%conv_choice%"=="1" (
    echo.
    echo Starting interactive conversion...
    if exist "%SOURCE_DIR%" (
        python power_bi_converter.py
    ) else (
        echo Error: Source directory not found!
        echo Please configure the correct path in option 3.
    )
) else if "%conv_choice%"=="2" (
    echo.
    echo Starting automated conversion...
    if exist "%SOURCE_DIR%" (
        python power_bi_auto_converter.py
    ) else (
        echo Error: Source directory not found!
        echo Please configure the correct path in option 3.
    )
) else if "%conv_choice%"=="3" (
    goto menu
)

pause
goto menu

:find_files
echo.
echo Launching file finder...
call find_pbix_files.bat
goto menu

:configure
echo.
echo Launching path configuration...
call config_paths.bat
goto menu

:check_source
echo.
echo ======================================================
echo Source Directory Contents
echo ======================================================
echo.
if exist "%SOURCE_DIR%" (
    echo Source: %SOURCE_DIR%
    echo.
    dir "%SOURCE_DIR%" /s *.pbix 2>nul
    if errorlevel 1 (
        echo No .pbix files found in this directory.
    )
) else (
    echo Error: Source directory does not exist!
    echo Current path: %SOURCE_DIR%
    echo.
    echo Please:
    echo 1. Verify the path is correct
    echo 2. Use option 2 to find Power BI files
    echo 3. Use option 3 to configure the correct path
)
echo.
pause
goto menu

:open_target
echo.
echo Creating target directory if it doesn't exist...
if not exist "%TARGET_DIR%" (
    mkdir "%TARGET_DIR%"
    echo Created: %TARGET_DIR%
)
echo Opening target directory...
start explorer "%TARGET_DIR%"
echo.
pause
goto menu

:view_log
echo.
echo ======================================================
echo Conversion Log
echo ======================================================
echo.
if exist "power_bi_conversion.log" (
    type power_bi_conversion.log
) else (
    echo Log file not found.
    echo Please run the conversion tool first to generate a log.
)
echo.
pause
goto menu

:help
cls
echo.
echo ======================================================
echo Help - Power BI Conversion Tool
echo ======================================================
echo.
echo QUICK START:
echo 1. Use option 2 to find your .pbix files
echo 2. Use option 3 to configure the correct paths
echo 3. Use option 1 to start the conversion
echo.
echo PATH CONFIGURATION:
echo - Source Directory: Contains your .pbix files
echo - Target Directory: Where .pbip files will be saved
echo.
echo CONVERSION PROCESS:
echo - Interactive: Step-by-step, recommended for beginners
echo - Automated: Processes all files automatically
echo.
echo IMPORTANT NOTES:
echo - Original .pbix files will NOT be deleted
echo - .pbip files will be in separate folders
echo - Check the log file for conversion details
echo.
echo TROUBLESHOOTING:
echo - If paths are wrong, use option 3 to configure
echo - Use option 2 to find your Power BI files
echo - Check option 4 to verify source directory
echo.
pause
goto menu

:exit_program
echo.
echo Exiting Power BI Conversion Tool...
echo Thank you for using this tool!
echo.
exit /b 0
