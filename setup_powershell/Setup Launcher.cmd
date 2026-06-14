@echo off
setlocal EnableExtensions
chcp 65001 >nul
title Linear Algebra Quiz - Setup Launcher

set "SCRIPT_DIR=%~dp0"
set "POWERSHELL_SCRIPT=%SCRIPT_DIR%setup.ps1"
set "POWERSHELL_EXE=%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe"

if not exist "%POWERSHELL_EXE%" set "POWERSHELL_EXE=powershell.exe"

if not exist "%POWERSHELL_SCRIPT%" (
    echo.
    echo The companion PowerShell file was not found:
    echo %POWERSHELL_SCRIPT%
    echo.
    echo Extract the complete ZIP and keep these files together:
    echo   Setup Launcher.cmd
    echo   setup.ps1
    echo.
    pause
    exit /b 1
)

pushd "%SCRIPT_DIR%" >nul

"%POWERSHELL_EXE%" -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Unblock-File -LiteralPath $env:POWERSHELL_SCRIPT -ErrorAction SilentlyContinue" >nul 2>&1
"%POWERSHELL_EXE%" -NoLogo -NoProfile -STA -ExecutionPolicy Bypass -File "%POWERSHELL_SCRIPT%"
set "EXIT_CODE=%ERRORLEVEL%"

popd >nul

if not "%EXIT_CODE%"=="0" (
    echo.
    echo The setup launcher ended with an error.
    echo Review the red PowerShell message above.
    echo.
    pause
)

exit /b %EXIT_CODE%
