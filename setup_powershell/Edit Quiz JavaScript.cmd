@echo off
setlocal
title Linear Algebra Quiz - JavaScript Editor

set "SCRIPT_DIR=%~dp0"
set "POWERSHELL_SCRIPT=%SCRIPT_DIR%edit-quiz-javascript.ps1"

if not exist "%POWERSHELL_SCRIPT%" (
    echo.
    echo The companion PowerShell file was not found:
    echo %POWERSHELL_SCRIPT%
    echo.
    echo Keep these two files together:
    echo   Edit Quiz JavaScript.cmd
    echo   edit-quiz-javascript.ps1
    echo.
    pause
    exit /b 1
)

powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%POWERSHELL_SCRIPT%"
set "EXIT_CODE=%ERRORLEVEL%"

if not "%EXIT_CODE%"=="0" (
    echo.
    echo The JavaScript editor ended with an error.
    pause
)

exit /b %EXIT_CODE%
