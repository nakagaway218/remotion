@echo off
setlocal

set "SCRIPT_DIR=%~dp0"
set "PWSH=C:\Program Files (x86)\PowerShell\7\pwsh.exe"

if not exist "%PWSH%" (
  set "PWSH=pwsh"
)

"%PWSH%" -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT_DIR%new-youtube-transcript-doc-from-clipboard.ps1" %*

if errorlevel 1 (
  echo.
  echo Failed. Check the message above.
  pause
  exit /b %errorlevel%
)

echo.
echo Done.
pause
