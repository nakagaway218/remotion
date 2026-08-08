@echo off
setlocal

chcp 65001 >nul
title AI Workplace Advisor

set "SCRIPT_DIR=%~dp0"
set "HELPER=%SCRIPT_DIR%Workplace-Advisor.ps1"

if not exist "%HELPER%" (
  echo Helper file was not found:
  echo %HELPER%
  echo.
  pause
  exit /b 1
)

set "PWSH="
where pwsh.exe >nul 2>nul
if not errorlevel 1 set "PWSH=pwsh.exe"
if not defined PWSH if exist "%ProgramFiles%\PowerShell\7\pwsh.exe" set "PWSH=%ProgramFiles%\PowerShell\7\pwsh.exe"
if not defined PWSH if exist "%ProgramFiles(x86)%\PowerShell\7\pwsh.exe" set "PWSH=%ProgramFiles(x86)%\PowerShell\7\pwsh.exe"

if defined PWSH (
  "%PWSH%" -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%HELPER%"
) else (
  powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%HELPER%"
)
set "EXIT_CODE=%ERRORLEVEL%"

echo.
echo Finished.
pause
exit /b %EXIT_CODE%
