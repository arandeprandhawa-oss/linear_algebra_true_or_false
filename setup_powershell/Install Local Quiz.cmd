@echo off
setlocal
title Linear Algebra Quiz - Local Installer

set "SCRIPT_DIR=%~dp0"
set "POWERSHELL_SCRIPT=%SCRIPT_DIR%setup-new-repo-no-firebase.ps1"

if not exist "%POWERSHELL_SCRIPT%" (
    echo.
    echo The companion PowerShell file was not found:
    echo %POWERSHELL_SCRIPT%
    echo.
    echo Keep these two files together in the same folder:
    echo   Install Local Quiz.cmd
    echo   setup-new-repo-no-firebase.ps1
    echo.
    pause
    exit /b 1
)

powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%POWERSHELL_SCRIPT%"
set "EXIT_CODE=%ERRORLEVEL%"

if not "%EXIT_CODE%"=="0" (
    echo.
    echo The PowerShell tool ended with an error.
    pause
)

exit /b %EXIT_CODE%
