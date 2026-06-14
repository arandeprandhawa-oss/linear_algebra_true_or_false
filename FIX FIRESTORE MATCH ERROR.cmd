@echo off
setlocal EnableExtensions
chcp 65001 >nul
title Linear Algebra Quiz - Fix Firestore Match Error

set "PROJECT_DIR=%~dp0"
set "PS1=%PROJECT_DIR%setup_powershell\deploy-firestore-rules.ps1"
set "POWERSHELL_EXE=%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe"
if not exist "%POWERSHELL_EXE%" set "POWERSHELL_EXE=powershell.exe"

if not exist "%PS1%" (
  echo.
  echo Missing file:
  echo %PS1%
  echo.
  echo Extract the complete ZIP first.
  pause
  exit /b 1
)

echo.
echo This repair is locked to this exact project folder:
echo %PROJECT_DIR%
echo.
echo It will rebuild the Firestore rules from this project's units,
echo categories, match lengths, and 2-to-6-player fields, then deploy them
echo to the Firebase project configured by this website.
echo.
pause

"%POWERSHELL_EXE%" -NoLogo -NoProfile -STA -ExecutionPolicy Bypass -File "%PS1%" -ProjectFolder "%PROJECT_DIR%"
set "EXIT_CODE=%ERRORLEVEL%"

if not "%EXIT_CODE%"=="0" (
  echo.
  echo The Firestore repair stopped with an error.
  echo Read the red message above.
  echo.
  pause
)

exit /b %EXIT_CODE%
