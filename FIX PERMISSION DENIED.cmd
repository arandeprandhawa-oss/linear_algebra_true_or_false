@echo off
setlocal EnableExtensions
chcp 65001 >nul
title Linear Algebra Quiz - Fix Firebase Permission Denied

rem IMPORTANT: Do not pass a folder path ending in a backslash to PowerShell.
rem The PowerShell script safely finds the exact project by starting from its
rem own setup_powershell folder and walking up to index.html.
set "PS1=%~dp0setup_powershell\deploy-firestore-rules.ps1"
set "POWERSHELL_EXE=%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe"
if not exist "%POWERSHELL_EXE%" set "POWERSHELL_EXE=powershell.exe"

if not exist "%PS1%" (
  echo.
  echo Missing file:
  echo %PS1%
  echo.
  echo Extract the complete ZIP before running this repair.
  pause
  exit /b 1
)

echo.
echo This will deploy the compatible multiplayer rules to the Firebase
echo project configured inside this exact website folder.
echo.
echo Project folder:
echo %~dp0
echo.
pause

"%POWERSHELL_EXE%" -NoLogo -NoProfile -STA -ExecutionPolicy Bypass -File "%PS1%"
set "EXIT_CODE=%ERRORLEVEL%"

if not "%EXIT_CODE%"=="0" (
  echo.
  echo The repair stopped with an error. Read the message above.
  echo.
  pause
)

exit /b %EXIT_CODE%
