@echo off
setlocal EnableExtensions
chcp 65001 >nul
title Linear Algebra Quiz - Repair Website

set "PROJECT_DIR=%~dp0"
set "UPDATER=%PROJECT_DIR%setup_powershell\Update Entire Project to GitHub.cmd"
set "RULES_UPDATER=%PROJECT_DIR%FIX FIRESTORE MATCH ERROR.cmd"

if not exist "%UPDATER%" (
    echo.
    echo The full-project updater was not found:
    echo %UPDATER%
    echo.
    echo Extract the complete ZIP before running this file.
    echo.
    pause
    exit /b 1
)

echo.
echo This will upload the repaired project files to GitHub.
echo It restores the website HTML, the fixed flashcards, the updated editor,
echo and the Firestore category list.
echo.
pause

call "%UPDATER%"
set "UPDATE_EXIT=%ERRORLEVEL%"

if not "%UPDATE_EXIT%"=="0" (
    echo.
    echo The website update did not finish successfully.
    echo Fix the error shown above before running the Firestore updater.
    echo.
    pause
    exit /b %UPDATE_EXIT%
)

if not exist "%RULES_UPDATER%" (
    echo.
    echo Website files were uploaded, but the Firestore updater was not found.
    echo Run it later from setup_powershell if you restore that file.
    echo.
    pause
    exit /b 0
)

echo.
choice /C YN /N /M "Run the Firestore Rules updater now? [Y/N]: "
if errorlevel 2 exit /b 0

call "%RULES_UPDATER%"
exit /b %ERRORLEVEL%
